import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:managit/models/user_model.dart';
import 'package:managit/pages/connection/connection.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _LeaveHomeState();
}

class _LeaveHomeState extends State<Home> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final String today = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final String time = DateFormat('HH:mm').format(DateTime.now());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserData userData;

  @override
  void initState() async {
    userData = await getCurrentUserData();
    super.initState();
  }

  String generateId() {
    final random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const length = 20;

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<UserData> getCurrentUserData() async {
    if (_user == null) {
      throw Exception('No user is currently logged in.');
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('User')
            .doc(_user.uid)
            .get();

    if (!snapshot.exists) {
      throw Exception('User data not found in Firestore.');
    }

    final UserData userData = UserData();
    userData.fromMap(snapshot.data() as Map<String, dynamic>);
    return userData;
  }

  Future<void> signOut() async {
    showDialog(
        context: (context),
        builder: (BuildContext context) {
          return Center(
            child: Platform.isAndroid
                ? const CircularProgressIndicator(
                    color: Color.fromARGB(255, 30, 60, 100),
                  )
                : const CupertinoActivityIndicator(),
          );
        });
    try {
      await _auth.signOut();
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const Login();
      }));
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
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
              signOut();
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
                    return Center(
                        child: SizedBox(
                      height: size.height * 0.075,
                      width: size.width * 0.35,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              fixedSize: WidgetStatePropertyAll(size * 0.1),
                              foregroundColor:
                                  const WidgetStatePropertyAll(Colors.white),
                              backgroundColor: const WidgetStatePropertyAll(
                                  Color.fromARGB(255, 30, 60, 100))),
                          onPressed: () {
                            final String notificationId = generateId();
                            final String attendanceId = generateId();
                            FirebaseFirestore.instance
                                .collection('Attendance')
                                .doc(attendanceId)
                                .set({});
                            FirebaseFirestore.instance
                                .collection('Notification')
                                .doc(notificationId)
                                .set({
                              'id': notificationId,
                              'userID': _user.uid,
                              'date': today,
                              'time': time,
                              'type': 'entré',
                              'shift': 'Matin',
                              'content': '',
                              'isRead': false
                            });
                          },
                          child: Text(
                            'Arrivée',
                            style: TextStyle(fontSize: size.width * 0.05),
                          )),
                    ));
                  } else {
                    var data = snapshots.data?.docs.first;
                    if (data!['sortieMatin'] == '') {
                      return ElevatedButton(
                          style: ButtonStyle(
                              fixedSize: WidgetStatePropertyAll(size * 0.1),
                              foregroundColor:
                                  const WidgetStatePropertyAll(Colors.white),
                              backgroundColor: const WidgetStatePropertyAll(
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
                              'isRead': false
                            });
                          },
                          child: Text('Sortie Pause',
                              style: TextStyle(fontSize: size.width * 0.05)));
                    } else if (data['entréAM'] == '') {
                      return ElevatedButton(
                          style: ButtonStyle(
                              fixedSize: WidgetStatePropertyAll(size * 0.1),
                              foregroundColor:
                                  const WidgetStatePropertyAll(Colors.white),
                              backgroundColor: const WidgetStatePropertyAll(
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
                              'isRead': false
                            });
                          },
                          child: Text('Entré',
                              style: TextStyle(fontSize: size.width * 0.05)));
                    } else if (data['sortieAM'] == '') {
                      return ElevatedButton(
                          style: ButtonStyle(
                              fixedSize: WidgetStatePropertyAll(size * 0.1),
                              foregroundColor:
                                  const WidgetStatePropertyAll(Colors.white),
                              backgroundColor: const WidgetStatePropertyAll(
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
                              'isRead': false
                            });
                          },
                          child: Text('Sortie',
                              style: TextStyle(fontSize: size.width * 0.05)));
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
