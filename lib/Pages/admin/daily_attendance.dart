import 'package:flutter/material.dart';

class DailyAttendance extends StatefulWidget {
  const DailyAttendance({super.key});

  @override
  State<StatefulWidget> createState() => _DailyAttendanceState();
}

class _DailyAttendanceState extends State<DailyAttendance> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('Daily Attendance Page'),
    ));
  }
}
