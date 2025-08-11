import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/src/services/notification_service.dart';
import 'package:mobile_app/src/services/status_monitor_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = true;
  bool _statusChangeNotifications = true;
  bool _systemNotifications = true;
  bool _isLoading = true;

  final NotificationService _notificationService = NotificationService();
  final StatusMonitorService _statusMonitor = StatusMonitorService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _notificationsEnabled = data['notificationsEnabled'] ?? true;
            _statusChangeNotifications =
                data['statusChangeNotifications'] ?? true;
            _systemNotifications = data['systemNotifications'] ?? true;
          });
        }
      }
    } catch (e) {
      print('🔥 Error loading settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'notificationsEnabled': _notificationsEnabled,
          'statusChangeNotifications': _statusChangeNotifications,
          'systemNotifications': _systemNotifications,
          'settingsUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Update monitoring based on settings
        if (_notificationsEnabled && _statusChangeNotifications) {
          if (!_statusMonitor.isMonitoring) {
            await _statusMonitor.startMonitoring();
          }
        } else {
          if (_statusMonitor.isMonitoring) {
            _statusMonitor.stopMonitoring();
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Settings saved successfully!')),
        );
      }
    } catch (e) {
      print('🔥 Error saving settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error saving settings: ${e.toString()}')),
      );
    }
  }

  Future<void> _testNotification() async {
    try {
      await _notificationService.showStatusChangeNotification(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔔 Test notification sent!')),
      );
    } catch (e) {
      print('🔥 Error sending test notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(175, 196, 234, 1),
      child: SafeArea(
        child: Column(
          children: [
            // Custom AppBar to match other pages
            Container(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
              child: Center(
                child: Text(
                  'Notification Settings',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromRGBO(21, 10, 10, 1),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main notification toggle
                            Card(
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 2.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '🔔 General Settings',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Enable Notifications',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                'Receive all notifications from the app',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Transform.scale(
                                          scale: 0.8,
                                          child: Switch(
                                            value: _notificationsEnabled,
                                            onChanged: (value) {
                                              setState(() =>
                                                  _notificationsEnabled =
                                                      value);
                                              _saveSettings();
                                            },
                                            activeColor: const Color.fromRGBO(
                                                118, 238, 89, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // Status change notifications
                            Card(
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 2.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '🔄 Status Change Notifications',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Cover Status Changes',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                'Get notified when cover extends or retracts',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Transform.scale(
                                          scale: 0.8,
                                          child: Switch(
                                            value: _statusChangeNotifications &&
                                                _notificationsEnabled,
                                            onChanged: _notificationsEnabled
                                                ? (value) {
                                                    setState(() =>
                                                        _statusChangeNotifications =
                                                            value);
                                                    _saveSettings();
                                                  }
                                                : null,
                                            activeColor: const Color.fromRGBO(
                                                118, 238, 89, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // System notifications
                            Card(
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 2.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '⚙️ System Notifications',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'System Updates',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                'Get notified about system maintenance and updates',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Transform.scale(
                                          scale: 0.8,
                                          child: Switch(
                                            value: _systemNotifications &&
                                                _notificationsEnabled,
                                            onChanged: _notificationsEnabled
                                                ? (value) {
                                                    setState(() =>
                                                        _systemNotifications =
                                                            value);
                                                    _saveSettings();
                                                  }
                                                : null,
                                            activeColor: const Color.fromRGBO(
                                                118, 238, 89, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 4.h),

                            // Test notification button
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _notificationsEnabled
                                    ? _testNotification
                                    : null,
                                icon: const Icon(Icons.notification_add),
                                label: const Text('Send Test Notification'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(244, 104, 72, 1),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 3.h),

                            // Information card
                            Card(
                              color: const Color.fromRGBO(255, 255, 255, 0.9),
                              child: Padding(
                                padding: EdgeInsets.all(4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: Color.fromRGBO(21, 10, 10, 1),
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'About Notifications',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromRGBO(
                                                21, 10, 10, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      '• You\'ll receive notifications when the clothesline cover status changes\n'
                                      '• Notifications work even when the app is closed\n'
                                      '• You can customize which notifications you receive\n'
                                      '• Test notifications help verify your settings work correctly',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h), // Bottom padding
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
