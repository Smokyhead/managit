import 'package:flutter/material.dart';

class PenaltyManagement extends StatefulWidget {
  const PenaltyManagement({super.key});

  @override
  State<StatefulWidget> createState() => _PenaltyManagementState();
}

class _PenaltyManagementState extends State<PenaltyManagement> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('Penalty Management Page')
    ));
  }
}
