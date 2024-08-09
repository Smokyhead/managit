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
  String? _selectedEmployee;
  String? _selectedId;
  int _selectedYear = 2024;
  List<int> years = [2024, 2025, 2026];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('User')
                    .where('role', isEqualTo: 'employee')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Platform.isAndroid
                          ? const CircularProgressIndicator(
                              color: Color.fromARGB(255, 30, 60, 100),
                            )
                          : const CupertinoActivityIndicator(),
                    );
                  }
                  final employees = snapshot.data!.docs;
                  return SizedBox(
                      width: size.width * 0.5,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Employé',
                        ),
                        value: _selectedEmployee, // Set the initial value here
                        items: employees.map((employee) {
                          return DropdownMenuItem<String>(
                            onTap: () {
                              _selectedId = employee['id'];
                            },
                            value: '${employee['Nom']} ${employee['Prénom']}',
                            child: Text(
                                '${employee['Nom']} ${employee['Prénom']}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEmployee = value;
                          });
                        },
                      ));
                },
              ),
              SizedBox(
                width: size.width * 0.3,
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Année',
                  ),
                  items: years.map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text('$year'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Autorisation')
                    .where('userId', isEqualTo: _selectedId)
                    .where('year', isEqualTo: _selectedYear)
                    .where('status', isEqualTo: 'approved')
                    .snapshots(),
                builder: (content, snapshots) {
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
                        "Rien à afficher",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {}
                  return SizedBox(
                    child: ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(),
                        itemCount: snapshots.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshots.data!.docs[index].data()
                              as Map<String, dynamic>;
                          return Container(
                            margin: EdgeInsets.all(size.width * 0.02),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 215, 230, 245),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 30, 60, 100))),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['date'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.width * 0.05),
                                  ),
                                  Text(
                                      "De '${data['startTime']}'  à  '${data['endTime']}'  (${data['hours']} heures)"),
                                  Text(
                                    data['reason'],
                                    maxLines: 3,
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  );
                }),
          )
        ],
      ),
    );
  }
}
