import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:mobile_app/src/components/weather_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/src/pages/open_app.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _status = true;
  Map<String, dynamic>? _weatherData;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
    _fetchInitialCoverStatus();
  }

  void _signOut() {
    try {
      FirebaseAuth.instance.signOut();
      print("User signed out!");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OpenApp()),
            (route) => false,
      );
    } catch (e) {
      print("Sign out error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign out failed. Try again.")),
      );
    }
  }

  void fetchWeather() async {
    try {
      final data = await WeatherService().getWeatherByCity('Accra');
      if (mounted) {
        setState(() {
          _weatherData = data;
        });
      }
    } catch (e) {
      print("Error fetching weather: $e");
      setState(() {
        _weatherData = null;
      });
    }
  }

  Future<void> _fetchInitialCoverStatus() async {
    setState(() {
      _isLoadingStatus = true; // Start loading
    });
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('coverSystem')
          .doc('status')
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _status = data['isExtended'] ?? true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _status = true;
          });
        }
        await updateCoverStatus(_status, isInitialSetup: true);
      }
    } catch (e) {
      print('Failed to fetch initial cover status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStatus = false; // Done loading
        });
      }
    }
  }
  Future<void> updateCoverStatus(bool newStatus, {bool isInitialSetup = false}) async {
    try {
      await FirebaseFirestore.instance
          .collection('coverSystem')
          .doc('status')
          .set({
        'isExtended': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!isInitialSetup) { // Only print for user actions
        print('Cover status updated to Firestore: $newStatus');
      }
    } catch (e) {
      print('Failed to update cover status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: ${e.toString()}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(175, 196, 234, 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Hello User",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(21, 10, 10, 1),
                    letterSpacing: 1,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 7.h),
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Align(
                alignment: Alignment.bottomRight,
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'signOut') {
                      _signOut();
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'signOut',
                      child: Text('Sign Out'),
                    ),
                  ],
                  child: Image.asset(
                    "assets/images/profile.png",
                    width: 10.w,
                    height: 10.w,
                  ),
                ),
              ),
            ),


            SizedBox(height: 5.h),
            if (_weatherData != null)
              Card(
                color: const Color.fromRGBO(255, 255, 255, 0.75),
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        Text(
                          "Weather in ${_weatherData!['name']}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${_weatherData!['weather'][0]['main']}   ${_weatherData!['main']['temp']}°C",
                          style: TextStyle(
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const CircularProgressIndicator(),
            SizedBox(height: 8.h),
            Card(
              color: const Color.fromRGBO(255, 255, 255, 0.75),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
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
                            _status
                                ? "Cover is currently extended"
                                : "Cover is currently retracted",
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
                                    updateCoverStatus(state);
                                  },
                                  activeTrackColor: const Color.fromRGBO(
                                      118, 238, 89, 1),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _status ? "Tap to Retract" : "Tap to Extend",
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
