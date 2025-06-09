import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('history');
  List<String> _statuses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatuses();
  }

  Future<void> _fetchStatuses() async {
    final snapshot = await _dbRef.get();
    List<String> statuses = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value is Map && value['cover_status'] != null) {
          statuses.add(value['cover_status'].toString());
        }
      });
    }
    setState(() {
      _statuses = statuses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(175, 196, 234, 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Center(
              child: Text(
                "History",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromRGBO(21, 10, 10, 1),
                  letterSpacing: 1,
                  height: 0.0,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            _isLoading
                ? const CircularProgressIndicator()
                : _statuses.isEmpty
                    ? const Text("No history found.")
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _statuses.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 1.h),
                            child: ListTile(
                              leading: const Icon(Icons.history),
                              title: Text(_statuses[index]),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
