import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

import 'package:intl/intl.dart';

class LeaveRequest extends StatefulWidget {
  const LeaveRequest({super.key});

  @override
  State<StatefulWidget> createState() => _LeaveRequestState();
}

enum LeaveType { prolonge, journee }

class _LeaveRequestState extends State<LeaveRequest> {
  final dateContr = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String formattedDate = "";
  late DateTime dateTime;
  LeaveType? _leaveType = LeaveType.prolonge;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de congé'),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(IconlyLight.close_square), onPressed: () {}),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Type de congé",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              SizedBox(
                width: size.width * 0.5,
                child: ListTile(
                  title: const Text('Prolongé'),
                  leading: Radio(
                    value: LeaveType.prolonge,
                    groupValue: _leaveType,
                    onChanged: (LeaveType? value) {
                      setState(() {
                        _leaveType = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: size.width * 0.5,
                child: ListTile(
                  title: const Text('Un jour'),
                  leading: Radio(
                    value: LeaveType.journee,
                    groupValue: _leaveType,
                    onChanged: (LeaveType? value) {
                      setState(() {
                        _leaveType = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: size.width * 0.025,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  child: _leaveType == LeaveType.journee
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Date",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.justify,
                            ),
                            SizedBox(
                              width: size.width * 0.5,
                              child: TextButton(
                                  style: ButtonStyle(
                                    side: WidgetStateProperty.all(
                                        const BorderSide(
                                            style: BorderStyle.solid,
                                            color: Colors.indigo)),
                                    elevation: WidgetStateProperty.all(6),
                                    backgroundColor: WidgetStateProperty.all(
                                        const Color.fromARGB(
                                            255, 224, 227, 241)),
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.indigo),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                    ),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      backgroundColor: Colors.white,
                                      context: context,
                                      builder: ((builder) => bottomSheet()),
                                    );
                                  },
                                  child: Text(
                                    formattedDate.isEmpty
                                        ? "jj/mm/aaaa"
                                        : formattedDate,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  )),
                            )
                          ],
                        )
                      : const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date début",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600)),
                            Text("Date fin",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600))
                          ],
                        )),
            ])),
      ),
    );
  }

  Widget bottomSheet() => Container(
        height: 350,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: <Widget>[
            const Text(
              "Sélectionner la date du rendez-vous",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 250,
              child: ScrollDatePicker(
                options: const DatePickerOptions(isLoop: false),
                selectedDate: _selectedDate,
                minimumDate: DateTime.now(),
                maximumDate: DateTime(2100),
                locale: const Locale('fr'),
                onDateTimeChanged: (DateTime value) {
                  setState(() {
                    _selectedDate = value;
                    formattedDate =
                        DateFormat('dd-MM-yyyy').format(_selectedDate);
                    dateContr.text = formattedDate;
                  });
                },
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ButtonStyle(
                side: WidgetStateProperty.all(const BorderSide(
                    style: BorderStyle.solid, color: Colors.indigo)),
                elevation: WidgetStateProperty.all(6),
                backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 224, 227, 241)),
                foregroundColor: WidgetStateProperty.all(Colors.indigo),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              child: const Text("ok"),
            )
          ],
        ),
      );
}
