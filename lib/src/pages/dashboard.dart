import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _status = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(175, 196, 234, 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 7.h),
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset("assets/images/profile.png"),
              ),
            ),
            SizedBox(height: 3.h),
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Hello User",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(21, 10, 10, 1),
                    letterSpacing: 1,
                    height: 0.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Card(
              color: const Color.fromRGBO(255, 255, 255, 0.75),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(height: 5.h),
                    Image.asset(
                      "assets/images/hero.png",
                      width: 80.w,
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Container(
                      color: Colors.white,
                      width: 80.w,
                      padding: EdgeInsets.all(7.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Current Status",
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            "Cover is currently retracted",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.scale(
                                scale: 1.5,
                                child: Switch(
                                  value: _status,
                                  onChanged: (state) {
                                    setState(() {
                                      _status = state;
                                    });
                                  },
                                  activeTrackColor:
                                      const Color.fromRGBO(118, 238, 89, 1),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "Tap to Extend",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromRGBO(244, 104, 72, 1),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
