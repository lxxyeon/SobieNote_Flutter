import 'package:flutter/material.dart';
import 'package:sobienote_flutter/common/const/colors.dart';
import 'package:sobienote_flutter/common/const/text_style.dart';
import 'package:sobienote_flutter/common/response/base_response.dart';
import 'package:sobienote_flutter/report/response/report_response.dart';

class ReportCategory extends StatelessWidget {
  final Future<BaseResponse<List<ReportResponse>>> categories;

  const ReportCategory({required this.categories, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BaseResponse<List<ReportResponse>>>(
      future: categories,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var items = snapshot.data!.data;
        items.sort((a, b) => b.value_cnt.compareTo(a.value_cnt));
        items = items.take(14).toList();

        final top3Keywords = getTop3Ranks(items);

        final top3List = items.where((e) => top3Keywords.containsKey(e.keyword)).toList();
        final remaining = items.where((e) => !top3Keywords.containsKey(e.keyword)).toList();

        final half = (remaining.length / 2).ceil();
        final leftRemaining = remaining.sublist(0, half);
        final rightList = remaining.sublist(half);

        final leftList = [...top3List, ...leftRemaining];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이번 달엔 여기에 많이 썼어요', style: kTitleTextStyle),
            const SizedBox(height: 30),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildColumn(
                      leftList,
                      CrossAxisAlignment.end,
                      TextAlign.right,
                      top3Keywords,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: GRAY_06,
                    ),
                  ),
                  Expanded(
                    child: _buildColumn(
                      rightList,
                      CrossAxisAlignment.start,
                      TextAlign.left,
                      {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, int> getTop3Ranks(List<ReportResponse> items) {
    final filtered = items.where((e) => e.value_cnt > 0).toList();
    filtered.sort((a, b) => b.value_cnt.compareTo(a.value_cnt));

    final Map<String, int> topRanks = {};
    int? lastCnt;
    int rank = 0;

    for (final item in filtered) {
      if (topRanks.length >= 3) break;

      if (item.value_cnt != lastCnt) {
        rank = topRanks.length + 1;
      }
      topRanks[item.keyword] = rank;
      lastCnt = item.value_cnt;
    }

    return topRanks;
  }


  Widget _buildColumn(List<ReportResponse> categories,
      CrossAxisAlignment alignment,
      TextAlign textAlign,
      Map<String, int> topRanks,) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: alignment,
      children:
      categories.map((item) {
        final rank = topRanks[item.keyword];
        final isTop3 = rank != null;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isTop3)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Image.asset(
                    'assets/images/rank${rank}.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              Text(
                item.keyword,
                textAlign: textAlign,
                style: const TextStyle(fontSize: 16),
              ),
              Expanded(child: Container()),
              Text(
                '${item.value_cnt}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
