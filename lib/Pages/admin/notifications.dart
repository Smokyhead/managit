import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<StatefulWidget> createState() => NotificationsState();
}

class NotificationsState extends State<Notifications> {
  // bool _iconSelected = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: size.width * 0.0475),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.select_all))
        ],
      ),
      body: const Center(
        child: Text('Notifications'),
      ),
    );
  }
}
