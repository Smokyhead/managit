import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlobalPermissionOverview extends StatefulWidget {
  const GlobalPermissionOverview({super.key});

  @override
  State<StatefulWidget> createState() => _GlobalPermissionOverviewState();
}

class _GlobalPermissionOverviewState extends State<GlobalPermissionOverview> {
  String? selectedEmployee;
  int selectedYear = DateTime.now().year;
  List<String> employeeList = [];
  List<int> yearList =
      List<int>.generate(10, (index) => DateTime.now().year - index);

  @override
  void initState() {
    super.initState();
    _fetchEmployeeList();
  }

  Future<void> _fetchEmployeeList() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('User').get();
    setState(() {
      employeeList = snapshot.docs
          .map((doc) => doc.id)
          .toList(); // Assuming doc.id is the employee's ID or name
    });
    // Debugging line
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  hint: const Text('Employé'),
                  value: selectedEmployee,
                  items: employeeList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedEmployee = newValue;
                    });
                    // Debugging line
                  },
                ),
                DropdownButton<int>(
                  hint: const Text('Année'),
                  value: selectedYear,
                  items: yearList.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedYear = newValue!;
                    });
                    // Debugging line
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: size.width * 0.02),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Autorisation')
                          .where('userId', isEqualTo: selectedEmployee)
                          .where('date',
                              isGreaterThanOrEqualTo: '$selectedYear-01-01')
                          .where('date',
                              isLessThanOrEqualTo: '$selectedYear-12-31')
                          .snapshots(),
                      builder: (context, snapshots) {
                        if (snapshots.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Platform.isAndroid
                                ? const CircularProgressIndicator(
                                    color: Color.fromARGB(255, 30, 60, 100),
                                  )
                                : const CupertinoActivityIndicator(),
                          );
                        }
                        final docs = snapshots.data?.docs;
                        if (docs == null || docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "Rien à afficher pour le moment",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else {
                          final columnOrder = [
                            'Nom',
                            'Prénom',
                            'Date',
                            'Heure début',
                            'Heure fin',
                            'Description'
                          ];
                          final columnKeys =
                              (docs.first.data() as Map<String, dynamic>)
                                  .keys
                                  .where((key) => columnOrder.contains(key))
                                  .toList();
                          columnKeys.sort((a, b) => columnOrder
                              .indexOf(a)
                              .compareTo(columnOrder.indexOf(b)));
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                border: TableBorder.all(color: Colors.grey),
                                headingRowColor: const WidgetStatePropertyAll(
                                    Color.fromARGB(255, 210, 213, 232)),
                                columns: columnKeys
                                    .map((key) => DataColumn(label: Text(key)))
                                    .toList(),
                                rows: docs.map((document) {
                                  final documentData =
                                      document.data() as Map<String, dynamic>;
                                  return DataRow(
                                    cells: columnKeys.map((key) {
                                      return DataCell(Text(
                                          documentData[key]?.toString() ?? ''));
                                    }).toList(),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
