import 'dart:async';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/services/auth_api.dart';
import 'package:lucy_app/theme/app_colors.dart';

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
  final List<Map<String, String>> _downloads = [
    {'title': 'Keigo: Polite Business Japanese 🙇', 'duration': '18:40', 'size': '12.4 MB'},
    {'title': 'Survival Speaking Level 3: Airport Slangs ✈️', 'duration': '12:15', 'size': '8.2 MB'},
  ];

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

        // Offline Downloads
        _buildOfflineDownloadsSection(),
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
  final _displayNameController = TextEditingController();
  PlatformFile? _avatarFile;
  String? _avatarUrl;
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    final session = AppSession.current;
    _displayNameController.text = session?.fullName ?? '';
    _avatarUrl = session?.avatarUrl;
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
