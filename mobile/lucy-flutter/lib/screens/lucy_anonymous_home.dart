import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/theme/app_colors.dart';

class LucyAnonymousHome extends StatefulWidget {
  const LucyAnonymousHome({super.key});

  @override
  State<LucyAnonymousHome> createState() => _LucyAnonymousHomeState();
}

class _LucyAnonymousHomeState extends State<LucyAnonymousHome> with TickerProviderStateMixin {
  late TabController _tabController;
  final String _userLevel = "Level 1";
  bool _isJoiningRandom = false;

  // Pulse animation for Live indicator
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ==========================================
  // MOCK DATA FOR LIVE ROOMS
  // ==========================================
  final Map<String, List<Map<String, dynamic>>> _liveRooms = {
    'Anh': [
      {
        'title': 'Survival Speaking: Cafe order & small talk ☕',
        'mentor': 'Professor K',
        'mentorRep': '4,982 REP',
        'listeners': 14,
        'level': 'Level 1',
        'color': const Color(0xFF64C3A5),
        'bgColors': [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
      },
      {
        'title': 'Job Interview Pitch: Gen Z Slangs & Etiquette 💼',
        'mentor': 'Sarah Jenkins',
        'mentorRep': '2,150 REP',
        'listeners': 28,
        'level': 'Level 6',
        'color': const Color(0xFF6366F1),
        'bgColors': [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
      },
      {
        'title': 'Movie Review Lounge: Discussing Marvel films 🎬',
        'mentor': 'Austin Miller',
        'mentorRep': '1,890 REP',
        'listeners': 9,
        'level': 'Level 3',
        'color': const Color(0xFFEC4899),
        'bgColors': [const Color(0xFFFDF2F8), const Color(0xFFFCE7F3)],
      },
    ],
    'Trung': [
      {
        'title': 'HSK 1 Conversational Drill: Introducing yourself 🤝',
        'mentor': 'Juan Rivera',
        'mentorRep': '2,845 REP',
        'listeners': 18,
        'level': 'Level 11',
        'color': const Color(0xFFF59E0B),
        'bgColors': [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
      },
      {
        'title': 'Dimsum & Tea culture vocabulary 🥟',
        'mentor': 'Mei Ling',
        'mentorRep': '3,450 REP',
        'listeners': 12,
        'level': 'Level 16',
        'color': const Color(0xFFEF4444),
        'bgColors': [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)],
      },
    ],
    'Nhật': [
      {
        'title': 'JLPT N5 Kaiwa: Basic travel direction phrases 🗺️',
        'mentor': 'Mina-san',
        'mentorRep': '3,211 REP',
        'listeners': 22,
        'level': 'Level 21',
        'color': const Color(0xFF8B5CF6),
        'bgColors': [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)],
      },
      {
        'title': 'Anime Slang: Talking like Naruto & Jujutsu Kaisen 🦊',
        'mentor': 'Takuya Sato',
        'mentorRep': '1,990 REP',
        'listeners': 35,
        'level': 'Level 26',
        'color': const Color(0xFFEC4899),
        'bgColors': [const Color(0xFFFFF1F2), const Color(0xFFFFE4E6)],
      },
    ]
  };

  // ==========================================
  // WIDGET BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header with custom drawn Gen Z virtual avatar and Level
        _buildLucyHeader(),
        const SizedBox(height: 18),

        // 2. Quick Join Interactive CTA
        _buildQuickJoinBanner(),
        const SizedBox(height: 24),

        // 3. TabBar for language tabs: Anh - Trung - Nhật
        _buildLanguageTabBar(),
        const SizedBox(height: 16),

        // Tab Views (Core Live list in dynamic scannable grid)
        // Dynamic Live list in clean scannable grid based on selected Tab
        _buildLiveRoomsGrid(
          _tabController.index == 0
              ? 'Anh'
              : _tabController.index == 1
                  ? 'Trung'
                  : 'Nhật',
        ),
        const SizedBox(height: 24),

        // 4. Leaderboard of Top Mentors
        _buildLeaderboardWidget(),
      ],
    );
  }

  // ==========================================
  // HEADER DESIGN (AVATAR & LEVEL ROADMAP)
  // ==========================================
  Widget _buildLucyHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
      child: Row(
        children: [
          // 3D/Anime Vector Avatar drawn by CustomPainter
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✨ Đây là Avatar ảo Persona của bạn để bảo mật danh tính!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF64C3A5), Color(0xFF6366F1), Color(0xFFFFB076)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: VirtualAvatarPainter(),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User Info & Clicking Sheet
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${AppSession.current?.fullName ?? 'Polyglot Ẩn Danh'} ✨",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _showLevelRoadmapBottomSheet,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              "SƠ CẤP",
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _userLevel,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelRoadmapBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lộ trình Đào tạo 100 Levels của LUCY 🏆",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hệ thống số hóa 100 level ngôn ngữ được phân chia thành 3 phân tầng Stage chính:",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _buildStageInfoRow("Sơ cấp (Level 1-30)", "Giao tiếp sinh tồn hàng ngày, phản xạ ẩn danh không áp lực tâm lý.", true),
            const Divider(height: 20),
            _buildStageInfoRow("Trung cấp (Level 31-70)", "Thảo luận sâu hơn, ghim tài liệu chuyên ngành cùng Lisa AI hỗ trợ.", false),
            const Divider(height: 20),
            _buildStageInfoRow("Cao cấp (Level 71-100)", "Trình bày luận điểm chuyên nghiệp, rèn giũa kỹ năng với Pro Mentors.", false),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Tuyệt vời, đã hiểu", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageInfoRow(String title, String desc, bool isCurrent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isCurrent ? Icons.check_circle : Icons.radio_button_off,
          color: isCurrent ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // QUICK JOIN BANNER DESIGN
  // ==========================================
  Widget _buildQuickJoinBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF7AD9BD), Color(0xFFFFB076)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "KẾT NỐI TỨC THÌ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Bắt Cặp Tham Gia Nhanh ⚡",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Vào phòng ngẫu nhiên phù hợp trình độ Sơ Cấp",
                  style: TextStyle(
                    color: Color(0xE6FFFFFF), // Standard white87
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Clickable Quick Join Action button
          GestureDetector(
            onTap: () {
              setState(() {
                _isJoiningRandom = true;
              });
              // Simulate real-time matchmaking delay (1.8 seconds)
              Future.delayed(const Duration(milliseconds: 1800), () {
                if (mounted) {
                  setState(() {
                    _isJoiningRandom = false;
                  });
                  _showAgoraCallSimulation(
                    title: "Survival Speaking Room ngẫu nhiên",
                    mentor: "Professor K",
                  );
                }
              });
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _isJoiningRandom
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(
                        Icons.bolt,
                        color: AppColors.primary,
                        size: 32,
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // TABBAR DESIGN FOR LANGUAGES
  // ==========================================
  Widget _buildLanguageTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        tabs: const [
          Tab(text: "🇬🇧 Tiếng Anh"),
          Tab(text: "🇨🇳 Tiếng Trung"),
          Tab(text: "🇯🇵 Tiếng Nhật"),
        ],
      ),
    );
  }

  // ==========================================
  // CORE SCANNABLE GRID FOR LIVE ROOMS
  // ==========================================
  Widget _buildLiveRoomsGrid(String languageKey) {
    final list = _liveRooms[languageKey] ?? [];

    if (list.isEmpty) {
      return const Center(
        child: Text(
          "Hiện chưa có phòng Live trực tiếp cho ngôn ngữ này.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final room = list[index];
        return _buildRoomGridCard(room);
      },
    );
  }

  Widget _buildRoomGridCard(Map<String, dynamic> room) {
    Color cardColor = room['color'] as Color;
    List<Color> bgColors = room['bgColors'] as List<Color>;

    return GestureDetector(
      onTap: () => _showAgoraCallSimulation(
        title: room['title'] as String,
        mentor: room['mentor'] as String,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tag bar: Pulser Live dot & Listeners count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 2,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) => Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(_pulseAnimation.value),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "LIVE",
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.red,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Headphone icon + Listeners
                Row(
                  children: [
                    const Icon(Icons.headphones_outlined, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text(
                      "${room['listeners']}",
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),

            // Title
            Text(
              room['title'] as String,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Mentor Tag
            Text(
              "🎙️ Mentor: ${room['mentor']}",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Level Tag Capsule
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cardColor.withOpacity(0.15)),
              ),
              child: Text(
                room['level'] as String,
                style: TextStyle(
                  color: cardColor.darken(0.1),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgoraCallSimulation({required String title, required String mentor}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Simulate connection steps
            bool connected = false;
            Future.delayed(const Duration(seconds: 1500), () {
              if (context.mounted) {
                setDialogState(() {
                  connected = true;
                });
              }
            });

            return AlertDialog(
              backgroundColor: AppColors.textPrimary, // Elegant dark theme for audio room
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              content: Container(
                width: 320,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated pulsar or connecting ring
                    connected
                        ? const CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.graphic_eq, color: Colors.white, size: 32),
                          )
                        : const SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 4,
                            ),
                          ),
                    const SizedBox(height: 24),
                    Text(
                      connected ? "ĐÃ THAM GIA PHÒNG" : "ĐANG KẾT NỐI REAL-TIME...",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Mentor chính: $mentor • 98% Reputation",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, color: Colors.white54, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Chế độ ẩn danh (Avatar Persona hoạt động)",
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.call_end),
                      label: const Text(
                        "Rời phòng Audio",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TOP WEEKLY MENTORS LEADERBOARD DESIGN
  // ==========================================
  Widget _buildLeaderboardWidget() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 20),
                  SizedBox(width: 6),
                  Text(
                    "BXH Mentor của Tuần 🏆",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "Xem tất cả",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          // Leaderboard top 3 rows
          _buildLeaderboardRow(1, "Professor K", "🇬🇧 Anh & Đức", "4.9k REP", Colors.amber.shade400, "PK"),
          const Divider(height: 16, color: AppColors.inputBorder),
          _buildLeaderboardRow(2, "Mei Ling", "🇨🇳 Tiếng Trung", "3.4k REP", Colors.grey.shade400, "ML"),
          const Divider(height: 16, color: AppColors.inputBorder),
          _buildLeaderboardRow(3, "Mina-san", "🇯🇵 Tiếng Nhật Bản", "3.2k REP", Colors.deepOrange.shade300, "MS"),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(
    int rank,
    String name,
    String language,
    String points,
    Color rankColor,
    String initials,
  ) {
    return Row(
      children: [
        // Rank circle badge
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rankColor.withOpacity(0.2),
          ),
          child: Center(
            child: Text(
              "$rank",
              style: TextStyle(
                color: rankColor.darken(0.3),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Simulated avatar
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                language,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),

        // Score points
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            points,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// VIRTUAL 3D/ANIME CUSTOM PAINTER FOR AVATAR
// ==========================================
class VirtualAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // 1. Draw glowing gradient cyber face outline
    final facePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));

    canvas.drawCircle(Offset(centerX, centerY), radius - 6, facePaint);

    // 2. Draw cute virtual Gen Z glowing visor shield
    final visorPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final visorPath = Path();
    visorPath.moveTo(centerX - 18, centerY - 8);
    visorPath.cubicTo(centerX - 10, centerY - 14, centerX + 10, centerY - 14, centerX + 18, centerY - 8);
    visorPath.cubicTo(centerX + 22, centerY + 2, centerX - 22, centerY + 2, centerX - 18, centerY - 8);
    visorPath.close();

    canvas.drawPath(visorPath, visorPaint);

    // 3. Draw a cute cyber ear/headphones highlight
    final earPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawArc(
      Rect.fromLTRB(4, 4, size.width - 4, size.height - 4),
      -math.pi * 0.95,
      math.pi * 0.45,
      false,
      earPaint,
    );
    canvas.drawArc(
      Rect.fromLTRB(4, 4, size.width - 4, size.height - 4),
      -math.pi * 0.5,
      math.pi * 0.45,
      false,
      earPaint,
    );

    // 4. Visor neon reflections (two small eyes / cute shine dots)
    final eyePaint = Paint()..color = const Color(0xFF06B6D4);
    canvas.drawCircle(Offset(centerX - 7, centerY - 6), 2, eyePaint);
    canvas.drawCircle(Offset(centerX + 7, centerY - 6), 2, eyePaint);

    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(centerX - 8, centerY - 7), 0.8, shinePaint);
    canvas.drawCircle(Offset(centerX + 6, centerY - 7), 0.8, shinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
