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
  LeaveDuration? _leaveDuration = LeaveDuration.prolonge;
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

  Future<void> saveLeaveData({
    required String userId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      final String notificationId = generateId();
      final String leaveId = generateId();
      FirebaseFirestore.instance
          .collection('Notification')
          .doc(notificationId)
          .set({
        'id': notificationId,
        'attendanceId': leaveId,
        'userID': _user!.uid,
        'timestamp': DateTime.now(),
        'content':
            '${_userData.nom} ${_userData.prenom} souhaite prendre un congé\nTapez pour voir les détails',
        'isRead': false,
        'validé': false,
        'typeNot': 'leaveRequest'
      });
      FirebaseFirestore.instance.collection('LeaveRequests').doc(leaveId).set({
        'userId': userId,
        'leaveType': leaveType,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'reason': reason,
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
    String reason = reasonController.text;
    String userId = _user!.uid;
    saveLeaveData(
      userId: userId,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
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
                        _leaveDuration = value;
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
                        _leaveDuration = value;
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
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(255, 229, 229, 229),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset.zero)
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(20)),
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
                                  "Nombre de jours : ${numberOfDays(formattedDate1, formattedDate2) + 1}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                          ],
                        ),
                ),
                SizedBox(height: size.height * 0.05),
                const Text(
                  "Motif de la demande",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: size.height * 0.01),
                TextFormField(
                  controller: reasonController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Entrez le motif de votre demande de congé',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 30, 60, 100),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 30, 60, 100),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le motif de votre demande de congé';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.05),
                const Text(
                  "Type de congé",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: size.height * 0.01),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  width: size.width * 0.9,
                  color: const Color.fromARGB(255, 240, 240, 240),
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
                SizedBox(height: size.height * 0.05),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Demande de congé soumise avec succès'),
                          ),
                        );
                        onSubmitLeaveRequest();
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
