import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/sensor_data.dart';
import '../utils/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Mặc định xem Nhiệt độ
  String _selectedType = 'temp'; // 'temp', 'hum', 'smoke'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        title: const Text(
          "Lịch sử đo đạc",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút back vì nằm trong tab bar
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // --- 1. MENU CHỌN LOẠI DỮ LIỆU ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip(
                  'Nhiệt độ',
                  'temp',
                  Icons.thermostat,
                  Colors.orange,
                ),
                const SizedBox(width: 10),
                _buildFilterChip('Độ ẩm', 'hum', Icons.water_drop, Colors.blue),
                const SizedBox(width: 10),
                _buildFilterChip(
                  'Khói (MQ2)',
                  'smoke',
                  Icons.cloud,
                  Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- 2. BIỂU ĐỒ ---
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('sensor_logs')
                    .orderBy(
                      'timestamp',
                      descending: true,
                    ) // Lấy mới nhất trước
                    .limit(20) // Lấy 20 điểm dữ liệu
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return const Center(child: Text("Lỗi tải dữ liệu"));
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty)
                    return const Center(child: Text("Chưa có dữ liệu lịch sử"));

                  // Convert sang List Model và đảo ngược để vẽ từ trái (cũ) sang phải (mới)
                  List<SensorReading> dataList = docs
                      .map((d) {
                        return SensorReading.fromMap(
                          d.data() as Map<String, dynamic>,
                        );
                      })
                      .toList()
                      .reversed
                      .toList();

                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 &&
                                  index < dataList.length &&
                                  index % 4 == 0) {
                                // Hiển thị giờ cho mỗi điểm thứ 4
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat(
                                      'HH:mm',
                                    ).format(dataList[index].timestamp),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(dataList.length, (index) {
                            double val = 0;
                            if (_selectedType == 'temp')
                              val = dataList[index].temperature;
                            else if (_selectedType == 'hum')
                              val = dataList[index].humidity;
                            else
                              val = dataList[index].mq2Adc.toDouble();
                            return FlSpot(index.toDouble(), val);
                          }),
                          isCurved: true,
                          color: _getColor(),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: _getColor().withAlpha((0.2 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (_selectedType == 'temp') return Colors.orange;
    if (_selectedType == 'hum') return Colors.blue;
    return Colors.grey;
  }

  Widget _buildFilterChip(
    String label,
    String type,
    IconData icon,
    Color color,
  ) {
    bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withAlpha((0.4 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
