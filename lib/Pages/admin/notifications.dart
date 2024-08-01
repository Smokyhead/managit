import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<StatefulWidget> createState() => NotificationsState();
}

class NotificationsState extends State<Notifications> {
  final String today = DateFormat('dd/MM/yyyy').format(DateTime.now());

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
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 30, 60, 100),
          foregroundColor: Colors.white,
          title: Text(
            'Notifications',
            style: TextStyle(fontSize: size.width * 0.0475),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
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
                      Timestamp timestamp = data['timestamp'];
                      DateTime notificationTime = timestamp.toDate();
                      String timeAgo =
                          timeago.format(notificationTime, locale: 'fr');
                      if (data['typeNot'] == 'pointage') {}
                      switch (data['typeNot']) {
                        case ('pointage'):
                          return ListTile(
                            tileColor: data['isRead'] == false
                                ? const Color.fromARGB(255, 215, 230, 245)
                                : Colors.transparent,
                            title: Padding(
                              padding:
                                  EdgeInsets.only(left: size.width * 0.035),
                              child: Text(data['content'],
                                  style:
                                      TextStyle(fontSize: size.width * 0.045)),
                            ),
                            subtitle: Column(
                              children: [
                                data['validé'] == false
                                    ? Padding(
                                        padding:
                                            EdgeInsets.all(size.height * 0.01),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                                style: const ButtonStyle(
                                                    shape: WidgetStatePropertyAll(
                                                        BeveledRectangleBorder()),
                                                    foregroundColor:
                                                        WidgetStatePropertyAll(
                                                            Colors.white),
                                                    backgroundColor:
                                                        WidgetStatePropertyAll(
                                                            Color.fromARGB(255,
                                                                30, 60, 100))),
                                                onPressed: () {
                                                  final String id =
                                                      generateId();
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'Notification')
                                                      .doc(data['id'])
                                                      .update({
                                                    'validé': true,
                                                    'isRead': true
                                                  });
                                                  FirebaseFirestore.instance
                                                      .collection('Attendance')
                                                      .doc(data['attendanceId'])
                                                      .update({'sent': false});
                                                  if (data['type'] ==
                                                          'entréMatin' ||
                                                      data['type'] ==
                                                          'entréAM') {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'UserNotification')
                                                        .doc(id)
                                                        .set({
                                                      'id': id,
                                                      'userID': data['userID'],
                                                      'timestamp':
                                                          DateTime.now(),
                                                      'date': today,
                                                      'content':
                                                          'Votre pointage a été validé.',
                                                      'isRead': false,
                                                    });
                                                  } else {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'UserNotification')
                                                        .doc(id)
                                                        .set({
                                                      'id': id,
                                                      'userID': data['userID'],
                                                      'timestamp':
                                                          DateTime.now(),
                                                      'date': today,
                                                      'content':
                                                          'Votre sortie a été validé.',
                                                      'isRead': false,
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  'Valider',
                                                  style: TextStyle(
                                                      fontSize:
                                                          size.height * 0.02),
                                                )),
                                            ElevatedButton(
                                                style: const ButtonStyle(
                                                  side: WidgetStatePropertyAll(
                                                      BorderSide(
                                                          color: Color.fromARGB(
                                                              255,
                                                              30,
                                                              60,
                                                              100))),
                                                  shape: WidgetStatePropertyAll(
                                                      BeveledRectangleBorder()),
                                                  foregroundColor:
                                                      WidgetStatePropertyAll(
                                                          Color.fromARGB(255,
                                                              30, 60, 100)),
                                                ),
                                                onPressed: () {
                                                  final String id =
                                                      generateId();
                                                  switch (data['type']) {
                                                    case ('entréMatin'):
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'Notification')
                                                          .doc(data['id'])
                                                          .update({
                                                        'validé': true,
                                                        'isRead': true
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'Attendance')
                                                          .doc(data[
                                                              'attendanceId'])
                                                          .delete();
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'UserNotification')
                                                          .doc(id)
                                                          .set({
                                                        'id': id,
                                                        'userID':
                                                            data['userID'],
                                                        'timestamp':
                                                            DateTime.now(),
                                                        'date': today,
                                                        'content':
                                                            'Votre pointage a été refusé.',
                                                        'isRead': false,
                                                      });
                                                    case ('sortieMatin'):
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'Notification')
                                                          .doc(data['id'])
                                                          .update({
                                                        'validé': true,
                                                        'isRead': true
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'Attendance')
                                                          .doc(data[
                                                              'attendanceId'])
                                                          .update({
                                                        'shiftMatin': '',
                                                        'sortieMatin': '',
                                                        'sent': false,
                                                        'tardinessMatin': ''
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'UserNotification')
                                                          .doc(id)
                                                          .set({
                                                        'id': id,
                                                        'userID':
                                                            data['userID'],
                                                        'timestamp':
                                                            DateTime.now(),
                                                        'date': today,
                                                        'content':
                                                            'Votre sortie a été refusé.',
                                                        'isRead': false,
                                                      });
                                                    case ('entréAM'):
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'Notification')
                                                          .doc(data['id'])
                                                          .update({
                                                        'validé': true,
                                                        'isRead': true
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'Attendance')
                                                          .doc(data[
                                                              'attendanceId'])
                                                          .update({
                                                        'sent': false,
                                                        'entréAM': ''
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'UserNotification')
                                                          .doc(id)
                                                          .set({
                                                        'id': id,
                                                        'userID':
                                                            data['userID'],
                                                        'timestamp':
                                                            DateTime.now(),
                                                        'date': today,
                                                        'content':
                                                            'Votre pointage a été refusé.',
                                                        'isRead': false,
                                                      });
                                                    case ('sortieAM'):
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'Notification')
                                                          .doc(data['id'])
                                                          .update({
                                                        'validé': true,
                                                        'isRead': true
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'Attendance')
                                                          .doc(data[
                                                              'attendanceId'])
                                                          .update({
                                                        'shiftAM': '',
                                                        'sortieAM': '',
                                                        'sent': false,
                                                        'tardinessAM': '',
                                                        'prod': '',
                                                        'retard': ''
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'UserNotification')
                                                          .doc(id)
                                                          .set({
                                                        'id': id,
                                                        'userID':
                                                            data['userID'],
                                                        'timestamp':
                                                            DateTime.now(),
                                                        'date': today,
                                                        'content':
                                                            'Votre sortie a été refusé.',
                                                        'isRead': false,
                                                      });
                                                  }
                                                },
                                                child: Text(
                                                  'Refuser',
                                                  style: TextStyle(
                                                      fontSize:
                                                          size.height * 0.02),
                                                ))
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: size.width * 0.035),
                                  child: Row(
                                    children: [
                                      Text(timeAgo),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        case ('leaveRequest'):
                          return ListTile(
                            tileColor: data['isRead'] == false
                                ? const Color.fromARGB(255, 215, 230, 245)
                                : Colors.transparent,
                            title: Padding(
                              padding:
                                  EdgeInsets.only(left: size.width * 0.035),
                              child: Text(
                                data['content'],
                                style: TextStyle(fontSize: size.width * 0.045),
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                                  EdgeInsets.only(left: size.width * 0.035),
                              child: Row(
                                children: [
                                  Text(timeAgo),
                                ],
                              ),
                            ),
                            onTap: () {
                              showBottomSheet(
                                  shape: const BeveledRectangleBorder(),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SizedBox(
                                      width: size.width,
                                      height: size.height * 0.35,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(size.width * 0.05),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Demande de congé',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: size.width * 0.065),
                                            ),
                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(data['user'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                SizedBox(
                                                  height: size.height * 0.03,
                                                ),
                                                data['days'] == 1
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              'Date:  ${data['date']}',
                                                              style: TextStyle(
                                                                  fontSize: size
                                                                          .width *
                                                                      0.05)),
                                                          Text(
                                                              'Nombre de jours:  ${data['days']}',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      size.width *
                                                                          0.05))
                                                        ],
                                                      )
                                                    : SizedBox(
                                                        width: size.width * 0.9,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                'Date de début:  "${data['startDate']}"',
                                                                style: TextStyle(
                                                                    fontSize: size
                                                                            .width *
                                                                        0.05)),
                                                            Text(
                                                                'Date de fin:  "${data['endDate']}"',
                                                                style: TextStyle(
                                                                    fontSize: size
                                                                            .width *
                                                                        0.05)),
                                                            Text(
                                                                'Nombre de jours:  "${data['days']}"',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        size.width *
                                                                            0.05))
                                                          ],
                                                        ),
                                                      ),
                                                SizedBox(
                                                  height: size.height * 0.02,
                                                ),
                                                data['status'] == 'pending'
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          ElevatedButton(
                                                              style: const ButtonStyle(
                                                                  shape: WidgetStatePropertyAll(
                                                                      BeveledRectangleBorder()),
                                                                  foregroundColor:
                                                                      WidgetStatePropertyAll(
                                                                          Colors
                                                                              .white),
                                                                  backgroundColor:
                                                                      WidgetStatePropertyAll(Color.fromARGB(
                                                                          255,
                                                                          30,
                                                                          60,
                                                                          100))),
                                                              onPressed:
                                                                  () async {
                                                                final DocumentSnapshot<
                                                                        Map<String,
                                                                            dynamic>>
                                                                    snapshot =
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'User')
                                                                        .doc(data[
                                                                            'userID'])
                                                                        .get();
                                                                final userdata =
                                                                    snapshot
                                                                        .data();
                                                                final String
                                                                    notId =
                                                                    generateId();
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'UserNotification')
                                                                    .doc(notId)
                                                                    .set({
                                                                  'id': notId,
                                                                  'userID': data[
                                                                      'userID'],
                                                                  'timestamp':
                                                                      DateTime
                                                                          .now(),
                                                                  'date': today,
                                                                  'content':
                                                                      'Votre demande de congé a été acceptée.\n ${data['days']} jours ont été retirés de votre solde de congé.',
                                                                  'isRead':
                                                                      false,
                                                                });
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Notification')
                                                                    .doc(data[
                                                                        'id'])
                                                                    .update({
                                                                  'isRead':
                                                                      true,
                                                                  'validé':
                                                                      true,
                                                                  'status':
                                                                      'Accepté'
                                                                });
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'LeaveRequests')
                                                                    .doc(data[
                                                                        'leaveId'])
                                                                    .update({
                                                                  'status':
                                                                      'approved'
                                                                });
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'User')
                                                                    .doc(data[
                                                                        'userID'])
                                                                    .update({
                                                                  'Solde congé':
                                                                      userdata![
                                                                              'Solde congé'] -
                                                                          data[
                                                                              'days']
                                                                });
                                                                Navigator.of(
                                                                    // ignore: use_build_context_synchronously
                                                                    context).pop();
                                                              },
                                                              child: Text(
                                                                'Valider',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        size.height *
                                                                            0.02),
                                                              )),
                                                          ElevatedButton(
                                                            style:
                                                                const ButtonStyle(
                                                              side: WidgetStatePropertyAll(BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          30,
                                                                          60,
                                                                          100))),
                                                              shape: WidgetStatePropertyAll(
                                                                  BeveledRectangleBorder()),
                                                              foregroundColor:
                                                                  WidgetStatePropertyAll(
                                                                      Color.fromARGB(
                                                                          255,
                                                                          30,
                                                                          60,
                                                                          100)),
                                                            ),
                                                            onPressed: () {
                                                              final String
                                                                  notId =
                                                                  generateId();
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'UserNotification')
                                                                  .doc(notId)
                                                                  .set({
                                                                'id': notId,
                                                                'userID': data[
                                                                    'userID'],
                                                                'timestamp':
                                                                    DateTime
                                                                        .now(),
                                                                'date': today,
                                                                'content':
                                                                    'Votre demande de congé a été refusé.',
                                                                'isRead': false,
                                                              });
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'LeaveRequests')
                                                                  .doc(data[
                                                                      'leaveId'])
                                                                  .delete();
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Notification')
                                                                  .doc(data[
                                                                      'id'])
                                                                  .update({
                                                                'isRead': true,
                                                                'validé': true,
                                                                'status':
                                                                    'Refusé'
                                                              });
                                                              Navigator.of(
                                                                  // ignore: use_build_context_synchronously
                                                                  context).pop();
                                                            },
                                                            child: const Text(
                                                                'Refuser'),
                                                          )
                                                        ],
                                                      )
                                                    : Text(
                                                        data['status'],
                                                        style: TextStyle(
                                                            fontSize:
                                                                size.width *
                                                                    0.055),
                                                      ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                          );
                        case ('autRequest'):
                          return ListTile(
                            tileColor: data['isRead'] == false
                                ? const Color.fromARGB(255, 215, 230, 245)
                                : Colors.transparent,
                            title: Padding(
                              padding:
                                  EdgeInsets.only(left: size.width * 0.035),
                              child: Text(
                                data['content'],
                                style: TextStyle(fontSize: size.width * 0.045),
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                                  EdgeInsets.only(left: size.width * 0.035),
                              child: Row(
                                children: [
                                  Text(timeAgo),
                                ],
                              ),
                            ),
                            onTap: () {
                              showBottomSheet(
                                  shape: const BeveledRectangleBorder(),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SizedBox(
                                      width: size.width,
                                      height: size.height * 0.4,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(size.width * 0.05),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Demande d'autorisation",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: size.width * 0.065),
                                            ),
                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(data['user'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                SizedBox(
                                                  height: size.height * 0.03,
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.9,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Date:  "${data['date']}"',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  size.width *
                                                                      0.05)),
                                                      Text(
                                                          'Heure de début:  "${data['startTime']}"',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  size.width *
                                                                      0.05)),
                                                      Text(
                                                          'Heure de fin:  "${data['endTime']}"',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  size.width *
                                                                      0.05)),
                                                      Text(
                                                          'Nombre d\'heures:  "${data['hours']}"',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  size.width *
                                                                      0.05))
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.02,
                                                ),
                                                data['status'] == 'pending'
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          ElevatedButton(
                                                              style: const ButtonStyle(
                                                                  shape: WidgetStatePropertyAll(
                                                                      BeveledRectangleBorder()),
                                                                  foregroundColor:
                                                                      WidgetStatePropertyAll(
                                                                          Colors
                                                                              .white),
                                                                  backgroundColor:
                                                                      WidgetStatePropertyAll(Color.fromARGB(
                                                                          255,
                                                                          30,
                                                                          60,
                                                                          100))),
                                                              onPressed:
                                                                  () async {
                                                                final DocumentSnapshot<
                                                                        Map<String,
                                                                            dynamic>>
                                                                    snapshot =
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'User')
                                                                        .doc(data[
                                                                            'userID'])
                                                                        .get();
                                                                final userdata =
                                                                    snapshot
                                                                        .data();

                                                                int a;
                                                                double b = userdata![
                                                                        'Sanctions'] +
                                                                    (data['hours'] /
                                                                        8)as double;
                                                                if (b - b.truncate() <
                                                                    0.6) {
                                                                  a = b
                                                                      .truncate();
                                                                } else {
                                                                  a = b.ceil();
                                                                }
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'User')
                                                                    .doc(data[
                                                                        'userID'])
                                                                    .update({
                                                                  'Sanctions': userdata[
                                                                          'Sanctions'] +
                                                                      (data['hours'] /
                                                                          8),
                                                                  'Solde congé': userdata[
                                                                          'Solde congé'] +
                                                                      userdata[
                                                                          'Solde congé année prec'] -
                                                                      userdata[
                                                                          'Congé pris'] -
                                                                      a
                                                                });
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Autorisation')
                                                                    .doc(data[
                                                                        'autId'])
                                                                    .update({
                                                                  'status':
                                                                      'approved'
                                                                });
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Notification')
                                                                    .doc(data[
                                                                        'id'])
                                                                    .update({
                                                                  'isRead':
                                                                      true,
                                                                  'validé':
                                                                      true,
                                                                  'status':
                                                                      'Accepté'
                                                                });
                                                                String notId1 =
                                                                    generateId();
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'UserNotification')
                                                                    .doc(notId1)
                                                                    .set({
                                                                  'id': notId1,
                                                                  'userID': data[
                                                                      'userID'],
                                                                  'timestamp':
                                                                      DateTime
                                                                          .now(),
                                                                  'date': today,
                                                                  'content':
                                                                      'Votre demande d\'autorisation a été acceptée.',
                                                                  'isRead':
                                                                      false,
                                                                });
                                                                Navigator.of(
                                                                    // ignore: use_build_context_synchronously
                                                                    context).pop();
                                                              },
                                                              child: Text(
                                                                'Valider',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        size.height *
                                                                            0.02),
                                                              )),
                                                          ElevatedButton(
                                                            style:
                                                                const ButtonStyle(
                                                              side: WidgetStatePropertyAll(BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          30,
                                                                          60,
                                                                          100))),
                                                              shape: WidgetStatePropertyAll(
                                                                  BeveledRectangleBorder()),
                                                              foregroundColor:
                                                                  WidgetStatePropertyAll(
                                                                      Color.fromARGB(
                                                                          255,
                                                                          30,
                                                                          60,
                                                                          100)),
                                                            ),
                                                            onPressed: () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Autorisation')
                                                                  .doc(data[
                                                                      'autId'])
                                                                  .delete();
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Notification')
                                                                  .doc(data[
                                                                      'id'])
                                                                  .update({
                                                                'isRead': true,
                                                                'validé': true,
                                                                'status':
                                                                    'Refusé'
                                                              });
                                                              String notId2 =
                                                                  generateId();
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'UserNotification')
                                                                  .doc(notId2)
                                                                  .set({
                                                                'id': notId2,
                                                                'userID': data[
                                                                    'userID'],
                                                                'timestamp':
                                                                    DateTime
                                                                        .now(),
                                                                'date': today,
                                                                'content':
                                                                    'Votre demande d\'autorisation a été refusée.',
                                                                'isRead': false,
                                                              });
                                                              Navigator.of(
                                                                  // ignore: use_build_context_synchronously
                                                                  context).pop();
                                                            },
                                                            child: const Text(
                                                                'Refuser'),
                                                          )
                                                        ],
                                                      )
                                                    : Text(
                                                        data['status'],
                                                        style: TextStyle(
                                                            fontSize:
                                                                size.width *
                                                                    0.055),
                                                      ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                          );
                      }
                      return const SizedBox.shrink();
                    });
              }
            }));
  }
}
