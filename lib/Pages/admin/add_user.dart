import 'package:flutter/material.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<StatefulWidget> createState() => AddUserState();
}

class AddUserState extends State<AddUser> {
  // bool _iconSelected = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(
          'Nouveau utilisateur',
          style: TextStyle(fontSize: size.width * 0.0475),
        ),
      ),
      body: const Center(
        child: Text('add user'),
      ),
    );
  }
}
