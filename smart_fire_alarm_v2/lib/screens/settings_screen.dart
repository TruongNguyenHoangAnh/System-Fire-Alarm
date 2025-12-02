import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Các giá trị mặc định
  double _currentInterval = 5.0;
  double _tempThreshold = 50.0; // Ngưỡng nhiệt độ mặc định
  double _smokeThreshold = 2000.0; // Ngưỡng khói mặc định

  final TextEditingController _deviceIdController = TextEditingController(
    text: "device_01",
  );
  final TextEditingController _ssidController = TextEditingController(
    text: "MyHomeWiFi",
  );
  final TextEditingController _passController = TextEditingController();

  final DocumentReference _configRef = FirebaseFirestore.instance
      .collection('devices_config')
      .doc('device_01');

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() async {
    try {
      final snapshot = await _configRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          if (data['send_interval'] != null) {
            _currentInterval = (data['send_interval'] / 1000).toDouble();
          }
          if (data['wifi_ssid'] != null)
            _ssidController.text = data['wifi_ssid'];
          if (data['device_id'] != null)
            _deviceIdController.text = data['device_id'];
          if (data['wifi_pass'] != null)
            _passController.text = data['wifi_pass'];

          // Load ngưỡng cài đặt (nếu có)
          if (data['temp_threshold'] != null) {
            _tempThreshold = (data['temp_threshold']).toDouble();
          }
          if (data['smoke_threshold'] != null) {
            _smokeThreshold = (data['smoke_threshold']).toDouble();
          }
        });
      }
    } catch (e) {
      print("Lỗi load config: $e");
    }
  }

  void _saveSettings() {
    int intervalMs = (_currentInterval * 1000).toInt();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Đang lưu cấu hình...")));

    _configRef
        .set({
          'send_interval': intervalMs,
          'wifi_ssid': _ssidController.text.trim(),
          'wifi_pass': _passController.text.trim(),
          'device_id': _deviceIdController.text.trim(),
          // Lưu thêm ngưỡng cảnh báo
          'temp_threshold': _tempThreshold,
          'smoke_threshold': _smokeThreshold,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Đã lưu cấu hình thành công!"),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Lỗi lưu: $error"),
              backgroundColor: AppColors.danger,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF8A65), AppColors.primaryOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Cài Đặt",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Điều chỉnh thông số thiết bị",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            // --- FORM ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(Icons.wifi, "Kết nối WiFi"),
                    const SizedBox(height: 15),
                    _buildTextField(_ssidController, "Tên WiFi (SSID)", false),
                    const SizedBox(height: 15),
                    _buildTextField(_passController, "Mật khẩu WiFi", true),

                    const Divider(height: 30),

                    _buildSectionTitle(
                      Icons.perm_device_information,
                      "Thông tin thiết bị",
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(_deviceIdController, "Device ID", false),

                    const Divider(height: 30),

                    // --- CẤU HÌNH NGƯỠNG CẢNH BÁO (MỚI) ---
                    _buildSectionTitle(
                      Icons.warning_amber_rounded,
                      "Ngưỡng Cảnh Báo",
                    ),

                    // 1. Ngưỡng Nhiệt độ
                    const SizedBox(height: 15),
                    _buildSliderLabel(
                      "Nhiệt độ báo động",
                      "${_tempThreshold.toInt()} °C",
                      Colors.red,
                    ),
                    Slider(
                      value: _tempThreshold,
                      min: 30,
                      max: 100,
                      divisions: 70,
                      activeColor: Colors.red,
                      inactiveColor: Colors.red.withValues(alpha: 0.2),
                      onChanged: (v) => setState(() => _tempThreshold = v),
                    ),

                    // 2. Ngưỡng Khói
                    _buildSliderLabel(
                      "Nồng độ Khói (Gas)",
                      "${_smokeThreshold.toInt()} PPM",
                      Colors.grey,
                    ),
                    Slider(
                      value: _smokeThreshold,
                      min: 500,
                      max: 4000,
                      divisions: 35,
                      activeColor: Colors.grey,
                      inactiveColor: Colors.grey.withValues(alpha: 0.2),
                      onChanged: (v) => setState(() => _smokeThreshold = v),
                    ),

                    const Divider(height: 30),

                    // Data Interval
                    _buildSliderLabel(
                      "Chu kỳ gửi dữ liệu",
                      "${_currentInterval.toInt()} giây",
                      AppColors.primaryOrange,
                    ),
                    Slider(
                      value: _currentInterval,
                      min: 1,
                      max: 60,
                      divisions: 59,
                      activeColor: AppColors.primaryOrange,
                      inactiveColor: AppColors.primaryOrange.withValues(
                        alpha: 0.2,
                      ),
                      onChanged: (v) => setState(() => _currentInterval = v),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Lưu cấu hình",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.logout, color: AppColors.danger),
                        label: const Text(
                          "Đăng Xuất",
                          style: TextStyle(color: AppColors.danger),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.danger),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted)
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderLabel(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isPass,
  ) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: hint,
        filled: true,
        fillColor: AppColors.bgGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple[300], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
