import 'package:flutter/material.dart';
import 'package:sobienote_flutter/common/const/colors.dart';

class GenderSelector extends StatefulWidget {
  final Function(String) onChanged;
  final String? initialGender; // ✅ 초기 선택값 (선택사항)

  const GenderSelector({
    Key? key,
    required this.onChanged,
    this.initialGender, // ✅ 선택적 파라미터
  }) : super(key: key);

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  late String selectedGender;

  @override
  void initState() {
    super.initState();
    // ✅ 초기값: 회원정보 수정에서는 전달받은 값 사용, 아니면 기본 '여성'
    selectedGender = widget.initialGender ?? '여성';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: GRAY_07,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 여성 버튼
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedGender = '여성';
                });
                widget.onChanged(selectedGender);
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selectedGender == '여성' ? Colors.white : GRAY_07,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selectedGender == '여성'
                      ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  '여성',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selectedGender == '여성'
                        ? Colors.black
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ),
          // 남성 버튼
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedGender = '남성';
                });
                widget.onChanged(selectedGender);
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selectedGender == '남성' ? Colors.white : GRAY_07,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selectedGender == '남성'
                      ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  '남성',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selectedGender == '남성'
                        ? Colors.black
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
