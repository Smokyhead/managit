import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyAttendance extends StatefulWidget {
  const DailyAttendance({super.key});

  @override
  State<DailyAttendance> createState() => _DailyAttendanceState();
}

class _DailyAttendanceState extends State<DailyAttendance> {
  final TextEditingController _date = TextEditingController();

  @override
  void initState() {
    _date.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    super.initState();
  }

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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: size.width * 0.1,
                ),
                Container(
                  color: const Color.fromARGB(255, 230, 230, 230),
                  height: size.height * 0.06,
                  width: size.width * 0.4,
                  child: TextField(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2100));
                      setState(() {
                        _date.text =
                            DateFormat('dd/MM/yyyy').format(pickedDate!);
                      });
                    },
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text(
                          'Date',
                          style: TextStyle(color: Colors.black),
                        ),
                        alignLabelWithHint: false),
                    controller: _date,
                    readOnly: true,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
