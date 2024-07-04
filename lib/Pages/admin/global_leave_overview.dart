import 'package:flutter/material.dart';

class GlobalLeaveOverview extends StatefulWidget {
  const GlobalLeaveOverview({super.key});

  @override
  State<StatefulWidget> createState() => _GlobalLeaveOverviewState();
}

class _GlobalLeaveOverviewState extends State<GlobalLeaveOverview> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Global Leave Overview Page'),
      ),
    );
  }
}
