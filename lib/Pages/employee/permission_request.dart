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

  void savePermissionData({
    required String userId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String reason,
  }) {
    FirebaseFirestore.instance.collection('permissions').add({
      'userId': userId,
      'date': date,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'reason': reason,
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
    reasonController.text = 'Tapez ici votre raison';
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Demande de permission'),
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
                        "Date de la permission",
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
                                _selectedEndTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                setState(() {
                                  if (_selectedEndTime != null) {
                                    formattedEndTime =
                                        _selectedEndTime!.format(context);
                                    endTimeContr.text = formattedEndTime;
                                  }
                                });
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                            onSubmitPermissionRequest();
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
