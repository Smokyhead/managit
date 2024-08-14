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
  bool modifyPressed = false;
  TimeOfDay? pickedTime;
  String formattedTime = '';

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime;
    pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return pickedTime!;
  }

  Future<Map<String, dynamic>> getAtt(String id) async {
    Map<String, dynamic>? data;
    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('Attendance').doc(id);
      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        data = docSnapshot.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error getting document: $e");
    }
    return data!;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final int hour = time.hour;
    final int minute = time.minute;
    final String formattedHour = hour.toString().padLeft(2, '0');
    final String formattedMinute = minute.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMinute';
  }

  String generateId() {
    final random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const length = 20;

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
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
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                SizedBox(
                                                  width: size.width * 0.3,
                                                  child: ElevatedButton(
                                                      style: const ButtonStyle(
                                                          shape: WidgetStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              15)))),
                                                          foregroundColor:
                                                              WidgetStatePropertyAll(
                                                                  Colors.white),
                                                          backgroundColor:
                                                              WidgetStatePropertyAll(
                                                                  Color.fromARGB(
                                                                      255,
                                                                      30,
                                                                      60,
                                                                      100))),
                                                      onPressed: () {
                                                        final String id =
                                                            generateId();
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Notification')
                                                            .doc(data['id'])
                                                            .update({
                                                          'validé': true,
                                                          'isRead': true
                                                        });
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Attendance')
                                                            .doc(data[
                                                                'attendanceId'])
                                                            .update({
                                                          'sent': false
                                                        });
                                                        if (data['type'] ==
                                                                'entréMatin' ||
                                                            data['type'] ==
                                                                'entréAM') {
                                                          FirebaseFirestore
                                                              .instance
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
                                                                'Votre pointage a été validé.',
                                                            'isRead': false,
                                                          });
                                                        } else {
                                                          FirebaseFirestore
                                                              .instance
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
                                                                'Votre sortie a été validé.',
                                                            'isRead': false,
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                        'Valider',
                                                        style: TextStyle(
                                                            fontSize:
                                                                size.height *
                                                                    0.02),
                                                      )),
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.3,
                                                  child: ElevatedButton(
                                                      style: const ButtonStyle(
                                                        side: WidgetStatePropertyAll(
                                                            BorderSide(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        30,
                                                                        60,
                                                                        100))),
                                                        shape: WidgetStatePropertyAll(
                                                            RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            15)))),
                                                        foregroundColor:
                                                            WidgetStatePropertyAll(
                                                                Color.fromARGB(
                                                                    255,
                                                                    30,
                                                                    60,
                                                                    100)),
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          modifyPressed =
                                                              !modifyPressed;
                                                          pickedTime = null;
                                                          formattedTime = "";
                                                        });
                                                      },
                                                      child: Text(
                                                        modifyPressed == false
                                                            ? 'Modifier'
                                                            : 'Annuler',
                                                        style: TextStyle(
                                                            fontSize:
                                                                size.height *
                                                                    0.02),
                                                      )),
                                                )
                                              ],
                                            ),
                                            modifyPressed == false
                                                ? const SizedBox.shrink()
                                                : SizedBox(
                                                    width: size.width,
                                                    height: size.height * 0.07,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        TextButton(
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
                                                                  RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(15)))),
                                                              foregroundColor:
                                                                  WidgetStatePropertyAll(
                                                                      Color.fromARGB(
                                                                          255,
                                                                          30,
                                                                          60,
                                                                          100)),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              pickedTime =
                                                                  await _selectTime(
                                                                      context);
                                                              setState(() {
                                                                formattedTime =
                                                                    _formatTimeOfDay(
                                                                        pickedTime!);
                                                              });
                                                            },
                                                            child: Text(
                                                              formattedTime
                                                                      .isEmpty
                                                                  ? data['time']
                                                                  : formattedTime,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      size.height *
                                                                          0.02),
                                                            )),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.05),
                                                        formattedTime.isNotEmpty
                                                            ? IconButton(
                                                                style: const ButtonStyle(
                                                                    foregroundColor:
                                                                        WidgetStatePropertyAll(Colors
                                                                            .white),
                                                                    backgroundColor:
                                                                        WidgetStatePropertyAll(Colors
                                                                            .green)),
                                                                onPressed:
                                                                    () async {
                                                                  final Map<
                                                                          String,
                                                                          dynamic>
                                                                      doc =
                                                                      await getAtt(
                                                                          data[
                                                                              'attendanceId']);
                                                                  final String
                                                                      id =
                                                                      generateId();
                                                                  switch (data[
                                                                      'type']) {
                                                                    case ('entréMatin'):
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Notification')
                                                                          .doc(data[
                                                                              'id'])
                                                                          .update({
                                                                        'validé':
                                                                            true,
                                                                        'isRead':
                                                                            true
                                                                      });
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Attendance')
                                                                          .doc(data[
                                                                              'attendanceId'])
                                                                          .update({
                                                                        'entréMatin':
                                                                            formattedTime,
                                                                        'sent':
                                                                            false
                                                                      });
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'UserNotification')
                                                                          .doc(
                                                                              id)
                                                                          .set({
                                                                        'id':
                                                                            id,
                                                                        'userID':
                                                                            data['userID'],
                                                                        'timestamp':
                                                                            DateTime.now(),
                                                                        'date':
                                                                            today,
                                                                        'content':
                                                                            'Votre pointage a été modifé : "$formattedTime".',
                                                                        'isRead':
                                                                            false,
                                                                      });
                                                                    case ('sortieMatin'):
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Attendance')
                                                                          .doc(data[
                                                                              'attendanceId'])
                                                                          .update({
                                                                        'shiftMatin': calculateDuration(
                                                                            doc['entréMatin'],
                                                                            formattedTime),
                                                                        'sortieMatin':
                                                                            formattedTime,
                                                                        'sent':
                                                                            false,
                                                                        'tardinessMatin': calculateTardiness(calculateDuration(
                                                                            doc['entréMatin'],
                                                                            formattedTime))
                                                                      });
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Notification')
                                                                          .doc(data[
                                                                              'id'])
                                                                          .update({
                                                                        'validé':
                                                                            true,
                                                                        'isRead':
                                                                            true
                                                                      });
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'UserNotification')
                                                                          .doc(
                                                                              id)
                                                                          .set({
                                                                        'id':
                                                                            id,
                                                                        'userID':
                                                                            data['userID'],
                                                                        'timestamp':
                                                                            DateTime.now(),
                                                                        'date':
                                                                            today,
                                                                        'content':
                                                                            'Votre pointage a été modifé : "$formattedTime".',
                                                                        'isRead':
                                                                            false,
                                                                      });
                                                                    case ('entréAM'):
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Notification')
                                                                          .doc(data[
                                                                              'id'])
                                                                          .update({
                                                                        'validé':
                                                                            true,
                                                                        'isRead':
                                                                            true
                                                                      });
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Attendance')
                                                                          .doc(data[
                                                                              'attendanceId'])
                                                                          .update({
                                                                        'entréAM':
                                                                            formattedTime,
                                                                        'sent':
                                                                            false
                                                                      });
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'UserNotification')
                                                                          .doc(
                                                                              id)
                                                                          .set({
                                                                        'id':
                                                                            id,
                                                                        'userID':
                                                                            data['userID'],
                                                                        'timestamp':
                                                                            DateTime.now(),
                                                                        'date':
                                                                            today,
                                                                        'content':
                                                                            'Votre pointage a été modifé : "$formattedTime".',
                                                                        'isRead':
                                                                            false,
                                                                      });
                                                                    case ('sortieAM'):
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Notification')
                                                                          .doc(data[
                                                                              'id'])
                                                                          .update({
                                                                        'validé':
                                                                            true,
                                                                        'isRead':
                                                                            true
                                                                      });
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'UserNotification')
                                                                          .doc(
                                                                              id)
                                                                          .set({
                                                                        'id':
                                                                            id,
                                                                        'userID':
                                                                            data['userID'],
                                                                        'timestamp':
                                                                            DateTime.now(),
                                                                        'date':
                                                                            today,
                                                                        'content':
                                                                            'Votre pointage a été modifé : "$formattedTime".',
                                                                        'isRead':
                                                                            false,
                                                                      });
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Attendance')
                                                                          .doc(data[
                                                                              'attendanceId'])
                                                                          .update({
                                                                        'retard': calculateDailyTardiness(sumDurations(
                                                                            doc[
                                                                                'shiftMatin'],
                                                                            calculateDuration(doc['entréAM'],
                                                                                formattedTime))),
                                                                        'prod': sumDurations(
                                                                            doc[
                                                                                'shiftMatin'],
                                                                            calculateDuration(doc['entréAM'],
                                                                                formattedTime)),
                                                                        'shiftAM': calculateDuration(
                                                                            doc['entréAM'],
                                                                            formattedTime),
                                                                        'sortieAM':
                                                                            formattedTime,
                                                                        'sent':
                                                                            false,
                                                                        'tardinessAM': calculateTardiness(calculateDuration(
                                                                            doc['entréAM'],
                                                                            formattedTime))
                                                                      });
                                                                  }
                                                                },
                                                                icon: const Icon(
                                                                    Icons
                                                                        .check))
                                                            : const SizedBox
                                                                .shrink(),
                                                      ],
                                                    ),
                                                  )
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
                                      height: size.height * 0.4,
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
                                                Text(data['type'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                Text(data['user'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                SizedBox(
                                                  height: size.height * 0.01,
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
                                                  height: size.height * 0.01,
                                                ),
                                                Text(data['reason'],
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                        fontSize: size.width *
                                                            0.035)),
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
                                                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              15)))),
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
                                                                        'LeaveRequest')
                                                                    .doc(data[
                                                                        'leaveId'])
                                                                    .update({
                                                                  'status':
                                                                      'approved'
                                                                });
                                                                if (userdata![
                                                                        'resteConge'] >=
                                                                    data[
                                                                        'days']) {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'User')
                                                                      .doc(data[
                                                                          'userID'])
                                                                      .update({
                                                                    'Congé pris':
                                                                        userdata['Congé pris'] +
                                                                            data['days'],
                                                                    'resteConge':
                                                                        userdata['resteConge'] -
                                                                            data['days']
                                                                  });
                                                                } else {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'User')
                                                                      .doc(data[
                                                                          'userID'])
                                                                      .update({
                                                                    'Congé pris':
                                                                        userdata['Congé pris'] +
                                                                            data['days'],
                                                                    'Reste congé':
                                                                        0,
                                                                    'Solde congé année prec': userdata[
                                                                            'Solde congé année prec'] -
                                                                        (data['days'] -
                                                                            userdata['Reste congé'])
                                                                  });
                                                                }

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
                                                                  RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(15)))),
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
                                                                      'LeaveRequest')
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
                                      height: size.height * 0.45,
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
                                                                      0.05)),
                                                      SizedBox(
                                                        height:
                                                            size.height * 0.01,
                                                      ),
                                                      Text(data['reason'],
                                                          maxLines: 3,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  size.width *
                                                                      0.035)),
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
                                                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              15)))),
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
                                                                        8) as double;
                                                                if (b - b.truncate() <
                                                                    0.5) {
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
                                                                  'resteConge': userdata[
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
                                                                  RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(15)))),
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

  String sumDurations(String duration1, String duration2) {
    List<String> parts1 = duration1.split(' ');
    int hours1 = int.parse(parts1[0].replaceAll('H', ''));
    int minutes1 = int.parse(parts1[1].replaceAll('m', ''));
    List<String> parts2 = duration2.split(' ');
    int hours2 = int.parse(parts2[0].replaceAll('H', ''));
    int minutes2 = int.parse(parts2[1].replaceAll('m', ''));
    int totalMinutes = (hours1 * 60 + minutes1) + (hours2 * 60 + minutes2);
    int totalHours = totalMinutes ~/ 60;
    int remainingMinutes = totalMinutes % 60;
    return '${totalHours}H ${remainingMinutes}m';
  }

  String calculateTardiness(String duration) {
    final regExp = RegExp(r'(\d+)H (\d+)m');
    final match = regExp.firstMatch(duration);

    if (match == null) {
      return 'Invalid format';
    }

    int hours = int.parse(match.group(1)!);
    int minutes = int.parse(match.group(2)!);
    int totalMinutesGiven = hours * 60 + minutes;
    int totalMinutesShift = 4 * 60;
    int differenceInMinutes = totalMinutesShift - totalMinutesGiven;
    if (differenceInMinutes <= 0) {
      return '0H 0m';
    }
    int tardyHours = differenceInMinutes ~/ 60;
    int tardyMinutes = differenceInMinutes % 60;

    return '${tardyHours}H ${tardyMinutes}m';
  }

  String calculateDailyTardiness(String recordedDuration) {
    List<String> parts = recordedDuration.split(' ');
    int recordedHours = int.parse(parts[0].replaceAll('H', ''));
    int recordedMinutes = int.parse(parts[1].replaceAll('m', ''));
    int recordedTotalMinutes = (recordedHours * 60) + recordedMinutes;
    int normalWorkDurationMinutes = 8 * 60;
    int tardinessMinutes = normalWorkDurationMinutes - recordedTotalMinutes;
    int tardinessHours = tardinessMinutes ~/ 60;
    int tardinessRemainingMinutes = tardinessMinutes % 60;
    return '${tardinessHours}H ${tardinessRemainingMinutes}m';
  }
}
