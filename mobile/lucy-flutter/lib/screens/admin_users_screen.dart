import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/services/auth_api.dart';
import 'package:lucy_app/services/lms_api.dart';
import 'package:lucy_app/services/payment_api.dart';
import 'package:lucy_app/theme/app_colors.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _authApi = AuthApi();
  final _paymentApi = PaymentApi();
  final _lmsApi = LmsApi();
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  
  // Tab index: 0 = Tài khoản, 1 = Đơn Mentor, 2 = Yêu cầu Creator, 3 = Nạp Xu, 4 = Rút Xu, 5 = Import DOCX
  int _currentTab = 0;

  // Tab 0: Tài khoản state
  String? _selectedRole = 'R002';
  int _currentPage = 1;
  AdminUsersPage? _page;

  // Tab 1 & 2: Applications state
  List<AdminApplication> _mentorApps = [];
  List<AdminApplication> _creatorRequests = [];
  List<TopUpOrder> _topUpOrders = [];
  List<WithdrawRequestInfo> _withdrawRequests = [];
  List<ImportedDocxFile> _importedDocxFiles = [];
  PaymentSetting? _momoSetting;
  PaymentWallet? _adminWallet;
  String? _selectedAppStatus;

  @override
  void initState() {
    super.initState();
    _loadTabCachedData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTabCachedData() {
    if (_currentTab == 0) {
      _loadUsers();
    } else if (_currentTab == 1) {
      _loadMentorApplications();
    } else if (_currentTab == 2) {
      _loadCreatorUpgradeRequests();
    } else if (_currentTab == 3) {
      _loadTopUpOrders();
    } else if (_currentTab == 4) {
      _loadWithdrawRequests();
    } else if (_currentTab == 5) {
      _loadImportedDocxFiles();
    }
  }

  void _switchTab(int tabIndex) {
    setState(() {
      _currentTab = tabIndex;
      _error = null;
      _selectedAppStatus = null;
    });
    _loadTabCachedData();
  }

  Future<void> _loadUsers() async {
    final session = AppSession.current;
    if (session == null) {
      setState(() => _error = 'Chưa có phiên đăng nhập admin.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await _authApi.getAdminUsers(
        token: session.accessToken,
        keyword: _searchController.text,
        role: _selectedRole,
        page: _currentPage,
      );
      if (!mounted) return;
      setState(() => _page = page);
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Không kết nối được Lucy.Auth.Api.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadImportedDocxFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final files = await _lmsApi.getImportedDocxFiles();
      if (!mounted) return;
      setState(() {
        _importedDocxFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _pickAndUploadDocx() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _lmsApi.uploadImportedDocx(
        file: result.files.first,
        uploadedBy: AppSession.current?.userId,
      );
      await _loadImportedDocxFiles();
      if (!mounted) return;
      _showSuccessSnack('File DOCX đã được upload và parser thành công.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _loadMentorApplications() async {
    final session = AppSession.current;
    if (session == null) {
      setState(() => _error = 'Chưa có phiên đăng nhập admin.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apps = await _authApi.getMentorApplications(
        token: session.accessToken,
        status: _selectedAppStatus,
      );
      if (!mounted) return;
      setState(() => _mentorApps = apps);
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Không kết nối được Lucy.Auth.Api.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCreatorUpgradeRequests() async {
    final session = AppSession.current;
    if (session == null) {
      setState(() => _error = 'Chưa có phiên đăng nhập admin.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reqs = await _authApi.getCreatorUpgradeRequests(
        token: session.accessToken,
        status: _selectedAppStatus,
      );
      if (!mounted) return;
      setState(() => _creatorRequests = reqs);
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Không kết nối được Lucy.Auth.Api.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTopUpOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final setting = await _paymentApi.getMomoSetting();
      final orders = await _paymentApi.getAdminTopUpOrders(status: _selectedAppStatus ?? 'PENDING');
      if (!mounted) return;
      setState(() {
        _momoSetting = setting;
        _topUpOrders = orders;
      });
    } on PaymentApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Khong ket noi duoc Lucy.AuthPayment.Api.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWithdrawRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final wallet = await _paymentApi.getWallet();
      final requests = await _paymentApi.getAdminWithdrawRequests(status: _selectedAppStatus ?? 'PENDING');
      if (!mounted) return;
      setState(() {
        _adminWallet = wallet;
        _withdrawRequests = requests;
      });
    } on PaymentApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Khong ket noi duoc Lucy.AuthPayment.Api.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = _page?.users ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Quản trị hệ thống',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Theo dõi tài khoản, phê duyệt Mentor ứng tuyển và nâng cấp Creator.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 18),
        _buildTabBar(),
        if (_currentTab == 0) ...[
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildRoleFilters(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Tổng tài khoản', '${_page?.total ?? users.length}', AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Đang hoạt động', '${users.where((u) => u.isStatus != 0).length}', Colors.orange.shade400)),
            ],
          ),
          const SizedBox(height: 18),
        ] else if (_currentTab == 3) ...[
          _buildTopUpToolbar(),
          const SizedBox(height: 12),
          _buildTopUpStatusFilters(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Tổng đơn nạp', '${_topUpOrders.length}', AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Chờ duyệt', '${_topUpOrders.where((o) => o.orderStatus == "PENDING").length}', Colors.orange.shade400)),
            ],
          ),
          const SizedBox(height: 18),
        ] else if (_currentTab == 4) ...[
          _buildWithdrawToolbar(),
          const SizedBox(height: 12),
          _buildWithdrawStatusFilters(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Ví Xu admin', '${(_adminWallet?.balance ?? 0).toStringAsFixed(0)} Xu', AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Phí trong danh sách', '${_withdrawRequests.fold<num>(0, (sum, item) => sum + item.feeAmount).toStringAsFixed(0)} Xu', Colors.orange.shade400)),
            ],
          ),
          const SizedBox(height: 18),
        ] else if (_currentTab == 5) ...[
          _buildDocxImportToolbar(),
          const SizedBox(height: 18),
        ] else ...[
          _buildStatusFilters(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Tong don',
                  '${_currentTab == 1 ? _mentorApps.length : _creatorRequests.length}',
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Chờ duyệt',
                  '${_currentTab == 1 ? _mentorApps.where((a) => a.status == "PENDING").length : _creatorRequests.where((a) => a.status == "PENDING").length}',
                  Colors.orange.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.primary))
        else if (_error != null)
          _buildErrorCard(_error!)
        else if (_currentTab == 0 && users.isEmpty)
          _buildEmptyCard()
        else if (_currentTab == 1 && _mentorApps.isEmpty)
          _buildEmptyCard()
        else if (_currentTab == 2 && _creatorRequests.isEmpty)
          _buildEmptyCard()
        else if (_currentTab == 3 && _topUpOrders.isEmpty)
          _buildEmptyCard()
        else if (_currentTab == 4 && _withdrawRequests.isEmpty)
          _buildEmptyCard()
        else if (_currentTab == 5 && _importedDocxFiles.isEmpty)
          _buildEmptyCard()
        else ...[
          if (_currentTab == 0) ...[
            ...users.map(_buildUserCard),
            _buildPager(),
          ] else if (_currentTab == 1) ...[
            ..._mentorApps.map(_buildApplicationCard),
          ] else if (_currentTab == 2) ...[
            ..._creatorRequests.map(_buildApplicationCard),
          ] else if (_currentTab == 3) ...[
            ..._topUpOrders.map(_buildTopUpOrderCard),
          ] else if (_currentTab == 4) ...[
            ..._withdrawRequests.map(_buildWithdrawRequestCard),
          ] else if (_currentTab == 5) ...[
            ..._importedDocxFiles.map(_buildImportedDocxCard),
          ],
        ],
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      (label: 'Tài khoản', index: 0, icon: Icons.people_outline),
      (label: 'Đơn Mentor', index: 1, icon: Icons.school_outlined),
      (label: 'Yêu cầu Creator', index: 2, icon: Icons.workspace_premium_outlined),
      (label: 'Nap Xu', index: 3, icon: Icons.account_balance_wallet_outlined),
      (label: 'Rút Xu', index: 4, icon: Icons.payments_outlined),
      (label: 'Import DOCX', index: 5, icon: Icons.upload_file_outlined),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _currentTab == tab.index;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchTab(tab.index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 16,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab.label,
                      style: TextStyle(
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
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

  Widget _buildDocxImportToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Import giáo trình DOCX', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Upload file DOCX để hệ thống kiểm tra, parser và lưu vào import-docx.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _pickAndUploadDocx,
            icon: const Icon(Icons.upload_file, size: 16),
            label: const Text('Upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportedDocxCard(ImportedDocxFile file) {
    final status = file.importStatus.toUpperCase();
    final color = status == 'IMPORTED'
        ? Colors.green.shade600
        : status == 'FAILED'
            ? Colors.red.shade600
            : Colors.orange.shade700;
    final levelRange = file.levelStart == null || file.levelEnd == null
        ? 'Chưa xác định level'
        : 'Level ${file.levelStart}-${file.levelEnd}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file_outlined, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.fileName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${file.languageId ?? 'Chưa có ngôn ngữ'} • $levelRange', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                if (file.errorMessage != null && file.errorMessage!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(file.errorMessage!, style: TextStyle(color: Colors.red.shade600, fontSize: 11)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên, email hoặc số điện thoại',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              ),
              onChanged: (_) {
                setState(() {
                  _currentPage = 1;
                });
                _loadUsers();
              },
              onSubmitted: (_) {
                _currentPage = 1;
                _loadUsers();
              },
            ),
          ),
          IconButton(
            onPressed: () {
              _currentPage = 1;
              _loadUsers();
            },
            icon: const Icon(Icons.refresh, color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilters() {
    final filters = <({String label, String? role, Color color})>[
      (label: 'Người học', role: 'R002', color: AppColors.primary),
      (label: 'Admin', role: 'R001', color: Colors.indigo),
      (label: 'Mentor', role: 'R003', color: Colors.orange),
      (label: 'Creator', role: 'R004', color: Colors.purple),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedRole == filter.role;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(filter.label),
              onSelected: (_) {
                setState(() {
                  _selectedRole = filter.role;
                  _currentPage = 1;
                });
                _loadUsers();
              },
              selectedColor: filter.color.withOpacity(0.15),
              backgroundColor: Colors.white,
              side: BorderSide(color: selected ? filter.color : AppColors.inputBorder),
              labelStyle: TextStyle(
                color: selected ? filter.color : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopUpToolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_2_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _momoSetting == null
                  ? 'Chưa cấu hình MoMo admin'
                  : 'MoMo: ${_momoSetting!.receiverName} - ${_momoSetting!.receiverPhone}',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton.icon(
            onPressed: _showMomoSettingDialog,
            icon: const Icon(Icons.settings_outlined, size: 16),
            label: const Text('Cấu hình'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpStatusFilters() {
    final filters = <({String label, String status, Color color})>[
      (label: 'Chờ duyệt', status: 'PENDING', color: Colors.orange),
      (label: 'Đã duyệt', status: 'PAID', color: Colors.green),
      (label: 'Từ chối', status: 'FAILED', color: Colors.red),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final selected = (_selectedAppStatus ?? 'PENDING') == filter.status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(filter.label),
              onSelected: (_) {
                setState(() => _selectedAppStatus = filter.status);
                _loadTopUpOrders();
              },
              selectedColor: filter.color.withOpacity(0.15),
              backgroundColor: Colors.white,
              side: BorderSide(color: selected ? filter.color : AppColors.inputBorder),
              labelStyle: TextStyle(color: selected ? filter.color : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWithdrawToolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Yêu cầu rút Xu: duyệt sau khi đã chuyển khoản số tiền thực nhận cho người dùng.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: _loadWithdrawRequests,
            icon: const Icon(Icons.refresh, color: AppColors.primaryDark),
            tooltip: 'Tải lại',
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawStatusFilters() {
    final filters = <({String label, String status, Color color})>[
      (label: 'Chờ duyệt', status: 'PENDING', color: Colors.orange),
      (label: 'Đã duyệt', status: 'SUCCESS', color: Colors.green),
      (label: 'Từ chối', status: 'FAILED', color: Colors.red),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final selected = (_selectedAppStatus ?? 'PENDING') == filter.status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(filter.label),
              onSelected: (_) {
                setState(() => _selectedAppStatus = filter.status);
                _loadWithdrawRequests();
              },
              selectedColor: filter.color.withOpacity(0.15),
              backgroundColor: Colors.white,
              side: BorderSide(color: selected ? filter.color : AppColors.inputBorder),
              labelStyle: TextStyle(color: selected ? filter.color : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusFilters() {
    final filters = <({String label, String? status, Color color})>[
      (label: 'Tất cả', status: null, color: AppColors.textSecondary),
      (label: 'Chờ duyệt', status: 'PENDING', color: Colors.orange),
      (label: 'Đã duyệt', status: 'APPROVED', color: Colors.green),
      (label: 'Từ chối', status: 'REJECTED', color: Colors.red),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedAppStatus == filter.status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(filter.label),
              onSelected: (_) {
                setState(() {
                  _selectedAppStatus = filter.status;
                });
                if (_currentTab == 1) {
                  _loadMentorApplications();
                } else {
                  _loadCreatorUpgradeRequests();
                }
              },
              selectedColor: filter.color.withOpacity(0.15),
              backgroundColor: Colors.white,
              side: BorderSide(color: selected ? filter.color : AppColors.inputBorder),
              labelStyle: TextStyle(
                color: selected ? filter.color : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Text(message, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: const Column(
        children: [
          Icon(Icons.manage_search, color: AppColors.textSecondary, size: 32),
          SizedBox(height: 8),
          Text(
            'Chưa có dữ liệu phù hợp.',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(AdminUser user) async {
    final session = AppSession.current;
    if (session == null) return;

    if (user.userId == session.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không thể tự khóa tài khoản của chính mình!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final nextStatus = user.isStatus == 0 ? 1 : 0;
    final actionText = nextStatus == 0 ? 'khóa' : 'mở khóa';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Xác nhận $actionText', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn $actionText tài khoản ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: nextStatus == 0 ? Colors.red.shade400 : AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(nextStatus == 0 ? 'Khóa' : 'Mở khóa', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authApi.updateUserStatus(
        token: session.accessToken,
        userId: user.userId,
        isStatus: nextStatus,
      );
      _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã $actionText tài khoản thành công!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Không kết nối được Lucy.Auth.Api.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildUserCard(AdminUser user) {
    final avatarUrl = _absoluteAvatarUrl(user.avatarUrl);
    final isSelf = user.userId == AppSession.current?.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
            child: avatarUrl == null
                ? Text(
                    user.fullName.isEmpty ? '?' : user.fullName.characters.first.toUpperCase(),
                    style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 3),
                Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 3),
                Text(user.phoneNumber, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 3),
                Text('Đăng ký: ${_formatDate(user.createdAt)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: user.roles.map(_buildRoleChip).toList(),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                user.isStatus == 0 ? Icons.lock_outline : Icons.verified_user_outlined,
                color: user.isStatus == 0 ? Colors.red.shade300 : AppColors.primary,
              ),
              if (!isSelf) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _toggleUserStatus(user),
                  icon: Icon(
                    user.isStatus == 0 ? Icons.lock_open_outlined : Icons.lock_outline,
                    color: user.isStatus == 0 ? Colors.green.shade600 : Colors.red.shade400,
                    size: 20,
                  ),
                  tooltip: user.isStatus == 0 ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                  style: IconButton.styleFrom(
                    backgroundColor: user.isStatus == 0 ? Colors.green.shade50 : Colors.red.shade50,
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpOrderCard(TopUpOrder order) {
    final statusColor = switch (order.orderStatus) {
      'PENDING' => Colors.orange,
      'PAID' => Colors.green,
      'FAILED' => Colors.red,
      _ => AppColors.textSecondary,
    };
    final isPending = order.orderStatus == 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Đơn: ${order.topUpOrderId}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(order.orderStatus, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('User: ${order.userId}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text('Số tiền: ${order.amount.toStringAsFixed(0)} VND', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
          Text('Số Xu cộng khi duyệt: ${order.coins.toStringAsFixed(0)} Xu', style: const TextStyle(color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.bold)),
          if (order.transferContent != null) ...[
            const SizedBox(height: 8),
            const Text('Nội dung learner cần chuyển:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
            SelectableText(order.transferContent!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
          ],
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectTopUpOrder(order),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: BorderSide(color: Colors.red.shade200)),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveTopUpOrder(order),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('Duyệt'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWithdrawRequestCard(WithdrawRequestInfo request) {
    final statusColor = switch (request.requestStatus) {
      'PENDING' => Colors.orange,
      'SUCCESS' => Colors.green,
      'FAILED' => Colors.red,
      _ => AppColors.textSecondary,
    };
    final isPending = request.requestStatus == 'PENDING';
    final vndAmount = request.netAmount * 1000;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Yêu cầu: ${request.withdrawRequestId}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(request.requestStatus, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('User: ${request.userId}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text('Ngân hàng: ${request.bankName}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
          SelectableText('Số tài khoản: ${request.bankAccountNumber}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          SelectableText('Chủ tài khoản: ${request.bankAccountName}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAmountChip('Khóa từ ví', '${request.amount.toStringAsFixed(0)} Xu', AppColors.primary),
              _buildAmountChip('Phí admin ${request.feePercent.toStringAsFixed(0)}%', '${request.feeAmount.toStringAsFixed(0)} Xu', Colors.orange),
              _buildAmountChip('Thực chuyển', '${request.netAmount.toStringAsFixed(0)} Xu', Colors.green),
              _buildAmountChip('Quy đổi', '${vndAmount.toStringAsFixed(0)} VND', Colors.indigo),
            ],
          ),
          if (request.rejectReason != null && request.rejectReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Lý do từ chối: ${request.rejectReason}', style: TextStyle(color: Colors.red.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectWithdrawRequest(request),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: BorderSide(color: Colors.red.shade200)),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveWithdrawRequest(request),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('Đã chuyển khoản'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _showMomoSettingDialog() async {
    final receiverNameController = TextEditingController(text: _momoSetting?.receiverName ?? 'System Admin');
    final receiverPhoneController = TextEditingController(text: _momoSetting?.receiverPhone ?? '');
    final templateController = TextEditingController(text: _momoSetting?.transferContentTemplate ?? 'LUCY NAP TIEN {ORDER_CODE}');
    PlatformFile? selectedQrFile;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cấu hình MoMo admin'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: receiverNameController, decoration: const InputDecoration(labelText: 'Tên người nhận')),
                TextField(controller: receiverPhoneController, decoration: const InputDecoration(labelText: 'Số điện thoại MoMo')),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
                      withData: true,
                    );
                    if (picked == null || picked.files.isEmpty) return;
                    setDialogState(() => selectedQrFile = picked.files.first);
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(selectedQrFile == null ? 'Chọn ảnh QR từ máy' : 'Đã chọn: ${selectedQrFile!.name}', overflow: TextOverflow.ellipsis),
                ),
                if (_momoSetting?.qrImageUrl != null && selectedQrFile == null) ...[
                  const SizedBox(height: 8),
                  const Text('Đang dùng QR đã upload trước đó.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 12),
                TextField(controller: templateController, decoration: const InputDecoration(labelText: 'Nội dung chuyển khoản mẫu')),
                const SizedBox(height: 8),
                const Text(
                  '{ORDER_CODE} là mã đơn nạp tiền do hệ thống tự tạo. Learner phải ghi mã này trong nội dung chuyển khoản để admin đối chiếu đúng đơn khi duyệt.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
          ],
        ),
      ),
    );
    if (shouldSave != true) return;

    try {
      await _paymentApi.saveMomoSetting(
        receiverName: receiverNameController.text.trim(),
        receiverPhone: receiverPhoneController.text.trim(),
        qrImageUrl: _momoSetting?.qrImageUrl,
        transferContentTemplate: templateController.text.trim(),
      );
      if (selectedQrFile != null) {
        await _paymentApi.uploadMomoQr(selectedQrFile!);
      }
      await _loadTopUpOrders();
      _showSuccessSnack('Đã lưu cấu hình MoMo.');
    } catch (e) {
      setState(() => _error = 'Không lưu được cấu hình MoMo: $e');
    }
  }

  Future<void> _approveTopUpOrder(TopUpOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyệt nạp Xu'),
        content: Text('Xác nhận đã nhận ${order.amount.toStringAsFixed(0)} VND từ user ${order.userId}? Hệ thống sẽ cộng ${order.coins.toStringAsFixed(0)} Xu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Duyệt')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _paymentApi.approveTopUpOrder(order.topUpOrderId);
      await _loadTopUpOrders();
      _showSuccessSnack('Đã duyệt và cộng Xu vào ví learner.');
    } catch (e) {
      setState(() => _error = 'Không duyệt được đơn nạp: $e');
    }
  }

  Future<void> _rejectTopUpOrder(TopUpOrder order) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối don nap'),
        content: TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Ly do'), maxLines: 2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, reasonController.text.trim()), child: const Text('Từ chối')),
        ],
      ),
    );
    if (reason == null) return;
    try {
      await _paymentApi.rejectTopUpOrder(order.topUpOrderId, reason: reason);
      await _loadTopUpOrders();
      _showSuccessSnack('Đã từ chối đơn nạp.');
    } catch (e) {
      setState(() => _error = 'Không từ chối được đơn nạp: $e');
    }
  }

  Future<void> _approveWithdrawRequest(WithdrawRequestInfo request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyệt rút Xu'),
        content: Text(
          'Xác nhận admin đã chuyển ${request.netAmount.toStringAsFixed(0)} Xu '
          '(${(request.netAmount * 1000).toStringAsFixed(0)} VND) cho ${request.bankAccountName}? '
          'Hệ thống sẽ ghi nhận phí admin ${request.feeAmount.toStringAsFixed(0)} Xu.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xác nhận')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _paymentApi.approveWithdrawRequest(request.withdrawRequestId);
      await _loadWithdrawRequests();
      _showSuccessSnack('Đã duyệt yêu cầu rút tiền và ghi nhận phí admin.');
    } catch (e) {
      setState(() => _error = 'Không duyệt được yêu cầu rút tiền: $e');
    }
  }

  Future<void> _rejectWithdrawRequest(WithdrawRequestInfo request) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối rút Xu'),
        content: TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Lý do'), maxLines: 2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, reasonController.text.trim()), child: const Text('Từ chối')),
        ],
      ),
    );
    if (reason == null) return;
    try {
      await _paymentApi.rejectWithdrawRequest(request.withdrawRequestId, reason: reason);
      await _loadWithdrawRequests();
      _showSuccessSnack('Đã từ chối yêu cầu rút tiền và hoàn Xu cho người dùng.');
    } catch (e) {
      setState(() => _error = 'Không từ chối được yêu cầu rút tiền: $e');
    }
  }

  Widget _buildApplicationCard(AdminApplication app) {
    final statusColor = switch (app.status) {
      'PENDING' => Colors.orange,
      'APPROVED' => Colors.green,
      'REJECTED' => Colors.red,
      _ => AppColors.textSecondary,
    };

    final statusText = switch (app.status) {
      'PENDING' => 'Chờ duyệt',
      'APPROVED' => 'Đã duyệt',
      'REJECTED' => 'Đã từ chối',
      _ => app.status,
    };

    final isPending = app.status == 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã: ${app.applicationId}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'ID người dùng: ${app.userId}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Ngày nộp: ${_formatDate(app.submittedAt)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          if (app.rejectReason != null && app.rejectReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Text(
                'Lý do từ chối: ${app.rejectReason}',
                style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(app),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApprove(app),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Phê duyệt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleApprove(AdminApplication app) async {
    final session = AppSession.current;
    if (session == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xác nhận duyệt', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn duyệt đơn này không? Người dùng sẽ được cấp quyền ${_currentTab == 1 ? "Mentor" : "Creator"}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Duyệt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_currentTab == 1) {
        await _authApi.approveMentorApplication(
          token: session.accessToken,
          applicationId: app.applicationId,
        );
      } else {
        await _authApi.approveCreatorUpgradeRequest(
          token: session.accessToken,
          requestId: app.applicationId,
        );
      }
      _showSuccessSnack('Phê duyệt đơn thành công.');
      _loadTabCachedData();
    } on AuthApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = 'Có lỗi xảy ra khi gọi API.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showRejectDialog(AdminApplication app) async {
    final session = AppSession.current;
    if (session == null) return;

    final reasonController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Từ chối đơn', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Vui lòng nhập lý do từ chối:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Lý do từ chối...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final val = reasonController.text.trim();
              if (val.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do.'), behavior: SnackBarBehavior.floating),
                );
                return;
              }
              Navigator.pop(context, val);
            },
            child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_currentTab == 1) {
        await _authApi.rejectMentorApplication(
          token: session.accessToken,
          applicationId: app.applicationId,
          reason: result,
        );
      } else {
        await _authApi.rejectCreatorUpgradeRequest(
          token: session.accessToken,
          requestId: app.applicationId,
          reason: result,
        );
      }
      _showSuccessSnack('Đã từ chối đơn.');
      _loadTabCachedData();
    } on AuthApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = 'Có lỗi xảy ra khi gọi API.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
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

  Widget _buildRoleChip(RoleInfo role) {
    final color = switch (role.roleId) {
      'R001' => Colors.indigo,
      'R002' => AppColors.primary,
      'R003' => Colors.orange,
      'R004' => Colors.purple,
      _ => AppColors.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        '${role.roleId} • ${role.roleName}',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPager() {
    final page = _page;
    if (page == null) return const SizedBox.shrink();
    final hasPrevious = _currentPage > 1;
    final hasNext = _currentPage * page.size < page.total;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: hasPrevious
              ? () {
                  setState(() => _currentPage -= 1);
                  _loadUsers();
                }
              : null,
          icon: const Icon(Icons.chevron_left),
          color: AppColors.primaryDark,
        ),
        Text(
          'Trang $_currentPage',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: hasNext
              ? () {
                  setState(() => _currentPage += 1);
                  _loadUsers();
                }
              : null,
          icon: const Icon(Icons.chevron_right),
          color: AppColors.primaryDark,
        ),
      ],
    );
  }
}


