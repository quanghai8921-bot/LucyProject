import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucy_app/theme/app_colors.dart';
import 'package:lucy_app/services/agora_audio_service.dart';
import 'package:lucy_app/services/file_download/file_download.dart';
import 'package:lucy_app/services/lms_api.dart';
import 'package:lucy_app/services/realtime_socket_service.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/services/payment_api.dart';

class LiveLearnerRoomDialog extends StatefulWidget {
  final String roomId;
  final String title;
  final String mentor;
  final String hostUserId;
  final String? levelId;
  final String? languageId;

  const LiveLearnerRoomDialog({
    super.key,
    required this.roomId,
    required this.title,
    required this.mentor,
    required this.hostUserId,
    this.levelId,
    this.languageId,
  });

  @override
  State<LiveLearnerRoomDialog> createState() => _LiveLearnerRoomDialogState();
}

class _LiveLearnerRoomDialogState extends State<LiveLearnerRoomDialog> with TickerProviderStateMixin {
  final RealtimeSocketService _realtimeSocket = RealtimeSocketService();
  final AgoraAudioService _agoraAudio = AgoraAudioService();
  final LmsApi _lmsApi = LmsApi();
  final PaymentApi _paymentApi = PaymentApi();
  
  bool _isDialogClosed = false;
  bool _isAgoraConnected = false;
  bool _isConnecting = false;
  bool _isMentorMuted = false;
  bool _isMyMuted = true;
  bool _isHandRaised = false;
  bool _isConnectingAgora = true;
  String? _agoraError;
  int _onlineCheckCount = 0;
  int _secondsElapsed = 0;
  Timer? _stopwatchTimer;
  Timer? _attendanceTimer;
  RoomStudyPlan? _studyPlan;
  
  final List<Map<String, dynamic>> _pinnedMaterials = [];
  
  final List<Map<String, String>> _chatMessages = [];
  final ScrollController _chatScrollController = ScrollController();
  final TextEditingController _chatInputController = TextEditingController();
  late AnimationController _waveformController;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startStopwatch();
    
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _setupRealtime();
    _joinAgoraAudio();
    _loadStudyPlan();
    _startAttendanceTimer();
  }

  void _setupRealtime() {
    _realtimeSocket.onRoomEnded((payload) {
      if (payload['roomId'] == widget.roomId && !_isDialogClosed && mounted) {
        _isDialogClosed = true;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phòng học đã kết thúc bởi Mentor! 🛑'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    _realtimeSocket.onMicChanged((payload) {
      final userId = '${payload['userId'] ?? ''}';
      final micEnabled = payload['micEnabled'] == true || '${payload['micStatus']}' == 'ON';
      if (userId == widget.hostUserId) {
        if (mounted) setState(() => _isMentorMuted = !micEnabled);
      } else if (userId == AppSession.current?.userId) {
        if (mounted) setState(() => _isMyMuted = !micEnabled);
      }
    });

    _realtimeSocket.onChatMessage((payload) {
      if (mounted) {
        setState(() {
          _chatMessages.add({
            'name': payload['displayName'] ?? 'Học viên',
            'avatar': '🗣️',
            'text': payload['text'] ?? '',
            'time': _formatCurrentTime(),
            'isSystem': 'false'
          });
        });
        _scrollToBottom();
      }
    });

    _realtimeSocket.onHandRaised((payload) {
      final raised = payload['raised'] == true;
      final userId = '${payload['userId'] ?? ''}';
      if (mounted) {
        setState(() {
          if (userId == AppSession.current?.userId) {
            _isHandRaised = raised;
          }
          _chatMessages.add({
            'name': 'Hệ thống LUCY',
            'avatar': '!',
            'text': '${payload['displayName'] ?? 'Học viên'} đã ${raised ? 'giơ tay phát biểu' : 'bỏ giơ tay'}',
            'time': _formatCurrentTime(),
            'isSystem': 'true'
          });
        });
        _scrollToBottom();
      }
    });

    _realtimeSocket.onSlidePinned((payload) {
      if (mounted) {
        setState(() {
          final title = payload['filename'] ?? payload['fileName'] ?? 'Tài liệu mới';
          final fileBase64 = '${payload['fileBase64'] ?? ''}';
          final fileType = '${payload['fileType'] ?? ''}';
          
          _pinnedMaterials.add({
             'title': title,
             'base64': fileBase64.isEmpty ? null : fileBase64,
             'mimeType': fileType.isEmpty ? null : fileType,
          });

          _chatMessages.add({
            'name': 'Hệ thống LUCY',
            'avatar': '🤖',
            'text': 'Mentor vừa ghim tài liệu mới: $title',
            'time': _formatCurrentTime(),
            'isSystem': 'true'
          });
        });
        _scrollToBottom();
      }
    });

    _realtimeSocket.socket.on('PAYMENT_NOTIFICATION', (data) {
      if (mounted) {
        final payload = data is String ? jsonDecode(data) : data;
        if (payload != null && payload['refType'] == 'DONATION') {
          setState(() {
             _chatMessages.add({
               'name': 'Hệ thống LUCY',
               'avatar': '💎',
               'text': '🎉 Mentor vừa nhận được quà tặng kim cương từ học viên!',
               'time': _formatCurrentTime(),
               'isSystem': 'true'
             });
          });
          _scrollToBottom();
        }
      }
    });

    _realtimeSocket.socket.on('ONLINE_CHECK_REQUEST', (_) {
      if (mounted) {
        _showOnlineCheckPopup();
      }
    });

    _realtimeSocket.socket.on('room:ended', (data) {
      if (mounted) {
        _handleEndSession();
      }
    });
  }

  void _showOnlineCheckPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        int secondsLeft = 10;
        Timer? countdownTimer;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (secondsLeft > 0) {
                setDialogState(() => secondsLeft--);
              } else {
                timer.cancel();
                Navigator.pop(ctx);
              }
            });
            return AlertDialog(
              title: const Text("Bạn còn ở đó không?"),
              content: Text("Vui lòng xác nhận sự có mặt của bạn. Popup sẽ tự đóng sau $secondsLeft giây."),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    countdownTimer?.cancel();
                    setState(() {
                      _onlineCheckCount++;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xác nhận trực tuyến.")));
                  },
                  child: const Text("Xác nhận có mặt"),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _handleEndSession() {
    if (_onlineCheckCount >= 3) {
      // Đủ điều kiện nhận bài kiểm tra
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Bài Kiểm Tra Mở Khóa"),
          content: const Text("Bạn đã có mặt đủ thời gian. Xin chúc mừng, bạn đã nhận được bài kiểm tra từ Mentor! (Mô phỏng bài test 80% điểm)"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _simulateQuizResult();
              },
              child: const Text("Làm Bài Ngay"),
            )
          ],
        ),
      );
    } else {
      // Không đủ điều kiện
      _showKickCountdown("Bạn không đủ điều kiện (có mặt < 3 lần) để nhận bài kiểm tra.");
    }
  }

  void _simulateQuizResult() {
    // Mô phỏng kết quả bài kiểm tra (ngẫu nhiên đậu/rớt cho demo)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Kết quả kiểm tra"),
        content: const Text("Bạn làm bài được 70% (Dưới 80%). Bạn KHÔNG đủ điều kiện pass."),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showKickCountdown("Bạn không vượt qua bài kiểm tra. Buộc rời phòng.");
            },
            child: const Text("Đóng"),
          )
        ],
      ),
    );
  }

  void _showKickCountdown(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        int secondsLeft = 5;
        Timer? countdownTimer;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (secondsLeft > 0) {
                setDialogState(() => secondsLeft--);
              } else {
                timer.cancel();
                Navigator.pop(ctx);
                if (mounted) Navigator.pop(context); // Thoát phòng học
              }
            });
            return AlertDialog(
              title: const Text("Thông Báo", style: TextStyle(color: Colors.red)),
              content: Text("$reason\n\nBạn sẽ rời phòng sau $secondsLeft giây..."),
            );
          },
        );
      },
    );
  }

  Future<void> _joinAgoraAudio() async {
    if (_isAgoraConnected || _isConnecting) return;
    _isConnecting = true;
    final session = AppSession.current;
    if (session == null) {
      if (mounted) setState(() => _agoraError = 'Phiên đăng nhập không hợp lệ.');
      return;
    }
    try {
      await _agoraAudio.join(
        roomId: widget.roomId,
        userId: session.userId,
        publishMicrophone: !_isMyMuted,
      );
      if (mounted) {
        setState(() {
          _isAgoraConnected = true;
          _agoraError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _agoraError = '$e';
        });
      }
    } finally {
      _isConnecting = false;
    }
  }

  @override
  void dispose() {
    _isDialogClosed = true;
    _stopwatchTimer?.cancel();
    _attendanceTimer?.cancel();
    _chatScrollController.dispose();
    _chatInputController.dispose();
    _waveformController.dispose();
    _agoraAudio.leave();
    _realtimeSocket.offRoomEnded();
    _realtimeSocket.offMicChanged();
    _realtimeSocket.offChatMessage();
    _realtimeSocket.offHandRaised();
    _realtimeSocket.offSlidePinned();
    super.dispose();
  }

  void _startStopwatch() {
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  Future<void> _loadStudyPlan() async {
    try {
      final plan = await _lmsApi.getRoomStudyPlan(widget.roomId);
      if (!mounted) return;
      setState(() {
        _studyPlan = plan;
      });
    } catch (_) {}
  }

  void _startAttendanceTimer() {
    _attendanceTimer?.cancel();
    _attendanceTimer = Timer.periodic(const Duration(minutes: 10), (_) => _askAttendance());
  }

  Future<void> _askAttendance() async {
    final session = AppSession.current;
    final levelId = widget.levelId;
    final subLevelId = _studyPlan?.subLevels.isNotEmpty == true ? _studyPlan!.subLevels.first.subLevelId : null;
    if (session == null || levelId == null || subLevelId == null || !mounted) return;
    try {
      final check = await _lmsApi.askAttendance(
        roomId: widget.roomId,
        userId: session.userId,
        levelId: levelId,
        subLevelId: subLevelId,
      );
      if (!mounted) return;
      var confirmed = false;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          Future.delayed(const Duration(seconds: 10), () {
            if (!confirmed && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Bạn có đang online không?', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Bấm xác nhận trong 10 giây để được tính đang học.'),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  confirmed = true;
                  await _lmsApi.confirmAttendance(check.checkId);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Xác nhận'),
              ),
            ],
          );
        },
      );
    } catch (_) {}
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatStopwatch(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _downloadPinnedFile(Map<String, dynamic> material) async {
    final base64String = material['base64'];
    if (base64String == null) return;
    try {
      final bytes = base64Decode(base64String);
      final savedTo = await downloadBytes(
        fileName: material['title'] ?? 'Tai_lieu',
        bytes: bytes,
        mimeType: material['mimeType'],
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tải tài liệu: $savedTo'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      children: [
                        _buildMentorAudioVisualizer(),
                        const SizedBox(height: 16),
                        _buildMaterialsList(),
                        const SizedBox(height: 16),
                        _buildCourseOutcomeCard(),
                        const SizedBox(height: 16),
                        _buildControlPanel(),
                        const SizedBox(height: 16),
                        _buildLiveChatContainer(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: const Border(bottom: BorderSide(color: AppColors.inputBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text("ĐANG TRONG PHÒNG", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatStopwatch(_secondsElapsed),
              style: const TextStyle(color: AppColors.primaryDark, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text("Rời Phòng?", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  content: const Text("Bạn có muốn rời khỏi phòng học này không?", style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("HỦY", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final dialogNavigator = Navigator.of(ctx);
                        final roomNavigator = Navigator.of(context);
                        final session = AppSession.current;
                        if (session != null) {
                          try {
                            await _agoraAudio.leave();
                            _realtimeSocket.leaveRoom(roomId: widget.roomId, userId: session.userId);
                            await _lmsApi.leaveRoom(roomId: widget.roomId, userId: session.userId);
                          } catch (_) {}
                        }
                        if (mounted) {
                          dialogNavigator.pop();
                          roomNavigator.pop();
                        }
                      },
                      child: const Text("RỜI KHỎI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 250),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.library_books, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text(
                "TÀI LIỆU MENTOR ĐÃ GHIM",
                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_pinnedMaterials.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "Chưa có tài liệu nào được ghim.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _pinnedMaterials.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final mat = _pinnedMaterials[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      mat['title'] ?? 'Tài liệu',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      "Được ghim bởi: ${widget.mentor}",
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    trailing: mat['base64'] != null
                        ? GestureDetector(
                            onTap: () => _downloadPinnedFile(mat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download, size: 14, color: Colors.orange.shade700),
                                  const SizedBox(width: 4),
                                  Text("Tải", style: TextStyle(color: Colors.orange.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMentorAudioVisualizer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_agoraError != null) ...[
          Text(
            _agoraError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AnimatedBuilder(
              animation: _waveformController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AudioWaveformPainter(
                    animationValue: _waveformController.value,
                    color: _isMentorMuted ? Colors.red.shade400.withOpacity(0.5) : AppColors.primary,
                    isMuted: _isMentorMuted,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseOutcomeCard() {
    final plan = _studyPlan;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan?.levelTitle ?? widget.title,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          if (plan?.levelDescription != null && plan!.levelDescription!.isNotEmpty) ...[
            Text(
              plan.levelDescription!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMicButton(),
        const SizedBox(width: 24),
        _buildHandButton(),
        const SizedBox(width: 24),
        _buildDonateButton(),
      ],
    );
  }

  Widget _buildDonateButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showDonateBottomSheet(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.pink.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(Icons.diamond_outlined, color: Colors.pink.shade400, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Tặng Quà",
          style: TextStyle(
            color: Colors.pink,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  void _showDonateBottomSheet() async {
    List<PaymentGift> gifts = [];
    bool isLoading = true;
    String? error;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            if (isLoading && gifts.isEmpty && error == null) {
              _paymentApi.getGifts().then((value) {
                setModalState(() {
                  gifts = value;
                  isLoading = false;
                });
              }).catchError((e) {
                setModalState(() {
                  error = e.toString();
                  isLoading = false;
                });
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16, right: 16, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tặng Kim Cương", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text("Ủng hộ Mentor bằng kim cương. 1 Kim Cương = 10 Xu.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
                  else if (error != null)
                    SizedBox(height: 150, child: Center(child: Text(error!, style: const TextStyle(color: Colors.red))))
                  else if (gifts.isEmpty)
                    const SizedBox(height: 150, child: Center(child: Text("Hệ thống chưa có quà tặng nào.")))
                  else
                    SizedBox(
                      height: 250,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: gifts.length,
                        itemBuilder: (context, index) {
                          final gift = gifts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              _confirmDonate(gift);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.pink.shade100),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.diamond, color: Colors.pinkAccent, size: 36),
                                  const SizedBox(height: 8),
                                  Text(gift.giftName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary), textAlign: TextAlign.center),
                                  const SizedBox(height: 4),
                                  Text("${gift.priceAmount.toInt()} KC", style: const TextStyle(color: Colors.pink, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDonate(PaymentGift gift) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Xác nhận tặng quà"),
        content: Text("Bạn có chắc muốn tặng '${gift.giftName}' với giá ${gift.priceAmount.toInt()} Kim Cương (tương đương ${gift.priceAmount.toInt() * 10} Xu) cho Mentor ${widget.mentor} không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                // 1 Diamond = 10 Xu, so amount to deduct is gift.priceAmount * 10
                final xuAmount = gift.priceAmount * 10;
                await _paymentApi.donate(
                  toUserId: widget.hostUserId,
                  amount: xuAmount,
                  roomId: widget.roomId,
                  messageText: "Tặng ${gift.giftName}",
                  giftImageUrl: gift.giftImageUrl ?? "https://cdn3.iconfinder.com/data/icons/object-emoji/50/Diamond-512.png",
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tặng quà thành công!")));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                }
              }
            },
            child: const Text("Tặng Ngay", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final nextMuted = !_isMyMuted;
            final session = AppSession.current;
            if (session != null) {
              setState(() => _isMyMuted = nextMuted);
              try {
                await _realtimeSocket.toggleMic(
                  roomId: widget.roomId,
                  userId: session.userId,
                  enabled: !nextMuted,
                  displayName: session.fullName,
                );
                await _lmsApi.updateMic(
                  roomId: widget.roomId,
                  userId: session.userId,
                  enabled: !nextMuted,
                );
                await _agoraAudio.setMicrophoneEnabled(!nextMuted);
              } catch (e) {
                if (mounted) setState(() => _isMyMuted = !nextMuted);
              }
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isMyMuted ? Colors.red.shade400 : AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: (_isMyMuted ? Colors.red : AppColors.primary).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(_isMyMuted ? Icons.mic_off : Icons.mic, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isMyMuted ? "Đã Tắt Mic" : "Mic Đang Bật",
          style: TextStyle(
            color: _isMyMuted ? Colors.red.shade600 : AppColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  Widget _buildHandButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final nextRaised = !_isHandRaised;
            setState(() => _isHandRaised = nextRaised);
            final session = AppSession.current;
            if (session != null) {
              _realtimeSocket.raiseHand(
                roomId: widget.roomId,
                userId: session.userId,
                raised: nextRaised,
              );
              try {
                await _lmsApi.updateHandRaise(
                  roomId: widget.roomId,
                  userId: session.userId,
                  raised: nextRaised,
                );
              } catch (_) {
                if (mounted) setState(() => _isHandRaised = !nextRaised);
              }
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isHandRaised ? Colors.orange.shade400 : Colors.white,
              border: Border.all(color: _isHandRaised ? Colors.orange.shade400 : AppColors.inputBorder, width: 2),
              boxShadow: _isHandRaised ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Icon(Icons.back_hand, color: _isHandRaised ? Colors.white : AppColors.textSecondary, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Dơ tay",
          style: TextStyle(
            color: _isHandRaised ? Colors.orange.shade600 : AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  Widget _buildLiveChatContainer() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(14.0),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary, size: 16),
                SizedBox(width: 6),
                Text("BÌNH LUẬN TRONG PHÒNG", style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _chatMessages.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final msg = _chatMessages[index];
                bool isSystem = msg['isSystem'] == 'true';

                if (isSystem) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                    ),
                    child: Text(
                      msg['text']!,
                      style: const TextStyle(color: AppColors.primaryDark, fontSize: 9.5, height: 1.3, fontWeight: FontWeight.w600),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(msg['avatar']!, style: const TextStyle(fontSize: 10)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  msg['name']!,
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  msg['time']!,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 8.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.inputBorder),
                              ),
                              child: Text(
                                msg['text']!,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatInputController,
                    decoration: InputDecoration(
                      hintText: "Nhập bình luận...",
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    style: const TextStyle(fontSize: 12),
                    onSubmitted: (_) => _sendChat(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendChat,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendChat() {
    final text = _chatInputController.text.trim();
    if (text.isEmpty) return;
    
    final session = AppSession.current;
    if (session != null) {
      _realtimeSocket.sendMessage(
        roomId: widget.roomId,
        userId: session.userId,
        text: text,
        displayName: session.displayName ?? session.fullName,
      );
      _chatInputController.clear();
    }
  }
}

class AudioWaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isMuted;

  AudioWaveformPainter({required this.animationValue, required this.color, this.isMuted = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = math.Random(101);
    const barCount = 20;
    final barWidth = size.width / (barCount * 1.5);
    final gap = barWidth * 0.5;

    for (int i = 0; i < barCount; i++) {
      final baseHeight = size.height * (0.3 + random.nextDouble() * 0.5);
      final pulse = isMuted ? 0.0 : math.sin(animationValue * 2 * math.pi + i * 0.8) * 0.35;
      final currentHeight = isMuted ? 4.0 : baseHeight * (1.0 + pulse);
      
      final x = i * (barWidth + gap) + gap;
      final y = size.height - currentHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, currentHeight),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color || oldDelegate.isMuted != isMuted;
  }
}
