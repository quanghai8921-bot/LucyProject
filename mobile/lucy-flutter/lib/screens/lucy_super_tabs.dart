import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/services/lms_api.dart';
import 'package:lucy_app/services/payment_api.dart';
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
  final LmsApi _lmsApi = LmsApi();
  List<CreatorPaidContent> _videos = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final session = AppSession.current;
    if (session == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final videos = await _lmsApi.getCreatorVideos(session.userId);
      if (!mounted) return;
      setState(() {
        _videos = videos;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Kho video Creator",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Upload video từ máy, đặt giá và quản lý video đã đăng bằng dữ liệu thật từ PaidContents.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _showUploadVideoDialog,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload video mới'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 20),
        if (_isLoading) const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        if (_error != null) Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        if (!_isLoading && _videos.isEmpty) _buildEmptyState(),
        if (!_isLoading) ..._videos.map(_buildVideoCard),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: const Text(
        'Chưa có video trong database. Hãy upload video thật để đăng bán.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _buildVideoCard(CreatorPaidContent video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
              const Icon(Icons.video_library_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(video.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Text(video.displayPrice, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          if (video.descriptionText?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(video.descriptionText!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(onPressed: () => _showEditVideoDialog(video), icon: const Icon(Icons.edit, size: 16), label: const Text('Sửa giá')),
              OutlinedButton.icon(onPressed: () => _replaceVideoFile(video), icon: const Icon(Icons.swap_horiz, size: 16), label: const Text('Thay file')),
              OutlinedButton.icon(onPressed: () => _deleteVideo(video), icon: const Icon(Icons.delete_outline, size: 16), label: const Text('Xóa')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showUploadVideoDialog() async {
    final session = AppSession.current;
    if (session == null) return;
    final picked = await FilePicker.platform.pickFiles(type: FileType.video, withData: true);
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final titleController = TextEditingController(text: file.name);
    final descController = TextEditingController();
    final priceController = TextEditingController(text: '0');
    if (!mounted) return;
    final shouldUpload = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng video trả phí'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gia Xu')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Upload')),
        ],
      ),
    );
    if (shouldUpload != true) return;
    await _lmsApi.uploadCreatorVideo(
      creatorUserId: session.userId,
      title: titleController.text.trim().isEmpty ? file.name : titleController.text.trim(),
      descriptionText: descController.text.trim(),
      priceAmount: num.tryParse(priceController.text.trim()) ?? 0,
      file: file,
    );
    await _loadVideos();
  }

  Future<void> _showEditVideoDialog(CreatorPaidContent video) async {
    final titleController = TextEditingController(text: video.title);
    final descController = TextEditingController(text: video.descriptionText ?? '');
    final priceController = TextEditingController(text: '${video.priceAmount}');
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gia Xu')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
        ],
      ),
    );
    if (shouldSave != true) return;
    await _lmsApi.updateCreatorVideo(
      contentId: video.contentId,
      title: titleController.text.trim(),
      descriptionText: descController.text.trim(),
      priceAmount: num.tryParse(priceController.text.trim()) ?? 0,
    );
    await _loadVideos();
  }

  Future<void> _replaceVideoFile(CreatorPaidContent video) async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.video, withData: true);
    if (picked == null || picked.files.isEmpty) return;
    await _lmsApi.replaceCreatorVideoFile(contentId: video.contentId, file: picked.files.first);
    await _loadVideos();
  }

  Future<void> _deleteVideo(CreatorPaidContent video) async {
    await _lmsApi.deleteCreatorVideo(video.contentId);
    await _loadVideos();
  }
}

// 3. PROFILE TAB - LUCY SUPER
// =========================================================================
class LucySuperProfile extends StatefulWidget {
  const LucySuperProfile({super.key});

  @override
  State<LucySuperProfile> createState() => _LucySuperProfileState();
}

class _LucySuperProfileState extends State<LucySuperProfile> {
  final priceController = TextEditingController(text: '49.00');
  final PaymentApi _paymentApi = PaymentApi();
  double _balance = 0.0;
  bool _isWalletLoading = false;
  bool _isWithdrawing = false;

  String get _creatorDisplayName {
    final fullName = AppSession.current?.fullName.trim();
    return fullName == null || fullName.isEmpty ? 'Creator' : fullName;
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

        // 2. Wallet & Withdraw Transactions (Interactive)
        _buildInteractiveWalletCard(),
        const SizedBox(height: 24),

        // 3. Default package pricing manager
        _buildDefaultPricingCard(),
        const SizedBox(height: 24),

        // 4. Revenue Distribution custom chart
        _buildRevenueDistributionCard(),
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
    ], );
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppSession.current?.fullName.trim().isNotEmpty == true ? AppSession.current!.fullName : 'Creator', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("Creator", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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
    final accountNameController = TextEditingController(text: _creatorDisplayName.toUpperCase());
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
