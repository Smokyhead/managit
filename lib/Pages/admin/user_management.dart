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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.5),
        child: ListView(
          children: const [],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 220, 225, 255),
        foregroundColor: Colors.indigo,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return const AddUser();
          }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
