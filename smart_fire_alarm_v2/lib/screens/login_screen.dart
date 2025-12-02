import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- LOGIC ĐĂNG NHẬP GOOGLE (MỚI) ---
  Future<void> _handleGoogleLogin() async {
    try {
      // 1. Mở cửa sổ chọn tài khoản Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return; // Người dùng bấm hủy
      }

      // Hiện loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // 2. Lấy thông tin xác thực
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Tạo chứng chỉ (Credential) cho Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập vào Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) Navigator.pop(context); // Tắt loading

      // 5. Vào màn hình chính
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng nhập Google thành công!"),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("Lỗi Google: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi đăng nhập Google. Vui lòng kiểm tra SHA-1."),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // --- LOGIC ĐĂNG NHẬP EMAIL (CŨ) ---
  Future<void> _handleLogin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      String message = "Lỗi đăng nhập";
      if (e.code == 'user-not-found' || e.code == 'invalid-credential')
        message = "Sai email hoặc mật khẩu.";
      else if (e.code == 'wrong-password')
        message = "Sai mật khẩu.";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 50,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Fire Alarm System",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Text(
                "Keep your space safe and monitored",
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_emailController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty) {
                            _handleLogin();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Vui lòng nhập đủ thông tin"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Center(
                      child: Text("or", style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 20),

                    // --- NÚT GOOGLE (ĐÃ GẮN HÀM) ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        icon: Image.asset(
                          'assets/google.png',
                          height: 24,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.g_mobiledata, color: Colors.red),
                        ),
                        label: const Text(
                          "Continue with Google",
                          style: TextStyle(color: AppColors.textDark),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        onPressed: _handleGoogleLogin, // <--- GỌI HÀM Ở ĐÂY
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Bạn chưa có tài khoản? ",
                            style: TextStyle(color: AppColors.textGrey),
                            children: [
                              TextSpan(
                                text: "Tạo tài khoản",
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
