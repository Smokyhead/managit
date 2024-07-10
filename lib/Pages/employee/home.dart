import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _LeaveHomeState();
}

class _LeaveHomeState extends State<Home> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final String today = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final String time = DateFormat('HH:mm').format(DateTime.now());

  String generateId() {
    final random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const length = 20;

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: const Color.fromARGB(255, 30, 60, 100),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Attendance')
                    .where('userID', isEqualTo: _user!.uid)
                    .where('date', isEqualTo: today)
                    .snapshots(),
                builder: (context, snapshots) {
                  if (snapshots.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 30, 60, 100),
                      ),
                    );
                  }
                  final docs = snapshots.data?.docs;
                  if (docs == null || docs.isEmpty) {
                    return Center(
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                foregroundColor:
                                    WidgetStatePropertyAll(Colors.white),
                                backgroundColor: WidgetStatePropertyAll(
                                    Color.fromARGB(255, 30, 60, 100))),
                            onPressed: () {
                              final String id = generateId();
                              FirebaseFirestore.instance
                                  .collection('Notification')
                                  .doc(id)
                                  .set({
                                'id': id,
                                'userID': _user.uid,
                                'date': today,
                                'time': time,
                                'type': 'entré',
                                'shift': 'Matin',
                              });
                            },
                            child: const Text('Arrivée')));
                  } else {
                    var data = snapshots.data?.docs.first;
                    if (data!['sortieMatin'] == '') {
                      return ElevatedButton(
                          style: const ButtonStyle(
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                              backgroundColor: WidgetStatePropertyAll(
                                  Color.fromARGB(255, 30, 60, 100))),
                          onPressed: () {
                            final String id = generateId();
                            FirebaseFirestore.instance
                                .collection('Notification')
                                .doc(id)
                                .set({
                              'id': id,
                              'userID': _user.uid,
                              'date': today,
                              'time': time,
                              'type': 'sortie',
                              'shift': 'Matin',
                            });
                          },
                          child: const Text('Sortie Pause'));
                    } else if (data['entréAM'] == '') {
                      return ElevatedButton(
                          style: const ButtonStyle(
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                              backgroundColor: WidgetStatePropertyAll(
                                  Color.fromARGB(255, 30, 60, 100))),
                          onPressed: () {
                            final String id = generateId();
                            FirebaseFirestore.instance
                                .collection('Notification')
                                .doc(id)
                                .set({
                              'id': id,
                              'userID': _user.uid,
                              'date': today,
                              'time': time,
                              'type': 'entré',
                              'shift': 'AM',
                            });
                          },
                          child: const Text('Entré'));
                    } else if (data['sortieAM'] == '') {
                      return ElevatedButton(
                          style: const ButtonStyle(
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                              backgroundColor: WidgetStatePropertyAll(
                                  Color.fromARGB(255, 30, 60, 100))),
                          onPressed: () {
                            final String id = generateId();
                            FirebaseFirestore.instance
                                .collection('Notification')
                                .doc(id)
                                .set({
                              'id': id,
                              'userID': _user.uid,
                              'date': today,
                              'time': time,
                              'type': 'sortie',
                              'shift': 'AM',
                            });
                          },
                          child: const Text('Sortie'));
                    }
                  }
                  throw Exception();
                })
          ],
        ),
      ),
    );
  }
}
