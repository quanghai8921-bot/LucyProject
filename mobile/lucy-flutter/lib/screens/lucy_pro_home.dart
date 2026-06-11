import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucy_app/services/file_download/file_download.dart';
import 'package:lucy_app/theme/app_colors.dart';
import 'package:lucy_app/services/agora_audio_service.dart';
import 'package:lucy_app/services/lms_api.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/services/realtime_socket_service.dart';

class LucyProHome extends StatefulWidget {
  const LucyProHome({super.key});

  @override
  State<LucyProHome> createState() => _LucyProHomeState();
}

class _LucyProHomeState extends State<LucyProHome> {
  final LmsApi _lmsApi = LmsApi();
  List<LearnerRoom> _mentorRooms = [];
  List<ImportedDocxFile> _importedDocxFiles = [];
  bool _isMentorRoomsLoading = false;
  String? _mentorRoomsError;

  @override
  void initState() {
    super.initState();
    _fetchMentorRooms();
    _fetchImportedDocxFiles();
  }

  String get _mentorDisplayName {
    final fullName = AppSession.current?.fullName.trim();
    return fullName == null || fullName.isEmpty ? 'Mentor' : fullName;
  }

  int get _openRoomCount => _mentorRooms
      .where((room) => room.roomStatus.toUpperCase() == 'OPEN')
      .length;

  int get _scheduledRoomCount => _mentorRooms
      .where((room) => room.roomStatus.toUpperCase() == 'SCHEDULED')
      .length;

  String _formatScheduledAt(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }

  Future<void> _fetchMentorRooms() async {
    final session = AppSession.current;
    if (session == null || session.userId.isEmpty) return;
    if (mounted) {
      setState(() {
        _isMentorRoomsLoading = true;
        _mentorRoomsError = null;
      });
    }
    try {
      final rooms = await _lmsApi.getMentorRooms(session.userId);
      rooms.sort((a, b) =>
          (b.scheduledStartAt ?? '').compareTo(a.scheduledStartAt ?? ''));
      if (mounted) {
        setState(() {
          _mentorRooms = rooms;
          _isMentorRoomsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMentorRoomsLoading = false;
          _mentorRoomsError = '$e';
        });
      }
    }
  }

  Future<void> _fetchImportedDocxFiles() async {
    try {
      final files = await _lmsApi.getImportedDocxFiles();
      if (mounted) {
        setState(() {
          _importedDocxFiles = files.where((file) => file.isImported).toList();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _importedDocxFiles = [];
        });
      }
    }
  }

  final List<Map<String, dynamic>> _curriculumDocs = [];

  final List<Map<String, dynamic>> _studentsProgress = [];

  final Map<String, String> _studentNotes = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Pro Header with actual avatar, reputation, wallet, and national ranking
        _buildProHeader(),
        const SizedBox(height: 20),

        // 2. Primary Actions: Prominent Create Live Room button
        _buildPrimaryActions(),
        const SizedBox(height: 24),

        // 3. LMS Uploaded Documents Area (Quick Pin)
        _buildLmsDocumentsSection(),
        const SizedBox(height: 24),

        // 4. Mentor room history and schedules from database
        _buildMentorRoomsSection(),
      ],
    );
  }

  // ==========================================
  // 1. PRO HEADER WITH WALLET & LEADERBOARD
  // ==========================================
  Widget _buildProHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mentor Info Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple.shade50,
                  border: Border.all(color: Colors.purple.shade200, width: 2),
                ),
                child: const Center(
                  child: Text("👨‍🏫", style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mentorDisplayName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Chuyên Gia Ngôn Ngữ",
                            style: TextStyle(
                              color: Colors.purple.shade700,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        const Text(
                          "Mentor chính thức",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.inputBorder),
          const SizedBox(height: 18),

          // Wallet & Rank Grid Layout
          Row(
            children: [
              // Earnings Wallet Widget
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.wallet,
                              color: AppColors.primaryDark, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "VÍ TIỀN MENTOR",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _openRoomCount.toString(),
                        style: TextStyle(
                          color: Colors.orange.shade400,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Phòng đang mở",
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Ranking Badge Widget
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.amber.shade200.withOpacity(0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events,
                              color: Colors.amber.shade700, size: 14),
                          const SizedBox(width: 4),
                          const Text(
                            "BẢNG XẾP HẠNG",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _scheduledRoomCount.toString(),
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Phòng đã lên lịch",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. PRIMARY ACTIONS: CREATE LIVE ROOM W/ BOTTOM SHEET
  // ==========================================
  Widget _buildPrimaryActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _showCreateLiveRoomBottomSheet,
          icon: const Icon(Icons.add_circle, color: Colors.white, size: 22),
          label: const Text(
            "TẠO PHÒNG LIVE DẠY HỌC MỚI",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 3,
            shadowColor: AppColors.primary.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  void _showCreateLiveRoomBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            // Keep status variables locally for editing
            String selectedLang = 'Anh';
            String selectedCurriculum = 'LISA';
            final roomTitleController = TextEditingController(
                text: 'Lớp live cùng $_mentorDisplayName');
            final levelNumberController = TextEditingController();
            ImportedDocxFile? selectedDocxFile;
            double roomDuration = 60.0;
            bool isAiModeratorEnabled = true;
            bool openNow = true;
            DateTime scheduledAt = DateTime.now().add(const Duration(hours: 1));

            return StatefulBuilder(builder: (context, setInnerState) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 20, 24,
                      MediaQuery.of(context).viewInsets.bottom + 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Pull Bar
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.inputBorder,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      const Row(
                        children: [
                          Icon(Icons.video_call_outlined,
                              color: AppColors.primary, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "Khởi Tạo Phòng Live Audio 🎙️",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Thiết lập phòng dạy học và chuẩn bị số hóa tài liệu lên Agora SDK.",
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 20),

                      // 1. Language selector chips
                      const Text(
                        "Ngôn ngữ giảng dạy:",
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Anh', 'Trung', 'Nhật'].map((lang) {
                          bool isCurrent = selectedLang == lang;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: ChoiceChip(
                              label: Text(
                                lang == 'Anh'
                                    ? '🇬🇧 Tiếng Anh'
                                    : lang == 'Trung'
                                        ? '🇨🇳 Tiếng Trung'
                                        : '🇯🇵 Tiếng Nhật',
                                style: TextStyle(
                                  color: isCurrent
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              selected: isCurrent,
                              onSelected: (selected) {
                                setInnerState(() {
                                  selectedLang = lang;
                                });
                              },
                              selectedColor: AppColors.primary,
                              backgroundColor: Colors.grey.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isCurrent
                                      ? AppColors.primary
                                      : AppColors.inputBorder,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // 2. Curriculum selection
                      const Text(
                        "Giáo trình giảng dạy:",
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text(
                                "LISA Core Curriculum (Học cùng Robot AI)",
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            value: 'LISA',
                            groupValue: selectedCurriculum,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setInnerState(() => selectedCurriculum = val!),
                          ),
                          RadioListTile<String>(
                            title: const Text(
                                "Chinese Standard Course (HSK Tương Tác)",
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            value: 'Chinese',
                            groupValue: selectedCurriculum,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setInnerState(() => selectedCurriculum = val!),
                          ),
                          RadioListTile<String>(
                            title: const Text(
                                "JLPT Preparation Standard (Giáo trình tiếng Nhật)",
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            value: 'Japanese',
                            groupValue: selectedCurriculum,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setInnerState(() => selectedCurriculum = val!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Tiêu đề phòng:",
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: roomTitleController,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: Luyện nói tiếng Anh Level 31',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Level bạn sẽ dạy:",
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: levelNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Nhập số level, ví dụ 31',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "File DOCX trong hệ thống:",
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Builder(builder: (context) {
                        final languageId = selectedLang == 'Anh'
                            ? 'ENG'
                            : selectedLang == 'Trung'
                                ? 'CHI'
                                : 'JAP';
                        final files = _importedDocxFiles
                            .where((file) =>
                                file.languageId == null ||
                                file.languageId == languageId)
                            .toList();
                        if (files.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade100),
                            ),
                            child: const Text(
                              'Chưa có file DOCX đã import cho ngôn ngữ này.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          );
                        }
                        if (selectedDocxFile == null ||
                            !files.any((file) =>
                                file.importedDocxFileId ==
                                selectedDocxFile!.importedDocxFileId)) {
                          selectedDocxFile = files.first;
                        }
                        return SizedBox(
                          height: 122,
                          child: ListView.builder(
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              final file = files[index];
                              final selected =
                                  selectedDocxFile?.importedDocxFileId ==
                                      file.importedDocxFileId;
                              return RadioListTile<String>(
                                dense: true,
                                value: file.importedDocxFileId,
                                groupValue:
                                    selectedDocxFile?.importedDocxFileId,
                                onChanged: (_) => setInnerState(
                                    () => selectedDocxFile = file),
                                title: Text(file.fileName,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  'Level ${file.levelStart ?? '?'}-${file.levelEnd ?? '?'}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary),
                                ),
                                activeColor: AppColors.primary,
                                selected: selected,
                              );
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // 3. Duration slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Thời lượng buổi Live:",
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${roomDuration.toInt()} phút",
                            style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Slider(
                        value: roomDuration,
                        min: 60,
                        max: 120,
                        divisions: 4,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primary.withOpacity(0.15),
                        onChanged: (val) {
                          setInnerState(() {
                            roomDuration = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // 4. Toggle AI Moderator Support
                      SwitchListTile(
                        title: const Text(
                          "Kích hoạt Trợ lý ảo AI Moderator",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        subtitle: const Text(
                          "Gợi ý câu hỏi thảo luận lên màn hình của Moderator dựa trên tài liệu ghim sẵn.",
                          style: TextStyle(
                              fontSize: 10.5, color: AppColors.textSecondary),
                        ),
                        value: isAiModeratorEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setInnerState(() {
                            isAiModeratorEnabled = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            icon: Icon(Icons.play_circle_outline),
                            label: Text('Mở ngay'),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            icon: Icon(Icons.schedule),
                            label: Text('Lên lịch'),
                          ),
                        ],
                        selected: {openNow},
                        onSelectionChanged: (values) {
                          setInnerState(() {
                            openNow = values.first;
                          });
                        },
                      ),
                      if (!openNow) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: scheduledAt,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (pickedDate == null || !context.mounted) return;
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(scheduledAt),
                            );
                            if (pickedTime == null) return;
                            setInnerState(() {
                              scheduledAt = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          },
                          icon: const Icon(Icons.event),
                          label: Text(
                              'Thời gian: ${_formatScheduledAt(scheduledAt)}'),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Confirm button
                      ElevatedButton(
                        onPressed: () async {
                          final roomTitle = roomTitleController.text.trim();
                          final levelNumber =
                              int.tryParse(levelNumberController.text.trim());
                          if (roomTitle.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Vui lòng nhập tiêu đề phòng.')),
                            );
                            return;
                          }
                          if (levelNumber == null || levelNumber <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Vui lòng nhập level hợp lệ.')),
                            );
                            return;
                          }

                          Navigator.pop(context); // Close BottomSheet
                          try {
                            final session = AppSession.current;
                            if (session != null) {
                              final room = await _lmsApi.createMentorRoom(
                                hostUserId: session.userId,
                                roomTitle: roomTitle,
                                levelNumber: levelNumber,
                                languageId: selectedLang == 'Anh'
                                    ? 'ENG'
                                    : selectedLang == 'Trung'
                                        ? 'CHI'
                                        : 'JAP',
                                importedDocxFileId:
                                    selectedDocxFile?.importedDocxFileId,
                                maxParticipants: 30,
                                roomStatus: openNow ? 'OPEN' : 'SCHEDULED',
                                scheduledStartAt:
                                    openNow ? DateTime.now() : scheduledAt,
                              );
                              await _fetchMentorRooms();

                              if (openNow) {
                                _showLiveStudioRoomSimulation(
                                  roomId: room.roomId,
                                  language: selectedLang,
                                  curriculum: selectedCurriculum,
                                  duration: roomDuration.toInt(),
                                  aiEnabled: isAiModeratorEnabled,
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Đã lên lịch phòng live.')),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Không thể khởi tạo phòng trên server: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("XÁC NHẬN & MỞ PHÒNG LIVE",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }

  void _showLiveStudioRoomSimulation({
    required String roomId,
    required String language,
    required String curriculum,
    required int duration,
    required bool aiEnabled,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return LiveStudioRoomDialog(
          roomId: roomId,
          language: language,
          curriculum: curriculum,
          duration: duration,
          aiEnabled: aiEnabled,
          curriculumDocs: _curriculumDocs,
        );
      },
    );
  }

  // ==========================================
  // 3. LMS CURRICULUM DOCUMENTS ("QUICK PIN")
  // ==========================================
  Widget _buildLmsDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tài liệu giảng dạy (LMS) 📂",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _fetchImportedDocxFiles,
              child: const Row(
                children: [
                  Icon(Icons.refresh, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text("Làm mới",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_importedDocxFiles.isEmpty)
          _buildEmptyPanel('Chưa có file DOCX đã import trong hệ thống.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _importedDocxFiles.length,
            itemBuilder: (context, index) {
              final doc = _importedDocxFiles[index];
              final accentColor = doc.languageId == 'CHI'
                  ? Colors.red.shade500
                  : doc.languageId == 'JAP'
                      ? Colors.indigo.shade500
                      : AppColors.primary;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.inputBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Custom styled file icon matching mockup
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(Icons.description, color: accentColor, size: 22),
                    ),
                    const SizedBox(width: 14),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.fileName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.inputBorder.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  doc.languageId ?? 'DOCX',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                doc.importStatus,
                                style: TextStyle(
                                  color: doc.isImported
                                      ? Colors.green.shade600
                                      : Colors.orange.shade600,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Text(
                      doc.levelStart == null
                          ? ''
                          : 'Lv ${doc.levelStart}-${doc.levelEnd}',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddLmsDocumentDialog() {
    final titleController = TextEditingController();
    String category = 'LISA Core';
    PlatformFile? selectedFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.upload_file, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text("Tải Lên Tài Liệu .docx",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Nhập tiêu đề giáo trình tài liệu của bạn:",
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "Ví dụ: LISA Level 4: At the Hotel Lobby 🏨",
                      hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  const Text("Phân hệ giáo trình học:",
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: ['LISA Core', 'Chinese Standard', 'Japanese Prep']
                        .map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        category = val!;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                        withData: true,
                        type: FileType.any,
                      );
                      final file = result?.files.single;
                      if (file == null) return;
                      setDialogState(() {
                        selectedFile = file;
                        if (titleController.text.trim().isEmpty) {
                          titleController.text = file.name;
                        }
                      });
                    },
                    icon: const Icon(Icons.attach_file, size: 16),
                    label: Text(
                      selectedFile?.name ?? 'Chọn file từ máy local',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("HỦY",
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    Navigator.pop(context);

                    Color customColor = const Color(0xFF64C3A5);
                    if (category == 'Chinese Standard') {
                      customColor = Colors.orange.shade300;
                    } else if (category == 'Japanese Prep') {
                      customColor = Colors.purple.shade200;
                    }

                    setState(() {
                      _curriculumDocs.insert(0, {
                        'id': 'doc_${DateTime.now().millisecondsSinceEpoch}',
                        'title': titleController.text.trim(),
                        'category': category,
                        'isPinned': false,
                        'status': 'Đang chờ duyệt',
                        'color': customColor,
                        'fileName':
                            selectedFile?.name ?? titleController.text.trim(),
                        'fileType': selectedFile?.extension == null
                            ? 'application/octet-stream'
                            : 'application/${selectedFile!.extension}',
                        'fileBase64': selectedFile?.bytes == null
                            ? ''
                            : base64Encode(selectedFile!.bytes!),
                      });
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "📄 Đã tải lên tài liệu mới thành công và đang đợi phê duyệt!"),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("TẢI LÊN",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMentorRoomsSection() {
    if (_isMentorRoomsLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_mentorRoomsError != null) {
      return _buildEmptyPanel(
          'Không tải được danh sách phòng: $_mentorRoomsError');
    }

    if (_mentorRooms.isEmpty) {
      return _buildEmptyPanel('Bạn chưa tạo phòng live nào.');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.meeting_room_outlined,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Phòng live đã tạo',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                onPressed: _fetchMentorRooms,
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                tooltip: 'Tải lại',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mentorRooms.length,
            itemBuilder: (context, index) =>
                _buildMentorRoomRow(_mentorRooms[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPanel(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Text(
        message,
        style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMentorRoomRow(LearnerRoom room) {
    final status = room.roomStatus.toUpperCase();
    final isOpen = status == 'OPEN';
    final isScheduled = status == 'SCHEDULED';
    final statusColor = isOpen
        ? AppColors.primary
        : isScheduled
            ? Colors.blue
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Icon(isOpen ? Icons.podcasts : Icons.event_note, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.roomTitle.isEmpty ? 'Phòng live' : room.roomTitle,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${room.participantCount} học viên • ${room.scheduledStartAt ?? 'Chưa có lịch'}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isScheduled)
            TextButton(
              onPressed: () => _openScheduledRoom(room),
              child: const Text('Mở bây giờ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else if (isOpen)
            TextButton(
              onPressed: () => _showLiveStudioRoomSimulation(
                roomId: room.roomId,
                language: room.languageId ?? 'Anh',
                curriculum: room.roomTitle,
                duration: 60,
                aiEnabled: true,
              ),
              child: const Text('Vào phòng',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else
            Text(status,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _openScheduledRoom(LearnerRoom room) async {
    try {
      final opened = await _lmsApi.openMentorRoom(room.roomId);
      await _fetchMentorRooms();
      if (!mounted) return;
      _showLiveStudioRoomSimulation(
        roomId: opened.roomId,
        language: opened.languageId ?? room.languageId ?? 'Anh',
        curriculum: opened.roomTitle,
        duration: 60,
        aiEnabled: true,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không mở được phòng: $e')),
      );
    }
  }

  // ==========================================
  // 4. STUDENT LEARNING PROGRESS ROADMAP DASHBOARD
  // ==========================================
  Widget _buildStudentProgressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Row(
            children: [
              Icon(Icons.assignment_ind_outlined,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 6),
              Text(
                "Lộ trình & Tiến độ học viên 📊",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total metrics summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressMetricCol(
                  "Học viên", "${_studentsProgress.length} hoạt động"),
              _buildProgressMetricCol("Hoàn thành", "0%"),
              _buildProgressMetricCol("Điểm thi Avg", "Chưa có"),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.inputBorder),
          const SizedBox(height: 16),

          // List of student progress rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _studentsProgress.length,
            itemBuilder: (context, index) {
              final student = _studentsProgress[index];
              double progress = student['progress'] as double;

              return GestureDetector(
                onTap: () => _showStudentDetailBottomSheet(student),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        // Avatar bubble
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          child: Text(student['avatar'] as String,
                              style: const TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 12),

                        // Info Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    student['name'] as String,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  Text(
                                    student['level'] as String,
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Linear progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor:
                                      AppColors.inputBorder.withOpacity(0.6),
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Percent tag
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textSecondary, size: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showStudentDetailBottomSheet(Map<String, dynamic> student) {
    final String sId = student['id'] as String;
    final notesController =
        TextEditingController(text: _studentNotes[sId] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            bool showCelebration = false;
            final currentLevelStr = student['level'] as String;
            final currentLvlNum =
                int.parse(currentLevelStr.replaceAll('Lvl ', ''));
            final progress = student['progress'] as double;

            return StatefulBuilder(builder: (context, setInnerSheetState) {
              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24,
                        MediaQuery.of(context).viewInsets.bottom + 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.inputBorder,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Header with profile brief
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.12),
                              child: Text(student['avatar'] as String,
                                  style: const TextStyle(fontSize: 26)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name'] as String,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          student['level'] as String,
                                          style: const TextStyle(
                                              color: AppColors.primaryDark,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Tiến trình khóa học: ${(progress * 100).toInt()}%",
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Level Roadmap representation
                        const Text(
                          "Lộ Trình Cấp Độ Học Viên 🚀",
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Timeline steps
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            final stepLvl = index + 1;
                            final isCompleted = stepLvl < currentLvlNum ||
                                (stepLvl == currentLvlNum && progress >= 1.0);
                            final isCurrent =
                                stepLvl == currentLvlNum && progress < 1.0;

                            return Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 3,
                                          color: index == 0
                                              ? Colors.transparent
                                              : isCompleted
                                                  ? AppColors.primary
                                                  : AppColors.inputBorder,
                                        ),
                                      ),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCompleted
                                              ? AppColors.primary
                                              : isCurrent
                                                  ? Colors.orange.shade300
                                                  : Colors.white,
                                          border: Border.all(
                                            color: isCompleted
                                                ? AppColors.primary
                                                : isCurrent
                                                    ? Colors.orange.shade300
                                                    : AppColors.inputBorder,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: isCompleted
                                              ? const Icon(Icons.check,
                                                  size: 12, color: Colors.white)
                                              : Text(
                                                  "$stepLvl",
                                                  style: TextStyle(
                                                    color: isCurrent
                                                        ? Colors.white
                                                        : AppColors
                                                            .textSecondary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 3,
                                          color: index == 4
                                              ? Colors.transparent
                                              : isCompleted &&
                                                      (index + 2 <=
                                                          currentLvlNum)
                                                  ? AppColors.primary
                                                  : AppColors.inputBorder,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Lvl $stepLvl",
                                    style: TextStyle(
                                      color: isCompleted
                                          ? AppColors.primaryDark
                                          : isCurrent
                                              ? Colors.orange.shade600
                                              : AppColors.textSecondary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),

                        // Teacher notes text box
                        const Text(
                          "Ghi Chú Của Mentor 📝",
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: notesController,
                          maxLines: 2,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText:
                                "Viết nhận xét lộ trình, điểm yếu cần khắc phục...",
                            hintStyle: TextStyle(
                                fontSize: 12, color: Colors.grey.shade400),
                            fillColor: Colors.grey.shade50,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.inputBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _studentNotes[sId] = notesController.text;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "📝 Đã cập nhật ghi chú học viên thành công!"),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.12),
                              foregroundColor: AppColors.primaryDark,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                            ),
                            child: const Text("LƯU GHI CHÚ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons: Approve level up
                        ElevatedButton.icon(
                          onPressed: () {
                            setInnerSheetState(() {
                              showCelebration = true;
                            });

                            // Simulate API level-up upgrade
                            Timer(const Duration(seconds: 2), () {
                              if (context.mounted) {
                                Navigator.pop(context); // Close bottomsheet
                                setState(() {
                                  // Update student level
                                  student['level'] = 'Lvl ${currentLvlNum + 1}';
                                  student['progress'] =
                                      0.15; // Reset progress for next level
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "🎉 Chúc mừng! Đã thăng cấp cho học viên lên Lvl ${currentLvlNum + 1}!"),
                                    backgroundColor: Colors.amber.shade700,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            });
                          },
                          icon: const Icon(Icons.verified, color: Colors.white),
                          label: const Text(
                            "PHÊ DUYỆT THĂNG CẤP (LEVEL UP)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade600,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Success level-up animation overlay
                  if (showCelebration)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber,
                                  ),
                                  child: const Icon(
                                    Icons.military_tech,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                builder: (context, opacity, child) {
                                  return Opacity(
                                    opacity: opacity,
                                    child: child,
                                  );
                                },
                                child: Column(
                                  children: [
                                    const Text(
                                      "PHÊ DUYỆT THÀNH CÔNG!",
                                      style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Chúc mừng học viên ${student['name']}\nĐược thăng cấp lên Lvl ${currentLvlNum + 1}!",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            });
          },
        );
      },
    );
  }

  Widget _buildProgressMetricCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// HIGH-FIDELITY LIVE STUDIO DIALOG SIMULATOR
// ==========================================
class LiveStudioRoomDialog extends StatefulWidget {
  final String? roomId;
  final String language;
  final String curriculum;
  final int duration;
  final bool aiEnabled;
  final num joinFee;
  final bool enableLocalRecording;
  final List<Map<String, dynamic>> curriculumDocs;

  const LiveStudioRoomDialog({
    super.key,
    this.roomId,
    required this.language,
    required this.curriculum,
    required this.duration,
    required this.aiEnabled,
    this.joinFee = 0,
    this.enableLocalRecording = false,
    required this.curriculumDocs,
  });

  @override
  State<LiveStudioRoomDialog> createState() => LiveStudioRoomDialogState();
}

class LiveStudioRoomDialogState extends State<LiveStudioRoomDialog>
    with TickerProviderStateMixin {
  final RealtimeSocketService _realtimeSocket = RealtimeSocketService();
  final AgoraAudioService _agoraAudio = AgoraAudioService();
  final LmsApi _lmsApi = LmsApi();
  int _participantCount = 0;
  int _secondsElapsed = 0;
  Timer? _stopwatchTimer;
  RoomStudyPlan? _studyPlan;
  bool _isStudyStarted = false;
  int _activeSubLevelIndex = 0;

  bool _isMuted = false;
  bool _isAgoraConnected = false;
  bool _isRecording = false;
  DateTime? _recordingStartedAt;
  String? _agoraError;
  String _currentlyPinnedTitle = 'Chưa chọn slide nào';

  bool _showDonationOverlay = false;
  String? _donationImageUrl;
  String? _donationMessage;

  int _promptIndex = 0;
  final List<String> _aiPrompts = [
    "Hãy mô tả hoạt động cuối tuần yêu thích nhất của bạn tại quán Cafe bằng tiếng nước ngoài?",
    "Roleplay: Đặt một cốc trà sữa và hỏi giảm đường, đá bằng tiếng nước bản địa?",
    "Gen Z Slang Challenge: Sử dụng từ lóng vừa học để miêu tả một bộ phim bạn thích nhất?",
    "Survival Speaking: Hỏi đường đi đến nhà ga gần nhất trong tình huống điện thoại hết pin?",
    "Business Talk: Giới thiệu ngắn gọn bản thân và 3 thế mạnh lớn nhất của bạn trong buổi phỏng vấn?",
  ];

  final List<Map<String, String>> _chatMessages = [];
  final ScrollController _chatScrollController = ScrollController();
  final TextEditingController _mentorChatInputController =
      TextEditingController();
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

    // Find initial pinned slide
    final initialPinned = widget.curriculumDocs.firstWhere(
      (doc) => doc['isPinned'] == true,
      orElse: () => <String, dynamic>{},
    );
    if (initialPinned.isNotEmpty) {
      _currentlyPinnedTitle = initialPinned['title'] as String;
    } else if (widget.curriculumDocs.isNotEmpty) {
      _currentlyPinnedTitle = widget.curriculumDocs.first['title'] as String;
    }

    _startStopwatch();
    _startChatSimulation();
    _loadStudyPlan();

    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Setup realtime socket listeners for Mentor
    final mentorId = AppSession.current?.userId;
    if (mentorId != null && mentorId.isNotEmpty) {
      _realtimeSocket.connect();
      _realtimeSocket.watchMentor(mentorId);
      if (widget.roomId != null && widget.roomId!.isNotEmpty) {
        _realtimeSocket.watchRoom(widget.roomId!);
      }
      _joinAgoraAudio(mentorId);
      _realtimeSocket.onMentorRoomUpdated((payload) {
        final roomId = '${payload['roomId'] ?? ''}';
        if (roomId != widget.roomId) return;

        final participants = payload['participants'];
        if (participants is List) {
          if (mounted) {
            setState(() {
              _participantCount = participants.length;
            });
          }
        }

        final joinedParticipant = payload['joinedParticipant'];
        if (joinedParticipant is Map) {
          final displayName =
              '${joinedParticipant['displayName'] ?? ''}'.trim();
          if (displayName.isNotEmpty && mounted) {
            setState(() {
              _chatMessages.add({
                'name': 'Hệ thống LUCY',
                'avatar': '🤖',
                'text': '$displayName vừa tham gia phòng',
                'time': _formatCurrentTime(),
                'isSystem': 'true'
              });
            });
            _scrollToBottom();
          }
        }

        final leftParticipant = payload['leftParticipant'];
        if (leftParticipant is Map) {
          final displayName = '${leftParticipant['displayName'] ?? ''}'.trim();
          if (displayName.isNotEmpty && mounted) {
            setState(() {
              _chatMessages.add({
                'name': 'Hệ thống LUCY',
                'avatar': '🤖',
                'text': '$displayName đã rời phòng',
                'time': _formatCurrentTime(),
                'isSystem': 'true'
              });
            });
            _scrollToBottom();
          }
        }
      });

      _realtimeSocket.onMicChanged((payload) {
        final userId = '${payload['userId'] ?? ''}';
        if (userId == mentorId) return; // Skip self mic updates
        final micEnabled =
            payload['micEnabled'] == true || '${payload['micStatus']}' == 'ON';
        final displayName = '${payload['displayName'] ?? 'Học viên'}';
        if (mounted) {
          setState(() {
            _chatMessages.add({
              'name': 'Hệ thống LUCY',
              'avatar': '🤖',
              'text': '$displayName đã ${micEnabled ? "bật" : "tắt"} micro 🎤',
              'time': _formatCurrentTime(),
              'isSystem': 'true'
            });
          });
          _scrollToBottom();
        }
      });

      _realtimeSocket.onChatMessage((payload) {
        if ('${payload['roomId'] ?? ''}' != widget.roomId) return;
        if (!mounted) return;
        setState(() {
          _chatMessages.add({
            'name': '${payload['displayName'] ?? 'Học viên'}',
            'avatar': '!',
            'text': '${payload['text'] ?? ''}',
            'time': _formatCurrentTime(),
            'isSystem': 'false'
          });
        });
        _scrollToBottom();
      });

      _realtimeSocket.onHandRaised((payload) {
        if ('${payload['roomId'] ?? ''}' != widget.roomId) return;
        if (!mounted) return;
        final raised = payload['raised'] == true;
        setState(() {
          _chatMessages.add({
            'name': 'Hệ thống LUCY',
            'avatar': '!',
            'text':
                '${payload['displayName'] ?? 'Học viên'} đã ${raised ? 'giơ tay phát biểu' : 'bỏ giơ tay'}',
            'time': _formatCurrentTime(),
            'isSystem': 'true'
          });
        });
        _scrollToBottom();
      });

      _realtimeSocket.onPaymentDonation((payload) {
        final rId = '${payload['roomId'] ?? payload['RoomId'] ?? ''}';
        if (rId != widget.roomId) return;
        if (!mounted) return;

        final name = '${payload['fromUserId'] ?? payload['FromUserId'] ?? 'Học viên'}';
        final amount = '${payload['netAmount'] ?? payload['NetAmount'] ?? '0'}';
        final giftUrl = payload['giftImageUrl'] ?? payload['GiftImageUrl'];

        setState(() {
          _showDonationOverlay = true;
          _donationImageUrl = giftUrl?.toString();
          _donationMessage = '$name đã tặng bạn $amount Xu';
        });

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showDonationOverlay = false;
            });
          }
        });
      });
    }
  }

  Future<void> _loadStudyPlan() async {
    if (widget.roomId == null || widget.roomId!.isEmpty) return;
    try {
      final plan = await _lmsApi.getRoomStudyPlan(widget.roomId!);
      if (mounted) {
        setState(() {
          _studyPlan = plan;
          _currentlyPinnedTitle =
              plan.importedDocxFile?.fileName ?? _currentlyPinnedTitle;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _agoraError = '$error';
        });
      }
    }
  }

  Future<void> _startStudyFlow() async {
    if (widget.roomId == null || widget.roomId!.isEmpty) return;
    try {
      await _lmsApi.startStudy(widget.roomId!);
      await _loadStudyPlan();
      if (mounted) {
        setState(() {
          _isStudyStarted = true;
          _activeSubLevelIndex = 0;
          _chatMessages.add({
            'name': 'Hệ thống LUCY',
            'avatar': '!',
            'text':
                'Mentor đã bắt đầu buổi học. Nội dung level đang được chạy theo DOCX đã chọn.',
            'time': _formatCurrentTime(),
            'isSystem': 'true',
          });
        });
        _scrollToBottom();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không bắt đầu được buổi học: $error')));
      }
    }
  }

  Future<void> _completeActiveSubLevel() async {
    final plan = _studyPlan;
    if (plan == null || widget.roomId == null || plan.subLevels.isEmpty) return;
    final current = plan.subLevels[_activeSubLevelIndex];
    await _lmsApi.completeRoomSubLevel(
        roomId: widget.roomId!, subLevelId: current.subLevelId);
    if (!mounted) return;
    if (_activeSubLevelIndex >= plan.subLevels.length - 1) {
      setState(() {
        _isStudyStarted = false;
        _chatMessages.add({
          'name': 'Hệ thống LUCY',
          'avatar': '!',
          'text':
              'Bạn đã hoàn tất dạy học chủ đề hôm nay. Có thể phát bài kiểm tra cho học viên đủ điều kiện.',
          'time': _formatCurrentTime(),
          'isSystem': 'true',
        });
      });
    } else {
      setState(() => _activeSubLevelIndex++);
    }
    _scrollToBottom();
    await _loadStudyPlan();
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _chatScrollController.dispose();
    _mentorChatInputController.dispose();
    _waveformController.dispose();
    _agoraAudio.leave();
    if (widget.roomId != null && widget.roomId!.isNotEmpty) {
      _realtimeSocket.unwatchRoom(widget.roomId!);
    }
    _realtimeSocket.offMicChanged();
    _realtimeSocket.offChatMessage();
    _realtimeSocket.offHandRaised();
    _realtimeSocket.offPaymentDonation();
    _realtimeSocket.disconnect();
    super.dispose();
  }

  Future<void> _joinAgoraAudio(String mentorId) async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;
    try {
      await _agoraAudio.join(
        roomId: roomId,
        userId: mentorId,
        publishMicrophone: !_isMuted,
      );
      if (mounted) {
        setState(() {
          _isAgoraConnected = true;
          _agoraError = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isAgoraConnected = false;
          _agoraError = '$error';
          _chatMessages.add({
            'name': 'He thong LUCY',
            'avatar': '!',
            'text': 'Agora RTC loi: $error',
            'time': _formatCurrentTime(),
            'isSystem': 'true'
          });
        });
      }
    }
  }

  void _startStopwatch() {
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _startChatSimulation() {
    // Add initial message
    _chatMessages.add({
      'name': 'Hệ thống LUCY',
      'avatar': '🤖',
      'text':
          'Phòng Live Audio đã khởi tạo thành công trên Agora RTC. Đang đợi học viên tham gia...',
      'time': 'Vừa xong',
      'isSystem': 'true'
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

  void _pinDocumentToRoom(Map<String, dynamic> doc) {
    final mentorId = AppSession.current?.userId;
    final roomId = widget.roomId;
    final title = '${doc['title'] ?? doc['fileName'] ?? 'Tài liệu'}';
    if (mentorId == null ||
        mentorId.isEmpty ||
        roomId == null ||
        roomId.isEmpty) return;

    _realtimeSocket.pinSlide(
      roomId: roomId,
      userId: mentorId,
      filename: title,
      fileBase64: '${doc['fileBase64'] ?? ''}',
      fileType: '${doc['fileType'] ?? 'application/octet-stream'}',
    );
  }

  void _sendMentorChat() {
    final text = _mentorChatInputController.text.trim();
    final session = AppSession.current;
    final roomId = widget.roomId;
    if (text.isEmpty || session == null || roomId == null || roomId.isEmpty)
      return;

    _realtimeSocket.sendMessage(
      roomId: roomId,
      userId: session.userId,
      text: text,
      displayName: session.fullName,
    );
    _mentorChatInputController.clear();
  }

  Future<void> _pickAndPinLiveMaterial() async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.any,
    );
    final file = result?.files.single;
    if (file == null) return;

    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Không đọc được nội dung file để ghim.')),
      );
      return;
    }
    if (!mounted) return;

    final doc = <String, dynamic>{
      'id': 'live_doc_${DateTime.now().millisecondsSinceEpoch}',
      'title': file.name,
      'category': 'Live room',
      'isPinned': true,
      'status': 'Đang chiếu',
      'color': AppColors.primary,
      'fileName': file.name,
      'fileType': file.extension == null
          ? 'application/octet-stream'
          : 'application/${file.extension}',
      'fileBase64': base64Encode(bytes),
    };

    setState(() {
      _currentlyPinnedTitle = file.name;
      for (final item in widget.curriculumDocs) {
        item['isPinned'] = false;
      }
      widget.curriculumDocs.insert(0, doc);
    });
    _pinDocumentToRoom(doc);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Đã ghim tài liệu: ${file.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Header Admin Bar
              _buildStudioTopHeader(),

              // 2. Main Studio Screen Area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      children: [
                        _buildStudyPlanCard(),
                        const SizedBox(height: 16),

                        // Active Pinned Slide Card representation
                        _buildActiveSlideBoard(),
                        const SizedBox(height: 16),

                        // Interactive controls: Mic, AI refreshes
                        _buildControlPanel(),
                        const SizedBox(height: 16),

                        // Live student chat logs
                        _buildLiveChatContainer(),
                        const SizedBox(height: 16),

                        // Pinnable documents slider in-studio
                        _buildStudioSlideSlider(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    if (_showDonationOverlay)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_donationImageUrl != null && _donationImageUrl!.startsWith('http'))
                            Image.network(_donationImageUrl!, width: 140, height: 140)
                          else if (_donationImageUrl != null)
                            Text(_donationImageUrl!, style: const TextStyle(fontSize: 100))
                          else
                            const Icon(Icons.card_giftcard, size: 100, color: Colors.pinkAccent),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              _donationMessage ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStudyPlanCard() {
    final plan = _studyPlan;
    final activeIndex = plan == null || plan.subLevels.isEmpty
        ? 0
        : _activeSubLevelIndex.clamp(0, plan.subLevels.length - 1).toInt();
    final active = plan == null || plan.subLevels.isEmpty
        ? null
        : plan.subLevels[activeIndex];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan?.importedDocxFile?.fileName ??
                      'Chưa tải được file DOCX của phòng',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${plan?.groupTitle ?? 'Nhóm level'} • ${plan?.levelTitle ?? widget.curriculum}',
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
          if ((plan?.levelDescription ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              plan!.levelDescription!,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11, height: 1.35),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          if (active == null)
            const Text('Chưa có sublevel cho level này.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11))
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(active.title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  if ((active.mainTask ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(active.mainTask!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ],
                  const SizedBox(height: 4),
                  Text('${active.durationMins ?? widget.duration} phút',
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isStudyStarted ? null : _startStudyFlow,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Bắt đầu học'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isStudyStarted && active != null
                      ? _completeActiveSubLevel
                      : null,
                  icon: const Icon(Icons.skip_next, size: 16),
                  label: Text(_activeSubLevelIndex >=
                          ((plan?.subLevels.length ?? 1) - 1)
                      ? 'Hoàn tất'
                      : 'Sublevel tiếp'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudioTopHeader() {
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
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Text(
                "LIVE ACTIVE",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8),
              ),
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
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Confirm exit dialog inside light theme
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text("Kết Thúc Buổi Live?",
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                  content: const Text(
                      "Bạn có thực sự muốn đóng phòng dạy học audio và trả lại học viên về trang chủ?",
                      style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("HỦY",
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final dialogNavigator = Navigator.of(ctx);
                        final studioNavigator = Navigator.of(context);
                        try {
                          if (widget.roomId != null &&
                              widget.roomId!.isNotEmpty) {
                            final lmsApi = LmsApi();
                            await lmsApi.endMentorRoom(widget.roomId!);

                            final realtimeSocket = RealtimeSocketService();
                            realtimeSocket.endRoom(widget.roomId!);
                            realtimeSocket.disconnect();
                          }
                        } catch (_) {}
                        if (mounted) {
                          dialogNavigator.pop();
                          studioNavigator.pop();
                        }
                      },
                      child: const Text("KẾT THÚC",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            },
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
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
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isAgoraConnected
                      ? (widget.language == 'Anh'
                          ? "🇬🇧 English"
                          : widget.language == 'Trung'
                              ? "🇨🇳 Chinese"
                              : "🇯🇵 Japanese")
                      : 'Audio dang ket noi',
                  style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _currentlyPinnedTitle,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Học viên sẽ nghe thấy giọng nói của bạn kết hợp với nội dung slide này.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
          ),
          if (widget.joinFee > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                'Phong Creator tra phi: ${widget.joinFee.toStringAsFixed(0)} Xu',
                style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
          if (_agoraError != null) ...[
            const SizedBox(height: 8),
            Text(
              _agoraError!,
              style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 16),

          // Custom Painted Animated waveform visualizer inside active board
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
                      color: _isMuted
                          ? Colors.red.shade400.withOpacity(0.5)
                          : AppColors.primary,
                      isMuted: _isMuted,
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
      children: [
        // Mic on/off
        _buildMicButton(),
        const SizedBox(width: 14),
        if (widget.enableLocalRecording) ...[
          _buildRecordButton(),
          const SizedBox(width: 14),
        ],

        // AI Suggestion Box
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.purple.shade200.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color: Colors.purpleAccent, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "AI MODERATOR PROMPT",
                          style: TextStyle(
                              color: Colors.purpleAccent,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    if (widget.aiEnabled)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _promptIndex =
                                (_promptIndex + 1) % _aiPrompts.length;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text("Tải gợi ý",
                              style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.aiEnabled
                      ? "\"${_aiPrompts[_promptIndex]}\""
                      : "\"Trợ lý ảo AI đang tắt trong buổi Live này\"",
                  style: TextStyle(
                    color: widget.aiEnabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 10.5,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleLocalRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red.shade600 : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(_isRecording ? 0.25 : 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop_rounded : Icons.fiber_manual_record,
              color: _isRecording ? Colors.white : Colors.red.shade500,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isRecording ? 'Dang ghi' : 'Ghi live',
          style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _toggleLocalRecording() async {
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
        _recordingStartedAt = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da bat dau ghi local tren may.')),
      );
      return;
    }

    final startedAt = _recordingStartedAt ?? DateTime.now();
    final endedAt = DateTime.now();
    setState(() {
      _isRecording = false;
      _recordingStartedAt = null;
    });
    final summary = [
      'Lucy live recording',
      'RoomId: ${widget.roomId ?? ''}',
      'Curriculum: ${widget.curriculum}',
      'Language: ${widget.language}',
      'JoinFee: ${widget.joinFee}',
      'StartedAt: ${startedAt.toIso8601String()}',
      'EndedAt: ${endedAt.toIso8601String()}',
      'DurationSeconds: ${endedAt.difference(startedAt).inSeconds}',
      'PinnedMaterial: $_currentlyPinnedTitle',
    ].join('\n');
    final fileName =
        'lucy_live_recording_${endedAt.millisecondsSinceEpoch}.txt';
    await downloadBytes(
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(summary)),
      mimeType: 'text/plain',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Da luu ban ghi local: $fileName')),
      );
    }
  }

  Widget _buildMicButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            final nextMuted = !_isMuted;
            setState(() {
              _isMuted = nextMuted;
            });
            final mentorId = AppSession.current?.userId;
            if (mentorId != null &&
                mentorId.isNotEmpty &&
                widget.roomId != null) {
              try {
                await _realtimeSocket.toggleMic(
                  roomId: widget.roomId!,
                  userId: mentorId,
                  enabled: !nextMuted,
                  displayName: AppSession.current?.fullName,
                );
                await _agoraAudio.setMicrophoneEnabled(!nextMuted);
                if (mounted) {
                  setState(() {
                    _isAgoraConnected = true;
                    _agoraError = null;
                  });
                }
              } catch (error) {
                if (mounted) {
                  setState(() {
                    _isMuted = !nextMuted;
                    _agoraError = '$error';
                  });
                }
                return;
              }
            }
            messenger.showSnackBar(
              SnackBar(
                content: Text(_isMuted
                    ? '🎤 Đã tắt tiếng Micro!'
                    : '🎤 Đã bật tiếng Micro!'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isMuted ? Colors.red.shade400 : AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: (_isMuted ? Colors.red : AppColors.primary)
                        .withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]),
            child: Icon(
              _isMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isMuted ? "Đã Tắt Mic" : "Mic Đang Bật",
          style: TextStyle(
            color: _isMuted ? Colors.red.shade600 : AppColors.textPrimary,
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
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      color: AppColors.textSecondary, size: 16),
                  SizedBox(width: 6),
                  Text("BÌNH LUẬN HỌC VIÊN",
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("$_participantCount Đang Nghe",
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
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
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.15)),
                    ),
                    child: Text(
                      msg['text']!,
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 9.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600),
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
                        child: Text(msg['avatar']!,
                            style: const TextStyle(fontSize: 10)),
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
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  msg['time']!,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 8.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.inputBorder),
                              ),
                              child: Text(
                                msg['text']!,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 11,
                                    height: 1.3),
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
          const Divider(height: 1, color: AppColors.inputBorder),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mentorChatInputController,
                    minLines: 1,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Nhắn tin cho học viên...',
                      hintStyle: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            const BorderSide(color: AppColors.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            const BorderSide(color: AppColors.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textPrimary),
                    onSubmitted: (_) => _sendMentorChat(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMentorChat,
                  icon: const Icon(Icons.send, size: 16),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  tooltip: 'Gửi tin nhắn',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioSlideSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "GHIM TÀI LIỆU KHÁC LÊN SLIDE CHIẾU 📌",
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8),
            ),
            TextButton.icon(
              onPressed: _pickAndPinLiveMaterial,
              icon: const Icon(Icons.attach_file, size: 14),
              label: const Text(
                'Chọn tài liệu',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (widget.curriculumDocs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: const Text(
              'Chưa có tài liệu. Bấm "Chọn tài liệu" để ghim file từ máy local.',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.curriculumDocs.length,
              itemBuilder: (context, index) {
                final doc = widget.curriculumDocs[index];
                final title = doc['title'] as String;
                bool isActive = _currentlyPinnedTitle == title;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentlyPinnedTitle = title;
                      for (final item in widget.curriculumDocs) {
                        item['isPinned'] = false;
                      }
                      doc['isPinned'] = true;
                    });
                    _pinDocumentToRoom(doc);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("📌 Đã chiếu Slide: $title"),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.inputBorder,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description,
                                color: doc['color'] as Color, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            isActive ? "ĐANG CHIẾU" : "ẤN ĐỂ CHIẾU",
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Custom Painter for audio visualizer waveforms in dark admin room
class AudioWaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isMuted;

  AudioWaveformPainter(
      {required this.animationValue,
      required this.color,
      this.isMuted = false});

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
      // Generate waving motion
      final pulse = isMuted
          ? 0.0
          : math.sin(animationValue * 2 * math.pi + i * 0.8) * 0.35;
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
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.isMuted != isMuted;
  }
}
