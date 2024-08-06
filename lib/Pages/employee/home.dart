import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:managit/pages/connection/connection.dart';
import 'package:managit/pages/employee/leave_request.dart';
import 'package:managit/pages/employee/notifications_user.dart';
import 'package:managit/pages/employee/permission_request.dart';
import 'package:badges/badges.dart' as badges;

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
  var sent = false;

  String generateId() {
    final random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const length = 20;

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
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

  String calculateDuration(String startTime, String endTime) {
    // Parse the start time
    List<String> startParts = startTime.split(':');
    int startHour = int.parse(startParts[0]);
    int startMinute = int.parse(startParts[1]);

    // Parse the end time
    List<String> endParts = endTime.split(':');
    int endHour = int.parse(endParts[0]);
    int endMinute = int.parse(endParts[1]);

    // Create TimeOfDay objects
    TimeOfDay start = TimeOfDay(hour: startHour, minute: startMinute);
    TimeOfDay end = TimeOfDay(hour: endHour, minute: endMinute);

    // Calculate the difference in minutes
    int startInMinutes = start.hour * 60 + start.minute;
    int endInMinutes = end.hour * 60 + end.minute;

    int differenceInMinutes = endInMinutes - startInMinutes;

    // Calculate hours and minutes
    int hours = differenceInMinutes ~/ 60;
    int minutes = differenceInMinutes % 60;

    // Return the duration in '0H 0m' format
    return '${hours}H ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('User')
            .where('id', isEqualTo: _user!.uid)
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
          final user = snapshot.data?.docs.first;
          final userd = user!.data();
          int rest = userd['resteConge'];
          int sanc = 0;
          if (userd['Sanctions'] - userd['Sanctions'].truncate() < 0.6) {
            sanc = userd['Sanctions'].truncate();
          } else {
            sanc = userd['Sanctions'].ceil();
          }
          if (DateTime.now().month == (user['NbMois'] + 1)) {
            FirebaseFirestore.instance
                .collection('User')
                .doc(_user.uid)
                .update({
              'NbMois': userd['NbMois'] + 1,
              'Solde congé': ((userd['NbMois'] + 1) * 1.75).truncate(),
              'resteConge': userd['Solde congé'] +
                  userd['Solde congé année prec'] -
                  sanc -
                  userd['Congé pris']
            });
          }
          if (userd['NbMois'] == 12 && DateTime.now().month == 1) {
            userd['year'] = userd['year'] + 1;
            FirebaseFirestore.instance
                .collection('User')
                .doc(_user.uid)
                .update({
              'NbMois': 1,
              'Solde congé': 1.75.truncate(),
              'resteConge': 1,
              'Solde congé année prec': rest,
              'Sanctions': 0
            });
          }
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
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('UserNotification')
                      .where('isRead', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshots) {
                    if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
                      return IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const NotificationsUser();
                          }));
                        },
                        icon: const Icon(Icons.notifications),
                      );
                    }

                    int unreadCount = snapshots.data!.docs.length;

                    return badges.Badge(
                      position: badges.BadgePosition.custom(end: 5),
                      badgeContent: Text(
                        unreadCount.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const NotificationsUser();
                          }));
                        },
                        icon: const Icon(Icons.notifications),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.015),
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
                            .where('userID', isEqualTo: _user.uid)
                            .where('date', isEqualTo: today)
                            .snapshots(),
                        builder: (context, snapshots) {
                          late int day;
                          late String message;
                          day = DateTime.now().weekday;
                          if (day == 1 ||
                              day == 2 ||
                              day == 3 ||
                              day == 4 ||
                              day == 7) {
                            message = 'A demain.';
                          } else {
                            message = "Bon weekend.";
                          }
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
                                          fixedSize: WidgetStatePropertyAll(
                                              size * 0.1),
                                          foregroundColor:
                                              const WidgetStatePropertyAll(
                                                  Colors.white),
                                          backgroundColor:
                                              const WidgetStatePropertyAll(
                                                  Color.fromARGB(
                                                      255, 30, 60, 100))),
                                      onPressed: () {
                                        setState(() {
                                          // time = DateFormat('HH:mm')
                                          //     .format(DateTime.now());
                                          time = '09:02';
                                        });
                                        final String notificationId =
                                            generateId();
                                        final String attendanceId =
                                            generateId();
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
                                              '${userd['Nom']} ${userd['Prénom']} à pointé son entrée matin à $time',
                                          'isRead': false,
                                          'validé': false,
                                          'typeNot': 'pointage'
                                        });
                                      },
                                      icon: Image.asset(
                                          'assets/fingerprint.png')),
                                )),
                              ],
                            );
                          } else {
                            var data = snapshots.data?.docs.first;
                            if (data!['entréMatin'] != '' &&
                                data['sent'] == true) {
                              return Text(
                                'Validation...',
                                style: TextStyle(fontSize: size.width * 0.05),
                              );
                            }
                            if (data['sortieMatin'] == '') {
                              return Column(
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
                                              // time = DateFormat('HH:mm')
                                              //     .format(DateTime.now());
                                              time = '13:00';
                                            });
                                            final String id = generateId();
                                            String shift = calculateDuration(
                                                data['entréMatin'], time);
                                            FirebaseFirestore.instance
                                                .collection('Attendance')
                                                .doc(data['id'])
                                                .update({
                                              'shiftMatin': shift,
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
                                                  '${userd['Nom']} ${userd['Prénom']} à pointé son sortie de pause à $time',
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
                              );
                            }
                            if (data['sortieMatin'] != '' &&
                                data['sent'] == true) {
                              return Text(
                                'Validation...',
                                style: TextStyle(fontSize: size.width * 0.05),
                              );
                            }
                            if (data['entréAM'] == '') {
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
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.white),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Color.fromARGB(
                                                          255, 30, 60, 100))),
                                          onPressed: () {
                                            setState(() {
                                              // time = DateFormat('HH:mm')
                                              //     .format(DateTime.now());
                                              time = '14:05';
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
                                                  '${userd['Nom']} ${userd['Prénom']} à pointé son entrée après la pause à $time',
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
                              );
                            }
                            if (data['entréAM'] != '' && data['sent'] == true) {
                              return Text(
                                'Validation...',
                                style: TextStyle(fontSize: size.width * 0.05),
                              );
                            }
                            if (data['sortieAM'] == '') {
                              return Column(
                                children: [
                                  Text('Sortie',
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
                                              // time = DateFormat('HH:mm')
                                              //     .format(DateTime.now());
                                              time = '18:10';
                                            });
                                            final String id = generateId();
                                            String shift = calculateDuration(
                                                data['entréAM'], time);
                                            String prod = sumDurations(
                                                data['shiftMatin'], shift);
                                            String retard =
                                                calculateDailyTardiness(prod);
                                            FirebaseFirestore.instance
                                                .collection('Attendance')
                                                .doc(data['id'])
                                                .update({
                                              'retard': retard,
                                              'prod': prod,
                                              'shiftAM': shift,
                                              'sortieAM': time,
                                              'sent': true,
                                              'tardinessAM':
                                                  _calculateTardiness(
                                                      data['entréAM'],
                                                      time,
                                                      'AM')
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
                                                  '${userd['Nom']} ${userd['Prénom']} à pointé son sortie à $time',
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
                              );
                            }
                            if (data['sortieAM'] != '' &&
                                data['sent'] == true) {
                              return Text(
                                'Validation...',
                                style: TextStyle(fontSize: size.width * 0.05),
                              );
                            }
                          }
                          return Text(
                            message,
                            style: TextStyle(fontSize: size.width * 0.05),
                          );
                        }),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Divider(),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue ${userd['Nom']} ${userd['Prénom']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.06),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('User')
                            .where('id', isEqualTo: _user.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Platform.isAndroid
                                  ? const CircularProgressIndicator(
                                      color: Color.fromARGB(255, 30, 60, 100),
                                    )
                                  : const CupertinoActivityIndicator(),
                            );
                          }
                          final userSnapshot = snapshot.data?.docs;
                          final user = userSnapshot!.first;
                          final userData = user.data();
                          int a;
                          double b = userData['Sanctions'] as double;
                          if (b - b.truncate() < 0.5) {
                            a = b.truncate();
                          } else {
                            a = b.ceil();
                          }
                          return Container(
                            width: size.width * 0.9,
                            padding: EdgeInsets.all(size.width * 0.03),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 224, 227, 241),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 30, 60, 100))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Nombre de mois éffectués: ",
                                      style: TextStyle(
                                          fontSize: size.width * 0.04),
                                    ),
                                    Text(
                                      '${userData['NbMois']}',
                                      style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Solde de congé: ',
                                      style: TextStyle(
                                          fontSize: size.width * 0.04),
                                    ),
                                    Text(
                                      '${userData['Solde congé']}',
                                      style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Congés pris: ",
                                      style: TextStyle(
                                          fontSize: size.width * 0.04),
                                    ),
                                    Text(
                                      '${userData['Congé pris']}',
                                      style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                              255, 221, 204, 53)),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Sanctions: ",
                                      style: TextStyle(
                                          fontSize: size.width * 0.04),
                                    ),
                                    Text(
                                      a.toString(),
                                      style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Reste de congés: ",
                                      style: TextStyle(
                                          fontSize: size.width * 0.04),
                                    ),
                                    Text(
                                      '${userData['resteConge']}',
                                      style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Reste de congés de l'année précédente: ",
                                      style: TextStyle(
                                          fontSize: size.width * 0.04),
                                    ),
                                    Text(
                                      '${userData['Solde congé année prec']}',
                                      style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              ],
                            ),
                          );
                        }),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Container(
                      width: size.width * 0.9,
                      height: size.height * 0.07,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 30, 60, 100),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const LeaveRequest();
                            }));
                          },
                          child: Text(
                            'Congés',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.055),
                          )),
                    ),
                    SizedBox(height: size.height * 0.025),
                    Container(
                      width: size.width * 0.9,
                      height: size.height * 0.07,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 30, 60, 100),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const PermissionRequest();
                            }));
                          },
                          child: Text(
                            'Autorisations',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.055),
                          )),
                    ),
                    SizedBox(height: size.height * 0.025),
                    Container(
                      width: size.width * 0.9,
                      height: size.height * 0.07,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 30, 60, 100),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const Scaffold();
                            }));
                          },
                          child: Text(
                            'Retards',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.055),
                          )),
                    ),
                    SizedBox(height: size.height * 0.025),
                    Container(
                      width: size.width * 0.9,
                      height: size.height * 0.07,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 30, 60, 100),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const Scaffold();
                            }));
                          },
                          child: Text(
                            'Absences',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.055),
                          )),
                    ),
                    SizedBox(height: size.height * 0.025),
                    Container(
                      width: size.width * 0.9,
                      height: size.height * 0.07,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 30, 60, 100),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const Scaffold();
                            }));
                          },
                          child: Text(
                            'Pénalités',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.055),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.height * 0.01),
                      child: Image.asset('assets/picture.png',
                          scale: size.height * 0.025),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  String sumDurations(String duration1, String duration2) {
    // Parse the first duration
    List<String> parts1 = duration1.split(' ');
    int hours1 = int.parse(parts1[0].replaceAll('H', ''));
    int minutes1 = int.parse(parts1[1].replaceAll('m', ''));

    // Parse the second duration
    List<String> parts2 = duration2.split(' ');
    int hours2 = int.parse(parts2[0].replaceAll('H', ''));
    int minutes2 = int.parse(parts2[1].replaceAll('m', ''));

    // Calculate total hours and minutes
    int totalMinutes = (hours1 * 60 + minutes1) + (hours2 * 60 + minutes2);
    int totalHours = totalMinutes ~/ 60;
    int remainingMinutes = totalMinutes % 60;

    // Return the sum of durations in '0H 0m' format
    return '${totalHours}H ${remainingMinutes}m';
  }

  String _calculateTardiness(String entryTime, String exitTime, String shift) {
    final entry = DateFormat('HH:mm').parse(entryTime);
    final exit = DateFormat('HH:mm').parse(exitTime);

    Duration tardiness;
    if (shift == 'Matin') {
      final shiftStart = DateTime(entry.year, entry.month, entry.day, 9, 0);
      final shiftEnd = DateTime(entry.year, entry.month, entry.day, 13, 0);

      tardiness = shiftEnd.difference(entry) - exit.difference(shiftStart);
    } else {
      final shiftStart = DateTime(entry.year, entry.month, entry.day, 14, 0);
      final shiftEnd = DateTime(entry.year, entry.month, entry.day, 18, 0);

      tardiness = shiftEnd.difference(entry) - exit.difference(shiftStart);
    }

    // Convert tardiness to string in the format '0H 0m'
    return _durationToString(tardiness);
  }

  String _durationToString(Duration duration) {
    int hours = duration.inHours * (-1);
    int minutes = duration.inMinutes.remainder(60) * (-1);

    return '${hours}H ${minutes}m';
  }

  String calculateDailyTardiness(String recordedDuration) {
    // Split the recorded duration into hours and minutes
    List<String> parts = recordedDuration.split(' ');
    int recordedHours = int.parse(parts[0].replaceAll('H', ''));
    int recordedMinutes = int.parse(parts[1].replaceAll('m', ''));

    // Convert recorded duration to minutes
    int recordedTotalMinutes = (recordedHours * 60) + recordedMinutes;

    // Define the normal work duration in minutes (8 hours)
    int normalWorkDurationMinutes = 8 * 60;

    // Calculate the tardiness in minutes
    int tardinessMinutes = normalWorkDurationMinutes - recordedTotalMinutes;

    // Convert tardiness back to hours and minutes
    int tardinessHours = tardinessMinutes ~/ 60;
    int tardinessRemainingMinutes = tardinessMinutes % 60;

    // Return the tardiness as a string in '0H 0m' format
    return '${tardinessHours}H ${tardinessRemainingMinutes}m';
  }
}
