import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucy_app/services/auth_api.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/theme/app_colors.dart';
import 'package:lucy_app/services/lms_api.dart';
import 'package:lucy_app/services/payment_api.dart';
import 'package:lucy_app/services/realtime_socket_service.dart';
import 'package:lucy_app/screens/live_learner_room_dialog.dart';

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

  final LmsApi _lmsApi = LmsApi();
  final PaymentApi _paymentApi = PaymentApi();
  final RealtimeSocketService _realtimeSocket = RealtimeSocketService();
  List<LmsRoom> _allRooms = [];
  List<LmsRoomHistory> _joinedRoomHistory = [];
  List<CreatorPaidContent> _publishedVideos = [];
  bool _isLoading = false;
  bool _isHistoryLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, initialIndex: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
        _fetchRooms();
        _fetchJoinedRoomHistory();
      }
    });
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);

    _fetchRooms();
    _fetchJoinedRoomHistory();

    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchRooms();
      _fetchJoinedRoomHistory();
    });
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final rooms = await _lmsApi.getAllRooms();
      final videos = await _lmsApi.getPublishedVideos();
      if (mounted) {
        setState(() {
          _allRooms = rooms;
          _publishedVideos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải danh sách phòng: $e')),
        );
      }
    }
  }

  Future<void> _fetchJoinedRoomHistory() async {
    final session = AppSession.current;
    if (session == null) return;
    setState(() {
      _isHistoryLoading = true;
    });
    try {
      final history = await _lmsApi.getJoinedRoomHistory(session.userId);
      if (mounted) {
        setState(() {
          _joinedRoomHistory = history;
          _isHistoryLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isHistoryLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _realtimeSocket.disconnect();
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Active rooms are fetched from LmsApi.


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
        if (_tabController.index == 0)
          _buildJoinedRoomHistorySection()
        else if (_tabController.index == 1)
          _buildCreatorContentSection()
        else
          _buildLiveRoomsGrid(
            _tabController.index == 2
                ? 'ENG'
                : _tabController.index == 3
                    ? 'CHI'
                    : 'JAP',
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
                  "${AppSession.current?.displayName ?? 'Polyglot Ẩn Danh'} ✨",
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
              if (_allRooms.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hiện không có phòng live nào hoạt động để tham gia nhanh!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              setState(() {
                _isJoiningRandom = true;
              });
              final randomRoom = _allRooms[math.Random().nextInt(_allRooms.length)];
              _joinLearnerRoom(randomRoom).whenComplete(() {
                if (mounted) {
                  setState(() {
                    _isJoiningRandom = false;
                  });
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
          Tab(text: "Lịch sử"),
          Tab(text: "⭐ Creator"),
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
  Widget _buildJoinedRoomHistorySection() {
    if (_isHistoryLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_joinedRoomHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: const Text(
          "Chua co lich su phong ban da tham gia.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lich su phong ban da tham gia",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._joinedRoomHistory.map(_buildHistoryRoomTile),
      ],
    );
  }

  Widget _buildHistoryRoomTile(LmsRoomHistory room) {
    final endedAt = room.endedAt;
    final endedText = endedAt == null
        ? room.roomStatus
        : "${endedAt.day}/${endedAt.month}/${endedAt.year}";
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.history, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.roomTitle,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Mentor: ${room.mentorName} | Level ${room.levelNumber ?? 0}",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            endedText,
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRoomsGrid(String languageKey) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final list = _allRooms.where((room) {
      if (room.languageId == null) return false;
      return room.languageId == languageKey;
    }).toList();

    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            "Hiện chưa có phòng Live trực tiếp cho ngôn ngữ này.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
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

  Widget _buildRoomGridCard(LmsRoom room) {
    final languageKey = _tabController.index == 2
        ? 'ENG'
        : _tabController.index == 3
            ? 'CHI'
            : 'JAP';
    Color cardColor;
    List<Color> bgColors;
    if (languageKey == 'ENG') {
      cardColor = const Color(0xFF64C3A5);
      bgColors = const [Color(0xFFECFDF5), Color(0xFFD1FAE5)];
    } else if (languageKey == 'CHI') {
      cardColor = const Color(0xFFEF4444);
      bgColors = const [Color(0xFFFEF2F2), Color(0xFFFEE2E2)];
    } else {
      cardColor = const Color(0xFF8B5CF6);
      bgColors = const [Color(0xFFF5F3FF), Color(0xFFEDE9FE)];
    }

    final listenersCount = room.participantCount;

    return GestureDetector(
      onTap: () async {
        final session = AppSession.current;
        if (session == null || session.userId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập để tham gia phòng!')),
          );
          return;
        }

        await _joinLearnerRoom(room);
      },
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
                            color: (room.roomStatus.toUpperCase() == 'SCHEDULED' ? Colors.blue : Colors.red)
                                .withOpacity(_pulseAnimation.value),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        room.roomStatus.toUpperCase() == 'SCHEDULED' ? "LÊN LỊCH" : "LIVE",
                        style: TextStyle(
                          fontSize: 8,
                          color: room.roomStatus.toUpperCase() == 'SCHEDULED' ? Colors.blue : Colors.red,
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
                      "$listenersCount",
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
              room.roomTitle,
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
              "Mentor: ${room.mentorName ?? room.hostUserId}",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Level Tag Capsule
            if (room.roomType != 'FREESTYLE')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cardColor.withOpacity(0.15)),
                ),
                child: Text(
                  room.levelNumber != null ? 'Level ${room.levelNumber}' : (room.levelId ?? 'Level 1'),
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

  static final Set<String> _purchasedRoomIds = {};

  Future<void> _joinLearnerRoom(LmsRoom room) async {
    final session = AppSession.current;
    if (session == null || session.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long dang nhap de tham gia phong!')),
      );
      return;
    }

    final isPaidRoom = room.accessType?.toUpperCase() == 'PAID' || (room.priceAmount ?? 0) > 0;
    if (isPaidRoom && !_purchasedRoomIds.contains(room.roomId)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mua ve live'),
          content: Text('Phong nay co phi ' + (room.priceAmount?.toStringAsFixed(0) ?? '0') + ' Xu. Ban muon thanh toan bang vi khong?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huy')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Thanh toan')),
          ],
        ),
      );
      if (confirmed != true) return;
      try {
        await _paymentApi.purchaseLive(room.roomId);
        _purchasedRoomIds.add(room.roomId);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Khong mua duoc ve live: ' + e.toString())),
        );
        return;
      }
    }

    final messenger = ScaffoldMessenger.of(context);
    var restJoined = false;
    try {
      await _lmsApi.joinRoom(roomId: room.roomId, userId: session.userId);
      restJoined = true;
      await _realtimeSocket.joinRoom(
        roomId: room.roomId,
        userId: session.userId,
        displayName: _sessionDisplayName(session),
      );
      _fetchRooms();

      if (!mounted) return;

      _showAgoraCallSimulation(
        roomId: room.roomId,
        title: room.roomTitle,
        mentor: room.mentorName ?? room.hostUserId,
        hostUserId: room.hostUserId,
        levelId: room.levelId,
        languageId: room.languageId,
      );
    } catch (e) {
      if (restJoined) {
        try {
          await _lmsApi.leaveRoom(roomId: room.roomId, userId: session.userId);
        } catch (_) {}
      }
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Khong the tham gia phong: $e')),
        );
      }
    }
  }

  String _sessionDisplayName(AuthSession session) {
    final displayName = session.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    return 'Learner ${session.userId.length > 4 ? session.userId.substring(session.userId.length - 4) : session.userId}';
  }

  void _showAgoraCallSimulation({
    required String roomId,
    required String title,
    required String mentor,
    required String hostUserId,
    String? levelId,
    String? languageId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LiveLearnerRoomDialog(
          roomId: roomId,
          title: title,
          mentor: mentor,
          hostUserId: hostUserId,
          levelId: levelId,
          languageId: languageId,
        ),
      ),
    ).then((_) {
      _fetchRooms();
      _fetchJoinedRoomHistory();
    });
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

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: const Text(
              "Chưa có dữ liệu xếp hạng mentor.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
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

  Widget _buildCreatorContentSection() {
    final creatorLives = _allRooms.where((r) => (r.roomType != null && r.roomType!.toUpperCase().contains('CREATOR')) || (r.priceAmount != null && r.priceAmount! > 0)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (creatorLives.isNotEmpty) ...[
          const Text(
            "Live Creator đang mở",
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: creatorLives.length,
            itemBuilder: (context, index) => _buildRoomGridCard(creatorLives[index]),
          ),
          const SizedBox(height: 24),
        ],
        const Text(
          "Video Creator đang bán",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (!_isLoading && _publishedVideos.isEmpty)
          _buildInfoBox('Chưa có video nào được publish trong PaidContents.'),
        if (!_isLoading) ..._publishedVideos.map((video) => _buildLearnerVideoCard(video, purchased: false)),
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
                  builder: (context) => AlertDialog(
                    title: Text(video.title),
                    content: Text(url.isEmpty ? 'Video này chưa có media URL.' : 'Media URL: $url'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
                    ],
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
      await _fetchRooms();
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


