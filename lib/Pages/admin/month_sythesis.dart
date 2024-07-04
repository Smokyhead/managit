import 'package:flutter/material.dart';

class MonthSythesis extends StatefulWidget {
  const MonthSythesis({super.key});

  @override
  State<StatefulWidget> createState() => _MonthSythesisState();
}

class _MonthSythesisState extends State<MonthSythesis> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('Monthly Sythesis Page')
    ));
  }
}
