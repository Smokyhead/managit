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
    _combinedStream = _createCombinedStream(); // Initialize here
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

  String _formatDuration(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '${hours}H ${remainingMinutes}Min';
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
                  return const Text('...');
                }

                final data = snapshot.data!;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('NOM PRENOM')),
                      DataColumn(label: Text('Environnement')),
                      DataColumn(label: Text('ABSENCE')),
                      DataColumn(label: Text('RETARD')),
                      DataColumn(label: Text('Entrée')),
                      DataColumn(label: Text('Sortie')),
                      DataColumn(label: Text('Shift Matin')),
                      DataColumn(label: Text('Entrée')),
                      DataColumn(label: Text('Sortie')),
                      DataColumn(label: Text('Shift Midi')),
                      DataColumn(label: Text('Prod')),
                    ],
                    rows: data.map((item) {
                      return DataRow(cells: [
                        DataCell(Text('${item['Nom']} ${item['Prénom']}')),
                        DataCell(Text(item['Environnement'] ?? 'Onsite')),
                        DataCell(Text(item['ABSENCE'] ?? 'Présent')),
                        DataCell(Text(item['RETARD'] ?? 'Non')),
                        DataCell(Text(item['entréMatin'] ?? '')),
                        DataCell(Text(item['sortieMatin'] ?? '')),
                        DataCell(
                            Text(_formatDuration(item['shiftMatin'] ?? 0))),
                        DataCell(Text(item['entréAM'] ?? '')),
                        DataCell(Text(item['sortieAM'] ?? '')),
                        DataCell(Text(_formatDuration(item['shiftMidi'] ?? 0))),
                        DataCell(Text(_formatDuration(item['prod'] ?? 0))),
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
