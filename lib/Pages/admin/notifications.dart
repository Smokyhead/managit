import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<StatefulWidget> createState() => NotificationsState();
}

class NotificationsState extends State<Notifications> {
  // bool _iconSelected = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 30, 60, 100),
          foregroundColor: Colors.white,
          title: Text(
            'Notifications',
            style: TextStyle(fontSize: size.width * 0.0475),
          ),
        ),
        body: Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Notification')
                    .orderBy('timestamp', descending: true)
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
                        "Aucune notification à afficher",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return ListView.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: snapshots.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshots.data!.docs[index].data()
                              as Map<String, dynamic>;
                          return ListTile(
                            title: Text(data['content'],
                                style: TextStyle(fontSize: size.width * 0.04)),
                            subtitle: Column(
                              children: [
                                data['validé'] == false
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('Notification')
                                                    .doc(data['id'])
                                                    .update({'validé': true});
                                                FirebaseFirestore.instance
                                                    .collection('Attendance')
                                                    .doc(data['attendanceId'])
                                                    .update({'sent': false});
                                              },
                                              child: const Text('Valider')),
                                          ElevatedButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('Notification')
                                                    .doc(data['id'])
                                                    .update({'validé': true});
                                                FirebaseFirestore.instance
                                                    .collection('Attendance')
                                                    .doc(data['attendanceId'])
                                                    .update({
                                                  data['type']: '',
                                                  'sent': false
                                                });
                                              },
                                              child: const Text('Décliner'))
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                Row(
                                  children: [
                                    data['date'] ==
                                            DateFormat('dd/MM/yyyy')
                                                .format(DateTime.now())
                                        ? const Text("Aujourd'hui",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500))
                                        : Text(data['date'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500))
                                  ],
                                )
                              ],
                            ),
                          );
                        });
                  }
                })));
  }
}
