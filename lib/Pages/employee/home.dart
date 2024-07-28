import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:managit/models/user_model.dart';
import 'package:managit/pages/connection/connection.dart';
import 'package:managit/pages/employee/leave_request.dart';
import 'package:managit/pages/employee/notifications_user.dart';
import 'package:managit/pages/employee/permission_request.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final String today = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String time = DateFormat('HH:mm').format(DateTime.now());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserData _userData;
  var sent = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('User')
            .doc(_user!.uid)
            .get();

    if (!snapshot.exists) {
      throw Exception('User data not found in Firestore.');
    }

    final UserData userData = UserData();
    userData.fromMap(snapshot.data() as Map<String, dynamic>);
    return userData;
  }

  Future<void> _fetchUserData() async {
    final userData = await getCurrentUserData();
    setState(() {
      _userData = userData;
    });
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
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const NotificationsUser();
                }));
              },
              icon: const Icon(Icons.notifications))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                child: Center(
                  child: Text(
                    DateFormat('dd - MM - yyyy').format(DateTime.now()),
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: size.width * 0.05),
                  ),
                ),
              ),
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
                      return Column(
                        children: [
                          Text('Arrivé Matin',
                              style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          Center(
                              child: SizedBox(
                            width: size.width * 0.25,
                            height: size.width * 0.3,
                            child: IconButton(
                                style: ButtonStyle(
                                    fixedSize:
                                        WidgetStatePropertyAll(size * 0.1),
                                    foregroundColor:
                                        const WidgetStatePropertyAll(
                                            Colors.white),
                                    backgroundColor:
                                        const WidgetStatePropertyAll(
                                            Color.fromARGB(255, 30, 60, 100))),
                                onPressed: () {
                                  setState(() {
                                    time = DateFormat('HH:mm')
                                        .format(DateTime.now());
                                  });
                                  final String notificationId = generateId();
                                  final String attendanceId = generateId();
                                  FirebaseFirestore.instance
                                      .collection('Attendance')
                                      .doc(attendanceId)
                                      .set({
                                    'id': attendanceId,
                                    'userID': _user.uid,
                                    'date': today,
                                    'entréMatin': time,
                                    'entréAM': '',
                                    'sortieMatin': '',
                                    'sortieAM': '',
                                    'shiftMatin': '',
                                    'shiftAM': '',
                                    'sent': true,
                                    'absence': 'non',
                                    'environnement': 'Onsite',
                                    'prod': '',
                                    'retard': ''
                                  });
                                  FirebaseFirestore.instance
                                      .collection('Notification')
                                      .doc(notificationId)
                                      .set({
                                    'id': notificationId,
                                    'attendanceId': attendanceId,
                                    'userID': _user.uid,
                                    'timestamp': DateTime.now(),
                                    'date': today,
                                    'time': time,
                                    'type': 'entréMatin',
                                    'content':
                                        '${_userData.nom} ${_userData.prenom} à pointé son entrée matin à $time',
                                    'isRead': false,
                                    'validé': false,
                                    'typeNot': 'pointage'
                                  });
                                },
                                icon: Image.asset('assets/fingerprint.png')),
                          )),
                        ],
                      );
                    } else {
                      var data = snapshots.data?.docs.first;
                      if (data!['sortieMatin'] == '') {
                        return data['sent'] == false
                            ? Column(
                                children: [
                                  Text('Sortie de pause',
                                      style: TextStyle(
                                          fontSize: size.width * 0.05,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: size.height * 0.02,
                                  ),
                                  Center(
                                    child: SizedBox(
                                      width: size.width * 0.25,
                                      height: size.width * 0.3,
                                      child: IconButton(
                                          style: const ButtonStyle(
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.white),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Color.fromARGB(
                                                          255, 30, 60, 100))),
                                          onPressed: () {
                                            setState(() {
                                              time = DateFormat('HH:mm')
                                                  .format(DateTime.now());
                                            });
                                            final String id = generateId();
                                            FirebaseFirestore.instance
                                                .collection('Attendance')
                                                .doc(data['id'])
                                                .update({
                                              'sortieMatin': time,
                                              'sent': true,
                                              'tardinessMatin':
                                                  _calculateTardiness(
                                                      data['entréMatin'],
                                                      time,
                                                      'Matin')
                                            });
                                            FirebaseFirestore.instance
                                                .collection('Notification')
                                                .doc(id)
                                                .set({
                                              'id': id,
                                              'userID': _user.uid,
                                              'attendanceId': data['id'],
                                              'timestamp': DateTime.now(),
                                              'date': today,
                                              'time': time,
                                              'type': 'sortieMatin',
                                              'content':
                                                  '${_userData.nom} ${_userData.prenom} à pointé son sortie de pause à $time',
                                              'isRead': false,
                                              'validé': false,
                                              'typeNot': 'pointage'
                                            });
                                          },
                                          icon: Image.asset(
                                              'assets/fingerprint.png')),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Validation...',
                                style: TextStyle(fontSize: size.width * 0.05),
                              );
                      } else if (data['entréAM'] == '') {
                        return data['sent'] == false
                            ? Column(
                                children: [
                                  Text('Retour',
                                      style: TextStyle(
                                          fontSize: size.width * 0.05,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: size.height * 0.02,
                                  ),
                                  Center(
                                    child: SizedBox(
                                      width: size.width * 0.25,
                                      height: size.width * 0.3,
                                      child: IconButton(
                                          style: const ButtonStyle(
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.white),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Color.fromARGB(
                                                          255, 30, 60, 100))),
                                          onPressed: () {
                                            setState(() {
                                              time = DateFormat('HH:mm')
                                                  .format(DateTime.now());
                                            });
                                            final String id = generateId();
                                            FirebaseFirestore.instance
                                                .collection('Attendance')
                                                .doc(data['id'])
                                                .update({
                                              'entréAM': time,
                                              'sent': true
                                            });
                                            FirebaseFirestore.instance
                                                .collection('Notification')
                                                .doc(id)
                                                .set({
                                              'id': id,
                                              'userID': _user.uid,
                                              'attendanceId': data['id'],
                                              'timestamp': DateTime.now(),
                                              'date': today,
                                              'time': time,
                                              'type': 'entréAM',
                                              'content':
                                                  '${_userData.nom} ${_userData.prenom} à pointé son entrée après la pause à $time',
                                              'isRead': false,
                                              'validé': false,
                                              'typeNot': 'pointage'
                                            });
                                          },
                                          icon: Image.asset(
                                              'assets/fingerprint.png')),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Validation...',
                                style: TextStyle(fontSize: size.width * 0.05),
                              );
                      } else if (data['sortieAM'] == '') {
                        return Column(
                          children: [
                            Text('Retour',
                                style: TextStyle(
                                    fontSize: size.width * 0.05,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            Center(
                              child: SizedBox(
                                width: size.width * 0.25,
                                height: size.width * 0.3,
                                child: IconButton(
                                    style: const ButtonStyle(
                                        foregroundColor: WidgetStatePropertyAll(
                                            Colors.white),
                                        backgroundColor: WidgetStatePropertyAll(
                                            Color.fromARGB(255, 30, 60, 100))),
                                    onPressed: () {
                                      setState(() {
                                        time = DateFormat('HH:mm')
                                            .format(DateTime.now());
                                      });
                                      final String id = generateId();
                                      FirebaseFirestore.instance
                                          .collection('Attendance')
                                          .doc(data['id'])
                                          .update({
                                        'sortieAM': time,
                                        'sent': true,
                                        'tardinessAM': _calculateTardiness(
                                            data['entréAM'], time, 'AM')
                                      });
                                      FirebaseFirestore.instance
                                          .collection('Notification')
                                          .doc(id)
                                          .set({
                                        'id': id,
                                        'userID': _user.uid,
                                        'attendanceId': data['id'],
                                        'timestamp': DateTime.now(),
                                        'date': today,
                                        'time': time,
                                        'type': 'sortieAM',
                                        'content':
                                            '${_userData.nom} ${_userData.prenom} à pointé son sortie à $time',
                                        'isRead': false,
                                        'validé': false,
                                        'typeNot': 'pointage'
                                      });
                                    },
                                    icon:
                                        Image.asset('assets/fingerprint.png')),
                              ),
                            ),
                          ],
                        );
                      }
                      if (data['sortieAM'] != '' && data['sent'] == true) {
                        return Text(
                          'Validation...',
                          style: TextStyle(fontSize: size.width * 0.05),
                        );
                      }
                    }
                    return Text(
                      'A demain',
                      style: TextStyle(fontSize: size.width * 0.05),
                    );
                  }),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Divider(),
              ),
              Container(
                width: size.width * 0.6,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 30, 60, 100)),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const LeaveRequest();
                      }));
                    },
                    child: const Text(
                      'Demander congé',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              SizedBox(height: size.height * 0.025),
              Container(
                width: size.width * 0.6,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 30, 60, 100)),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const PermissionRequest();
                      }));
                    },
                    child: const Text(
                      'Demander autorisation',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              SizedBox(height: size.height * 0.025),
              Container(
                width: size.width * 0.6,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 30, 60, 100)),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const Scaffold();
                      }));
                    },
                    child: const Text(
                      'Retards',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              SizedBox(height: size.height * 0.025),
              Container(
                width: size.width * 0.6,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 30, 60, 100)),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const Scaffold();
                      }));
                    },
                    child: const Text(
                      'Pénalités',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              SizedBox(height: size.height * 0.025),
              Container(
                width: size.width * 0.6,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 30, 60, 100)),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const Scaffold();
                      }));
                    },
                    child: const Text(
                      'Absences',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateTardiness(String entryTime, String exitTime, String shift) {
    final entry = DateFormat('HH:mm').parse(entryTime);
    final exit = DateFormat('HH:mm').parse(exitTime);

    Duration tardiness;
    if (shift == 'Matin') {
      final shiftStart = DateTime(entry.year, entry.month, entry.day, 8, 0);
      final shiftEnd = DateTime(entry.year, entry.month, entry.day, 12, 0);

      tardiness = shiftEnd.difference(entry) - exit.difference(shiftStart);
    } else {
      final shiftStart = DateTime(entry.year, entry.month, entry.day, 13, 0);
      final shiftEnd = DateTime(entry.year, entry.month, entry.day, 17, 0);

      tardiness = shiftEnd.difference(entry) - exit.difference(shiftStart);
    }

    int tardinessMinutes = tardiness.inMinutes;

    // Update tardiness record
    _updateTardinessRecord(shift, tardinessMinutes);

    return tardinessMinutes;
  }

  // Update tardiness record
  Future<void> _updateTardinessRecord(
      String shift, int tardinessMinutes) async {
    final String tardinessId = generateId();
    final tardinessRef =
        FirebaseFirestore.instance.collection('Tardiness').doc(tardinessId);

    await tardinessRef.set({
      'id': tardinessId,
      'userID': _user!.uid,
      'date': today,
      'shift': shift,
      'tardiness': tardinessMinutes * (-1),
    }, SetOptions(merge: true));
  }
}

/*final String id = generateId();
                                          FirebaseFirestore.instance
                                              .collection('Attendance')
                                              .doc(data['id'])
                                              .update({
                                            'sortieAM': time,
                                            'sent': true,
                                            'tardinessAM': _calculateTardiness(
                                                data['entréAM'], time, 'AM')
                                          });
                                          FirebaseFirestore.instance
                                              .collection('Notification')
                                              .doc(id)
                                              .set({
                                            'id': id,
                                            'userID': _user.uid,
                                            'attendanceId': data['id'],
                                            'timestamp': DateTime.now(),
                                            'date': today,
                                            'time': time,
                                            'type': 'sortieAM',
                                            'content':
                                                '${_userData.nom} ${_userData.prenom} à pointé son sortie à $time',
                                            'isRead': false,
                                            'validé': false,
                                            'typeNot': 'pointage'
                                          });*/