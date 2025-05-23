import 'package:flutter/material.dart';
import 'package:mobile_app/src/pages/login_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class OpenApp extends StatelessWidget {
  const OpenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(203, 220, 253, 1),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 15.h),
            CircleAvatar(
              backgroundImage: const AssetImage("assets/images/logo.jpg"),
              radius: 35.w,
            ),
            SizedBox(height: 7.h),
            SizedBox(
              width: 50.w,
              child: Text(
                "Clothesline Monitor",
                style: TextStyle(
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromRGBO(61, 63, 82, 1),
                  height: 0.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(61, 63, 82, 1),
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 1.3.h,
                ),
                elevation: 20,
              ),
              child: Text(
                "Sign up",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 0.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
