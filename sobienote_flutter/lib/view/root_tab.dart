import 'package:flutter/material.dart';
import 'package:sobienote_flutter/view/home_screen.dart';
import 'package:sobienote_flutter/view/report_screen.dart';
import 'package:sobienote_flutter/view/upload_screen.dart';

import '../common/const/colors.dart';
import '../component/default_layout.dart';

class RootTab extends StatefulWidget {
  static String get routeName => 'home';
  const RootTab({super.key});

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with TickerProviderStateMixin {
  int index = 0;
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(tabListener);
  }

  @override
  void dispose() {
    controller.removeListener(tabListener);
    super.dispose();
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: controller.index == 1 ? LIGHT_TEAL : Colors.white,
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          backgroundColor: controller.index == 1 ? Colors.white : TAB_BG_COLOR,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          unselectedItemColor: UNSELECTED_GRAY,
          selectedItemColor: DARK_TEAL,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() {
              controller.index = index;
            });
          },
          currentIndex: index,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box_rounded),
              label: '추가',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: '보고서',
            ),
          ],
        ),
      ),
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [HomeScreen(), UploadScreen(), ReportScreen()],
      ),
    );
  }
}
