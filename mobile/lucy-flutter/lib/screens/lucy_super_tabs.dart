import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/theme/app_colors.dart';

// =========================================================================
// 1. EXPLORE TAB - LUCY SUPER
// =========================================================================
class LucySuperExplore extends StatefulWidget {
  const LucySuperExplore({super.key});

  @override
  State<LucySuperExplore> createState() => _LucySuperExploreState();
}

class _LucySuperExploreState extends State<LucySuperExplore> {
  final Set<String> _appliedCampaigns = {};

  final List<Map<String, String>> _trends = [
    {'keyword': 'Gen Z Slang Challenge 💬', 'growth': '+42%', 'demand': 'High Demand'},
    {'keyword': 'Keigo Business Ethics 🙇', 'growth': '+28%', 'demand': 'Medium Demand'},
    {'keyword': 'HSK 4 Job Interview 💼', 'growth': '+35%', 'demand': 'High Demand'},
  ];

  final List<Map<String, String>> _campaigns = [
    {'id': 'c1', 'brand': 'ELSA Speak Sponsor 🎙️', 'budget': '\$500 - \$1,500', 'status': 'Đang tuyển'},
    {'id': 'c2', 'brand': 'Duolingo Brand Ambassador 🦉', 'budget': '\$1,200 - \$3,000', 'status': 'Đang tuyển'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          "Trung Tâm Xu Hướng & Tài Trợ 🌍",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Phân tích từ khóa học tập hot nhất để định hướng nội dung và nhận hợp đồng tài trợ từ đối tác.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // 1. Trending Keywords
        _buildTrendingKeywordsSection(),
        const SizedBox(height: 24),

        // 2. Sponsor Matching Board
        _buildSponsorMatchingSection(),
      ],
    );
  }

  Widget _buildTrendingKeywordsSection() {
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
          const Text(
            "TỪ KHÓA ĐANG HOT TRONG CỘNG ĐỒNG 💬",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _trends.length,
            itemBuilder: (context, index) {
              final trend = _trends[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(trend['keyword']!, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12.5)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(trend['growth']!, style: TextStyle(color: Colors.green.shade700, fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(trend['demand']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorMatchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cơ Hội Hợp Tác Tài Trợ (Sponsorship) 🤝",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _campaigns.length,
          itemBuilder: (context, index) {
            final campaign = _campaigns[index];
            final cId = campaign['id']!;
            bool isApplied = _appliedCampaigns.contains(cId);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Icon(Icons.handshake_outlined, color: Color(0xFF6366F1))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(campaign['brand']!, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12.5)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(campaign['budget']!, style: TextStyle(color: Colors.deepOrange.shade600, fontSize: 9.5, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(campaign['status']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isApplied) {
                          _appliedCampaigns.remove(cId);
                        } else {
                          _appliedCampaigns.add(cId);
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isApplied ? '🔓 Đã rút hồ sơ nộp tài trợ.' : '✅ Đã nộp hồ sơ xin tài trợ thành công!'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApplied ? Colors.grey.shade100 : const Color(0xFF6366F1).withOpacity(0.12),
                      foregroundColor: isApplied ? Colors.grey : const Color(0xFF6366F1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: Text(isApplied ? "ĐÃ NỘP" : "NỘP ĐƠN", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// =========================================================================
// 2. LIBRARY TAB - LUCY SUPER
// =========================================================================
class LucySuperLibrary extends StatefulWidget {
  const LucySuperLibrary({super.key});

  @override
  State<LucySuperLibrary> createState() => _LucySuperLibraryState();
}

class _LucySuperLibraryState extends State<LucySuperLibrary> {
  final List<Map<String, String>> _rawAudioFiles = [
    {'title': 'Live Audio: Coffee Shop Keigo 101', 'date': '2 ngày trước', 'duration': '45:10'},
    {'title': 'Live Audio: Business Mandarin Slangs', 'date': '5 ngày trước', 'duration': '62:30'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          "Kho Tài Nguyên & Lịch Xuất Bản 📁",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Xem các file ghi âm audio thô sẵn sàng dựng Podcast và lập lịch phát hành chuỗi bài học.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // 1. Raw audio vault
        const Text(
          "Ghi âm Live thô chờ dựng Podcast 🎙️",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rawAudioFiles.length,
          itemBuilder: (context, index) {
            final file = _rawAudioFiles[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.audio_file_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(file['title']!, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text("${file['duration']} • ${file['date']}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("⚡ Đang tạo dựng bản nháp Podcast từ: ${file['title']}"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: const Text("DỰNG PODCAST", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // 2. Publication schedule
        const Text(
          "Lịch xuất bản scheduled 📅",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Column(
            children: [
              _buildScheduleRow("Thứ Hai ➔", "Xuất bản Ep. 43 Remote work tips (Free)"),
              const Divider(height: 1),
              _buildScheduleRow("Thứ Năm ➔", "Xuất bản HSK 2 Office interview (Premium)"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleRow(String day, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Text(day, style: TextStyle(color: Colors.deepOrange.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// =========================================================================
// 3. PROFILE TAB - LUCY SUPER
// =========================================================================
class LucySuperProfile extends StatefulWidget {
  const LucySuperProfile({super.key});

  @override
  State<LucySuperProfile> createState() => _LucySuperProfileState();
}

class _LucySuperProfileState extends State<LucySuperProfile> {
  final priceController = TextEditingController(text: '49.00');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          "Hồ Sơ Nhà Sáng Tạo Cao Cấp ✪",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Quản lý số liệu fan subscribers, cơ cấu thu nhập và thiết lập mức giá mặc định.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // 1. Creator Hub statistics
        _buildCreatorHubCard(),
        const SizedBox(height: 24),

        // 2. Default package pricing manager
        _buildDefaultPricingCard(),
        const SizedBox(height: 24),

        // 3. Revenue Distribution custom chart
        _buildRevenueDistributionCard(),
      ],
    );
  }

  Widget _buildCreatorHubCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF6366F1),
                child: Text("S", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppSession.current?.fullName.trim().isNotEmpty == true ? AppSession.current!.fullName : 'Creator', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Creator", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHubMetric("0", "Người theo dõi"),
              _buildHubMetric("0", "Premium Series"),
              _buildHubMetric("Chưa có", "Đánh giá Avg"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHubMetric(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5)),
      ],
    );
  }

  Widget _buildDefaultPricingCard() {
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
          const Text("THIẾT LẬP MỨC GIÁ KHÓA HỌC MẶC ĐỊNH", style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          const Text("Giá mặc định khi khởi tạo một Premium Series mới:", style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      prefixText: "\$ ",
                      suffixText: "USD",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚙️ Đã lưu thiết lập giá trần khóa học thành công!"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(80, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("LƯU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueDistributionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "CƠ CẤU DOANH THU SUPER CREATOR",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: RevenueDistributionPainter(
                    colors: [const Color(0xFF6366F1), AppColors.primary, Colors.orange.shade300],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildPieLegendRow("Paid Series (65%)", const Color(0xFF6366F1)),
                    const SizedBox(height: 6),
                    _buildPieLegendRow("Podcasts (20%)", AppColors.primary),
                    const SizedBox(height: 6),
                    _buildPieLegendRow("Live Gifts (15%)", Colors.orange.shade300),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieLegendRow(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Custom Painter for Revenue Distribution Pie Chart
class RevenueDistributionPainter extends CustomPainter {
  final List<Color> colors;

  RevenueDistributionPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    // Draw Paid Series (65%)
    paint.color = colors[0];
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * 0.65, true, paint);

    // Draw Podcasts (20%)
    paint.color = colors[1];
    canvas.drawArc(rect, -math.pi / 2 + 2 * math.pi * 0.65, 2 * math.pi * 0.20, true, paint);

    // Draw Live Gifts (15%)
    paint.color = colors[2];
    canvas.drawArc(rect, -math.pi / 2 + 2 * math.pi * 0.85, 2 * math.pi * 0.15, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
