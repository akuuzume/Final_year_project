import 'package:flutter/material.dart';
import 'package:mobile_app/src/pages/register.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: const AssetImage("assets/images/sky.png"),
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.dstATop,
            ),
          ),
        ),
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text(
              "Welcome to",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(21, 10, 10, 1),
                letterSpacing: 1,
                height: 0.0,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Our clothesline app",
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(21, 10, 10, 1),
                letterSpacing: 1,
                height: 0.0,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Please log in to your account to continue",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(21, 10, 10, 1),
                letterSpacing: 1,
                height: 0.0,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Email or Phone number",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(21, 10, 10, 1),
                letterSpacing: 1,
                height: 0.0,
              ),
            ),
            SizedBox(height: 0.2.h),
            const TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "Password",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(21, 10, 10, 1),
                letterSpacing: 1,
                height: 0.0,
              ),
            ),
            SizedBox(height: 0.2.h),
            const TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(244, 104, 72, 1),
                  letterSpacing: 1,
                  height: 0.0,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(61, 63, 82, 1),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 1.3.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  minimumSize: Size(double.infinity, 7.h)),
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 0.0,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don’t have an account?",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(0, 0, 0, 1),
                    letterSpacing: 1,
                    height: 0.0,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: Text(
                    "  Please register",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromRGBO(212, 52, 24, 1),
                      letterSpacing: 1,
                      height: 0.0,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
