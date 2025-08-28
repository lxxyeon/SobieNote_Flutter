import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../common/const/data.dart';

Future<Map<String, String>?> showSchoolGradePicker(
    BuildContext context, {
      required String? selectedSchool,
      required String? selectedGrade,
    }) async {
  // schoolList 대신 SCHOOL_GRADE_MAP.keys 사용
  final List<String> schoolList = SCHOOL_GRADE_MAP.keys.toList();

  int selectedSchoolIndex = selectedSchool != null
      ? schoolList.indexOf(selectedSchool)
      : 0;

  List<String> currentGradeList =
      SCHOOL_GRADE_MAP[schoolList[selectedSchoolIndex]] ?? [];

  int selectedGradeIndex = (selectedGrade != null &&
      currentGradeList.contains(selectedGrade))
      ? currentGradeList.indexOf(selectedGrade)
      : 0;

  return await showCupertinoModalPopup<Map<String, String>>(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 300,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('취소'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('확인'),
                      onPressed: () {
                        Navigator.of(context).pop({
                          'school': schoolList[selectedSchoolIndex],
                          'grade': currentGradeList[selectedGradeIndex],
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      // 학교 선택
                      Flexible(
                        flex: 7,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedSchoolIndex,
                          ),
                          itemExtent: 32,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedSchoolIndex = index;
                              currentGradeList = SCHOOL_GRADE_MAP[schoolList[index]] ?? [];
                              selectedGradeIndex = 0;
                            });
                          },
                          children: schoolList
                              .map((e) => Center(child: Text(e)))
                              .toList(),
                        ),
                      ),
                      // 학년/나이 선택
                      Flexible(
                        flex: 3,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedGradeIndex,
                          ),
                          itemExtent: 32,
                          onSelectedItemChanged: (index) {
                            selectedGradeIndex = index;
                          },
                          children: currentGradeList
                              .map((e) => Center(child: Text(e)))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
