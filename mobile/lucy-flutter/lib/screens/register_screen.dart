import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucy_app/screens/dashboard_screen.dart';
import 'package:lucy_app/services/app_session.dart';
import 'package:lucy_app/services/auth_api.dart';
import 'package:lucy_app/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authApi = AuthApi();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _wantsLearner = true;
  bool _wantsMentor = false;
  bool _isSubmitting = false;
  PlatformFile? _certificateFile;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 450),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'LUC', style: TextStyle(color: AppColors.primary)),
                          TextSpan(text: 'Y', style: TextStyle(color: Colors.orange.shade300)),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chọn vai trò phù hợp để bắt đầu với LUCY.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  _buildLabel('Họ và tên'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _nameController, hintText: 'Nguyễn Văn A'),
                  const SizedBox(height: 20),
                  _buildLabel('Địa chỉ Email'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _emailController, hintText: 'hello@lucy.app'),
                  const SizedBox(height: 20),
                  _buildLabel('Số điện thoại'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _phoneController, hintText: '0912345678'),
                  const SizedBox(height: 20),
                  _buildRoleSection(),
                  if (_wantsMentor) ...[
                    const SizedBox(height: 20),
                    _buildCertificatePicker(),
                  ],
                  const SizedBox(height: 20),
                  _buildLabel('Mật khẩu'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: '........',
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onTogglePassword: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Nhập lại mật khẩu'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: '........',
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onTogglePassword: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Đăng ký',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Đã có tài khoản? ",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Đăng nhập ngay',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Bạn muốn đăng ký với vai trò là gì?'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Column(
            children: [
              CheckboxListTile(
                value: _wantsLearner,
                onChanged: (value) {
                  setState(() {
                    _wantsLearner = value ?? false;
                    if (!_wantsLearner && !_wantsMentor) _wantsMentor = true;
                  });
                },
                title: const Text('Người học', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Truy cập trang học ngay sau khi đăng ký.'),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: 1),
              CheckboxListTile(
                value: _wantsMentor,
                onChanged: (value) {
                  setState(() {
                    _wantsMentor = value ?? false;
                    if (!_wantsLearner && !_wantsMentor) _wantsLearner = true;
                  });
                },
                title: const Text('Mentor', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Cần upload chứng chỉ và chờ admin duyệt.'),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCertificatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Ảnh chứng chỉ mentor'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickCertificate,
          icon: const Icon(Icons.upload_file),
          label: Text(
            _certificateFile == null ? 'Chọn ảnh chứng chỉ từ máy tính' : _certificateFile!.name,
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            side: const BorderSide(color: AppColors.inputBorder),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _certificateFile = result.files.first);
  }

  Future<void> _submitRegister() async {
    final validation = _validate();
    if (validation != null) {
      _showSnack(validation);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      AuthSession? session;

      if (_wantsMentor) {
        await _authApi.registerMentor(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
          certificateFile: _certificateFile,
        );

        if (_wantsLearner) {
          session = await _authApi.login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          session = await _collectLearnerAvatar(session);
          if (session == null) return;
          await _showResultDialog(
            title: 'Đăng ký thành công',
            message: 'Bạn có thể truy cập tài khoản người học ngay. Hồ sơ mentor sẽ chờ admin duyệt.',
            actionText: 'Vào trang người học',
            onAction: () => _goHome(session!),
          );
        } else {
          await _showResultDialog(
            title: 'Chờ admin duyệt',
            message: 'Hồ sơ mentor của bạn đã được gửi. Bạn cần chờ admin duyệt trước khi truy cập khu vực mentor.',
            actionText: 'Quay lại đăng nhập',
            onAction: () => Navigator.pop(context),
          );
        }
      } else {
        session = await _authApi.registerLearner(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
        );
        session = await _collectLearnerAvatar(session);
        if (session == null) return;
        await _showResultDialog(
          title: 'Đăng ký thành công',
          message: 'Bạn đã đăng ký thành công và có thể truy cập ngay.',
          actionText: 'Vào trang người học',
          onAction: () => _goHome(session!),
        );
      }
    } on AuthApiException catch (error) {
      _showSnack(error.message);
    } catch (_) {
      _showSnack('Không kết nối được Lucy.Auth.Api. Hãy kiểm tra backend đang chạy.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) return 'Vui lòng nhập họ và tên.';
    if (_emailController.text.trim().isEmpty) return 'Vui lòng nhập email.';
    if (_phoneController.text.trim().length != 10) return 'Số điện thoại cần đúng 10 số.';
    if (!_wantsLearner && !_wantsMentor) return 'Vui lòng chọn ít nhất một vai trò.';
    if (_wantsMentor && _certificateFile == null) return 'Vui lòng upload ảnh chứng chỉ mentor.';
    if (_passwordController.text.length < 6) return 'Mật khẩu cần ít nhất 6 ký tự.';
    if (_passwordController.text != _confirmPasswordController.text) return 'Mật khẩu nhập lại không khớp.';
    return null;
  }

  Future<AuthSession?> _collectLearnerAvatar(AuthSession session) async {
    final displayNameController = TextEditingController(text: session.fullName);
    PlatformFile? avatarFile;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Hoàn tất hồ sơ người học'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Hãy nhập tên sẽ hiển thị và upload ảnh đại diện.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: displayNameController,
                    decoration: InputDecoration(
                      labelText: 'Tên hiển thị',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                        withData: true,
                      );
                      if (result == null || result.files.isEmpty) return;
                      setDialogState(() => avatarFile = result.files.first);
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      avatarFile == null ? 'Upload ảnh đại diện' : avatarFile!.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    final name = displayNameController.text.trim();
    displayNameController.dispose();

    if (confirmed != true) return null;
    return _authApi.updateAvatar(
      token: session.accessToken,
      displayName: name.isEmpty ? session.fullName : name,
      avatarFile: avatarFile,
    );
  }

  Future<void> _showResultDialog({
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onAction();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(actionText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _goHome(AuthSession session) {
    AppSession.set(session);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(
          role: LucyRole.anonymous,
          allowedRoles: {LucyRole.anonymous},
        ),
      ),
      (route) => false,
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? (obscureText ?? true) : false,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (obscureText ?? true) ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
