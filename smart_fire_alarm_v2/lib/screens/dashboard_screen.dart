import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_data.dart';
import '../widgets/sensor_card.dart';
import '../utils/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Stream Cảm biến (Realtime Data)
    final Stream<DocumentSnapshot> sensorStream = FirebaseFirestore.instance
        .collection('current_status')
        .doc('device_01')
        .snapshots();

    // 2. Stream Cấu hình (Settings - Để lấy ngưỡng cảnh báo)
    final Stream<DocumentSnapshot> configStream = FirebaseFirestore.instance
        .collection('devices_config')
        .doc('device_01')
        .snapshots();

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      // Dùng StreamBuilder lồng nhau để lấy cả 2 dữ liệu
      body: StreamBuilder<DocumentSnapshot>(
        stream: configStream, // Lắng nghe cấu hình trước
        builder: (context, configSnap) {
          // Giá trị mặc định nếu chưa load được config
          double tempThreshold = 50.0;
          double smokeThreshold = 2000.0;

          if (configSnap.hasData && configSnap.data!.exists) {
            final configData = configSnap.data!.data() as Map<String, dynamic>;
            if (configData['temp_threshold'] != null) {
              tempThreshold = (configData['temp_threshold']).toDouble();
            }
            if (configData['smoke_threshold'] != null) {
              smokeThreshold = (configData['smoke_threshold']).toDouble();
            }
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: sensorStream, // Lắng nghe cảm biến
            builder: (context, sensorSnap) {
              if (sensorSnap.hasError)
                return const Center(child: Text("Lỗi kết nối!"));
              if (sensorSnap.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!sensorSnap.hasData || !sensorSnap.data!.exists)
                return const Center(child: Text("Chưa có dữ liệu"));

              // Parse dữ liệu cảm biến
              final data = sensorSnap.data!.data() as Map<String, dynamic>;
              final sensor = SensorReading.fromMap(data);

              // --- LOGIC SO SÁNH VỚI NGƯỠNG ĐỘNG ---
              bool isTempAlert = sensor.temperature > tempThreshold;
              bool isSmokeAlert = sensor.mq2Adc > smokeThreshold;
              bool isFireAlert = sensor.flame; // Lửa thì luôn báo động

              bool isDanger = isTempAlert || isSmokeAlert || isFireAlert;

              Color headerColor = isDanger
                  ? AppColors.danger
                  : AppColors.primaryGreen;

              return Column(
                children: [
                  // --- HEADER ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDanger
                                ? Icons.warning_rounded
                                : Icons.check_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          isDanger ? "CẢNH BÁO NGUY HIỂM!" : "An Toàn",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isDanger
                              ? "Phát hiện: ${isFireAlert ? 'LỬA ' : ''}${isSmokeAlert ? 'KHÓI ' : ''}${isTempAlert ? 'NHIỆT ĐỘ CAO' : ''}"
                              : "Hệ thống hoạt động bình thường",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Cập nhật: ${_formatTime(sensor.timestamp)}",
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- GRID ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.1,
                        children: [
                          SensorCard(
                            title: "Nhiệt độ",
                            value:
                                "${sensor.temperature.toStringAsFixed(1)} °C",
                            icon: Icons.thermostat_rounded,
                            iconColor: Colors.orange,
                            isAlert: isTempAlert, // So sánh với ngưỡng cài đặt
                          ),
                          SensorCard(
                            title: "Độ ẩm",
                            value: "${sensor.humidity.toStringAsFixed(0)} %",
                            icon: Icons.water_drop_rounded,
                            iconColor: Colors.blue,
                          ),
                          SensorCard(
                            title: "Nồng độ Khói",
                            value: "${sensor.mq2Adc}",
                            icon: Icons.cloud,
                            iconColor: Colors.grey,
                            isAlert: isSmokeAlert, // So sánh với ngưỡng cài đặt
                          ),
                          SensorCard(
                            title: "Lửa",
                            value: sensor.flame ? "CÓ LỬA" : "An toàn",
                            icon: Icons.local_fire_department_rounded,
                            iconColor: Colors.red,
                            isAlert: isFireAlert,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }
}
