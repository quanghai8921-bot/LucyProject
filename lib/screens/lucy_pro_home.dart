import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucy_app/theme/app_colors.dart';

class LucyProHome extends StatefulWidget {
  const LucyProHome({super.key});

  @override
  State<LucyProHome> createState() => _LucyProHomeState();
}

class _LucyProHomeState extends State<LucyProHome> {
  // Mock balance and stats (mutable for realistic dynamic updates)
  double _totalEarnings = 4280.50;
  int _giftsReceived = 128;
  int _weeklyRank = 4;

  // Stateful LMS curriculum documents list
  final List<Map<String, dynamic>> _curriculumDocs = [
    {
      'id': 'doc1',
      'title': 'LISA Level 3: Coffee Shop Conversations ☕',
      'category': 'LISA Core',
      'isPinned': true,
      'status': 'Đã duyệt',
      'color': const Color(0xFF64C3A5),
    },
    {
      'id': 'doc2',
      'title': 'HSK 2: Job Interview & Office Vocabulary 💼',
      'category': 'Chinese Standard',
      'isPinned': false,
      'status': 'Đã duyệt',
      'color': Colors.orange.shade300,
    },
    {
      'id': 'doc3',
      'title': 'JLPT N4: Keigo - Polite Japanese in Business 🙇',
      'category': 'Japanese Prep',
      'isPinned': false,
      'status': 'Đang chờ duyệt',
      'color': Colors.purple.shade200,
    },
  ];

  // Stateful Student Progress List
  final List<Map<String, dynamic>> _studentsProgress = [
    {'id': 'std1', 'name': 'Phạm Văn Minh', 'level': 'Lvl 4', 'progress': 0.80, 'avatar': '👦'},
    {'id': 'std2', 'name': 'Mina Nguyễn', 'level': 'Lvl 5', 'progress': 0.95, 'avatar': '👩'},
    {'id': 'std3', 'name': 'John Doe', 'level': 'Lvl 2', 'progress': 0.30, 'avatar': '👱'},
    {'id': 'std4', 'name': 'Kenji Sato', 'level': 'Lvl 3', 'progress': 0.65, 'avatar': '👨'},
  ];

  // Stateful storage for teacher notes (keyed by student id)
  final Map<String, String> _studentNotes = {
    'std1': 'Phát âm tốt, cần thêm tự tin nói trước đám đông.',
    'std2': 'Cực kỳ năng nổ trong các chủ đề Cafe. Gần đạt điều kiện thăng cấp.',
    'std3': 'Cần ôn tập từ vựng chủ đề gia đình.',
    'std4': 'Nắm chắc ngữ pháp, phản xạ hơi chậm nhưng rất chuẩn xác.',
  };

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

        // 4. Student Learning Progress Dashboard
        _buildStudentProgressSection(),
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
                    const Text(
                      "Alex Rivera",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                          "98% Uy tín (Lvl 12)",
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
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.wallet, color: AppColors.primaryDark, size: 14),
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
                        "\$${_totalEarnings.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.orange.shade400,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$_giftsReceived Quà tặng học viên",
                        style: const TextStyle(
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
                    border: Border.all(color: Colors.amber.shade200.withOpacity(0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 14),
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
                        "Top #$_weeklyRank",
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Đứng đầu Bảng tuần",
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
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
            double roomDuration = 60.0;
            bool isAiModeratorEnabled = true;

            return StatefulBuilder(builder: (context, setInnerState) {
              return Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
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
                        Icon(Icons.video_call_outlined, color: AppColors.primary, size: 28),
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
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 20),

                    // 1. Language selector chips
                    const Text(
                      "Ngôn ngữ giảng dạy:",
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Anh', 'Trung', 'Nhật'].map((lang) {
                        bool isCurrent = selectedLang == lang;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: ChoiceChip(
                            label: Text(
                              lang == 'Anh' ? '🇬🇧 Tiếng Anh' : lang == 'Trung' ? '🇨🇳 Tiếng Trung' : '🇯🇵 Tiếng Nhật',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : AppColors.textPrimary,
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
                                color: isCurrent ? AppColors.primary : AppColors.inputBorder,
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
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text("LISA Core Curriculum (Học cùng Robot AI)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          value: 'LISA',
                          groupValue: selectedCurriculum,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setInnerState(() => selectedCurriculum = val!),
                        ),
                        RadioListTile<String>(
                          title: const Text("Chinese Standard Course (HSK Tương Tác)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          value: 'Chinese',
                          groupValue: selectedCurriculum,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setInnerState(() => selectedCurriculum = val!),
                        ),
                        RadioListTile<String>(
                          title: const Text("JLPT Preparation Standard (Giáo trình tiếng Nhật)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          value: 'Japanese',
                          groupValue: selectedCurriculum,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setInnerState(() => selectedCurriculum = val!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. Duration slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Thời lượng buổi Live:",
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${roomDuration.toInt()} phút",
                          style: const TextStyle(color: AppColors.primaryDark, fontSize: 14, fontWeight: FontWeight.bold),
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
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      subtitle: const Text(
                        "Gợi ý câu hỏi thảo luận lên màn hình của Moderator dựa trên tài liệu ghim sẵn.",
                        style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
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

                    // Confirm button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close BottomSheet
                        _showLiveStudioRoomSimulation(
                          language: selectedLang,
                          curriculum: selectedCurriculum,
                          duration: roomDuration.toInt(),
                          aiEnabled: isAiModeratorEnabled,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("XÁC NHẬN & MỞ PHÒNG LIVE", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }

  void _showLiveStudioRoomSimulation({
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
              onPressed: _showAddLmsDocumentDialog,
              child: const Row(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text("Tải lên .docx", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _curriculumDocs.length,
          itemBuilder: (context, index) {
            final doc = _curriculumDocs[index];
            bool isPinned = doc['isPinned'] as bool;
            Color accentColor = doc['color'] as Color;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isPinned ? AppColors.primary : AppColors.inputBorder, width: isPinned ? 1.5 : 1),
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
                    child: Icon(Icons.description, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 14),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['title'] as String,
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
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.inputBorder.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                doc['category'] as String,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              doc['status'] as String,
                              style: TextStyle(
                                color: doc['status'] == 'Đã duyệt' ? Colors.green.shade600 : Colors.orange.shade600,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Pin/Ghim Action Button with Tooltips
                  IconButton(
                    onPressed: () {
                      setState(() {
                        // Toggle this one, but turn off others to simulate a single active pinned slide
                        final nextState = !isPinned;
                        for (var d in _curriculumDocs) {
                          d['isPinned'] = false;
                        }
                        doc['isPinned'] = nextState;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(!isPinned ? '📌 Đã ghim tài liệu thành công vào buổi Live!' : '📌 Đã gỡ ghim tài liệu!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(
                      isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: isPinned ? AppColors.primary : AppColors.textSecondary,
                    ),
                    tooltip: isPinned ? 'Gỡ ghim' : 'Ghim vào buổi Live',
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

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.upload_file, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text("Tải Lên Tài Liệu .docx", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Nhập tiêu đề giáo trình tài liệu của bạn:", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "Ví dụ: LISA Level 4: At the Hotel Lobby 🏨",
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  const Text("Phân hệ giáo trình học:", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: ['LISA Core', 'Chinese Standard', 'Japanese Prep'].map((cat) {
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("HỦY", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
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
                      });
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("📄 Đã tải lên tài liệu mới thành công và đang đợi phê duyệt!"),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("TẢI LÊN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
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
              Icon(Icons.assignment_ind_outlined, color: AppColors.primary, size: 20),
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
              _buildProgressMetricCol("Học viên", "${_studentsProgress.length} hoạt động"),
              _buildProgressMetricCol("Hoàn thành", "84.5%"),
              _buildProgressMetricCol("Điểm thi Avg", "92/100"),
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
                          child: Text(student['avatar'] as String, style: const TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 12),

                        // Info Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  backgroundColor: AppColors.inputBorder.withOpacity(0.6),
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
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
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
    final notesController = TextEditingController(text: _studentNotes[sId] ?? '');

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
            final currentLvlNum = int.parse(currentLevelStr.replaceAll('Lvl ', ''));
            final progress = student['progress'] as double;

            return StatefulBuilder(builder: (context, setInnerSheetState) {
              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
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
                              backgroundColor: AppColors.primary.withOpacity(0.12),
                              child: Text(student['avatar'] as String, style: const TextStyle(fontSize: 26)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name'] as String,
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          student['level'] as String,
                                          style: const TextStyle(color: AppColors.primaryDark, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Tiến trình khóa học: ${(progress * 100).toInt()}%",
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
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
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Timeline steps
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            final stepLvl = index + 1;
                            final isCompleted = stepLvl < currentLvlNum || (stepLvl == currentLvlNum && progress >= 1.0);
                            final isCurrent = stepLvl == currentLvlNum && progress < 1.0;

                            return Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 3,
                                          color: index == 0 ? Colors.transparent : isCompleted ? AppColors.primary : AppColors.inputBorder,
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
                                              ? const Icon(Icons.check, size: 12, color: Colors.white)
                                              : Text(
                                                  "$stepLvl",
                                                  style: TextStyle(
                                                    color: isCurrent ? Colors.white : AppColors.textSecondary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 3,
                                          color: index == 4 ? Colors.transparent : isCompleted && (index + 2 <= currentLvlNum) ? AppColors.primary : AppColors.inputBorder,
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
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: notesController,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: "Viết nhận xét lộ trình, điểm yếu cần khắc phục...",
                            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                            fillColor: Colors.grey.shade50,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.inputBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.primary),
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
                                  content: Text("📝 Đã cập nhật ghi chú học viên thành công!"),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary.withOpacity(0.12),
                              foregroundColor: AppColors.primaryDark,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text("LƯU GHI CHÚ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
                                  student['progress'] = 0.15; // Reset progress for next level
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("🎉 Chúc mừng! Đã thăng cấp cho học viên lên Lvl ${currentLvlNum + 1}!"),
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
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade600,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                                      style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Chúc mừng học viên ${student['name']}\nĐược thăng cấp lên Lvl ${currentLvlNum + 1}!",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
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
  final String language;
  final String curriculum;
  final int duration;
  final bool aiEnabled;
  final List<Map<String, dynamic>> curriculumDocs;

  const LiveStudioRoomDialog({
    required this.language,
    required this.curriculum,
    required this.duration,
    required this.aiEnabled,
    required this.curriculumDocs,
  });

  @override
  State<LiveStudioRoomDialog> createState() => LiveStudioRoomDialogState();
}

class LiveStudioRoomDialogState extends State<LiveStudioRoomDialog> with TickerProviderStateMixin {
  int _secondsElapsed = 0;
  Timer? _stopwatchTimer;
  Timer? _chatTimer;

  bool _isMuted = false;
  String _currentlyPinnedTitle = 'Chưa chọn slide nào';

  int _promptIndex = 0;
  final List<String> _aiPrompts = [
    "Hãy mô tả hoạt động cuối tuần yêu thích nhất của bạn tại quán Cafe bằng tiếng nước ngoài?",
    "Roleplay: Đặt một cốc trà sữa và hỏi giảm đường, đá bằng tiếng nước bản địa?",
    "Gen Z Slang Challenge: Sử dụng từ lóng vừa học để miêu tả một bộ phim bạn thích nhất?",
    "Survival Speaking: Hỏi đường đi đến nhà ga gần nhất trong tình huống điện thoại hết pin?",
    "Business Talk: Giới thiệu ngắn gọn bản thân và 3 thế mạnh lớn nhất của bạn trong buổi phỏng vấn?",
  ];

  final List<Map<String, String>> _allMockChatTemplates = [
    {'name': 'Minh Phạm', 'avatar': '👦', 'text': 'Chào thầy Alex Rivera ạ! 🤩'},
    {'name': 'Mina Nguyễn', 'avatar': '👩', 'text': 'Giáo trình LISA gợi ý câu này hay và tự nhiên quá!'},
    {'name': 'John Doe', 'avatar': '👱', 'text': 'Agora stream tiếng rõ mượt lắm thầy ơi 🎤'},
    {'name': 'Kenji Sato', 'avatar': '👨', 'text': 'Em mới dùng thử tính năng Gen Z Slang này, cuốn thật sự'},
    {'name': 'Lyly Lê', 'avatar': '👧', 'text': 'Thầy giải thích chỗ Keigo dễ hiểu hơn trên lớp nhiều'},
    {'name': 'Duy Nguyễn', 'avatar': '👦', 'text': 'Vibe phòng học chill ghê, không bị áp lực nói sai'},
    {'name': 'Emma Watson', 'avatar': '👱‍♀️', 'text': 'Robot LISA sửa phát âm chuẩn đét luôn!'},
    {'name': 'Yuki Chan', 'avatar': '👩‍🦰', 'text': 'Học kiểu roleplay thế này vui hơn nhiều!'},
    {'name': 'Leo Baker', 'avatar': '👨‍🦱', 'text': 'Đã share phòng cho mấy đứa bạn học cùng, mượt ghê!'},
  ];

  final List<Map<String, String>> _chatMessages = [];
  final ScrollController _chatScrollController = ScrollController();
  late AnimationController _waveformController;

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

    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _chatTimer?.cancel();
    _chatScrollController.dispose();
    _waveformController.dispose();
    super.dispose();
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
      'text': 'Phòng Live Audio đã khởi tạo thành công trên Agora RTC. Đang đợi học viên tham gia...',
      'time': 'Vừa xong',
      'isSystem': 'true'
    });

    _chatTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (mounted) {
        final random = math.Random();
        final template = _allMockChatTemplates[random.nextInt(_allMockChatTemplates.length)];
        setState(() {
          _chatMessages.add({
            'name': template['name']!,
            'avatar': template['avatar']!,
            'text': template['text']!,
            'time': _formatCurrentTime(),
            'isSystem': 'false'
          });
        });

        // Scroll to bottom smoothly
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      children: [
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
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Text(
                "LIVE ACTIVE",
                style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8),
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
                  title: const Text("Kết Thúc Buổi Live?", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  content: const Text("Bạn có thực sự muốn đóng phòng dạy học audio và trả lại học viên về trang chủ?", style: TextStyle(color: AppColors.textSecondary)),
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
                      onPressed: () {
                        Navigator.pop(ctx); // Close dialog
                        Navigator.pop(context); // Exit full screen studio
                      },
                      child: const Text("KẾT THÚC", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8),
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
                  widget.language == 'Anh' ? "🇬🇧 English" : widget.language == 'Trung' ? "🇨🇳 Chinese" : "🇯🇵 Japanese",
                  style: const TextStyle(color: AppColors.primaryDark, fontSize: 9, fontWeight: FontWeight.bold),
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
          const Text(
            "Học viên sẽ nghe thấy giọng nói của bạn kết hợp với nội dung slide này.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
          ),
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
                      color: _isMuted ? Colors.red.shade400.withOpacity(0.5) : AppColors.primary,
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

        // AI Suggestion Box
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.shade200.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "AI MODERATOR PROMPT",
                          style: TextStyle(color: Colors.purpleAccent, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    if (widget.aiEnabled)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _promptIndex = (_promptIndex + 1) % _aiPrompts.length;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text("Tải gợi ý", style: TextStyle(color: Colors.purple.shade700, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.aiEnabled ? "\"${_aiPrompts[_promptIndex]}\"" : "\"Trợ lý ảo AI đang tắt trong buổi Live này\"",
                  style: TextStyle(
                    color: widget.aiEnabled ? AppColors.textPrimary : AppColors.textSecondary,
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

  Widget _buildMicButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isMuted = !_isMuted;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isMuted ? '🎤 Đã tắt tiếng Micro!' : '🎤 Đã bật tiếng Micro!'),
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
                  color: (_isMuted ? Colors.red : AppColors.primary).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
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
      height: 240,
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
                  Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary, size: 16),
                  SizedBox(width: 6),
                  Text("BÌNH LUẬN HỌC VIÊN", style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("12 Đang Nghe", style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }

  Widget _buildStudioSlideSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "GHIM TÀI LIỆU KHÁC LÊN SLIDE CHIẾU 📌",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),
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
                  });
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
                    color: isActive ? AppColors.primary.withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.inputBorder,
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
                          Icon(Icons.description, color: doc['color'] as Color, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
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
                            color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
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

  AudioWaveformPainter({required this.animationValue, required this.color});

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
      final pulse = math.sin(animationValue * 2 * math.pi + i * 0.8) * 0.35;
      final currentHeight = baseHeight * (1.0 + pulse);
      
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
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}
