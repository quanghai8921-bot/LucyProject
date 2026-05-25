import 'package:flutter/material.dart';
import 'package:lucy_app/theme/app_colors.dart';
import 'package:lucy_app/screens/lucy_pro_home.dart'; // To leverage LiveStudioRoomDialog

class LucySuperHome extends StatefulWidget {
  const LucySuperHome({super.key});

  @override
  State<LucySuperHome> createState() => _LucySuperHomeState();
}

class _LucySuperHomeState extends State<LucySuperHome> {
  // Mock data for recorded Podcasts (mutable for realistic prototype updates)
  final List<Map<String, dynamic>> _podcasts = [
    {
      'id': 'pod1',
      'title': 'Digital Nomads: Ep. 42 • Remote work tips 💻',
      'views': '14.2k listens',
      'price': 0.0, // Free
      'status': 'Nháp',
      'color': const Color(0xFF64C3A5),
    },
    {
      'id': 'pod2',
      'title': 'The Future of AI in Art: ChatGPT & Midjourney 🎨',
      'views': '8.9k listens',
      'price': 5.0, // Premium $5.00
      'status': 'Đã xuất bản',
      'color': const Color(0xFF6366F1),
    },
    {
      'id': 'pod3',
      'title': 'Business Negotiations in Mandarin: Ep. 11 🇨🇳',
      'views': '4.5k listens',
      'price': 12.0, // Premium $12.00
      'status': 'Nháp',
      'color': Colors.orange.shade300,
    },
  ];

  // Stateful Premium Content Series List
  final List<Map<String, dynamic>> _premiumSeries = [
    {
      'title': 'Gen Z Slang Mastery Course 💬',
      'episodes': 12,
      'price': 49.00,
      'students': 128,
    },
    {
      'title': 'Advanced HSK Speaking Blueprint 🇨🇳',
      'episodes': 18,
      'price': 79.00,
      'students': 85,
    },
  ];

  // Simple mock LMS curriculum documents to pass to the Live Studio Dialog
  final List<Map<String, dynamic>> _mockCurriculumDocs = [
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
      'title': 'JLPT N4: Keigo - Polite Japanese in Business 🙇',
      'category': 'Japanese Prep',
      'isPinned': false,
      'status': 'Đã duyệt',
      'color': Colors.purple.shade200,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Creator Header and Community Growth Chart
        _buildCreatorAnalyticsSection(),
        const SizedBox(height: 24),

        // 2. Inherited Action: Create Live Room (Tận dụng Dialog từ Pro)
        _buildInheritedActions(),
        const SizedBox(height: 24),

        // 3. PodcastStudioWidget (Horizontal List View & Management)
        const Text(
          "Studio Podcast sáng tạo 🎙️",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        PodcastStudioWidget(
          podcasts: _podcasts,
          onUpdate: () => setState(() {}),
        ),
        const SizedBox(height: 24),

        // 4. PremiumContentWidget (Premium Content Space & Revenue Stats)
        const Text(
          "Chuỗi nội dung thu phí (Premium Content) 🚀",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        PremiumContentWidget(
          premiumSeries: _premiumSeries,
          onAddSeries: _showAddPremiumSeriesDialog,
          onUpdate: () => setState(() {}),
        ),
      ],
    );
  }

  // ==========================================
  // CREATOR ANALYTICS HEADER W/ CUSTOM CHART
  // ==========================================
  Widget _buildCreatorAnalyticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
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
          const Text(
            "CỘNG ĐỒNG PHÁT TRIỂN TUẦN NÀY",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "+12.5k học viên mới",
                style: TextStyle(
                  color: Colors.teal.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Super Creator Tier ✪",
                  style: TextStyle(color: AppColors.primaryDark, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bezier Chart
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: SuperBezierPainter(
                curveColor: AppColors.primary,
                fillGradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.25), AppColors.primary.withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // INHERITED ACTION BUTTONS (CREATES ROOM USING PRO STUDIO DIALOG)
  // ==========================================
  Widget _buildInheritedActions() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Phát sóng dạy học Live",
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                Text(
                  "Tận dụng toàn bộ công cụ LMS của Mentor Pro",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showCreateLiveRoomBottomSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Mở Live", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
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
          curriculumDocs: _mockCurriculumDocs,
        );
      },
    );
  }

  void _showAddPremiumSeriesDialog() {
    final titleController = TextEditingController();
    final episodesController = TextEditingController(text: '10');
    final priceController = TextEditingController(text: '49.00');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.rocket_launch, color: AppColors.primary),
              SizedBox(width: 8),
              Text("Tạo Chuỗi Premium Mới", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Tiêu đề chuỗi bài học cao cấp:", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Ví dụ: Master Business Japanese Series 🇯🇵",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Số tập dự kiến:", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: episodesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Mức phí trọn gói (\$):", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
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

                setState(() {
                  _premiumSeries.insert(0, {
                    'title': titleController.text.trim(),
                    'episodes': int.tryParse(episodesController.text) ?? 10,
                    'price': double.tryParse(priceController.text) ?? 49.00,
                    'students': 0,
                  });
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("🚀 Đã khởi tạo chuỗi bài học cao cấp thành công!"),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("TẠO CHUỖI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

// ==========================================
// CUSTOM WIDGET 1: PODCASTSTUDIOWIDGET (HORIZONTAL LISTVIEW)
// ==========================================
class PodcastStudioWidget extends StatelessWidget {
  final List<Map<String, dynamic>> podcasts;
  final VoidCallback onUpdate;

  const PodcastStudioWidget({
    super.key,
    required this.podcasts,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: podcasts.length,
        itemBuilder: (context, index) {
          final pod = podcasts[index];
          double price = pod['price'] as double;
          String status = pod['status'] as String;
          Color accentColor = pod['color'] as Color;

          return ValueListenableBuilder<String>(
            valueListenable: SharedAudioState.currentTitle,
            key: ValueKey(pod['id']),
            builder: (context, playingTitle, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: SharedAudioState.isPlaying,
                builder: (context, isPlaying, _) {
                  bool isThisPlaying = (playingTitle == pod['title']) && isPlaying;

                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16, bottom: 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isThisPlaying
                            ? AppColors.primary
                            : status == 'Đã xuất bản'
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.inputBorder,
                        width: isThisPlaying ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isThisPlaying ? AppColors.primary.withOpacity(0.08) : Colors.black.withOpacity(0.01),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Podcast Icon, status & views
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.mic, color: accentColor, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    pod['views'] as String,
                                    style: TextStyle(color: accentColor.darken(0.15), fontSize: 9.5, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                // Inline Interactive Play/Pause Button syncing with bottom player
                                GestureDetector(
                                  onTap: () {
                                    if (isThisPlaying) {
                                      SharedAudioState.isPlaying.value = false;
                                    } else {
                                      SharedAudioState.currentTitle.value = pod['title'] as String;
                                      SharedAudioState.isPlaying.value = true;
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: isThisPlaying ? Colors.red.shade400 : AppColors.primary,
                                    child: Icon(
                                      isThisPlaying ? Icons.pause : Icons.play_arrow,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'Đã xuất bản' ? Colors.green.shade50 : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: status == 'Đã xuất bản' ? Colors.green.shade700 : Colors.orange.shade700,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Title
                        Text(
                          pod['title'] as String,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Pricing Info tag
                        Row(
                          children: [
                            const Icon(Icons.local_offer_outlined, color: AppColors.textSecondary, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              price == 0.0 ? "Miễn phí" : "Premium: \$${price.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: price == 0.0 ? AppColors.textSecondary : Colors.deepOrange.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Management Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Edit Button
                            _buildMiniActionBtn(
                              label: "Sửa",
                              icon: Icons.edit_outlined,
                              onTap: () => _showEditTitleDialog(context, pod),
                            ),
                            // Price setting button
                            _buildMiniActionBtn(
                              label: "Đặt phí",
                              icon: Icons.payments_outlined,
                              onTap: () => _showPricingSliderDialog(context, pod),
                            ),
                            // Publish toggle button
                            _buildMiniActionBtn(
                              label: status == 'Đã xuất bản' ? "Thu hồi" : "Công khai",
                              icon: status == 'Đã xuất bản' ? Icons.visibility_off_outlined : Icons.publish_outlined,
                              onTap: () {
                                status == 'Đã xuất bản' ? pod['status'] = 'Nháp' : pod['status'] = 'Đã xuất bản';
                                onUpdate();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(status == 'Đã xuất bản' ? '🔒 Đã chuyển Podcast về trạng thái Nháp!' : '🌐 Đã xuất bản công khai Podcast lên cộng đồng!'),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMiniActionBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textPrimary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTitleDialog(BuildContext context, Map<String, dynamic> pod) {
    final controller = TextEditingController(text: pod['title'] as String);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Chỉnh sửa tiêu đề Podcast", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: "Nhập tiêu đề...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              pod['title'] = controller.text;
              onUpdate();
              Navigator.pop(context);
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPricingSliderDialog(BuildContext context, Map<String, dynamic> pod) {
    double tempPrice = pod['price'] as double;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Cài đặt phí Premium", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tempPrice == 0.0 ? "Miễn phí" : "\$${tempPrice.toStringAsFixed(2)} USD",
                style: TextStyle(color: tempPrice == 0.0 ? AppColors.textSecondary : Colors.deepOrange.shade600, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Slider(
                value: tempPrice,
                min: 0,
                max: 30,
                divisions: 6,
                activeColor: Colors.deepOrange.shade500,
                onChanged: (val) {
                  setDialogState(() {
                    tempPrice = val;
                  });
                },
              ),
              const Text("Học viên cần thanh toán bằng Credit/Ví điện tử để nghe lại tập Premium này.", style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                pod['price'] = tempPrice;
                onUpdate();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tempPrice == 0.0 ? '🔓 Podcast đã được đặt về Miễn phí!' : '💰 Đã đặt phí Podcast: \$${tempPrice.toStringAsFixed(2)} thành công!'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("Cài đặt", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM WIDGET 2: PREMIUMCONTENTWIDGET (REVENUE SPACE & PAID STATS)
// ==========================================
class PremiumContentWidget extends StatelessWidget {
  final List<Map<String, dynamic>> premiumSeries;
  final VoidCallback onAddSeries;
  final VoidCallback onUpdate;

  const PremiumContentWidget({
    super.key,
    required this.premiumSeries,
    required this.onAddSeries,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header of space
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "🌟 DOANH THU PREMIUM",
                  style: TextStyle(
                    color: Colors.deepOrange.shade700,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Phân tích Doanh thu khóa học & Series 📈",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Analytical stats grid (Now Clickable to show bar chart dialog!)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showRevenueChartDialog(context, "Doanh thu Tổng"),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: _buildRevenueMetricCard("Doanh thu Tổng", "\$12,450.00", Colors.orange.shade600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showRevenueChartDialog(context, "Học viên Trả phí"),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: _buildRevenueMetricCard("Học viên Trả phí", "450 Students", Colors.teal.shade600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showRevenueChartDialog(context, "Tỷ lệ C.Rate"),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: _buildRevenueMetricCard("Tỷ lệ C.Rate", "6.4% C.Rate", Colors.deepPurple.shade600),
                  ),
                ),
              ),
            ],
          ),
          
          // Render Premium Series list dynamically
          _buildPremiumSeriesList(),

          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.inputBorder),
          const SizedBox(height: 20),

          // Paid Course actions CTA
          const Text(
            "Sáng tạo Chuỗi Premium Series mới 🚀",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Tạo nội dung giảng dạy chuyên sâu dưới dạng chuỗi bài podcast có thu phí trọn gói.",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAddSeries,
            icon: const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
            label: const Text("TẠO CHUỖI BÀI HỌC CAO CẤP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Xem chi tiết", style: TextStyle(color: Colors.grey, fontSize: 7.5, fontWeight: FontWeight.bold)),
              Icon(Icons.chevron_right, size: 8, color: Colors.grey),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPremiumSeriesList() {
    if (premiumSeries.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Chuỗi Premium Đang Hoạt Động 🏷️",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: premiumSeries.length,
            itemBuilder: (context, index) {
              final series = premiumSeries[index];
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.inputBorder.withOpacity(0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      series['title'] as String,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${series['episodes']} tập • ${series['students']} học viên",
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "\$${(series['price'] as double).toStringAsFixed(2)}",
                          style: TextStyle(color: Colors.deepOrange.shade600, fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showRevenueChartDialog(BuildContext context, String metricTitle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.bar_chart, color: AppColors.primary),
              const SizedBox(width: 8),
              Text("Biểu đồ $metricTitle", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Container(
            width: 320,
            height: 240,
            padding: const EdgeInsets.only(top: 20),
            child: CustomPaint(
              painter: RevenueBarChartPainter(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ĐÓNG", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

// ==========================================
// CUSTOM MONTHLY REVENUE BAR CHART PAINTER
// ==========================================
class RevenueBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBar = Paint()..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;

    final labelStyle = TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.bold);
    const valueStyle = TextStyle(color: AppColors.textPrimary, fontSize: 8.5, fontWeight: FontWeight.w900);

    final List<double> data = [1200, 1800, 2400, 3100, 3800, 4280];
    final List<String> months = ['Th 1', 'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6'];
    const maxVal = 5000.0;

    // Draw horizontal grid lines
    for (int i = 1; i <= 4; i++) {
      final y = size.height * (1 - i / 4) * 0.85;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final barWidth = size.width / (data.length * 1.6);
    final gap = barWidth * 0.6;

    for (int i = 0; i < data.length; i++) {
      final pct = data[i] / maxVal;
      final barHeight = size.height * pct * 0.8;

      final x = i * (barWidth + gap) + gap / 2;
      final y = size.height * 0.85 - barHeight;

      // Render vertical gradient fill for premium look
      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final gradient = const LinearGradient(
        colors: [AppColors.primary, Color(0xFF6366F1)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );
      paintBar.shader = gradient.createShader(rect);

      // Draw beautiful rounded bar chart card
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      canvas.drawRRect(rrect, paintBar);

      // Draw monthly label below bar
      final textPainterMonth = TextPainter(
        text: TextSpan(text: months[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterMonth.paint(canvas, Offset(x + (barWidth - textPainterMonth.width) / 2, size.height * 0.88));

      // Draw value tag directly above the bar
      final textPainterVal = TextPainter(
        text: TextSpan(text: '\$${data[i].toInt()}', style: valueStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterVal.paint(canvas, Offset(x + (barWidth - textPainterVal.width) / 2, y - 13));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// CUSTOM BEZIER PAINTER FOR RECONSTRUCTING COMMUNITY GROWTH
// ==========================================
class SuperBezierPainter extends CustomPainter {
  final Color curveColor;
  final Gradient fillGradient;

  SuperBezierPainter({required this.curveColor, required this.fillGradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = curveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final pathLine = Path();
    
    // Wave drawing
    pathLine.moveTo(0, size.height * 0.7);
    pathLine.cubicTo(
      size.width * 0.2, size.height * 0.75,
      size.width * 0.35, size.height * 0.95,
      size.width * 0.5, size.height * 0.4,
    );
    pathLine.cubicTo(
      size.width * 0.65, size.height * 0.05,
      size.width * 0.8, size.height * 0.85,
      size.width * 0.9, size.height * 0.7,
    );
    pathLine.cubicTo(
      size.width * 0.95, size.height * 0.65,
      size.width * 0.98, size.height * 0.35,
      size.width, size.height * 0.3,
    );

    // Path fill
    final pathFill = Path.from(pathLine);
    pathFill.lineTo(size.width, size.height);
    pathFill.lineTo(0, size.height);
    pathFill.close();

    final paintFill = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(pathFill, paintFill);
    canvas.drawPath(pathLine, paintLine);

    // Accent dot
    final dotPaint = Paint()..color = curveColor;
    final dotStrokePaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.72), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.72), 5, dotStrokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
