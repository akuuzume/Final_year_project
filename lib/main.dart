import 'package:flutter/material.dart';
import 'package:mobile_app/src/pages/splash.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          home: const SplashScreen(),
        );
      },
    );
  }
}
