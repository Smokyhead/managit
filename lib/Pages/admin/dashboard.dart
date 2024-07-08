import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String id;

  Future<void> getID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('uid')!;
  }

  @override
  void initState() {
    getID();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(id)));
  }
}
