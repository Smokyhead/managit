import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyAttendance extends StatefulWidget {
  const DailyAttendance({super.key});

  @override
  State<DailyAttendance> createState() => _DailyAttendanceState();
}

class _DailyAttendanceState extends State<DailyAttendance> {
  final TextEditingController _date = TextEditingController();
  final String dateTime = DateFormat('dd/MM/yyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _date.text = DateFormat('dd/MM/yyy').format(DateTime.now());
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: size.width * 0.1,
                ),
                Container(
                  color: const Color.fromARGB(255, 211, 211, 211),
                  height: size.height * 0.06,
                  width: size.width * 0.35,
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Date'),
                        alignLabelWithHint: false),
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
