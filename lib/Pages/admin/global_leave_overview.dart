import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlobalLeaveOverview extends StatefulWidget {
  const GlobalLeaveOverview({super.key});

  @override
  State<StatefulWidget> createState() => _GlobalLeaveOverviewState();
}

class _GlobalLeaveOverviewState extends State<GlobalLeaveOverview> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.width * 0.02),
        child: Column(
          children: [
            Center(
              child: Text(
                'Année ${DateTime.now().year}',
                style: TextStyle(
                    fontSize: size.width * 0.05, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .where('role', isEqualTo: 'employee')
                  .snapshots(),
              builder: (context, snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) {
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
                    'Solde congé',
                    'Congé pris',
                    'Sanctions',
                    'Reste congé',
                    'Solde congé année prec',
                  ];
                  final columnKeys = (docs.first.data() as Map<String, dynamic>)
                      .keys
                      .where((key) => columnOrder.contains(key))
                      .toList();
                  columnKeys.add('Reste congé');
                  columnKeys.sort((a, b) =>
                      columnOrder.indexOf(a).compareTo(columnOrder.indexOf(b)));
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
                              if (key == 'Reste congé') {
                                return DataCell(Text(
                                    (documentData['Solde congé'] -
                                            (documentData['Sanctions'] +
                                                documentData['Congé pris']))
                                        .toString()));
                              }
                              return DataCell(
                                  Text(documentData[key]?.toString() ?? ''));
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
    ));
  }
}
