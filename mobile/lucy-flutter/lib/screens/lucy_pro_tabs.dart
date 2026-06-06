import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/theme/app_colors.dart';

// =========================================================================
// 1. EXPLORE TAB - LUCY PRO
// =========================================================================
class LucyProExplore extends StatefulWidget {
  const LucyProExplore({super.key});

  @override
  State<LucyProExplore> createState() => _LucyProExploreState();
}

class _LucyProExploreState extends State<LucyProExplore> {
  final List<Map<String, dynamic>> _topMentors = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          "Cộng Đồng Nghiệp Vụ & Xu Hướng 🌍",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Theo dõi xu hướng dạy học hot nhất trong tuần và giao lưu cùng các Mentor hàng đầu.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // 1. Trends Chart Card
        _buildTrendsChartCard(),
        const SizedBox(height: 24),

        // 2. Leaderboard
        _buildTopMentorsSection(),
      ],
    );
  }

  Widget _buildTrendsChartCard() {
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "XU HƯỚNG CHỦ ĐỀ ĐƯỢC QUAN TÂM NHẤT 📈",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: TeachingTrendsPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMentorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bảng Xếp Hạng Mentor Tuần Này 🥇",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_topMentors.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: const Text(
              "Chưa có dữ liệu xếp hạng mentor.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          )
        else
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _topMentors.length,
            itemBuilder: (context, index) {
              final mentor = _topMentors[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: mentor['color'].withOpacity(0.12),
                      child: Text(mentor['avatar'] as String, style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mentor['name'] as String, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text("${mentor['rating']} ⭐", style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(mentor['hours'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5)),
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
    );
  }
}

// Custom Painter for Teaching Trends Column Chart
class TeachingTrendsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBar = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;

    final labelStyle = TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.bold);
    const valueStyle = TextStyle(color: AppColors.textPrimary, fontSize: 9, fontWeight: FontWeight.bold);

    final List<double> data = [88, 76, 62, 45];
    final List<String> topics = ['E.Cafe', 'LISA', 'Keigo', 'HSK 4'];

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (1 - i / 3) * 0.85;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final barWidth = size.width / (data.length * 1.6);
    final gap = barWidth * 0.6;

    for (int i = 0; i < data.length; i++) {
      final pct = data[i] / 100.0;
      final barHeight = size.height * pct * 0.8;

      final x = i * (barWidth + gap) + gap / 2;
      final y = size.height * 0.85 - barHeight;

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      canvas.drawRRect(rrect, paintBar);

      // Month
      final textPainterMonth = TextPainter(
        text: TextSpan(text: topics[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterMonth.paint(canvas, Offset(x + (barWidth - textPainterMonth.width) / 2, size.height * 0.88));

      // Value
      final textPainterVal = TextPainter(
        text: TextSpan(text: '${data[i]}%', style: valueStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterVal.paint(canvas, Offset(x + (barWidth - textPainterVal.width) / 2, y - 13));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================================
// 2. LIBRARY TAB - LUCY PRO
// =========================================================================
class LucyProLibrary extends StatefulWidget {
  const LucyProLibrary({super.key});

  @override
  State<LucyProLibrary> createState() => _LucyProLibraryState();
}

class _LucyProLibraryState extends State<LucyProLibrary> {
  final List<Map<String, dynamic>> _lmsSlides = [
    {'title': 'LISA Lesson Plan 3: Travel Dialogue ✈️', 'category': 'LISA Core', 'color': const Color(0xFF64C3A5)},
    {'title': 'JLPT N4 Polite Japanese Keigo Standard 🙇', 'category': 'Japanese Prep', 'color': Colors.purple.shade200},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          "Kho Học Liệu & Hồ Sơ LMS 📂",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Lưu trữ bài giảng chuẩn, tài liệu học tập ghim nhanh và hồ sơ ghi chú học sinh tích lũy.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // 1. Quick slide catalog
        const Text(
          "Tài liệu giảng dạy ghim nhanh 📌",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _lmsSlides.length,
          itemBuilder: (context, index) {
            final slide = _lmsSlides[index];
            final color = slide['color'] as Color;

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
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.description, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(slide['title'] as String, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(slide['category'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("📌 Đã ghim slide giảng dạy thành công: ${slide['title']}"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      foregroundColor: AppColors.primaryDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: const Text("GHIM NHANH", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // 2. Student Records Folders
        const Text(
          "Thư mục hồ sơ học viên tích lũy 📁",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildFolderCard("Lớp Survival English", "12 Học viên", Colors.teal)),
            const SizedBox(width: 12),
            Expanded(child: _buildFolderCard("Lớp HSK Business", "8 Học viên", Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildFolderCard(String name, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.folder, color: color, size: 36),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(count, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// =========================================================================
// 3. PROFILE TAB - LUCY PRO
// =========================================================================
class LucyProProfile extends StatefulWidget {
  const LucyProProfile({super.key});

  @override
  State<LucyProProfile> createState() => _LucyProProfileState();
}

class _LucyProProfileState extends State<LucyProProfile> {
  double _balance = 0.0;
  bool _isWithdrawing = false;

  final List<Map<String, String>> _testimonials = [];

  String get _mentorDisplayName {
    final fullName = AppSession.current?.fullName.trim();
    return fullName == null || fullName.isEmpty ? 'Mentor' : fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              "Hồ Sơ Cá Nhân Mentor 👨‍🏫",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Quản lý thông tin chứng nhận, đánh giá học viên và số dư Ví tiền.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // 1. Roster Profile Card
            _buildRosterProfileCard(),
            const SizedBox(height: 24),

            // 2. Wallet & Withdraw Transactions (Interactive)
            _buildInteractiveWalletCard(),
            const SizedBox(height: 24),

            // 3. Testimonials
            _buildTestimonialsSection(),
          ],
        ),

        // Payout transfering overlay spinner
        if (_isWithdrawing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text(
                      "Đang kết nối cổng ngân hàng chuyển tiền...",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Đang xử lý yêu cầu rút tiền...",
                      style: TextStyle(color: Colors.orange.shade300, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRosterProfileCard() {
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
                backgroundColor: AppColors.primary,
                child: Text("👨‍🏫", style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_mentorDisplayName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("Mentor chính thức", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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
              _buildRosterMetric("0 giờ", "Dạy học"),
              _buildRosterMetric("Chưa có", "Chứng chỉ"),
              _buildRosterMetric("Chưa có", "Đánh giá"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRosterMetric(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5)),
      ],
    );
  }

  Widget _buildInteractiveWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.shade200.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.orange, size: 18),
                  SizedBox(width: 6),
                  Text("RÚT TIỀN THU NHẬP", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ],
              ),
              Text(
                "Ví: \$${_balance.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.orange.shade800, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text("Cài đặt tài khoản ngân hàng liên kết:", style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.credit_card, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 10),
                Text("Chưa liên kết tài khoản ngân hàng", style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _balance > 0 ? _simulateBankWithdraw : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size(double.infinity, 46),
            ),
            child: Text(
              _balance > 0 ? "YÊU CẦU RÚT SỐ DƯ HIỆN CÓ" : "CHƯA CÓ SỐ DƯ ĐỂ RÚT",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateBankWithdraw() {
    setState(() {
      _isWithdrawing = true;
    });

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isWithdrawing = false;
          _balance = 0.0;
        });

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text("Giao Dịch Thành Công!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: const Text(
              "Yêu cầu rút tiền đã được ghi nhận.",
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("ĐỒNG Ý", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      }
    });
  }

  Widget _buildTestimonialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nhận Xét Của Học Viên 🌟",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_testimonials.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: const Text(
              "Chưa có đánh giá học viên.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          )
        else
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _testimonials.length,
            itemBuilder: (context, index) {
              final review = _testimonials[index];
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(review['name']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      review['review']!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
}
