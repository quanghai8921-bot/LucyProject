import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/services/payment_api.dart';
import 'package:lucy_app/services/lms_api.dart';
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
  final LmsApi _lmsApi = LmsApi();

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
        const SizedBox(height: 20),

        // 3. Quizzes
        const Text(
          "Quản lý bài kiểm tra 📝",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildQuizManagementSection(),
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

  Widget _buildQuizManagementSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz, color: Colors.blueAccent, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tạo bài kiểm tra mới", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 4),
                    Text("Hỗ trợ trắc nghiệm và tự luận.", style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _showQuizCreationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: const Text("TẠO NGAY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuizCreationDialog() {
    String quizTitle = "";
    String passingScore = "80";
    String quizType = "MULTIPLE_CHOICE";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Tạo Bài Kiểm Tra"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: "Tiêu đề bài kiểm tra"),
                      onChanged: (val) => quizTitle = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: "Điểm đạt (%) (Mặc định 80)"),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => passingScore = val,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: quizType,
                      decoration: const InputDecoration(labelText: "Loại bài kiểm tra"),
                      items: const [
                        DropdownMenuItem(value: "MULTIPLE_CHOICE", child: Text("Trắc nghiệm")),
                        DropdownMenuItem(value: "ESSAY", child: Text("Tự luận")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => quizType = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
                ElevatedButton(
                  onPressed: () async {
                    if (quizTitle.isEmpty) return;
                    Navigator.pop(ctx);
                    try {
                      final quiz = await _lmsApi.createQuiz({
                        'roomId': 'R-000', // Need to pass active room ID, but for now we put a placeholder
                        'title': quizTitle,
                        'quizType': quizType,
                        'passingScore': num.tryParse(passingScore) ?? 80,
                        'status': 'PUBLISHED',
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tạo bài kiểm tra thành công: ${quiz.title}")));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                      }
                    }
                  },
                  child: const Text("Tạo"),
                ),
              ],
            );
          },
        );
      },
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
  final PaymentApi _paymentApi = PaymentApi();
  double _balance = 0.0;
  bool _isWalletLoading = false;
  bool _isWithdrawing = false;

  final List<Map<String, String>> _testimonials = [];

  String get _mentorDisplayName {
    final fullName = AppSession.current?.fullName.trim();
    return fullName == null || fullName.isEmpty ? 'Mentor' : fullName;
  }

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() {
      _isWalletLoading = true;
    });
    try {
      final wallet = await _paymentApi.getWallet();
      if (!mounted) return;
      setState(() {
        _balance = wallet.balance.toDouble();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tải được ví: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isWalletLoading = false;
        });
      }
    }
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
                _isWalletLoading ? "Đang tải ví..." : "Ví: ${_balance.toStringAsFixed(0)} Xu",
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
            onPressed: _balance > 0 ? _showWithdrawDialog : null,
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

  Future<void> _showWithdrawDialog() async {
    final bankNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final accountNameController = TextEditingController(text: _mentorDisplayName.toUpperCase());
    final amountController = TextEditingController(text: _balance.toStringAsFixed(0));

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeu cau rut tien'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'So Xu muon rut')),
            TextField(controller: bankNameController, decoration: const InputDecoration(labelText: 'Tên ngân hàng')),
            TextField(controller: accountNumberController, decoration: const InputDecoration(labelText: 'So tai khoan')),
            TextField(controller: accountNameController, decoration: const InputDecoration(labelText: 'Ten chu tai khoan')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Gui yeu cau')),
        ],
      ),
    );
    if (shouldSubmit != true) return;

    setState(() {
      _isWithdrawing = true;
    });

    try {
      await _paymentApi.withdraw(
        amount: num.tryParse(amountController.text.trim()) ?? 0,
        bankName: bankNameController.text.trim(),
        bankAccountNumber: accountNumberController.text.trim(),
        bankAccountName: accountNameController.text.trim(),
      );
      await _loadWallet();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da gui yeu cau rut tien, dang cho admin duyet.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Khong tao duoc yeu cau rut tien: ' + e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isWithdrawing = false;
        });
      }
    }
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


