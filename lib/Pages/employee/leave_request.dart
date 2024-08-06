// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:managit/models/user_model.dart';

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
  final _formKey = GlobalKey<FormState>();
  final dateContr = TextEditingController();
  final dateContr1 = TextEditingController();
  final dateContr2 = TextEditingController();
  final reasonController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedDate1;
  DateTime? _selectedDate2;
  String formattedDate = "";
  String formattedDate1 = "";
  String formattedDate2 = "";
  LeaveDuration _leaveDuration = LeaveDuration.prolonge;
  LeaveType? _selectedLeaveType = LeaveType.congeAnnuel;
  final User? _user = FirebaseAuth.instance.currentUser;
  late UserData _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<UserData> getCurrentUserData() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('User')
            .doc(_user!.uid)
            .get();

    if (!snapshot.exists) {
      throw Exception('User data not found in Firestore.');
    }

    final UserData userData = UserData();
    userData.fromMap(snapshot.data() as Map<String, dynamic>);
    return userData;
  }

  Future<void> _fetchUserData() async {
    final userData = await getCurrentUserData();
    setState(() {
      _userData = userData;
    });
  }

  String generateId() {
    final random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const length = 20;

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  int numberOfDays(String date1, String date2) {
    final format = DateFormat('dd-MM-yyyy');
    final DateTime dateTime1 = format.parse(date1);
    final DateTime dateTime2 = format.parse(date2);
    return dateTime2.difference(dateTime1).inDays;
  }

  List<Map<String, int>> tunisianHolidays = [
    {'month': 1, 'day': 1}, // New Year's Day
    {'month': 3, 'day': 20}, // Independence Day
    {'month': 4, 'day': 9}, // Martyrs' Day
    {'month': 5, 'day': 1}, // Labour Day
    {'month': 7, 'day': 25}, // Republic Day
    {'month': 10, 'day': 15}, // Evacuation Day
  ];

  bool isHoliday(DateTime date) {
    return tunisianHolidays.any((holiday) =>
        holiday['day'] == date.day && holiday['month'] == date.month);
  }

  bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  int calculateBusinessDays(DateTime startDate, DateTime endDate) {
    int days = 0;
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      if (!isWeekend(currentDate) && !isHoliday(currentDate)) {
        days++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return days;
  }

  Future<void> saveLeaveDataOneDay({
    required String userId,
    required String leaveType,
    required DateTime date,
  }) async {
    try {
      final String notificationId = generateId();
      final String leaveId = generateId();
      FirebaseFirestore.instance
          .collection('Notification')
          .doc(notificationId)
          .set({
        'id': notificationId,
        'leaveId': leaveId,
        'userID': _user!.uid,
        'timestamp': DateTime.now(),
        'content':
            '${_userData.nom} ${_userData.prenom} souhaite prendre un congé.\nTapez pour voir les détails.',
        'user': '${_userData.nom} ${_userData.prenom}',
        'date': formattedDate,
        'days': 1,
        'reason': reasonController.text,
        'isRead': false,
        'validé': false,
        'typeNot': 'leaveRequest',
        'status': 'pending'
      });
      FirebaseFirestore.instance.collection('LeaveRequests').doc(leaveId).set({
        'id': leaveId,
        'userId': userId,
        'leaveType': leaveType,
        'date': formattedDate,
        'days': 1,
        'status': 'pending', // Initial status can be pending
        'requestDate': Timestamp.now(), // Date of the request
        'reason': reasonController.text
      });

      print('Leave request saved successfully.');
    } catch (e) {
      print('Error saving leave request: $e');
    }
  }

  void onSubmitLeaveRequestOneDay() {
    String leaveType = _selectedLeaveType!.displayName;
    DateTime date = _selectedDate!;
    String userId = _user!.uid;
    saveLeaveDataOneDay(
      userId: userId,
      leaveType: leaveType,
      date: date,
    );
  }

  Future<void> saveLeaveData({
    required String userId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final String notificationId = generateId();
      final String leaveId = generateId();
      FirebaseFirestore.instance
          .collection('Notification')
          .doc(notificationId)
          .set({
        'id': notificationId,
        'leaveId': leaveId,
        'userID': _user!.uid,
        'timestamp': DateTime.now(),
        'content':
            '${_userData.nom} ${_userData.prenom} souhaite prendre un congé.\nTapez pour voir les détails.',
        'user': '${_userData.nom} ${_userData.prenom}',
        'startDate': formattedDate1,
        'endDate': formattedDate2,
        'days': calculateBusinessDays(_selectedDate1!, _selectedDate2!),
        'reason': reasonController.text,
        'isRead': false,
        'validé': false,
        'typeNot': 'leaveRequest',
        'status': 'pending'
      });
      FirebaseFirestore.instance.collection('LeaveRequests').doc(leaveId).set({
        'id': leaveId,
        'userId': userId,
        'leaveType': leaveType,
        'startDate': formattedDate1,
        'endDate': formattedDate2,
        'days': calculateBusinessDays(_selectedDate1!, _selectedDate2!),
        'reason': reasonController.text,
        'status': 'pending', // Initial status can be pending
        'requestDate': Timestamp.now(), // Date of the request
      });

      print('Leave request saved successfully.');
    } catch (e) {
      print('Error saving leave request: $e');
    }
  }

  void onSubmitLeaveRequest() {
    String leaveType = _selectedLeaveType!.displayName;
    DateTime startDate = _selectedDate1!;
    DateTime endDate = _selectedDate2!;
    String userId = _user!.uid;
    saveLeaveData(
        userId: userId,
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de congé'),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: const Color.fromARGB(255, 30, 60, 100),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Type de congé",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: size.height * 0.01),
                ListTile(
                  title: const Text('Prolongé'),
                  leading: Radio<LeaveDuration>(
                    value: LeaveDuration.prolonge,
                    groupValue: _leaveDuration,
                    onChanged: (LeaveDuration? value) {
                      setState(() {
                        _leaveDuration = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Un jour'),
                  leading: Radio<LeaveDuration>(
                    value: LeaveDuration.journee,
                    groupValue: _leaveDuration,
                    onChanged: (LeaveDuration? value) {
                      setState(() {
                        _leaveDuration = value!;
                      });
                    },
                  ),
                ),
                SizedBox(height: size.width * 0.025),
                Container(
                  padding: EdgeInsetsDirectional.only(
                      top: size.height * 0.025,
                      bottom: size.height * 0.025,
                      start: size.width * 0.04,
                      end: size.width * 0.01),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 224, 227, 241),
                  ),
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
                                              color: Color.fromARGB(
                                                  255, 30, 60, 100))),
                                      elevation: WidgetStateProperty.all(6),
                                      backgroundColor: WidgetStateProperty.all(
                                          const Color.fromARGB(
                                              255, 224, 227, 241)),
                                      foregroundColor: WidgetStateProperty.all(
                                          const Color.fromARGB(
                                              255, 30, 60, 100)),
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
                                        if (_selectedDate != null) {
                                          formattedDate =
                                              DateFormat('dd-MM-yyyy')
                                                  .format(_selectedDate!);
                                          dateContr.text = formattedDate;
                                        }
                                      });
                                    },
                                    child: Text(
                                      formattedDate.isEmpty
                                          ? "jj - mm - aaaa"
                                          : formattedDate,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18),
                                    ),
                                  ),
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
                                  ),
                                ),
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
                                                  color: Color.fromARGB(
                                                      255, 30, 60, 100))),
                                          elevation: WidgetStateProperty.all(6),
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 224, 227, 241)),
                                          foregroundColor:
                                              WidgetStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 30, 60, 100)),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                        ),
                                        onPressed: () async {
                                          _selectedDate1 = await showDatePicker(
                                            context: context,
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2100),
                                            initialDate: _selectedDate1 ??
                                                DateTime.now(),
                                            currentDate: _selectedDate1,
                                          );
                                          setState(() {
                                            if (_selectedDate1 != null) {
                                              formattedDate1 =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(_selectedDate1!);
                                              dateContr1.text = formattedDate1;
                                            }
                                          });
                                        },
                                        child: Text(
                                          formattedDate1.isEmpty
                                              ? "jj - mm - aaaa"
                                              : formattedDate1,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18),
                                        ),
                                      ),
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
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: size.width * 0.05),
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
                                                  color: Color.fromARGB(
                                                      255, 30, 60, 100))),
                                          elevation: WidgetStateProperty.all(6),
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 224, 227, 241)),
                                          foregroundColor:
                                              WidgetStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 30, 60, 100)),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                        ),
                                        onPressed: () async {
                                          _selectedDate2 = await showDatePicker(
                                            context: context,
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2100),
                                            initialDate: _selectedDate2 ??
                                                DateTime.now(),
                                            currentDate: _selectedDate2,
                                          );
                                          setState(() {
                                            if (_selectedDate2 != null) {
                                              formattedDate2 =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(_selectedDate2!);
                                              dateContr2.text = formattedDate2;
                                              calculateBusinessDays(
                                                  _selectedDate1!,
                                                  _selectedDate2!);
                                            }
                                          });
                                        },
                                        child: Text(
                                          formattedDate2.isEmpty
                                              ? "jj - mm - aaaa"
                                              : formattedDate2,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18),
                                        ),
                                      ),
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
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (formattedDate1.isNotEmpty &&
                                formattedDate2.isNotEmpty)
                              Padding(
                                padding:
                                    EdgeInsets.only(top: size.width * 0.07),
                                child: Text(
                                  "Nombre de jours : ${calculateBusinessDays(_selectedDate1!, _selectedDate2!)}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                          ],
                        ),
                ),
                SizedBox(height: size.height * 0.02),
                const Text(
                  "Nature de congé",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: size.height * 0.01),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: const Color.fromARGB(255, 30, 60, 100)),
                      color: const Color.fromARGB(255, 224, 227, 241)),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  width: size.width * 0.9,
                  child: DropdownButtonFormField<LeaveType>(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    isExpanded: true,
                    value: _selectedLeaveType,
                    onChanged: (LeaveType? newValue) {
                      setState(() {
                        _selectedLeaveType = newValue;
                      });
                    },
                    items: LeaveType.values.map((LeaveType leaveType) {
                      return DropdownMenuItem<LeaveType>(
                        value: leaveType,
                        child: Text(leaveType.displayName),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                const Text(
                  "Raison",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: size.height * 0.01),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: reasonController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 30, 60, 100),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 30, 60, 100),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 224, 227, 241),
                    hintText: "Écrivez la raison ici...",
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.2,
                          vertical: size.height * 0.02),
                      backgroundColor: const Color.fromARGB(255, 30, 60, 100),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_leaveDuration == LeaveDuration.journee &&
                            dateContr.text.isNotEmpty) {
                          if (isHoliday(_selectedDate!) ||
                              isWeekend(_selectedDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Le congé ne peut pas être au cours d\'un weekend ou un jour ferié'),
                              ),
                            );
                          } else {
                            if ((_userData.soldeAnneePrec +
                                        _userData.soldeConge) -
                                    1 >=
                                0) {
                              onSubmitLeaveRequestOneDay();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Demande de congé soumise avec succès'),
                                ),
                              );
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Solde insuffisant'),
                                ),
                              );
                            }
                          }
                        }

                        if (_leaveDuration == LeaveDuration.prolonge &&
                            dateContr1.text.isNotEmpty &&
                            dateContr2.text.isNotEmpty) {
                          if ((_userData.soldeAnneePrec +
                                      _userData.soldeConge) -
                                  calculateBusinessDays(
                                      _selectedDate1!, _selectedDate2!) >=
                              0) {
                            onSubmitLeaveRequest();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Demande de congé soumise avec succès'),
                              ),
                            );
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Solde insuffisant'),
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez séléctionner la date.'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Soumettre',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
