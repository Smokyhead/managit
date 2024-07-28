// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:managit/models/user_model.dart';

class PermissionRequest extends StatefulWidget {
  const PermissionRequest({super.key});

  @override
  State<StatefulWidget> createState() => _PermissionRequestState();
}

class _PermissionRequestState extends State<PermissionRequest> {
  final reasonController = TextEditingController();
  final dateContr = TextEditingController();
  final startTimeContr = TextEditingController();
  final endTimeContr = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String formattedDate = "";
  String formattedStartTime = "";
  String formattedEndTime = "";
  final User? _user = FirebaseAuth.instance.currentUser;
  // ignore: unused_field
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

  void savePermissionData({
    required String userId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String reason,
  }) {
    final String notificationId = generateId();
    final String authId = generateId();
    FirebaseFirestore.instance.collection('Autorisation').doc(authId).set({
      'id': authId,
      'userId': userId,
      'date': date,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'reason': reason,
      'status': 'pending',
      'requestDate': Timestamp.now(),
    });
    FirebaseFirestore.instance
        .collection('Notification')
        .doc(notificationId)
        .set({
      'id': notificationId,
      'authId': authId,
      'userID': _user!.uid,
      'timestamp': DateTime.now(),
      'content':
          '${_userData.nom} ${_userData.prenom} souhaite prendre une autorisation.\nTapez pour voir les détails.',
      'isRead': false,
      'validé': false,
      'typeNot': 'authRequest'
    });
  }

  void onSubmitPermissionRequest() {
    DateTime date = _selectedDate!;
    TimeOfDay startTime = _selectedStartTime!;
    TimeOfDay endTime = _selectedEndTime!;
    String reason = reasonController.text;
    String userId = _user!.uid;
    savePermissionData(
      userId: userId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      reason: reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Demande d'autorisation"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: const Color.fromARGB(255, 30, 60, 100),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Date de l'autorisation",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                side: WidgetStateProperty.all(
                                  const BorderSide(
                                    style: BorderStyle.solid,
                                    color: Color.fromARGB(255, 30, 60, 100),
                                  ),
                                ),
                                elevation: WidgetStateProperty.all(6),
                                backgroundColor: WidgetStateProperty.all(
                                  const Color.fromARGB(255, 224, 227, 241),
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  const Color.fromARGB(255, 30, 60, 100),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                _selectedDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  initialDate: _selectedDate ?? DateTime.now(),
                                  currentDate: _selectedDate,
                                );
                                setState(() {
                                  if (_selectedDate != null) {
                                    formattedDate = DateFormat('dd-MM-yyyy')
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
                                    fontWeight: FontWeight.w500, fontSize: 18),
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
                          )
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Text(
                        "Heure de début",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                side: WidgetStateProperty.all(
                                  const BorderSide(
                                    style: BorderStyle.solid,
                                    color: Color.fromARGB(255, 30, 60, 100),
                                  ),
                                ),
                                elevation: WidgetStateProperty.all(6),
                                backgroundColor: WidgetStateProperty.all(
                                  const Color.fromARGB(255, 224, 227, 241),
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  const Color.fromARGB(255, 30, 60, 100),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                _selectedStartTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                setState(() {
                                  if (_selectedStartTime != null) {
                                    formattedStartTime =
                                        _selectedStartTime!.format(context);
                                    startTimeContr.text = formattedStartTime;
                                  }
                                });
                              },
                              child: Text(
                                formattedStartTime.isEmpty
                                    ? "HH:MM"
                                    : formattedStartTime,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                formattedStartTime = "";
                                _selectedStartTime = null;
                              });
                            },
                            icon: const Icon(
                              IconlyBold.delete,
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Text(
                        "Heure de fin",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                side: WidgetStateProperty.all(
                                  const BorderSide(
                                    style: BorderStyle.solid,
                                    color: Color.fromARGB(255, 30, 60, 100),
                                  ),
                                ),
                                elevation: WidgetStateProperty.all(6),
                                backgroundColor: WidgetStateProperty.all(
                                  const Color.fromARGB(255, 224, 227, 241),
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  const Color.fromARGB(255, 30, 60, 100),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                if (_selectedStartTime == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Veuillez d'abord sélectionner l'heure de début."),
                                    ),
                                  );
                                  return;
                                }

                                final TimeOfDay? pickedEndTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: _selectedStartTime!,
                                );

                                if (pickedEndTime != null) {
                                  final int startInMinutes =
                                      _selectedStartTime!.hour * 60 +
                                          _selectedStartTime!.minute;
                                  final int endInMinutes =
                                      pickedEndTime.hour * 60 +
                                          pickedEndTime.minute;
                                  if (endInMinutes - startInMinutes <= 240) {
                                    setState(() {
                                      _selectedEndTime = pickedEndTime;
                                      formattedEndTime =
                                          _selectedEndTime!.format(context);
                                      endTimeContr.text = formattedEndTime;
                                    });
                                  } else {
                                    setState(() {
                                      _selectedEndTime = null;
                                      formattedEndTime = '';
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "La durée maximale est de 4 heures."),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                formattedEndTime.isEmpty
                                    ? "HH:MM"
                                    : formattedEndTime,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                formattedEndTime = "";
                                _selectedEndTime = null;
                              });
                            },
                            icon: const Icon(
                              IconlyBold.delete,
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Text(
                        "Raison",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: size.height * 0.01),
                      TextField(
                        controller: reasonController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Tapez ici votre raison',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.2,
                                vertical: size.height * 0.02),
                            backgroundColor:
                                const Color.fromARGB(255, 30, 60, 100),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            if (_selectedStartTime == null ||
                                _selectedEndTime == null ||
                                reasonController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Veuillez entrer les informations de la demande."),
                                ),
                              );
                            } else {
                              onSubmitPermissionRequest();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Demande d'autorisation soumise avec succès"),
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
                    ]))));
  }
}
