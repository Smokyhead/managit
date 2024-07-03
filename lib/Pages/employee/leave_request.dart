import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

class LeaveRequest extends StatefulWidget {
  const LeaveRequest({super.key});

  @override
  State<StatefulWidget> createState() => _LeaveRequestState();
}

enum LeaveDuration { prolonge, journee }

enum LeaveType {
  congeAnnuel,
  congeMaladie,
  congeMaternite,
  congePaternite,
  congeParental,
  congeSansSolde,
  congeMariage,
  congeDeces,
  congeEvenementFamilial
}

extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.congeAnnuel:
        return 'Congé annuel';
      case LeaveType.congeMaladie:
        return 'Congé de maladie';
      case LeaveType.congeMaternite:
        return 'Congé maternité';
      case LeaveType.congePaternite:
        return 'Congé paternité';
      case LeaveType.congeParental:
        return 'Congé parental';
      case LeaveType.congeSansSolde:
        return 'Congé sans solde';
      case LeaveType.congeMariage:
        return 'Congé de mariage';
      case LeaveType.congeDeces:
        return 'Congé de décès';
      case LeaveType.congeEvenementFamilial:
        return 'Congé pour engagement familial';
      default:
        return '';
    }
  }
}

class _LeaveRequestState extends State<LeaveRequest> {
  final reasonController = TextEditingController();
  final dateContr = TextEditingController();
  final dateContr1 = TextEditingController();
  final dateContr2 = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedDate1;
  DateTime? _selectedDate2;
  String formattedDate = "";
  String formattedDate1 = "";
  String formattedDate2 = "";
  late DateTime dateTime;
  LeaveDuration? _leaveDuration = LeaveDuration.prolonge;

  int numberOfdays(String date1, String date2) {
    final format = DateFormat('dd-MM-yyyy');
    final DateTime dateTime1 = format.parse(date1);
    final DateTime dateTime2 = format.parse(date2);
    return dateTime2.difference(dateTime1).inDays;
  }

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
                    value: LeaveDuration.prolonge,
                    groupValue: _leaveDuration,
                    onChanged: (LeaveDuration? value) {
                      setState(() {
                        _leaveDuration = value;
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
                    value: LeaveDuration.journee,
                    groupValue: _leaveDuration,
                    onChanged: (LeaveDuration? value) {
                      setState(() {
                        _leaveDuration = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: size.width * 0.025,
              ),
              Container(
                  padding: EdgeInsetsDirectional.only(
                      top: size.height * 0.025,
                      bottom: size.height * 0.025,
                      start: size.width * 0.04,
                      end: size.width * 0.01),
                  decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(255, 229, 229, 229),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: Offset.zero)
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Color.fromARGB(255, 224, 227, 241)),
                  alignment: Alignment.centerLeft,
                  child: _leaveDuration == LeaveDuration.journee
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
                            Row(
                              children: [
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: TextButton(
                                      style: ButtonStyle(
                                        side: WidgetStateProperty.all(
                                            const BorderSide(
                                                style: BorderStyle.solid,
                                                color: Colors.indigo)),
                                        elevation: WidgetStateProperty.all(6),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                const Color.fromARGB(
                                                    255, 224, 227, 241)),
                                        foregroundColor:
                                            WidgetStateProperty.all(
                                                Colors.indigo),
                                        shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                        ),
                                      ),
                                      onPressed: () async {
                                        _selectedDate = await showDatePicker(
                                          context: context,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                          initialDate:
                                              _selectedDate ?? DateTime.now(),
                                          currentDate: _selectedDate,
                                        );
                                        setState(() {
                                          _selectedDate;
                                          formattedDate =
                                              DateFormat('dd-MM-yyyy')
                                                  .format(_selectedDate!);
                                          dateContr.text = formattedDate;
                                        });
                                      },
                                      child: Text(
                                        formattedDate.isEmpty
                                            ? "jj - mm - aaaa"
                                            : formattedDate,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18),
                                      )),
                                ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        formattedDate = "";
                                        _selectedDate = null;
                                      });
                                    },
                                    icon: const Icon(
                                      IconlyBold.delete,
                                      color: Colors.red,
                                    ))
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Date début",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.justify,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.4,
                                      child: TextButton(
                                          style: ButtonStyle(
                                            side: WidgetStateProperty.all(
                                                const BorderSide(
                                                    style: BorderStyle.solid,
                                                    color: Colors.indigo)),
                                            elevation:
                                                WidgetStateProperty.all(6),
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    const Color.fromARGB(
                                                        255, 224, 227, 241)),
                                            foregroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.indigo),
                                            shape: WidgetStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                            ),
                                          ),
                                          onPressed: () async {
                                            _selectedDate1 =
                                                await showDatePicker(
                                              context: context,
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2100),
                                              initialDate: _selectedDate1 ??
                                                  DateTime.now(),
                                              currentDate: _selectedDate1,
                                            );
                                            setState(() {
                                              _selectedDate1;
                                              formattedDate1 =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(_selectedDate1!);
                                              dateContr1.text = formattedDate1;
                                            });
                                          },
                                          child: Text(
                                            formattedDate1.isEmpty
                                                ? "jj - mm - aaaa"
                                                : formattedDate1,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18),
                                          )),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            formattedDate1 = "";
                                            _selectedDate1 = null;
                                          });
                                        },
                                        icon: const Icon(
                                          IconlyBold.delete,
                                          color: Colors.red,
                                        ))
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Date fin",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.justify,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.4,
                                      child: TextButton(
                                          style: ButtonStyle(
                                            side: WidgetStateProperty.all(
                                                const BorderSide(
                                                    style: BorderStyle.solid,
                                                    color: Colors.indigo)),
                                            elevation:
                                                WidgetStateProperty.all(6),
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    const Color.fromARGB(
                                                        255, 224, 227, 241)),
                                            foregroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.indigo),
                                            shape: WidgetStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                            ),
                                          ),
                                          onPressed: () async {
                                            _selectedDate2 =
                                                await showDatePicker(
                                              context: context,
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2100),
                                              initialDate: _selectedDate2 ??
                                                  DateTime.now(),
                                              currentDate: _selectedDate2,
                                            );
                                            setState(() {
                                              _selectedDate2;
                                              formattedDate2 =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(_selectedDate2!);
                                              dateContr2.text = formattedDate2;
                                            });
                                          },
                                          child: Text(
                                            formattedDate2.isEmpty
                                                ? "jj - mm - aaaa"
                                                : formattedDate2,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18),
                                          )),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            formattedDate2 = "";
                                            _selectedDate2 = null;
                                          });
                                        },
                                        icon: const Icon(
                                          IconlyBold.delete,
                                          color: Colors.red,
                                        ))
                                  ],
                                ),
                              ],
                            ),
                            (formattedDate1.isNotEmpty &&
                                    formattedDate2.isNotEmpty)
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: size.width * 0.07,
                                      ),
                                      Text(
                                        "Nombre de jours : ${numberOfdays(formattedDate1, formattedDate2) + 1}",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ],
                        )),
              SizedBox(height: size.height * 0.05),
              Container(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                width: size.width * 0.9,
                color: const Color.fromARGB(255, 240, 240, 240),
                child: DropdownButton<LeaveType>(
                  borderRadius: BorderRadius.circular(5),

                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  menuMaxHeight: size.height * 0.1,
                  isExpanded: true,
                  value: LeaveType.congeAnnuel, // Initial value
                  onChanged: (LeaveType? newValue) {},
                  items: LeaveType.values.map((LeaveType leaveType) {
                    return DropdownMenuItem<LeaveType>(
                      value: leaveType,
                      child: Text(leaveType.displayName),
                    );
                  }).toList(),
                ),
              ),
            ])),
      ),
    );
  }
}
