import 'package:flutter/material.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<StatefulWidget> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('User management'),
      ),
    );
  }
}
