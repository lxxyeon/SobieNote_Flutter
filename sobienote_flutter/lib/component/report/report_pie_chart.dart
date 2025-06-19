import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sobienote_flutter/common/const/text_style.dart';
import 'package:sobienote_flutter/common/response/base_response.dart';

import '../../common/const/colors.dart';
import '../../report/response/report_response.dart';

class ReportPieChart extends StatefulWidget {
  final Future<BaseResponse<List<ReportResponse>>> emotions;

  const ReportPieChart({super.key, required this.emotions});

  @override
  State<ReportPieChart> createState() => _ReportPieChartState();
}

class _ReportPieChartState extends State<ReportPieChart> {
  int touchedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('소비하면서 느낀 감정이에요', style: kTitleTextStyle),
        ),
        renderPieChart(),
      ],
    );
  }

  Widget renderPieChart() {
    return FutureBuilder<BaseResponse<List<ReportResponse>>>(
      future: widget.emotions,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.data;
        final filtered =
            items.where((e) => e.value_cnt > 0).toList()
              ..sort((a, b) => b.value_cnt.compareTo(a.value_cnt));
        final top6 = filtered.take(6).toList();
        final totalCount = top6.fold<int>(
          0,
          (sum, item) => sum + item.value_cnt,
        );

        if (totalCount == 0 || top6.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text('감정 데이터가 없어요'),
          );
        }

        final List<Color> pieColors = [PIE1, PIE2, PIE3, PIE4, PIE5, PIE6];
        final touched =
            (touchedIndex >= 0 && touchedIndex < top6.length)
                ? top6[touchedIndex]
                : null;

        return AspectRatio(
          aspectRatio: 1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse?.touchedSection == null) {
                          touchedIndex = -1;
                        } else {
                          touchedIndex =
                              pieTouchResponse!
                                  .touchedSection!
                                  .touchedSectionIndex;
                        }
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  sections: List.generate(top6.length, (i) {
                    final emotion = top6[i];
                    return PieChartSectionData(
                      color: pieColors[i],
                      value: emotion.value_cnt.toDouble(),
                      title: '',
                      badgeWidget: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(102),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          emotion.keyword,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      radius: i == touchedIndex ? 65.0 : 60.0,
                    );
                  }),
                ),
              ),
              if (touched != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      touched.keyword,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    Text(
                      '${(touched.value_cnt / totalCount * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 21),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
