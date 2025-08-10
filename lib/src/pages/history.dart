import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(175, 196, 234, 1),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          Center(
            child: Text(
              "History",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: const Color.fromRGBO(21, 10, 10, 1),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('coverSystem')
                  .doc('status')
                  .collection('history')
                  .orderBy('timestamp', descending: true)
                  .limit(50) // Show last 50 entries
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "No history found.",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "Changes will appear here when you toggle the cover.",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final isExtended = data['isExtended'] ?? false;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final updatedAt = data['updatedAt'] as Timestamp?;
                    final source = data['source'] ?? 'unknown';

                    // Use timestamp first, then updatedAt as fallback
                    final dateTime = timestamp?.toDate() ?? updatedAt?.toDate();

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 0.8.h),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: isExtended
                                ? const Color.fromRGBO(118, 238, 89, 0.2)
                                : const Color.fromRGBO(244, 104, 72, 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isExtended ? Icons.expand_more : Icons.expand_less,
                            color: isExtended
                                ? const Color.fromRGBO(118, 238, 89, 1)
                                : const Color.fromRGBO(244, 104, 72, 1),
                            size: 6.w,
                          ),
                        ),
                        title: Text(
                          isExtended ? "Cover Extended" : "Cover Retracted",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (dateTime != null) ...[
                              SizedBox(height: 0.5.h),
                              Text(
                                DateFormat('MMM dd, yyyy • hh:mm a')
                                    .format(dateTime.toLocal()),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            if (source != 'unknown') ...[
                              SizedBox(height: 0.3.h),
                              Row(
                                children: [
                                  Icon(
                                    _getSourceIcon(source),
                                    size: 3.w,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    _getSourceDisplay(source),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'mobile_app':
        return Icons.smartphone;
      case 'web_app':
        return Icons.web;
      case 'manual_entry':
        return Icons.edit;
      case 'automatic':
        return Icons.autorenew;
      default:
        return Icons.device_unknown;
    }
  }

  String _getSourceDisplay(String source) {
    switch (source.toLowerCase()) {
      case 'mobile_app':
        return 'Mobile App';
      case 'web_app':
        return 'Web App';
      case 'manual_entry':
        return 'Manual Entry';
      case 'automatic':
        return 'Automatic';
      default:
        return source;
    }
  }
}
