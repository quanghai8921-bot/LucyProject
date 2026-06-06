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

class LiveLearnerRoomDialog extends StatefulWidget {
  final String roomId;
  final String title;
  final String mentor;
  final String hostUserId;

  const LiveLearnerRoomDialog({
    super.key,
    required this.roomId,
    required this.title,
    required this.mentor,
    required this.hostUserId,
  });

  @override
  State<LiveLearnerRoomDialog> createState() => _LiveLearnerRoomDialogState();
}

class _LiveLearnerRoomDialogState extends State<LiveLearnerRoomDialog> with TickerProviderStateMixin {
  final RealtimeSocketService _realtimeSocket = RealtimeSocketService();
  final AgoraAudioService _agoraAudio = AgoraAudioService();
  final LmsApi _lmsApi = LmsApi();
  
  bool _isDialogClosed = false;
  bool _isAgoraConnected = false;
  bool _isConnecting = false;
  bool _isMentorMuted = false;
  bool _isMyMuted = true;
  bool _isHandRaised = false;
  String? _agoraError;
  int _secondsElapsed = 0;
  Timer? _stopwatchTimer;
  
  String _currentlyPinnedTitle = 'Chưa chọn slide nào';
  String? _currentlyPinnedBase64;
  String? _currentlyPinnedMimeType;
  
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
          _currentlyPinnedTitle = payload['filename'] ?? payload['fileName'] ?? 'Tài liệu mới';
          final fileBase64 = '${payload['fileBase64'] ?? ''}';
          _currentlyPinnedBase64 = fileBase64.isEmpty ? null : fileBase64;
          final fileType = '${payload['fileType'] ?? ''}';
          _currentlyPinnedMimeType = fileType.isEmpty ? null : fileType;
          _chatMessages.add({
            'name': 'Hệ thống LUCY',
            'avatar': '🤖',
            'text': 'Mentor vừa ghim tài liệu mới: $_currentlyPinnedTitle',
            'time': _formatCurrentTime(),
            'isSystem': 'true'
          });
        });
        _scrollToBottom();
      }
    });
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

  void _downloadPinnedFile() async {
    if (_currentlyPinnedBase64 == null) return;
    try {
      final bytes = base64Decode(_currentlyPinnedBase64!);
      final savedTo = await downloadBytes(
        fileName: _currentlyPinnedTitle,
        bytes: bytes,
        mimeType: _currentlyPinnedMimeType,
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
                        _buildActiveSlideBoard(),
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

  Widget _buildActiveSlideBoard() {
    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.slideshow, color: AppColors.primary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "SLIDE GIÁO TRÌNH ĐANG CHIẾU",
                    style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                ],
              ),
              if (_currentlyPinnedBase64 != null)
                GestureDetector(
                  onTap: _downloadPinnedFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download, size: 12, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text("Tải xuống", style: TextStyle(color: Colors.orange.shade700, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _currentlyPinnedTitle,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Mentor: ${widget.mentor}",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
          ),
          if (_agoraError != null) ...[
            const SizedBox(height: 8),
            Text(
              _agoraError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 10.5, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
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
      ],
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
