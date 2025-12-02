import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Hàm xử lý Đăng ký
  Future<void> _handleRegister() async {
    // 1. Validate cơ bản
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp")),
      );
      return;
    }

    // 2. Bắt đầu gửi yêu cầu
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. Thành công -> Tắt loading
      if (mounted) Navigator.pop(context);

      // 4. Hiện thông báo và quay về Login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng ký thành công! Vui lòng đăng nhập."),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context); // Quay lại trang Login
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context); // Tắt loading

      String message = "Lỗi đăng ký";
      if (e.code == 'weak-password') {
        message = "Mật khẩu quá yếu (cần >6 ký tự).";
      } else if (e.code == 'email-already-in-use')
        message = "Email này đã được đăng ký.";
      else if (e.code == 'invalid-email')
        message = "Email không hợp lệ.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_add_alt_1_rounded,
                size: 60,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(height: 10),
              const Text(
                "Tạo tài khoản",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Text(
                "Tham gia ngay để bảo vệ ngôi nhà của bạn",
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      _emailController,
                      "Email",
                      Icons.email_outlined,
                      false,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _passwordController,
                      "Password",
                      Icons.lock_outline,
                      true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _confirmPasswordController,
                      "Confirm Password",
                      Icons.verified_user,
                      true,
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Đăng ký",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    bool isPass,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
