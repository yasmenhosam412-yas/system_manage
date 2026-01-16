import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PerformanceChart extends StatelessWidget {
  final int present;
  final int remote;
  final int onLeave;
  final int completedTasks;
  final int allTasks;

  const PerformanceChart({
    super.key,
    required this.present,
    required this.remote,
    required this.onLeave,
    required this.completedTasks,
    required this.allTasks,
  });

  @override
  Widget build(BuildContext context) {
    int totalAttendance = present + remote + onLeave;
    double attendanceScore = totalAttendance == 0
        ? 0
        : (present + 0.5 * remote) / totalAttendance * 100;
    double taskScore = completedTasks / allTasks * 100;
    double performanceScore = (attendanceScore * 0.6 + taskScore * 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Performance Score: ${performanceScore.toStringAsFixed(1)}%",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  ([
                    present.toDouble(),
                    remote.toDouble(),
                    onLeave.toDouble(),
                    completedTasks.toDouble(),
                  ].reduce((a, b) => a > b ? a : b)) +
                  5,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Present');
                        case 1:
                          return const Text('Remote');
                        case 2:
                          return const Text('On Leave');
                        case 3:
                          return const Text('Tasks');
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: present.toDouble(),
                      color: Colors.green,
                      width: 20,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: remote.toDouble(),
                      color: Colors.orange,
                      width: 20,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: onLeave.toDouble(),
                      color: Colors.red,
                      width: 20,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [
                    BarChartRodData(
                      toY: completedTasks.toDouble(),
                      color: Colors.blue,
                      width: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
