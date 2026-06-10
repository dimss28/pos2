import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

/// Mini 7-day trend chart with filled gradient area + polyline.
/// Highlights the last (or [highlightIndex]) point.
///
/// Maps to: `TrendChart` in `.claude/new-design/screens/report.jsx`.
class AppTrendChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final int? highlightIndex;
  final double height;

  const AppTrendChart({
    super.key,
    required this.data,
    required this.labels,
    this.highlightIndex,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    assert(data.length == labels.length,
        'data and labels must be the same length');
    final hi = highlightIndex ?? data.length - 1;

    final maxY = data.isEmpty ? 1.0 : data.reduce((a, b) => a > b ? a : b);
    final spots = <FlSpot>[
      for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i]),
    ];

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: maxY * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: AppTypography.labelM.copyWith(
                        color: p.onSurfaceVar,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: p.primary,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) {
                  final isHi = spot.x.toInt() == hi;
                  return FlDotCirclePainter(
                    radius: isHi ? 5 : 3,
                    color: isHi ? p.primary : Colors.white,
                    strokeColor: p.primary,
                    strokeWidth: 2,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    p.primary.withValues(alpha: 0.22),
                    p.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
