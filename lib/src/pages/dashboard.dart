import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:mobile_app/src/components/weather_service.dart';
import 'package:mobile_app/src/services/notification_service.dart';
import 'package:mobile_app/src/services/status_monitor_service.dart';
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
  final NotificationService _notificationService = NotificationService();
  final StatusMonitorService _statusMonitor = StatusMonitorService();

  @override
  void initState() {
    super.initState();
    fetchWeather();
    _fetchInitialCoverStatus();
    _initializeNotifications();
    ensureHistoryIntegrity(); // Ensure all history data is properly structured
  }

  @override
  void dispose() {
    // Stop monitoring when dashboard is disposed
    _statusMonitor.stopMonitoring();
    super.dispose();
  }

  /// Initialize notification system
  Future<void> _initializeNotifications() async {
    try {
      // Start monitoring status changes for notifications
      await _statusMonitor.startMonitoring();
      print('✅ Notification monitoring initialized');
    } catch (e) {
      print('🔥 Error initializing notifications: $e');
    }
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
        const SnackBar(content: Text("Sign out failed. Try again.")),
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

  Future<void> ensureHistoryIntegrity() async {
    try {
      // Get all history entries to check for data consistency
      QuerySnapshot historySnapshot = await FirebaseFirestore.instance
          .collection('coverSystem')
          .doc('status')
          .collection('history')
          .orderBy('timestamp', descending: true)
          .limit(100) // Get last 100 entries
          .get();

      print('Found ${historySnapshot.docs.length} history entries');

      // You can add migration logic here if needed
      for (var doc in historySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Check if entry needs updating (e.g., missing fields)
        if (!data.containsKey('userId') || !data.containsKey('source')) {
          await doc.reference.update({
            'userId': FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
            'source':
                data.containsKey('source') ? data['source'] : 'legacy_entry',
            'userEmail': FirebaseAuth.instance.currentUser?.email ?? 'unknown',
          });
          print('Updated legacy history entry: ${doc.id}');
        }
      }
    } catch (e) {
      print('Error ensuring history integrity: $e');
    }
  }

  Future<void> addCoverHistory(bool isExtended,
      {String? source, String? notes}) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('coverSystem').doc('status');

      await docRef.collection('history').add({
        'isExtended': isExtended,
        'timestamp': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'source': source ?? 'manual_entry',
        'userId': FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
        'userEmail': FirebaseAuth.instance.currentUser?.email ?? 'unknown',
        'notes': notes,
      });
      print(
          'History entry added via addCoverHistory: $isExtended, source: ${source ?? 'manual_entry'}');
    } catch (e) {
      print('Error adding cover history: $e');
    }
  }

  Future<void> updateCoverStatus(bool newStatus,
      {bool isInitialSetup = false}) async {
    try {
      print(
          'updateCoverStatus called with: $newStatus, isInitialSetup: $isInitialSetup');

      // Update the main status document
      await FirebaseFirestore.instance
          .collection('coverSystem')
          .doc('status')
          .set({
        'isExtended': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Main status document updated successfully');

      // Add entry to history subcollection (only for user actions, not initial setup)
      if (!isInitialSetup) {
        print('Adding entry to history subcollection...');
        await FirebaseFirestore.instance
            .collection('coverSystem')
            .doc('status')
            .collection('history')
            .add({
          'isExtended': newStatus,
          'timestamp': FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(), // Keep both for compatibility
          'source': 'mobile_app',
          'userId': FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
          'userEmail': FirebaseAuth.instance.currentUser?.email ?? 'unknown',
        });

        print('History entry added successfully');
        print('Cover status updated to Firestore: $newStatus');

        // Show immediate feedback notification for manual changes
        await _notificationService.showStatusChangeNotification(newStatus);
      } else {
        print('Skipping history entry (initial setup)');
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
            SizedBox(height: 2.h),
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
                          _isLoadingStatus
                              ? Text(
                                  "Loading status...",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                    letterSpacing: 1,
                                  ),
                                )
                              : Text(
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
                                  activeTrackColor:
                                      const Color.fromRGBO(118, 238, 89, 1),
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
