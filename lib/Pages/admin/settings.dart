import 'package:flutter/material.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<StatefulWidget> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('Settings Page'),
    ));
  }
}
