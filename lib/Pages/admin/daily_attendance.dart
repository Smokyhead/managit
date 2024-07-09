import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyAttendance extends StatefulWidget {
  const DailyAttendance({super.key});

  @override
  State<DailyAttendance> createState() => _DailyAttendanceState();
}

class _DailyAttendanceState extends State<DailyAttendance> {
  final TextEditingController _date = TextEditingController();
  final String dateTime = DateFormat('dd/mm/yyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Date',
                  style: TextStyle(fontSize: size.width * 0.05),
                ),
                SizedBox(
                  width: size.width * 0.1,
                ),
                Container(
                  color: const Color.fromARGB(255, 223, 196, 196),
                  height: size.height * 0.05,
                  width: size.width * 0.4,
                  child: TextField(
                    decoration: InputDecoration(label: Text(dateTime)),
                    controller: _date,
                    readOnly: true,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
