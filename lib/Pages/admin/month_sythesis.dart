import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:managit/models/user_model.dart';
import 'package:intl/intl.dart';

class MonthSythesis extends StatefulWidget {
  const MonthSythesis({super.key});

  @override
  State<StatefulWidget> createState() => _MonthSythesisState();
}

class _MonthSythesisState extends State<MonthSythesis> {
  late Future<List<UserTardiness>> _userTardinessList;
  String? selectedMonth;
  String? selectedYear;
  UserData? selectedUser;
  List<UserData> allUsers = [];

  final List<String> months = [
    'Janvier',
    'Fevrier',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Aout',
    'Septembre',
    'Octobre',
    'Novembre',
    'Decembre'
  ];

  final List<String> years = [
    '2024',
    '2025',
    '2026',
    '2027'
  ]; // Add more years as needed

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
    _userTardinessList = _fetchUserTardiness();
  }

  Future<void> _fetchAllUsers() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('User')
        .where('role', isEqualTo: 'employee')
        .get();

    setState(() {
      allUsers = userSnapshot.docs.map((doc) {
        UserData user = UserData();
        user.fromMap(doc.data() as Map<String, dynamic>);
        user.id = doc.id;
        return user;
      }).toList();
    });
  }

  Future<List<UserTardiness>> _fetchUserTardiness() async {
    List<UserTardiness> userTardinessList = [];

    QuerySnapshot tardinessSnapshot =
        await FirebaseFirestore.instance.collection('Tardiness').get();

    Map<String, Map<String, int>> userTardinessMap = {};

    for (var tardinessDoc in tardinessSnapshot.docs) {
      var tardinessData = tardinessDoc.data() as Map<String, dynamic>;
      String userId = tardinessData['userID'];
      DateTime date = (tardinessData['date'] as Timestamp).toDate();
      String monthYear = DateFormat('MM-yyyy').format(date);

      if (tardinessData.containsKey('tardiness') &&
          tardinessData['tardiness'] is num) {
        int minutes = (tardinessData['tardiness'] as num).toInt();

        if (!userTardinessMap.containsKey(userId)) {
          userTardinessMap[userId] = {};
        }
        if (!userTardinessMap[userId]!.containsKey(monthYear)) {
          userTardinessMap[userId]![monthYear] = 0;
        }
        userTardinessMap[userId]![monthYear] =
            (userTardinessMap[userId]![monthYear] ?? 0) + minutes;
      }
    }

    for (var user in allUsers) {
      if (userTardinessMap.containsKey(user.id)) {
        userTardinessList.add(UserTardiness(user, userTardinessMap[user.id]!));
      } else {
        userTardinessList.add(UserTardiness(user, {}));
      }
    }

    return userTardinessList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<UserData>(
                  hint: const Text('Employé'),
                  value: selectedUser,
                  onChanged: (UserData? newValue) {
                    setState(() {
                      selectedUser = newValue;
                      selectedYear = null; // Reset year when user changes
                      selectedMonth = null; // Reset month when user changes
                    });
                  },
                  items: [
                    const DropdownMenuItem<UserData>(
                      value: null,
                      child: Text('Tous'),
                    ),
                    ...allUsers.map((UserData user) {
                      return DropdownMenuItem<UserData>(
                        value: user,
                        child: Text('${user.nom} ${user.prenom}'),
                      );
                    }).toList(),
                  ],
                ),
                if (selectedUser == null)
                  DropdownButton<String>(
                    hint: const Text('Mois'),
                    value: selectedMonth,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMonth = newValue;
                      });
                    },
                    items: months.asMap().entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: (entry.key + 1).toString().padLeft(2, '0'),
                        child: Text(entry.value),
                      );
                    }).toList(),
                  )
                else
                  DropdownButton<String>(
                    hint: const Text('Année'),
                    value: selectedYear,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue;
                      });
                    },
                    items: years.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserTardiness>>(
              future: _userTardinessList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Une erreur est survenue'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Rien à afficher'));
                }

                List<UserTardiness> userTardinessList = snapshot.data!;

                if (selectedUser != null) {
                  // Show individual user's yearly tardiness
                  UserTardiness selectedUserTardiness =
                      userTardinessList.firstWhere(
                    (ut) => ut.user.id == selectedUser!.id,
                    orElse: () => UserTardiness(selectedUser!, {}),
                  );

                  List<MapEntry<String, int>> yearlyTardiness =
                      selectedUserTardiness.monthlyTardiness.entries
                          .where(
                              (entry) => entry.key.endsWith(selectedYear ?? ''))
                          .toList();

                  yearlyTardiness.sort((a, b) => a.key.compareTo(b.key));

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Mois')),
                        DataColumn(label: Text('Total de retard')),
                      ],
                      rows: months.asMap().entries.map((entry) {
                        String monthKey =
                            (entry.key + 1).toString().padLeft(2, '0') +
                                '-' +
                                (selectedYear ?? '');
                        int totalMinutes = yearlyTardiness
                            .firstWhere((element) => element.key == monthKey,
                                orElse: () => MapEntry(monthKey, 0))
                            .value;
                        Duration tardiness =
                            Duration(minutes: totalMinutes.abs());
                        String formattedTardiness =
                            '${tardiness.inHours}h ${tardiness.inMinutes.remainder(60)}m';
                        return DataRow(cells: [
                          DataCell(Text(entry.value)),
                          DataCell(Text(formattedTardiness)),
                        ]);
                      }).toList(),
                      headingRowColor: WidgetStateColor.resolveWith(
                          (states) => Colors.grey[300]!),
                      headingTextStyle:
                          const TextStyle(fontWeight: FontWeight.bold),
                      border: TableBorder.all(color: Colors.grey),
                    ),
                  );
                } else {
                  // Show all employees' tardiness for selected month
                  userTardinessList.sort((a, b) {
                    int aTardiness = a.monthlyTardiness[selectedMonth != null
                            ? '$selectedMonth-${DateTime.now().year}'
                            : ''] ??
                        0;
                    int bTardiness = b.monthlyTardiness[selectedMonth != null
                            ? '$selectedMonth-${DateTime.now().year}'
                            : ''] ??
                        0;
                    return bTardiness.compareTo(aTardiness);
                  });

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nom & Prénom')),
                        DataColumn(label: Text('Total de retard')),
                      ],
                      rows: userTardinessList.map((userTardiness) {
                        int totalMinutes = userTardiness.monthlyTardiness[
                                selectedMonth != null
                                    ? '$selectedMonth-${DateTime.now().year}'
                                    : ''] ??
                            0;
                        Duration tardiness =
                            Duration(minutes: totalMinutes.abs());
                        String formattedTardiness = tardiness.inMinutes == 0
                            ? '0h 0m'
                            : '${tardiness.inHours}h ${tardiness.inMinutes.remainder(60)}m';
                        return DataRow(cells: [
                          DataCell(Text(
                              '${userTardiness.user.nom} ${userTardiness.user.prenom}')),
                          DataCell(Text(formattedTardiness)),
                        ]);
                      }).toList(),
                      headingRowColor: WidgetStateColor.resolveWith(
                          (states) => Colors.grey[300]!),
                      headingTextStyle:
                          const TextStyle(fontWeight: FontWeight.bold),
                      border: TableBorder.all(color: Colors.grey),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserTardiness {
  final UserData user;
  final Map<String, int> monthlyTardiness;

  UserTardiness(this.user, this.monthlyTardiness);
}
