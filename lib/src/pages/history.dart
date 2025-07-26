import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('coverSystem')
                  .doc('status')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("No history found."));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final isExtended = data['isExtended'];
                final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

                return ListView(
                  children: [
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(isExtended == true ? "Cover Extended" : "Cover Retracted"),
                        subtitle: updatedAt != null
                            ? Text(
                          '${updatedAt.toLocal()}',
                          style: const TextStyle(fontSize: 12),
                        )
                            : null,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
