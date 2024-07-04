import 'package:flutter/material.dart';

class AbsenceManagement extends StatefulWidget {
  const AbsenceManagement({super.key});

  @override
  State<StatefulWidget> createState() => _AbsenceManagementState();
}

class _AbsenceManagementState extends State<AbsenceManagement> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('Absence Management Page')
    ));
  }
}
