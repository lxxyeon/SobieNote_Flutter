import 'package:flutter/material.dart';
import 'package:sobienote_flutter/common/const/colors.dart';

class TopSheetSelector extends StatelessWidget {
  final bool isVisible;
  final double topOffset;
  final int selectedMonth;
  final int selectedYear;
  final int tabIndex;
  final bool? isSelectingYear;
  final VoidCallback? onToggleMode;
  final ValueChanged<int> onMonthSelected;
  final ValueChanged<int> onYearSelected;

  const TopSheetSelector({
    super.key,
    required this.isVisible,
    required this.topOffset,
    required this.selectedMonth,
    required this.selectedYear,
    required this.tabIndex,
    this.isSelectingYear,
    this.onToggleMode,
    required this.onMonthSelected,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return SizedBox.shrink();

    final isYearMode = isSelectingYear ?? (tabIndex == 1);

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onToggleMode != null)
                GestureDetector(
                  onTap: onToggleMode ?? () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$selectedYear년',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              isYearMode
                  ? _buildGrid(
                    context,
                    12,
                    (i) => '${2014 + i}년',
                    selectedYear,
                    onYearSelected,
                    baseValue: 2014,
                  )
                  : _buildGrid(
                    context,
                    12,
                    (i) => '${i + 1}월',
                    selectedMonth,
                    onMonthSelected,
                    baseValue: 1,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    int count,
    String Function(int) labelBuilder,
    int selectedValue,
    ValueChanged<int> onSelect, {
    int baseValue = 0,
  }) {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: 3 / 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: List.generate(count, (i) {
        final value = baseValue + i;
        final isSelected = selectedValue == value;

        return GestureDetector(
          onTap: () => onSelect(value),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? DARK_TEAL : KEYPAD_GRAY,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              labelBuilder(i),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        );
      }),
    );
  }
}
