import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:managit/pages/admin/add_user.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<StatefulWidget> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 215, 230, 245),
        foregroundColor: const Color.fromARGB(255, 30, 60, 100),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return const AddUser();
          }));
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .where('role', isEqualTo: 'employee')
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
                      "Aucun utilisateur à afficher",
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
                          title: Text("${data['Nom']} ${data['Prénom']}",
                              style: TextStyle(fontSize: size.width * 0.05)),
                          trailing: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.more_vert)),
                        );
                      });
                }
              })),
    );
  }
}
