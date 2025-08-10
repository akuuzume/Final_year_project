import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/src/services/notification_service.dart';

class StatusMonitorService {
  static final StatusMonitorService _instance = StatusMonitorService._internal();
  factory StatusMonitorService() => _instance;
  StatusMonitorService._internal();

  StreamSubscription<DocumentSnapshot>? _statusSubscription;
  bool? _lastKnownStatus;
  final NotificationService _notificationService = NotificationService();

  /// Start monitoring status changes
  Future<void> startMonitoring() async {
    try {
      print('🔍 Starting status monitoring...');
      
      // Listen to the main status document
      _statusSubscription = FirebaseFirestore.instance
          .collection('coverSystem')
          .doc('status')
          .snapshots()
          .listen(
        _handleStatusChange,
        onError: (error) {
          print('🔥 Error in status monitoring: $error');
        },
      );
      
      print('✅ Status monitoring started successfully');
    } catch (e) {
      print('🔥 Error starting status monitoring: $e');
    }
  }

  /// Handle status change events
  void _handleStatusChange(DocumentSnapshot snapshot) async {
    try {
      if (!snapshot.exists) {
        print('⚠️ Status document does not exist');
        return;
      }

      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        print('⚠️ Status document has no data');
        return;
      }

      bool currentStatus = data['isExtended'] ?? true;
      
      // Check if this is a genuine change (not the first load)
      if (_lastKnownStatus != null && _lastKnownStatus != currentStatus) {
        print('🔄 Status changed from $_lastKnownStatus to $currentStatus');
        
        // Show notification for the change
        await _notificationService.showStatusChangeNotification(currentStatus);
        
        // Log the change
        print(currentStatus 
          ? '☂️ Cover extended - sending protection notification'
          : '☀️ Cover retracted - sending drying notification');
      } else if (_lastKnownStatus == null) {
        print('📊 Initial status loaded: $currentStatus');
      }
      
      _lastKnownStatus = currentStatus;
    } catch (e) {
      print('🔥 Error handling status change: $e');
    }
  }

  /// Stop monitoring status changes
  void stopMonitoring() {
    try {
      _statusSubscription?.cancel();
      _statusSubscription = null;
      _lastKnownStatus = null;
      print('🛑 Status monitoring stopped');
    } catch (e) {
      print('🔥 Error stopping status monitoring: $e');
    }
  }

  /// Get current monitoring status
  bool get isMonitoring => _statusSubscription != null;
}
