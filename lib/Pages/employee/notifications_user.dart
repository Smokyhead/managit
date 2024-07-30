import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsUser extends StatefulWidget {
  const NotificationsUser({super.key});

  @override
  State<StatefulWidget> createState() => NotificationsUserState();
}

class NotificationsUserState extends State<NotificationsUser> {
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('UserNotification')
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
                var data =
                    snapshots.data!.docs[index].data() as Map<String, dynamic>;
                Timestamp timestamp = data['timestamp'];
                DateTime notificationTime = timestamp.toDate();
                String timeAgo = timeago.format(notificationTime, locale: 'fr');
                bool isRead = data['isRead'] ?? false;

                if (data['isRead'] == false) {
                  Future.delayed(const Duration(seconds: 10), () {
                    setState(() {
                      data['isRead'] = true;
                    });
                    FirebaseFirestore.instance
                        .collection('UserNotification')
                        .doc(snapshots.data!.docs[index].id)
                        .update({'isRead': true});
                  });
                }
                return ListTile(
                  tileColor: !isRead
                      ? const Color.fromARGB(255, 215, 230, 245)
                      : Colors.transparent,
                  title: Padding(
                    padding: EdgeInsets.only(left: size.width * 0.035),
                    child: Text(data['content'],
                        style: TextStyle(fontSize: size.width * 0.045)),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(
                        left: size.width * 0.035, top: size.width * 0.02),
                    child: Text(timeAgo),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
