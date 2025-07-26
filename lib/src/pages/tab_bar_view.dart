import 'package:flutter/material.dart';
import 'package:mobile_app/src/pages/dashboard.dart';
import 'package:mobile_app/src/pages/history.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  void _onTap(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _pages = [
      const Dashboard(),
      const HistoryPage(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
        ),
        child: BottomAppBar(
          height: 8.h,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Material(
                  color: const Color.fromRGBO(61, 63, 82, 1),
                  child: InkWell(
                    onTap: () => _onTap(0),
                    child: SizedBox(
                      height: double.infinity,
                      child: Center(
                        child: Text(
                          "Dashboard",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 1,
                            height: 0.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 0.2.w),
              Expanded(
                child: Material(
                  color: const Color.fromRGBO(61, 63, 82, 1),
                  child: InkWell(
                    onTap: () => _onTap(1),
                    child: SizedBox(
                      height: double.infinity,
                      child: Center(
                        child: Text(
                          "History",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 1,

                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
