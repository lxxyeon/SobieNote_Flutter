import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sobienote_flutter/common/const/colors.dart';
import 'package:sobienote_flutter/component/board_selection.dart';
import 'package:sobienote_flutter/component/default_layout.dart';
import 'package:sobienote_flutter/goal/goal_provider.dart';
import 'package:sobienote_flutter/view/setting_screen.dart';

import '../common/const/text_style.dart';
import '../component/top_sheet_selector.dart';
import '../images/image_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isTopSheetVisible = false;
  bool isSelectingYear = false;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _toggleTopSheet() {
    setState(() {
      isTopSheetVisible = !isTopSheetVisible;
    });
  }

  void _toggleMode() {
    setState(() {
      isSelectingYear = !isSelectingYear;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;
    final images = ref.watch(imagesProvider((selectedYear, selectedMonth)));
    final goal = ref.watch(goalProvider((selectedYear, selectedMonth)));
    if (_goalController.text.isEmpty || _goalController.text != goal.value) {
      _goalController.text = goal.value ?? '';
    }
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              centerTitle: true,
              expandedHeight: kToolbarHeight + 130,
              title: GestureDetector(
                onTap: _toggleTopSheet,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🗓 $selectedMonth 월 소비기록', style: kTitleTextStyle),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    context.pushNamed(SettingScreen.routeName);
                  },
                  icon: Icon(Icons.more_horiz),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(130),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '이번 달 소비목표',
                            style: TextStyle(fontSize: 16, color: FONT_GRAY),
                          ),
                          const SizedBox(height: 9),
                          TextField(
                            controller: _goalController,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  _goalController.text.isEmpty
                                      ? '목표를 적어주세요!'
                                      : null,
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.cloud_upload,
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                onPressed: () async {
                                  final text = _goalController.text.trim();
                                  if (text.isNotEmpty) {
                                    await ref.read(
                                      setGoalProvider((
                                        selectedYear,
                                        selectedMonth,
                                        text,
                                      )).future,
                                    );
                                    FocusScope.of(context).unfocus();
                                    showCupertinoDialog(
                                      context: context,
                                      builder:
                                          (_) => CupertinoAlertDialog(
                                            title: Text(
                                              '$selectedMonth 월 목표가 저장됐어요!',
                                            ),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: Text('확인'),
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                    );
                                    ref.invalidate(
                                      goalProvider((
                                        selectedYear,
                                        selectedMonth,
                                      )),
                                    );
                                  }
                                },
                              ),
                              filled: true,
                              fillColor: TEAL,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (images.isLoading)
              SliverFillRemaining(
                child: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (images.hasError ||
                images.value == null ||
                images.value!.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Image.asset('assets/images/nullImg_G.png'),
              )
            else if (images.value!.isNotEmpty)
              SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DefaultLayout(
                                backgroundColor: LIGHT_TEAL,
                                child: BoardSelection(
                                  boardId: images.value![index].boardId,
                                ),
                              ),
                        ),
                      );
                    },
                    child: Image.network(images.value![index].imagePath),
                  );
                }, childCount: images.value!.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
              ),
          ],
        ),
        if (isTopSheetVisible)
          Positioned.fill(
            top: appBarHeight,
            child: GestureDetector(
              onTap: _toggleTopSheet,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
        TopSheetSelector(
          isVisible: isTopSheetVisible,
          topOffset: appBarHeight,
          selectedMonth: selectedMonth,
          selectedYear: selectedYear,
          tabIndex: 0,
          isSelectingYear: isSelectingYear,
          onToggleMode: _toggleMode,
          onMonthSelected: (val) {
            setState(() {
              selectedMonth = val;
            });
          },
          onYearSelected: (val) {
            setState(() {
              selectedYear = val;
            });
          },
        ),
      ],
    );
  }
}
