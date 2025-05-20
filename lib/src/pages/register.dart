import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
              "Welcome",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(21, 10, 10, 1),
                letterSpacing: 1,
                height: 0.0,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(0, 0, 0, 1),
                    letterSpacing: 1,
                    height: 0.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    " Login",
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
            ),
            SizedBox(height: 8.h),
            Text(
              "First Name",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
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
            SizedBox(height: 3.h),
            Text(
              "Last Name",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
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
            SizedBox(height: 3.h),
            Text(
              "Email",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
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
            SizedBox(height: 3.h),
            Text(
              "Phone",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
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
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              ),
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
                "Sign up",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 0.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
