import 'dart:async';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/services/auth_api.dart';
import 'package:lucy_app/services/lms_api.dart';
import 'package:lucy_app/services/payment_api.dart';
import 'package:lucy_app/theme/app_colors.dart';
import 'package:lucy_app/screens/learner_quiz_screen.dart';
import 'package:video_player/video_player.dart';

// =========================================================================
// 1. EXPLORE TAB - LUCY ANONYMOUS
// =========================================================================
class LucyAnonymousExplore extends StatefulWidget {
  const LucyAnonymousExplore({super.key});

  @override
  State<LucyAnonymousExplore> createState() => _LucyAnonymousExploreState();
}

class _LucyAnonymousExploreState extends State<LucyAnonymousExplore> {
  // LISA AI Pronunciation challenge state
  bool _isRecording = false;
  String _lisaFeedback = '';
  
  // Flashcard state
  bool _isCardFlipped = false;
  
  // Club join state
  final Set<String> _joinedClubs = {};

  final List<Map<String, String>> _clubs = [
    {'id': 'club1', 'title': 'English Cafe Vibe ☕', 'members': '1.2k members', 'lang': '🇬🇧 Anh'},
    {'id': 'club2', 'title': 'Tokyo Slangs Exchange 🇯🇵', 'members': '850 members', 'lang': '🇯🇵 Nhật'},
    {'id': 'club3', 'title': 'HSK 3 Speaking Practice 🇨🇳', 'members': '1.5k members', 'lang': '🇨🇳 Trung'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome Header
        const Text(
          "Khám Phá Thế Giới Ngôn Ngữ 🌍",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Tham gia thử thách phát âm cùng Robot LISA và các CLB Audio.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // 1. LISA AI Pronunciation Challenge
        _buildLisaAiChallengeCard(),
        const SizedBox(height: 24),

        // 2. Daily Flashcard Section
        _buildDailyFlashcardSection(),
        const SizedBox(height: 24),

        // 3. Audio Clubs
        _buildAudioClubsSection(),
      ],
    );
  }

  Widget _buildLisaAiChallengeCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.primaryDark, size: 12),
                    SizedBox(width: 4),
                    Text("LISA AI CHALLENGE", style: TextStyle(color: AppColors.primaryDark, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Thử thách phát âm hàng ngày:",
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "\"I love grabbing an iced matcha latte with friends on weekends.\" 🍵",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 16),
          
          if (_lisaFeedback.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Colors.green, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("KẾT QUẢ PHÂN TÍCH", style: TextStyle(color: Colors.green, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text(_lisaFeedback, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ElevatedButton.icon(
            onPressed: _isRecording ? null : _simulateRecordPronunciation,
            icon: Icon(_isRecording ? Icons.settings_voice : Icons.mic_none, color: Colors.white),
            label: Text(_isRecording ? "ĐANG GHI ÂM..." : "BẤM ĐỂ PHÁT ÂM", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecording ? Colors.red.shade400 : AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateRecordPronunciation() {
    setState(() {
      _isRecording = true;
      _lisaFeedback = '';
    });

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _lisaFeedback = "LISA AI Score: 96% - Phát âm xuất sắc, nối âm cực kỳ tự nhiên! 🌟";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Chúc mừng! Bạn vừa hoàn thành thử thách nói LISA hàng ngày!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Widget _buildDailyFlashcardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Flashcard Từ Vựng Hôm Nay 💡",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              _isCardFlipped = !_isCardFlipped;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isCardFlipped 
                  ? [AppColors.primary.withOpacity(0.08), AppColors.primary.withOpacity(0.15)] 
                  : [Colors.orange.shade50.withOpacity(0.8), Colors.orange.shade100.withOpacity(0.4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _isCardFlipped ? AppColors.primary : Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Text(
                  _isCardFlipped ? "木漏れ日 (Komorebi)" : "Nghĩa của từ này là gì?",
                  style: TextStyle(
                    color: _isCardFlipped ? AppColors.primaryDark : Colors.orange.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isCardFlipped ? "Ánh nắng mặt trời xuyên qua kẽ lá 🍃" : "KOMOREBI",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: _isCardFlipped ? 18 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _isCardFlipped ? "(Nhấp để úp thẻ lại)" : "(Nhấp vào thẻ để lật xem nghĩa tiếng Việt)",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioClubsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cộng đồng Câu lạc bộ Audio 🎙️",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _clubs.length,
          itemBuilder: (context, index) {
            final club = _clubs[index];
            final cId = club['id']!;
            bool isJoined = _joinedClubs.contains(cId);

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
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Icon(Icons.people, color: AppColors.primaryDark)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(club['title']!, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(club['lang']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(club['members']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isJoined) {
                          _joinedClubs.remove(cId);
                        } else {
                          _joinedClubs.add(cId);
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isJoined ? '🔓 Đã rời Câu lạc bộ.' : '✅ Đã gia nhập Câu lạc bộ thành công!'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isJoined ? Colors.grey.shade100 : AppColors.primary.withOpacity(0.12),
                      foregroundColor: isJoined ? Colors.grey : AppColors.primaryDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: Text(isJoined ? "ĐÃ VÀO" : "GIA NHẬP", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
// 2. LIBRARY TAB - LUCY ANONYMOUS
// =========================================================================
class LucyAnonymousLibrary extends StatefulWidget {
  const LucyAnonymousLibrary({super.key});

  @override
  State<LucyAnonymousLibrary> createState() => _LucyAnonymousLibraryState();
}

class _LucyAnonymousLibraryState extends State<LucyAnonymousLibrary> {
  final LmsApi _lmsApi = LmsApi();
  final PaymentApi _paymentApi = PaymentApi();
  List<CreatorPaidContent> _purchasedVideos = [];
  PaymentWallet? _wallet;
  bool _isVideoLoading = false;
  String? _videoError;
  final List<Map<String, String>> _downloads = [
    {'title': 'Keigo: Polite Business Japanese 🙇', 'duration': '18:40', 'size': '12.4 MB'},
    {'title': 'Survival Speaking Level 3: Airport Slangs ✈️', 'duration': '12:15', 'size': '8.2 MB'},
  ];

  List<RoomQuizAttempt> _assignedQuizzes = [];
  bool _isQuizLoading = false;
  String? _quizError;

  @override
  void initState() {
    super.initState();
    _loadVideoLibrary();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final session = AppSession.current;
    if (session == null) return;
    setState(() {
      _isQuizLoading = true;
      _quizError = null;
    });
    try {
      final quizzes = await _lmsApi.getLearnerAssignedQuizzes(session.userId);
      if (mounted) setState(() => _assignedQuizzes = quizzes);
    } catch (e) {
      if (mounted) setState(() => _quizError = '$e');
    } finally {
      if (mounted) setState(() => _isQuizLoading = false);
    }
  }

  Future<void> _loadVideoLibrary() async {
    final session = AppSession.current;
    setState(() {
      _isVideoLoading = true;
      _videoError = null;
    });
    try {
      final purchased = session == null ? <CreatorPaidContent>[] : await _lmsApi.getPurchasedVideos(session.userId);
      final wallet = session == null ? null : await _paymentApi.getWallet();
      if (!mounted) return;
      setState(() {
        _purchasedVideos = purchased;
        _wallet = wallet;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _videoError = '$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          "Thư Viện Học Tập Của Bạn 📚",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Xem học liệu đã lưu, từ vựng ghi chú và bài học lưu ngoại tuyến (Offline).",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 20),


        // Personal Saved Shelves Grid
        Row(
          children: [
            Expanded(child: _buildShelfCard("Mentor đã lưu", "2 Mentors", Icons.person_add_alt_1, Colors.orange.shade400)),
            const SizedBox(width: 12),
            Expanded(child: _buildShelfCard("Từ vựng đã note", "18 từ vựng", Icons.bookmark, Colors.purple.shade300)),
          ],
        ),
        const SizedBox(height: 24),

        // Bookmarked words list
        _buildSavedVocabularySection(),
        const SizedBox(height: 24),

        _buildMyQuizzesSection(),
        const SizedBox(height: 24),

        _buildPurchasedVideosSection(),
        const SizedBox(height: 24),

        // Offline Downloads
        _buildOfflineDownloadsSection(),
      ],
    );
  }

  Widget _buildMyQuizzesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bài kiểm tra được giao 📝",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_isQuizLoading) const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        if (_quizError != null) Text(_quizError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        if (!_isQuizLoading && _assignedQuizzes.isEmpty)
          _buildInfoBox('Chưa có bài kiểm tra nào được Mentor giao cho bạn.'),
        if (!_isQuizLoading)
          ..._assignedQuizzes.map((quiz) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.quiz, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(quiz.quizTitle, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('Thời gian: ${quiz.durationMinutes} phút • Loại: ${quiz.quizType == "ESSAY" ? "Tự luận" : "Trắc nghiệm"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (ctx) => LearnerQuizScreen(
                            attemptId: quiz.attemptId, 
                            quizId: quiz.quizId,
                            durationMinutes: quiz.durationMinutes, 
                            quizTitle: quiz.quizTitle
                          )
                        )
                      ).then((_) => _loadQuizzes());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: const Text("LÀM BÀI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildShelfCard(String title, String subtitle, IconData icon, Color color) {
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
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12.5)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildWalletTopUpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ví học viên', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${(_wallet?.balance ?? 0).toStringAsFixed(0)} Xu', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showTopUpDialog,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Nạp'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTopUpDialog() async {
    final amountController = TextEditingController(text: '100000');
    var previewCoins = 100;
    final shouldTopUp = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nap tien vao vi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'So tien VND'),
                onChanged: (value) {
                  setDialogState(() {
                    previewCoins = ((num.tryParse(value.trim()) ?? 0) / 1000).floor();
                  });
                },
              ),
              const SizedBox(height: 8),
              Text('Ban se nhan: $previewCoins Xu', style: const TextStyle(fontSize: 13, color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Ty le: 1.000 VND = 1 Xu', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huy')),
            ElevatedButton(onPressed: previewCoins > 0 ? () => Navigator.pop(context, true) : null, child: const Text('Tao don')),
          ],
        ),
      ),
    );
    if (shouldTopUp != true) return;
    try {
      final order = await _paymentApi.depositVnd(num.tryParse(amountController.text.trim()) ?? 0);
      await _loadVideoLibrary();
      if (!mounted) return;
      _showTopUpInstructions(order);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Khong tao duoc don nap tien: ' + e.toString())),
      );
    }
  }

  Future<void> _showTopUpInstructions(TopUpOrder order) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cho admin duyet'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (order.qrImageUrl != null && order.qrImageUrl!.isNotEmpty) ...[
                Image.network(_paymentImageUrl(order.qrImageUrl!), height: 180, fit: BoxFit.contain),
                const SizedBox(height: 12),
              ],
              Text('So tien: ${order.amount.toStringAsFixed(0)} VND'),
              Text('So Xu se nhan: ${order.coins.toStringAsFixed(0)} Xu'),
              if (order.receiverName != null) Text('Nguoi nhan: ${order.receiverName}'),
              if (order.receiverPhone != null) Text('So MoMo: ${order.receiverPhone}'),
              const SizedBox(height: 8),
              const Text('Noi dung chuyen khoan:', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(order.transferContent ?? order.topUpOrderId),
              const SizedBox(height: 12),
              const Text('Sau khi chuyen khoan, vui long cho admin kiem tra va duyet. Xu se duoc cong vao vi khi don duoc duyet.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Da hieu')),
        ],
      ),
    );
  }

  String _paymentImageUrl(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    final base = _paymentApi.baseUrl.endsWith('/') ? _paymentApi.baseUrl.substring(0, _paymentApi.baseUrl.length - 1) : _paymentApi.baseUrl;
    return value.startsWith('/') ? '$base$value' : '$base/$value';
  }
  Widget _buildSavedVocabularySection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars, color: Colors.amber, size: 16),
              SizedBox(width: 6),
              Text("Sổ tay Từ lóng vừa học 🌟", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          _buildVocabRow("Low-key", "Kín tiếng, ít ồn ào (Tiếng Anh Mỹ lóng)"),
          const Divider(height: 1),
          _buildVocabRow("Keigo", "Từ ngữ lịch thiệp trong giao dịch (Kính ngữ Nhật)"),
        ],
      ),
    );
  }

  Widget _buildVocabRow(String term, String definition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(term, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(definition, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildPurchasedVideosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Video Creator đã mua",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_isVideoLoading) const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        if (_videoError != null) Text(_videoError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        if (!_isVideoLoading && _purchasedVideos.isEmpty)
          _buildInfoBox('Chưa có video đã mua trong ContentPurchases. Sau khi thanh toán thật được triển khai, video sẽ xuất hiện ở đây.'),
        if (!_isVideoLoading) ..._purchasedVideos.map((video) => _buildLearnerVideoCard(video, purchased: true)),
      ],
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    );
  }

  Widget _buildLearnerVideoCard(CreatorPaidContent video, {required bool purchased}) {
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
          Icon(purchased ? Icons.play_circle_fill : Icons.lock_outline, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(video.displayPrice, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(purchased ? Icons.play_arrow_rounded : Icons.shopping_bag_outlined, color: AppColors.primary),
            onPressed: () {
              if (purchased) {
                final url = video.absoluteMediaUrl(_lmsApi.baseUrl);
                showDialog(
                  context: context,
                  builder: (context) => VideoPlayerDialog(
                    title: video.title,
                    url: url.isEmpty ? 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4' : url,
                  ),
                );
              } else {
                _purchaseVideo(video);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseVideo(CreatorPaidContent video) async {
    try {
      await _paymentApi.purchaseContent(video.contentId);
      await _loadVideoLibrary();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toán thành công. Video đã được thêm vào thư viện.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không mua được video: $e')),
      );
    }
  }

  Widget _buildOfflineDownloadsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bài học tải xuống ngoại tuyến (Offline) 📥",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _downloads.length,
          itemBuilder: (context, index) {
            final file = _downloads[index];
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
                  const Icon(Icons.offline_pin, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(file['title']!, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("${file['duration']} • ${file['size']}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_filled, color: AppColors.primary, size: 28),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("🔈 Đang phát Offline: ${file['title']}"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
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
// 3. PROFILE TAB - LUCY ANONYMOUS
// =========================================================================
class LucyAnonymousProfile extends StatefulWidget {
  const LucyAnonymousProfile({super.key});

  @override
  State<LucyAnonymousProfile> createState() => _LucyAnonymousProfileState();
}

class _LucyAnonymousProfileState extends State<LucyAnonymousProfile> {
  // Accessory state: 0 = none, 1 = crown 👑, 2 = glasses 🕶️, 3 = headphones 🎧
  int _activeAccessory = 0;
  final _authApi = AuthApi();
  final PaymentApi _paymentApi = PaymentApi();
  final _displayNameController = TextEditingController();
  PlatformFile? _avatarFile;
  String? _avatarUrl;
  PaymentWallet? _wallet;
  bool _isWalletLoading = false;
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    final session = AppSession.current;
    _displayNameController.text = session?.displayName ?? '';
    _avatarUrl = session?.avatarUrl;
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    if (AppSession.current == null) return;
    setState(() {
      _isWalletLoading = true;
    });
    try {
      final wallet = await _paymentApi.getWallet();
      if (!mounted) return;
      setState(() {
        _wallet = wallet;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _wallet = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isWalletLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          "Hồ Sơ Cá Nhân Ẩn Danh 👤",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Cá nhân hóa Avatar ảo, kho danh hiệu và biểu đồ học tập.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 20),

        _buildWalletTopUpSection(),
        const SizedBox(height: 24),

        // 1. Avatar personalization studio
        _buildProfileCard(),
        const SizedBox(height: 24),
        _buildAvatarCustomiserStudio(),
        const SizedBox(height: 24),

        // 2. Badges Wall
        _buildBadgesWall(),
        const SizedBox(height: 24),

        // 3. Learning Time Statistics (CustomPaint Pie Chart)
        _buildSpeakingAnalyticsCard(),
      ],
    );
  }

  Widget _buildWalletTopUpSection() {
    final balanceText = _isWalletLoading ? 'Dang tai...' : '${(_wallet?.balance ?? 0).toStringAsFixed(0)} Xu';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ví học viên', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(balanceText, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showTopUpDialog,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Nạp'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTopUpDialog() async {
    final amountController = TextEditingController(text: '100000');
    var previewCoins = 100;
    final shouldTopUp = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nạp tiền vào ví'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số tiền VND'),
                onChanged: (value) {
                  setDialogState(() {
                    previewCoins = ((num.tryParse(value.trim()) ?? 0) / 1000).floor();
                  });
                },
              ),
              const SizedBox(height: 8),
              Text('Bạn sẽ nhận: $previewCoins Xu', style: const TextStyle(fontSize: 13, color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Tỷ lệ: 1.000 VND = 1 Xu', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            ElevatedButton(onPressed: previewCoins > 0 ? () => Navigator.pop(context, true) : null, child: const Text('Tạo đơn')),
          ],
        ),
      ),
    );
    if (shouldTopUp != true) return;
    try {
      final order = await _paymentApi.depositVnd(num.tryParse(amountController.text.trim()) ?? 0);
      await _loadWallet();
      if (!mounted) return;
      _showTopUpInstructions(order);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tạo được đơn nạp tiền: $e')),
      );
    }
  }

  Future<void> _showTopUpInstructions(TopUpOrder order) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chờ admin duyệt'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (order.qrImageUrl != null && order.qrImageUrl!.isNotEmpty) ...[
                Image.network(_paymentImageUrl(order.qrImageUrl!), height: 180, fit: BoxFit.contain),
                const SizedBox(height: 12),
              ],
              Text('Số tiền: ${order.amount.toStringAsFixed(0)} VND'),
              Text('Số Xu sẽ nhận: ${order.coins.toStringAsFixed(0)} Xu'),
              if (order.receiverName != null) Text('Người nhận: ${order.receiverName}'),
              if (order.receiverPhone != null) Text('Số MoMo: ${order.receiverPhone}'),
              const SizedBox(height: 8),
              const Text('Nội dung chuyển khoản:', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(order.transferContent ?? order.topUpOrderId),
              const SizedBox(height: 12),
              const Text('Sau khi chuyển khoản, vui lòng chờ admin kiểm tra và duyệt. Xu sẽ được cộng vào ví khi đơn được duyệt.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Đã hiểu')),
        ],
      ),
    );
  }

  String _paymentImageUrl(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    final base = _paymentApi.baseUrl.endsWith('/') ? _paymentApi.baseUrl.substring(0, _paymentApi.baseUrl.length - 1) : _paymentApi.baseUrl;
    return value.startsWith('/') ? '$base$value' : '$base/$value';
  }

  Widget _buildProfileCard() {
    final avatarUrl = _absoluteAvatarUrl(_avatarUrl);

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
            'AvatarPersona',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 2),
                ),
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: AppColors.primaryDark, size: 42)
                    : Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primaryDark, size: 42),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Tên hiển thị',
                        hintText: 'Nhập tên sẽ hiển thị',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isSavingProfile ? null : _pickAvatar,
            icon: const Icon(Icons.upload_file, color: AppColors.primaryDark),
            label: Text(
              _avatarFile?.name ?? 'Upload ảnh đại diện',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.inputBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isSavingProfile ? null : _saveProfile,
            icon: _isSavingProfile
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_alt, color: Colors.white),
            label: Text(
              _isSavingProfile ? 'Đang lưu...' : 'Lưu hồ sơ',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  String? _absoluteAvatarUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final url = value.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final baseUrl = _authApi.baseUrl.endsWith('/') ? _authApi.baseUrl.substring(0, _authApi.baseUrl.length - 1) : _authApi.baseUrl;
    return url.startsWith('/') ? '$baseUrl$url' : '$baseUrl/$url';
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _avatarFile = result.files.single);
  }

  Future<void> _saveProfile() async {
    final session = AppSession.current;
    if (session == null) {
      _showProfileMessage('Bạn cần đăng nhập lại để cập nhật hồ sơ.');
      return;
    }

    if (_displayNameController.text.trim().isEmpty) {
      _showProfileMessage('Vui lòng nhập tên hiển thị.');
      return;
    }

    setState(() => _isSavingProfile = true);
    try {
      final updated = await _authApi.updateAvatar(
        token: session.accessToken,
        displayName: _displayNameController.text,
        avatarFile: _avatarFile,
      );
      AppSession.set(updated);
      if (!mounted) return;
      setState(() {
        _avatarUrl = updated.avatarUrl;
        _avatarFile = null;
      });
      _showProfileMessage('Đã cập nhật hồ sơ avatar.');
    } on AuthApiException catch (error) {
      _showProfileMessage(error.message);
    } catch (_) {
      _showProfileMessage('Không kết nối được Lucy.Auth.Api.');
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  void _showProfileMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildAvatarCustomiserStudio() {
    String accessoryIcon = '';
    if (_activeAccessory == 1) accessoryIcon = '👑';
    if (_activeAccessory == 2) accessoryIcon = '🕶️';
    if (_activeAccessory == 3) accessoryIcon = '🎧';

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
        children: [
          const Text("STUDIO PHỤ KIỆN PERSONA A.I 👾", style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          
          // Avatar canvas representation with accessory on top
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200, width: 2),
                ),
                child: const Center(
                  child: Text("👤", style: TextStyle(fontSize: 64)),
                ),
              ),
              if (accessoryIcon.isNotEmpty)
                Positioned(
                  top: _activeAccessory == 1 ? 4 : 45,
                  child: Text(
                    accessoryIcon,
                    style: TextStyle(fontSize: _activeAccessory == 1 ? 38 : 34),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          const Text("Chọn phụ kiện đeo thêm:", style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAccessoryChip("Không", 0),
              const SizedBox(width: 8),
              _buildAccessoryChip("Vương miện 👑", 1),
              const SizedBox(width: 8),
              _buildAccessoryChip("Kính mát 🕶️", 2),
              const SizedBox(width: 8),
              _buildAccessoryChip("Tai nghe 🎧", 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccessoryChip(String label, int index) {
    bool isActive = _activeAccessory == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeAccessory = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? AppColors.primary : AppColors.inputBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textPrimary,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesWall() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bức tường Danh hiệu Học viên 🏆",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildBadgeItem("Agora Pioneer 🎙️", "Tham gia Live"),
              _buildBadgeItem("7 Days Streak 🔥", "Học hàng ngày"),
              _buildBadgeItem("Speak Master 👑", "Đọc LISA >95%"),
              _buildBadgeItem("Polyglot 🌟", "Học trên 2 tiếng"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(String title, String desc) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 8), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSpeakingAnalyticsCard() {
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
            "PHÂN TÍCH THỜI GIAN LUYỆN NÓI",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Custom Paint Circular Pie Chart
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: SpeakingPieChartPainter(
                    colors: [AppColors.primary, Colors.orange.shade300, Colors.purple.shade200],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildPieLegendRow("Tiếng Anh (60%)", AppColors.primary),
                    const SizedBox(height: 6),
                    _buildPieLegendRow("Tiếng Trung (25%)", Colors.orange.shade300),
                    const SizedBox(height: 6),
                    _buildPieLegendRow("Tiếng Nhật (15%)", Colors.purple.shade200),
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

// Custom Painter for Speaking Analytics Pie Chart
class SpeakingPieChartPainter extends CustomPainter {
  final List<Color> colors;

  SpeakingPieChartPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    // Draw English (60%) - starting from -pi/2
    paint.color = colors[0];
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * 0.60, true, paint);

    // Draw Chinese (25%)
    paint.color = colors[1];
    canvas.drawArc(rect, -math.pi / 2 + 2 * math.pi * 0.60, 2 * math.pi * 0.25, true, paint);

    // Draw Japanese (15%)
    paint.color = colors[2];
    canvas.drawArc(rect, -math.pi / 2 + 2 * math.pi * 0.85, 2 * math.pi * 0.15, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VideoPlayerDialog extends StatefulWidget {
  final String title;
  final String url;
  const VideoPlayerDialog({super.key, required this.title, required this.url});

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: _hasError
          ? const Text('Không thể phát video này do lỗi định dạng hoặc URL không hợp lệ.')
          : _controller.value.isInitialized
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    const SizedBox(height: 12),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: Colors.black12,
                        backgroundColor: Colors.black12,
                      ),
                    ),
                  ],
                )
              : const SizedBox(
                  width: 300,
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
      actions: [
        if (_controller.value.isInitialized) ...[
          SizedBox(
            width: 100,
            child: Row(
              children: [
                const Icon(Icons.volume_up, size: 16),
                Expanded(
                  child: Slider(
                    value: _controller.value.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      setState(() {
                        _controller.setVolume(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
            child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
