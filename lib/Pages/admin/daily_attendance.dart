import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyAttendance extends StatefulWidget {
  const DailyAttendance({super.key});

  @override
  State<DailyAttendance> createState() => _DailyAttendanceState();
}

class _DailyAttendanceState extends State<DailyAttendance> {
  final TextEditingController _date = TextEditingController();
  late Stream<List<Map<String, dynamic>>> _combinedStream;

  @override
  void initState() {
    super.initState();
    _date.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _combinedStream = _createCombinedStream();
  }

  Stream<List<Map<String, dynamic>>> _createCombinedStream() {
    return FirebaseFirestore.instance
        .collection('User')
        .where('role', isEqualTo: 'employee')
        .snapshots()
        .asyncMap((userSnapshot) async {
      List<Map<String, dynamic>> combinedData = [];
      for (var userDoc in userSnapshot.docs) {
        var userData = userDoc.data();
        var attendanceSnapshot = await FirebaseFirestore.instance
            .collection('Attendance')
            .where('userID', isEqualTo: userDoc.id)
            .where('date', isEqualTo: _date.text)
            .get();

        Map<String, dynamic> attendanceData = {};
        if (attendanceSnapshot.docs.isNotEmpty) {
          attendanceData = attendanceSnapshot.docs.first.data();
        }

        combinedData.add({
          ...userData,
          ...attendanceData,
        });
      }
      return combinedData;
    });
  }

  void _updateCombinedStream() {
    setState(() {
      _combinedStream = _createCombinedStream();
    });
  }

  String _formatDuration(String? duration) {
    if (duration == null || duration.isEmpty) return '0H 0Min';

    final regex = RegExp(r'(\d+)H (\d+)m');
    final match = regex.firstMatch(duration);

    if (match != null) {
      final hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      return '${hours}H ${minutes}Min';
    }

    // Fallback if the format doesn't match
    return 'Invalid Duration';
  }

  String calculateDuration(String startTime, String endTime) {
    // Parse the input time strings into DateTime objects
    DateTime start = DateTime.parse('2000-01-01 $startTime:00');
    DateTime end = DateTime.parse('2000-01-01 $endTime:00');

    // Calculate the difference between the end and start times
    Duration difference = end.difference(start);

    // Extract hours and minutes from the difference
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);

    // Return the formatted duration as a string
    return '${hours}H ${minutes}m';
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
                SizedBox(width: size.width * 0.1),
                Container(
                  color: const Color.fromARGB(255, 230, 230, 230),
                  height: size.height * 0.06,
                  width: size.width * 0.4,
                  child: TextField(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2100));
                      if (pickedDate != null) {
                        setState(() {
                          _date.text =
                              DateFormat('dd/MM/yyyy').format(pickedDate);
                          _updateCombinedStream();
                        });
                      }
                    },
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label:
                            Text('Date', style: TextStyle(color: Colors.black)),
                        alignLabelWithHint: false),
                    controller: _date,
                    readOnly: true,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _combinedStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Nom & Prénom')),
                      DataColumn(label: Text('Environnement')),
                      DataColumn(label: Text('Absence')),
                      DataColumn(label: Text('Retard')),
                      DataColumn(label: Text('Entrée Matin')),
                      DataColumn(label: Text('Sortie Matin')),
                      DataColumn(label: Text('Shift Matin')),
                      DataColumn(label: Text('Entrée AM')),
                      DataColumn(label: Text('Sortie AM')),
                      DataColumn(label: Text('Shift Midi')),
                      DataColumn(label: Text('Prod')),
                    ],
                    rows: data.map((item) {
                      return DataRow(cells: [
                        DataCell(Text('${item['Nom']} ${item['Prénom']}')),
                        DataCell(Text(item['environnement'] ?? 'Onsite')),
                        DataCell(Text(item['absence'] ?? 'Non')),
                        DataCell(Text(item['retard'] ?? '')),
                        DataCell(Text(item['entréMatin'] ?? '')),
                        DataCell(Text(item['sortieMatin'] ?? '')),
                        DataCell(Text(
                            _formatDuration(item['shiftMatin'] ?? '0H 0m'))),
                        DataCell(Text(item['entréAM'] ?? '')),
                        DataCell(Text(item['sortieAM'] ?? '')),
                        DataCell(Text(
                            _formatDuration(item['shiftMidi'] ?? '0H 0m'))),
                        DataCell(
                            Text(_formatDuration(item['prod'] ?? '0H 0m'))),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
