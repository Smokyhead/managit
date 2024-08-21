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
  String formattedDate = "";
  final User? _user = FirebaseAuth.instance.currentUser;
  late UserData _userData;
  int nhours = 0;
  String? selectedStartTime;
  String? selectedEndTime;

  final List<String> hours = [
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00"
  ];

  List<String> getEndTimeOptions(String startTime) {
    final startIndex = hours.indexOf(startTime);
    final possibleEndTimes = hours.sublist(startIndex + 1).where((time) {
      final difference = hours.indexOf(time) - startIndex;
      return difference >= 1 && difference <= 4;
    }).toList();

    // Add 18:00 only if the start time is 14:00, 15:00, 16:00, or 17:00
    if (['14:00', '15:00', '16:00', '17:00'].contains(startTime)) {
      if (!possibleEndTimes.contains('18:00')) {
        possibleEndTimes.add('18:00');
      }
    }

    return possibleEndTimes;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
    required String date,
    required String startTime,
    required String endTime,
    required String reason,
  }) {
    final String notificationId = generateId();
    final String autId = generateId();
    FirebaseFirestore.instance.collection('Autorisation').doc(autId).set({
      'id': autId,
      'userId': userId,
      'date': formattedDate,
      'startTime': selectedStartTime,
      'endTime': selectedEndTime,
      'hours': calculateHoursDifference(selectedStartTime!, selectedEndTime!),
      'reason': reason,
      'status': 'pending',
      'requestDate': DateTime.now(),
      'year': DateTime.now().year
    });
    FirebaseFirestore.instance
        .collection('Notification')
        .doc(notificationId)
        .set({
      'id': notificationId,
      'autId': autId,
      'userID': _user!.uid,
      'user': "${_userData.nom} ${_userData.prenom}",
      'timestamp': DateTime.now(),
      'content':
          '${_userData.nom} ${_userData.prenom} souhaite prendre une autorisation.\nTapez pour voir les détails.',
      'reason': reasonController.text,
      'date': formattedDate,
      'startTime': selectedStartTime,
      'endTime': selectedEndTime,
      'hours': calculateHoursDifference(selectedStartTime!, selectedEndTime!),
      'isRead': false,
      'validé': false,
      'typeNot': 'autRequest',
      'status': 'pending'
    });
  }

  void onSubmitPermissionRequest() {
    if (_selectedDate != null) {
      if (_selectedDate!.weekday == DateTime.saturday ||
          _selectedDate!.weekday == DateTime.sunday) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Les autorisations ne peuvent pas être demandées pour le week-end"),
          ),
        );
        return;
      }
    }

    String date = formattedDate;
    String startTime = selectedStartTime!;
    String endTime = selectedEndTime!;
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

  int calculateHoursDifference(String startTime, String endTime) {
    // Parse the start time and end time
    TimeOfDay start = TimeOfDay(
      hour: int.parse(startTime.split(':')[0]),
      minute: int.parse(startTime.split(':')[1]),
    );

    TimeOfDay end = TimeOfDay(
      hour: int.parse(endTime.split(':')[0]),
      minute: int.parse(endTime.split(':')[1]),
    );

    // Calculate the difference in hours
    int startInMinutes = start.hour * 60 + start.minute;
    int endInMinutes = end.hour * 60 + end.minute;

    int differenceInMinutes = endInMinutes - startInMinutes;
    int differenceInHours = (differenceInMinutes / 60).floor();

    return differenceInHours;
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
                                    formattedDate = DateFormat('dd/MM/yyyy')
                                        .format(_selectedDate!);
                                    dateContr.text = formattedDate;
                                  }
                                });
                              },
                              child: Text(
                                formattedDate.isEmpty
                                    ? "jj / mm / aaaa"
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
                            child: DropdownButtonFormField<String>(
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
                                fillColor:
                                    const Color.fromARGB(255, 224, 227, 241),
                              ),
                              value: selectedStartTime,
                              items: hours
                                  .map(
                                    (time) => DropdownMenuItem(
                                      value: time,
                                      child: Text(time),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedStartTime = value;
                                  selectedEndTime = null; // Reset end time
                                });
                              },
                              hint: const Text("Sélectionner"),
                              icon: const Icon(IconlyLight.time_circle,
                                  color: Color.fromARGB(255, 30, 60, 100)),
                            ),
                          ),
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
                            child: DropdownButtonFormField<String>(
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
                                fillColor:
                                    const Color.fromARGB(255, 224, 227, 241),
                              ),
                              value: selectedEndTime,
                              items: selectedStartTime != null
                                  ? getEndTimeOptions(selectedStartTime!)
                                      .map(
                                        (time) => DropdownMenuItem(
                                          value: time,
                                          child: Text(time),
                                        ),
                                      )
                                      .toList()
                                  : [],
                              onChanged: (value) {
                                setState(() {
                                  selectedEndTime = value;
                                });
                              },
                              hint: const Text("Sélectionner"),
                              icon: const Icon(IconlyLight.time_circle,
                                  color: Color.fromARGB(255, 30, 60, 100)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.05),
                      const Text(
                        "Raison",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
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
                      SizedBox(height: size.height * 0.1),
                      Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              const Color.fromARGB(255, 30, 60, 100),
                            ),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.white),
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(
                                horizontal: size.width * 0.2,
                                vertical: size.height * 0.02,
                              ),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (formattedDate.isEmpty ||
                                selectedStartTime!.isEmpty ||
                                selectedEndTime!.isEmpty ||
                                reasonController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Veuillez remplir tous les champs.'),
                                ),
                              );
                            } else {
                              if (isHoliday(_selectedDate!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Les autorisations ne peuvent pas être demandées pour les jours feriés.'),
                                  ),
                                );
                              } else {
                                if (_userData.resteConge - (nhours / 8) <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Solde insuffisant.'),
                                    ),
                                  );
                                } else {
                                  onSubmitPermissionRequest();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Demande d'autorisation soumise avec succès."),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }
                              }
                            }
                          },
                          child: const Text(
                            "Soumettre",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ]))));
  }
}
