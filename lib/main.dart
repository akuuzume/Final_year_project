import 'package:flutter/material.dart';
import 'package:mobile_app/src/pages/dashboard.dart';
import 'package:mobile_app/src/pages/splash.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return const MaterialApp(
          home: Dashboard(),
        );
      },
    );
  }
}
