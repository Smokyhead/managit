import 'package:flutter/material.dart';

class TardinessManagement extends StatefulWidget {
  const TardinessManagement({super.key});

  @override
  State<StatefulWidget> createState() => _TardinessManagementState();
}

class _TardinessManagementState extends State<TardinessManagement> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('Tardiness Management Page')
    ));
  }
}
