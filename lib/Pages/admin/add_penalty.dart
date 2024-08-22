// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:managit/models/user_model.dart';

class AddPenalty extends StatefulWidget {
  const AddPenalty({super.key});

  @override
  State<StatefulWidget> createState() => AddPenaltyState();
}

class AddPenaltyState extends State<AddPenalty> {
  final String today = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String? month;
  int? year;
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployee;
  List<String> types = ['Heure', 'Jours'];
  String? _selectedType;
  int hours = 0;
  final dateContr = TextEditingController();
  final dateContr1 = TextEditingController();
  final dateContr2 = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedDate1;
  DateTime? _selectedDate2;
  String formattedDate = "";
  String formattedDate1 = "";
  String formattedDate2 = "";
  final reasonController = TextEditingController();

  List<Map<String, int>> tunisianHolidays = [
    {'month': 1, 'day': 1}, // New Year's Day
    {'month': 3, 'day': 20}, // Independence Day
    {'month': 4, 'day': 9}, // Martyrs' Day
    {'month': 5, 'day': 1}, // Labour Day
    {'month': 7, 'day': 25}, // Republic Day
    {'month': 10, 'day': 15}, // Evacuation Day
  ];

  int calculateDays(DateTime startDate, DateTime endDate) {
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

  bool isHoliday(DateTime date) {
    return tunisianHolidays.any((holiday) =>
        holiday['day'] == date.day && holiday['month'] == date.month);
  }

  bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  String generateId() {
    final random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const length = 20;

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 60, 100),
        foregroundColor: Colors.white,
        title: Text(
          'Ajouter une pénalité',
          style: TextStyle(fontSize: size.width * 0.0475),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('User')
                    .where('role', isEqualTo: 'employee')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final employees = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Séléctionner un employé',
                    ),
                    items: employees.map((employee) {
                      return DropdownMenuItem<String>(
                        value: employee.id,
                        child: Text('${employee['Nom']} ${employee['Prénom']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployee = value;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Veuillez séléctionner un employé'
                        : null,
                  );
                },
              ),
              SizedBox(height: size.height * 0.02),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                items: types.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Veuillez séléctionner un employé' : null,
              ),
              SizedBox(height: size.height * 0.04),
              _selectedType == null
                  ? const SizedBox.shrink()
                  : _selectedType == 'Heure'
                      ? Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Date",
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
                                          _selectedDate = await showDatePicker(
                                            context: context,
                                            firstDate: DateTime(2024),
                                            lastDate: DateTime(2100),
                                            initialDate:
                                                _selectedDate ?? DateTime.now(),
                                            currentDate: _selectedDate,
                                          );
                                          setState(() {
                                            if (_selectedDate != null) {
                                              formattedDate =
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(_selectedDate!);
                                              dateContr.text = formattedDate;
                                              year = _selectedDate!.year;
                                              switch (_selectedDate!.month) {
                                                case (1):
                                                  month = 'Janvier';
                                                case (2):
                                                  month = 'Février';
                                                case (3):
                                                  month = 'Mars';
                                                case (4):
                                                  month = 'Avril';
                                                case (5):
                                                  month = 'May';
                                                case (6):
                                                  month = 'Juin';
                                                case (7):
                                                  month = 'Juillet';
                                                case (8):
                                                  month = 'Août';
                                                case (9):
                                                  month = 'Septembre';
                                                case (10):
                                                  month = 'Octobre';
                                                case (11):
                                                  month = 'Novembre';
                                                case (12):
                                                  month = 'Decembre';
                                              }
                                            }
                                          });
                                        },
                                        child: Text(
                                          formattedDate.isEmpty
                                              ? "jj / mm / aaaa"
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
                            ),
                            SizedBox(height: size.height * 0.04),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: size.height * 0.08,
                                  width: size.height * 0.08,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hours--;
                                      });
                                    },
                                    icon: const Icon(Icons.exposure_neg_1),
                                    style: ButtonStyle(
                                        side: const WidgetStatePropertyAll(
                                            BorderSide(
                                                color: Color.fromARGB(
                                                    255, 30, 60, 100))),
                                        backgroundColor: const WidgetStatePropertyAll(
                                            Color.fromARGB(255, 215, 230, 245)),
                                        foregroundColor:
                                            const WidgetStatePropertyAll(
                                                Color.fromARGB(
                                                    255, 30, 60, 100)),
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)))),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.05),
                                Text('$hours',
                                    style: TextStyle(
                                        fontSize: size.width * 0.06,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(width: size.width * 0.05),
                                SizedBox(
                                  height: size.height * 0.08,
                                  width: size.height * 0.08,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hours++;
                                      });
                                    },
                                    icon: const Icon(Icons.plus_one),
                                    style: ButtonStyle(
                                        side: const WidgetStatePropertyAll(
                                            BorderSide(
                                                color: Color.fromARGB(
                                                    255, 30, 60, 100))),
                                        backgroundColor: const WidgetStatePropertyAll(
                                            Color.fromARGB(255, 215, 230, 245)),
                                        foregroundColor:
                                            const WidgetStatePropertyAll(
                                                Color.fromARGB(
                                                    255, 30, 60, 100)),
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)))),
                                  ),
                                )
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
                                            firstDate: DateTime(2024),
                                            lastDate: DateTime(2100),
                                            initialDate: _selectedDate1 ??
                                                DateTime.now(),
                                            currentDate: _selectedDate1,
                                          );
                                          setState(() {
                                            if (_selectedDate1 != null) {
                                              formattedDate1 =
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(_selectedDate1!);
                                              dateContr1.text = formattedDate1;
                                              year = _selectedDate1!.year;
                                              switch (_selectedDate1!.month) {
                                                case (1):
                                                  month = 'Janvier';
                                                case (2):
                                                  month = 'Février';
                                                case (3):
                                                  month = 'Mars';
                                                case (4):
                                                  month = 'Avril';
                                                case (5):
                                                  month = 'May';
                                                case (6):
                                                  month = 'Juin';
                                                case (7):
                                                  month = 'Juillet';
                                                case (8):
                                                  month = 'Août';
                                                case (9):
                                                  month = 'Septembre';
                                                case (10):
                                                  month = 'Octobre';
                                                case (11):
                                                  month = 'Novembre';
                                                case (12):
                                                  month = 'Decembre';
                                              }
                                            }
                                          });
                                        },
                                        child: Text(
                                          formattedDate1.isEmpty
                                              ? "jj / mm / aaaa"
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
                                            firstDate: DateTime(2024),
                                            lastDate: DateTime(2100),
                                            initialDate: _selectedDate2 ??
                                                DateTime.now(),
                                            currentDate: _selectedDate2,
                                          );
                                          setState(() {
                                            if (_selectedDate2 != null) {
                                              formattedDate2 =
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(_selectedDate2!);
                                              dateContr2.text = formattedDate2;
                                              calculateDays(_selectedDate1!,
                                                  _selectedDate2!);
                                            }
                                          });
                                        },
                                        child: Text(
                                          formattedDate2.isEmpty
                                              ? "jj / mm / aaaa"
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
                                  "Nombre de jours : ${calculateDays(_selectedDate1!, _selectedDate2!)}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                          ],
                        ),
              SizedBox(height: size.height * 0.04),
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
                  hintText: "Écrivez la raison ici... (Facultatif)",
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Center(
                child: Container(
                  margin: const EdgeInsetsDirectional.only(top: 5),
                  width: size.width * 0.4,
                  height: 60,
                  child: TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _handleSubmit();
                        }
                      },
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(10),
                        backgroundColor: WidgetStateProperty.all(
                            const Color.fromARGB(255, 30, 60, 100)),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      child: Text("Soumettre",
                          style: TextStyle(fontSize: size.width * 0.05))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<UserData> getCurrentUserData() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('User')
            .doc(_selectedEmployee)
            .get();

    if (!snapshot.exists) {
      throw Exception('User data not found in Firestore.');
    }

    final UserData userData = UserData();
    userData.fromMap(snapshot.data() as Map<String, dynamic>);
    return userData;
  }

  Future<void> _saveDataH() async {
    final userData = await getCurrentUserData();
    String idP = generateId();
    String idN = generateId();
    int a;
    double b = userData.sanctions + (hours / 8);
    if (b - b.truncate() < 0.5) {
      a = b.truncate();
    } else {
      a = b.ceil();
    }
    try {
      FirebaseFirestore.instance.collection('Penalties').doc(idP).set({
        'id': idP,
        'employeeId': _selectedEmployee,
        'type': 'hours',
        'date': formattedDate,
        'hours': hours,
        'reason': reasonController.text.trim(),
        'year': year,
        'month': month
      });
      FirebaseFirestore.instance.collection('UserNotification').doc(idN).set({
        'id': idN,
        'userID': _selectedEmployee,
        'timestamp': DateTime.now(),
        'date': today,
        'content':
            'Une Pénalité a été soumise le "$formattedDate" ($hours heures)',
        'isRead': false,
      });
      FirebaseFirestore.instance
          .collection('User')
          .doc(_selectedEmployee)
          .update({
        'Sanctions': userData.sanctions + (hours / 8),
        'resteConge': userData.soldeConge +
            userData.soldeAnneePrec -
            userData.congePris -
            a
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Succés'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveDataJ() async {
    final userData = await getCurrentUserData();
    String idP = generateId();
    String idN = generateId();
    try {
      FirebaseFirestore.instance.collection('Penalties').doc(idP).set({
        'id': idP,
        'employeeId': _selectedEmployee,
        'type': 'days',
        'date1': formattedDate1,
        'date2': formattedDate2,
        'reason': reasonController.text.trim(),
        'year': year,
        'month': month,
        
      });
      FirebaseFirestore.instance.collection('UserNotification').doc(idN).set({
        'id': idN,
        'userID': _selectedEmployee,
        'timestamp': DateTime.now(),
        'date': today,
        'content':
            'Une Pénalité a été soumise de "$formattedDate1" à "$formattedDate2"',
        'isRead': false,
      });
      FirebaseFirestore.instance
          .collection('User')
          .doc(_selectedEmployee)
          .update({
        'Sanctions': userData.sanctions +
            calculateDays(_selectedDate1!, _selectedDate2!),
        'resteConge': userData.soldeConge +
            userData.soldeAnneePrec -
            userData.congePris -
            calculateDays(_selectedDate1!, _selectedDate2!)
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Succés'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedEmployee != null && _selectedType != null) {
      switch (_selectedType) {
        case ('Heure'):
          if (formattedDate.isEmpty || hours == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veuillez séléctionner la date et l\'heure'),
              ),
            );
          } else {
            if (isHoliday(_selectedDate!) || isWeekend(_selectedDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Les pénalités ne peuvent pas être soumises pour le week-end ou les jours feriés.'),
                ),
              );
            } else {
              if (hours > 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le maximum des heures est 8.'),
                  ),
                );
              } else {
                _saveDataH();
              }
            }
          }
        case ('Jours'):
          if (formattedDate1.isEmpty || formattedDate2.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veuillez séléctionner les dates'),
              ),
            );
          } else {
            _saveDataJ();
          }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Veuillez séléctionner l\'employé et le type de pénalité.'),
        ),
      );
    }
  }
}
