import 'package:flutter/material.dart';
import 'package:lucy_app/theme/app_colors.dart';
import 'package:lucy_app/screens/lucy_anonymous_home.dart';
import 'package:lucy_app/screens/lucy_pro_home.dart';
import 'package:lucy_app/screens/lucy_super_home.dart';
import 'package:lucy_app/screens/lucy_anonymous_tabs.dart';
import 'package:lucy_app/screens/lucy_pro_tabs.dart';
import 'package:lucy_app/screens/lucy_super_tabs.dart';

enum LucyRole {
  anonymous, // LUCY (Anonymous User)
  proMentor, // LUCY Pro (Mentor)
  superCreator // LUCY Super (Content Creator)
}

class DashboardScreen extends StatefulWidget {
  final LucyRole role;
  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late LucyRole _currentRole;
  int _navIndex = 0;
  String? _selectedLanguageFilter = 'LISA';

  @override
  void initState() {
    super.initState();
    _currentRole = widget.role;
    if (_currentRole == LucyRole.anonymous) {
      SharedAudioState.currentTitle.value = "LISTENING IN: French Cafe Vibe...";
    } else if (_currentRole == LucyRole.proMentor) {
      SharedAudioState.currentTitle.value = "Weekly Mentor Brief - Lvl 12";
    } else if (_currentRole == LucyRole.superCreator) {
      SharedAudioState.currentTitle.value = "Weekly Analytics Brief - Live";
    }
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
          bottom: false,
          child: Column(
            children: [
              // Top Custom App Bar with Logo & Settings & Interactive Role Switcher
              _buildTopHeader(),
              _buildRoleSelector(),

              // Core Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildRoleSpecificBody(),
                        const SizedBox(height: 100), // Padding to prevent overlay with bottom widgets
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBarWithMiniPlayer(),
    );
  }

  // ==========================================
  // TOP BAR & ROLE SWITCHER
  // ==========================================

  Widget _buildTopHeader() {
    String roleAvatarText = "S";
    Color avatarColor = AppColors.primary;
    if (_currentRole == LucyRole.anonymous) {
      roleAvatarText = "👤";
      avatarColor = Colors.orange.shade300;
    } else if (_currentRole == LucyRole.proMentor) {
      roleAvatarText = "M";
      avatarColor = Colors.purple.shade300;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Avatar / Persona Ring
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: avatarColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: avatarColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: _currentRole == LucyRole.anonymous
                      ? const Text("👤", style: TextStyle(fontSize: 22))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            color: avatarColor.withOpacity(0.15),
                            child: Center(
                              child: Text(
                                roleAvatarText,
                                style: TextStyle(
                                  color: avatarColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentRole == LucyRole.anonymous
                        ? "Persona Ẩn Danh"
                        : "Alex Rivera",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _currentRole == LucyRole.anonymous
                        ? "Học tập ẩn danh"
                        : _currentRole == LucyRole.proMentor
                            ? "LVL 12 • 98% Uy tín"
                            : "Super Creator Tier ✪",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // App Title Logo matching Login
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'LUC', style: TextStyle(color: AppColors.primary)),
                TextSpan(text: 'Y', style: TextStyle(color: Colors.orange.shade300)),
              ],
            ),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),

          // Settings Button
          IconButton(
            onPressed: () {
              // Sign out or settings popup
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text("Tùy chọn", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  content: const Text("Bạn có muốn đăng xuất khỏi ứng dụng LUCY?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Hủy", style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to login
                      },
                      child: const Text("Đăng xuất", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.04),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
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
        children: LucyRole.values.map((role) {
          bool isSelected = _currentRole == role;
          String label = "";
          IconData icon = Icons.person;

          switch (role) {
            case LucyRole.anonymous:
              label = "Ẩn danh (LUCY)";
              icon = Icons.visibility_off_outlined;
              break;
            case LucyRole.proMentor:
              label = "Pro (Mentor)";
              icon = Icons.school_outlined;
              break;
            case LucyRole.superCreator:
              label = "Super Creator";
              icon = Icons.workspace_premium_outlined;
              break;
          }

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentRole = role;
                  if (role == LucyRole.anonymous) {
                    SharedAudioState.currentTitle.value = "LISTENING IN: French Cafe Vibe...";
                  } else if (role == LucyRole.proMentor) {
                    SharedAudioState.currentTitle.value = "Weekly Mentor Brief - Lvl 12";
                  } else if (role == LucyRole.superCreator) {
                    SharedAudioState.currentTitle.value = "Weekly Analytics Brief - Live";
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // DISPATCH CORE BODY BY ROLE
  // ==========================================

  Widget _buildRoleSpecificBody() {
    switch (_navIndex) {
      case 0: // Bảng tin (Home)
        switch (_currentRole) {
          case LucyRole.anonymous:
            return const LucyAnonymousHome();
          case LucyRole.proMentor:
            return const LucyProHome();
          case LucyRole.superCreator:
            return const LucySuperHome();
        }
      case 1: // Khám phá (Explore)
        switch (_currentRole) {
          case LucyRole.anonymous:
            return const LucyAnonymousExplore();
          case LucyRole.proMentor:
            return const LucyProExplore();
          case LucyRole.superCreator:
            return const LucySuperExplore();
        }
      case 2: // Central Action
        return _buildCentralQuickActionView();
      case 3: // Thư viện (Library)
        switch (_currentRole) {
          case LucyRole.anonymous:
            return const LucyAnonymousLibrary();
          case LucyRole.proMentor:
            return const LucyProLibrary();
          case LucyRole.superCreator:
            return const LucySuperLibrary();
        }
      case 4: // Cá nhân (Profile)
        switch (_currentRole) {
          case LucyRole.anonymous:
            return const LucyAnonymousProfile();
          case LucyRole.proMentor:
            return const LucyProProfile();
          case LucyRole.superCreator:
            return const LucySuperProfile();
        }
      default:
        return const LucyAnonymousHome();
    }
  }

  Widget _buildCentralQuickActionView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1.1),
            duration: const Duration(seconds: 1),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "KẾT NỐI AGORA SIÊU TỐC ⚡",
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tự động tìm kiếm và đồng bộ hóa các luồng âm thanh phù hợp nhất với cấp độ học của bạn bằng Agora RTC SDK.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("⚡ Đang quét các phòng Live Audio real-time gần nhất..."),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("QUÉT AGORA CHANNELS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 1: ANONYMOUS USER (LUCY)
  // ==========================================

  Widget _buildAnonymousView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome Text
        const Text(
          "Chào bạn, Polyglot!",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Học tập thoải mái, giảm áp lực giao tiếp cùng Lucy.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Search Learning Room
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const TextField(
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Tìm kiếm phòng học trực tuyến...",
              hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Jump into Survival Speaking Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF7AD9BD), Color(0xFFFFCC80)],
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
                        "SẴN SÀNG ĐỂ NÓI?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Tham Gia Phòng\nSurvival Speaking ⚡",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Giao tiếp ẩn danh 100% giảm e ngại",
                      style: TextStyle(
                        color: Color(0xFFEEEEEE),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.bolt,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Live Now Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Phòng đang Live hot 🔥",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Xem tất cả",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal List of Live Rooms
        SizedBox(
          height: 155,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildLiveRoomCard(
                language: "English",
                level: "Level 1-5 (Survival)",
                participantsCount: 14,
                gradientColors: [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                borderColor: AppColors.primary,
              ),
              const SizedBox(width: 16),
              _buildLiveRoomCard(
                language: "Chinese (中文)",
                level: "Level 11-15 (HSK 1-2)",
                participantsCount: 8,
                gradientColors: [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
                borderColor: Colors.orange.shade300,
              ),
              const SizedBox(width: 16),
              _buildLiveRoomCard(
                language: "Japanese (日本語)",
                level: "Level 21-25 (JLPT N5)",
                participantsCount: 6,
                gradientColors: [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                borderColor: Colors.purple.shade200,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Top Mentors List
        const Text(
          "Mentor hàng đầu tuần này 🌟",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            children: [
              _buildMentorListItem(
                rank: 1,
                name: "Professor K",
                subject: "English & German Expert",
                repScore: 4982,
                avatarInitials: "PK",
                rankColor: Colors.amber.shade400,
              ),
              const Divider(height: 1, color: AppColors.inputBorder),
              _buildMentorListItem(
                rank: 2,
                name: "Mina-san",
                subject: "Japanese Native Educator",
                repScore: 3211,
                avatarInitials: "MS",
                rankColor: Colors.grey.shade400,
              ),
              const Divider(height: 1, color: AppColors.inputBorder),
              _buildMentorListItem(
                rank: 3,
                name: "Juan Rivera",
                subject: "Spanish & Chinese Bilingual",
                repScore: 2845,
                avatarInitials: "JR",
                rankColor: Colors.deepOrange.shade300,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveRoomCard({
    required String language,
    required String level,
    required int participantsCount,
    required List<Color> gradientColors,
    required Color borderColor,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "LIVE",
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.red,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    "$participantsCount",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
          const Spacer(),
          Text(
            language,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            level,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Small avatars overlapping
              _buildMiniAvatarOverlap(),
              const SizedBox(width: 8),
              Text(
                "+$participantsCount người khác",
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniAvatarOverlap() {
    return SizedBox(
      width: 44,
      height: 20,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: CircleAvatar(radius: 9, backgroundColor: Colors.teal.shade100, child: const Text("👱", style: TextStyle(fontSize: 10))),
            ),
          ),
          Positioned(
            left: 12,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: CircleAvatar(radius: 9, backgroundColor: Colors.orange.shade100, child: const Text("👩", style: TextStyle(fontSize: 10))),
            ),
          ),
          Positioned(
            left: 24,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: CircleAvatar(radius: 9, backgroundColor: Colors.indigo.shade100, child: const Text("👦", style: TextStyle(fontSize: 10))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorListItem({
    required int rank,
    required String name,
    required String subject,
    required int repScore,
    required String avatarInitials,
    required Color rankColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 28,
            height: 28,
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
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              avatarInitials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subject,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Rep Score Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$repScore",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Text(
                "REP SCORE",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 2: PRO MENTOR VIEW (LUCY PRO)
  // ==========================================

  Widget _buildProMentorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome and Rating Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Thống kê tổng quan 📈",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 14),
                  SizedBox(width: 4),
                  Text(
                    "98% Reputation",
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 12),

        // Total Earnings Main Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TỔNG THU NHẬP",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$4,280.50",
                    style: TextStyle(
                      color: Colors.orange.shade400, // Golden accent matching the mockup
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.green.shade600, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "+12.5% tuần này",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Sub Grid stats (Gifts & Credits)
        Row(
          children: [
            Expanded(
              child: _buildSubStatCard(
                icon: Icons.card_giftcard,
                value: "128",
                label: "Gifts nhận được",
                iconColor: Colors.pink.shade300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSubStatCard(
                icon: Icons.shield_outlined,
                value: "2.4k",
                label: "Credits tích lũy",
                iconColor: Colors.indigo.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Create Room CTA
        const Text(
          "Điều phối buổi Live 🎙️",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đang khởi tạo phòng Live mới cho Mentor...'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
          label: const Text(
            "TẠO PHÒNG LIVE DẠY HỌC",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 2,
            shadowColor: AppColors.primary.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 12),

        // Curriculum Filter Chips (LISA, Chinese, Japanese)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['LISA', 'Chinese (中文)', 'Japanese (日本語)'].map((subject) {
              bool isSelected = _selectedLanguageFilter == subject;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    subject,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedLanguageFilter = selected ? subject : null;
                    });
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.inputBorder,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Today's Schedule
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lịch trình dạy học hôm nay 📅",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "24 Oct, 2023",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildScheduleItemCard(
          dateDay: "14",
          dateMonth: "OCT",
          title: "Advanced Conversational Mandarin",
          subTitle: "Chủ đề: Thương thảo hợp đồng (Business Negotiations)",
          statusTag: "LIVE SAU 2H",
          isLiveSoon: true,
          registeredCount: 14,
          accentColor: Colors.orange.shade400,
        ),
        const SizedBox(height: 12),

        _buildScheduleItemCard(
          dateDay: "16",
          dateMonth: "OCT",
          title: "LISA Co-teaching Lab",
          subTitle: "Phân hệ: Ngôn ngữ đường phố & Thành ngữ (Slang & Idioms)",
          statusTag: "16:30 - 17:30 GMT",
          isLiveSoon: false,
          registeredCount: 32,
          accentColor: AppColors.primary,
        ),
        const SizedBox(height: 24),

        // Heatmap Section
        const Row(
          children: [
            Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              "Mức độ tương tác học viên (Heatmap)",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
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
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildHeatmapBar(heightPercent: 0.35, label: "T2"),
                    _buildHeatmapBar(heightPercent: 0.55, label: "T3"),
                    _buildHeatmapBar(heightPercent: 0.25, label: "T4"),
                    _buildHeatmapBar(heightPercent: 0.90, label: "T5", isHighlight: true),
                    _buildHeatmapBar(heightPercent: 0.45, label: "T6"),
                    _buildHeatmapBar(heightPercent: 0.30, label: "T7"),
                    _buildHeatmapBar(heightPercent: 0.70, label: "CN"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItemCard({
    required String dateDay,
    required String dateMonth,
    required String title,
    required String subTitle,
    required String statusTag,
    required bool isLiveSoon,
    required int registeredCount,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date block
          Container(
            width: 52,
            height: 60,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dateDay,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  dateMonth,
                  style: TextStyle(
                    color: accentColor.darken(0.15),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLiveSoon ? Colors.red.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusTag,
                        style: TextStyle(
                          color: isLiveSoon ? Colors.red.shade700 : Colors.blue.shade700,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subTitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildMiniAvatarOverlap(),
                    const SizedBox(width: 8),
                    Text(
                      "$registeredCount người đăng ký",
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
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
    );
  }

  Widget _buildHeatmapBar({
    required double heightPercent,
    required String label,
    bool isHighlight = false,
  }) {
    Color barColor = isHighlight ? Colors.amber.shade400 : AppColors.primary.withOpacity(0.6);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 24,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                gradient: LinearGradient(
                  colors: [barColor.withOpacity(0.8), barColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: FractionallySizedBox(
                heightFactor: heightPercent,
                child: const SizedBox(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 3: SUPER CREATOR (LUCY SUPER)
  // ==========================================

  Widget _buildSuperCreatorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Heading
        const Text(
          "Chào mừng trở lại, Alex 👋",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Cộng đồng đang rất sôi động. Có 12 lives được lên lịch tuần này.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Community Growth Card (Bezier curve chart drawing)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.inputBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CỘNG ĐỒNG PHÁT TRIỂN",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "+12.5k học viên mới",
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.trending_up, color: AppColors.primaryDark, size: 12),
                        SizedBox(width: 3),
                        Text(
                          "Live",
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Bezier Custom Painter Chart
              SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(
                  painter: BezierCurveChartPainter(
                    curveColor: AppColors.primary,
                    fillGradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.0)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Metrics Row (Earnings & Course enrollments)
        Row(
          children: [
            Expanded(
              child: _buildCreatorMetricCard(
                title: "THU NHẬP TUẦN",
                value: "\$4,280.50",
                subText: "↑ 18% vs tuần trước",
                borderAccent: Colors.purple.shade200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCreatorMetricCard(
                title: "KHÓA HỌC ĐĂNG KÝ",
                value: "1,842",
                subText: "Học viên đang học",
                borderAccent: Colors.green.shade200,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Podcast Management Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Quản lý Podcast phát sóng 🎧",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Text(
                    "View Studio",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 6),

        _buildPodcastListItem(
          episodeTitle: "Digital Nomads: Ep. 42",
          views: "14.2k lượt nghe",
          earnings: "\$342.00 kiếm được",
          statusTag: "ĐÃ GHI ÂM",
          iconColor: Colors.blue.shade400,
        ),
        const SizedBox(height: 12),

        _buildPodcastListItem(
          episodeTitle: "The Future of AI in Art",
          views: "8.9k lượt nghe",
          earnings: "\$186.50 kiếm được",
          statusTag: "ĐÃ GHI ÂM",
          iconColor: Colors.deepOrange.shade300,
        ),
        const SizedBox(height: 24),

        // Quick Go Live card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.textPrimary, // Matching dark premium look but clean contrast
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Go Live Ngay Bây Giờ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Phát sóng trực tiếp và kết nối cùng cộng đồng học viên.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Premium Series Banner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
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
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "⚡ GỢI Ý CÔNG CỤ AI",
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Tạo chuỗi bài học\nPremium Series tiếp theo 🚀",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Trí tuệ nhân tạo LUCY AI dự đoán chủ đề 'Web3 Marketing & English' có tiềm năng vượt trội hơn 92% nội dung hiện tại của bạn.",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Horizontal action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade100,
                        foregroundColor: Colors.purple.shade700,
                        elevation: 0,
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Bắt đầu chuỗi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.inputBorder),
                        foregroundColor: AppColors.textPrimary,
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Xem phân tích", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Mini Revenue Card inside Premium Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.inputBorder.withOpacity(0.6)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "DỰ ĐOÁN DOANH THU",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "/ 30 ngày",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$12.5k USD",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Chuyển đổi: 6.4%", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text("Thích thú: Rất Cao", style: TextStyle(fontSize: 9, color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorMetricCard({
    required String title,
    required String value,
    required String subText,
    required Color borderAccent,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderAccent.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastListItem({
    required String episodeTitle,
    required String views,
    required String earnings,
    required String statusTag,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Simulated thumbnail
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.play_circle_fill, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),

          // Core Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episodeTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      views,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      earnings,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "ĐÃ LƯU",
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // NAVIGATION & MINI AUDIO PLAYER BAR
  // ==========================================

  Widget _buildBottomNavigationBarWithMiniPlayer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating active audio bar matching design mockups
          ValueListenableBuilder<String>(
            valueListenable: SharedAudioState.currentTitle,
            builder: (context, songTitle, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: SharedAudioState.isPlaying,
                builder: (context, isPlaying, _) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        // Audio Wave Visualizer representation
                        Icon(
                          Icons.graphic_eq,
                          color: isPlaying ? AppColors.primary : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            songTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 20),
                          onPressed: () {
                            // Dummy skip
                          },
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            SharedAudioState.isPlaying.value = !isPlaying;
                          },
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.skip_next, color: Colors.white, size: 20),
                          onPressed: () {
                            // Dummy skip
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // Standard Bottom Navigation Items
          BottomNavigationBar(
            currentIndex: _navIndex,
            onTap: (index) {
              setState(() {
                _navIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: "Bảng tin",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                label: "Khám phá",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                label: "",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined),
                label: "Thư viện",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: "Cá nhân",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CUSTOM BEZIER CHART PAINTER FOR CREATOR
// ==========================================

class BezierCurveChartPainter extends CustomPainter {
  final Color curveColor;
  final Gradient fillGradient;

  BezierCurveChartPainter({required this.curveColor, required this.fillGradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = curveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final pathLine = Path();
    
    // Draw a wave matching the exact style of mockup 1
    pathLine.moveTo(0, size.height * 0.7);
    pathLine.cubicTo(
      size.width * 0.2, size.height * 0.75,
      size.width * 0.35, size.height * 0.95,
      size.width * 0.5, size.height * 0.4,
    );
    pathLine.cubicTo(
      size.width * 0.65, size.height * 0.0,
      size.width * 0.8, size.height * 0.85,
      size.width * 0.9, size.height * 0.7,
    );
    pathLine.cubicTo(
      size.width * 0.95, size.height * 0.65,
      size.width * 0.98, size.height * 0.35,
      size.width, size.height * 0.3,
    );

    // Create a path for filling gradient under the line
    final pathFill = Path.from(pathLine);
    pathFill.lineTo(size.width, size.height);
    pathFill.lineTo(0, size.height);
    pathFill.close();

    final paintFill = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw the gradient filled area first
    canvas.drawPath(pathFill, paintFill);

    // Draw the Bezier line on top
    canvas.drawPath(pathLine, paintLine);

    // Draw active dot at 90% of graph as shown in design mockup
    final dotPaint = Paint()
      ..color = curveColor
      ..style = PaintingStyle.fill;
    final dotStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dotX = 0.9 * 280; // approximate placement on screen width
    // target point y calculations
    final targetY = size.height * 0.7; // approximate matching placement on curve
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.72), 6, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.72), 6, dotStrokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extra visual styles mapping
extension ColorsExtra on Colors {
  static const Color whiteEE = Color(0xFFEEEEEE);
}
