import 'package:flutter/material.dart';

class GlobalPermissionOverview extends StatefulWidget {
  const GlobalPermissionOverview({super.key});

  @override
  State<StatefulWidget> createState() => _GlobalPermissionOverviewState();
}

class _GlobalPermissionOverviewState extends State<GlobalPermissionOverview> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Global Permission Overview'),
      ),
    );
  }
}
