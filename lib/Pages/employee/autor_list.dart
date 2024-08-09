import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:managit/pages/employee/permission_request.dart';

class AutorList extends StatefulWidget {
  const AutorList({super.key});

  @override
  State<StatefulWidget> createState() => _AutorListState();
}

class _AutorListState extends State<AutorList> {
  int selectedYear = DateTime.now().year;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Liste des autorisations'),
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: const Color.fromARGB(255, 30, 60, 100),
          foregroundColor: Colors.white,
        ),
        body: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 215, 230, 245),
            foregroundColor: const Color.fromARGB(255, 30, 60, 100),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return const PermissionRequest();
              }));
            },
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              DropdownButton<int>(
                hint: const Text('Employé'),
                value: selectedYear,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedYear = newValue!;
                  });
                },
                items: const [
                  DropdownMenuItem<int>(
                    value: 2024,
                    child: Text('2024'),
                  ),
                ],
              ),
              SizedBox(
                width: size.width * 0.05,
              )
            ],
          ),
          body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Autorisation')
                  .where('year', isEqualTo: selectedYear)
                  .where('status', isEqualTo: 'approved')
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
                        var data = snapshots.data!.docs[index].data();
                        return Container(
                          margin: EdgeInsets.all(size.width * 0.02),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 215, 230, 245),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 30, 60, 100))),
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
        ));
  }
}
