import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm import này

class SensorReading {
  final double temperature;
  final double humidity;
  final bool flame;
  final int mq2Adc;
  final bool gas;
  final DateTime timestamp; // Thêm trường thời gian để hiển thị

  SensorReading({
    required this.temperature,
    required this.humidity,
    required this.flame,
    required this.mq2Adc,
    required this.gas,
    required this.timestamp,
  });

  // Hàm parse từ Firestore (Map<String, dynamic>)
  factory SensorReading.fromMap(Map<String, dynamic> data) {
    // Hàm phụ để ép kiểu số an toàn
    double parseDouble(dynamic val) {
      if (val is int) return val.toDouble();
      if (val is double) return val;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return 0;
    }

    // Xử lý Timestamp của Firestore
    DateTime ts = DateTime.now();
    if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
      ts = (data['timestamp'] as Timestamp).toDate();
    }

    return SensorReading(
      temperature: parseDouble(data['temperature']),
      humidity: parseDouble(data['humidity']),

      // Sơn đặt tên là 'flame_detected' trong hình, code cũ là 'flame'
      // Hãy sửa cho khớp với hình của Sơn:
      flame: data['flame_detected'] == true,

      // Sơn đặt tên là 'gas_value'
      mq2Adc: parseInt(data['gas_value']),

      // Tự tính gas từ giá trị mq2 nếu db không có trường gas riêng
      gas: parseInt(data['gas_value']) > 2000,

      timestamp: ts,
    );
  }
}
