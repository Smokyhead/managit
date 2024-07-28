import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:managit/models/user_model.dart';

class MonthSythesis extends StatefulWidget {
  const MonthSythesis({super.key});

  @override
  State<StatefulWidget> createState() => _MonthSythesisState();
}

class _MonthSythesisState extends State<MonthSythesis> {
  late Future<List<UserTardiness>> _userTardinessList;

  @override
  void initState() {
    super.initState();
    _userTardinessList = _fetchUserTardiness();
  }

  Future<List<UserTardiness>> _fetchUserTardiness() async {
    List<UserTardiness> userTardinessList = [];

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('User')
        .where('role', isEqualTo: 'employee')
        .get();

    for (var userDoc in userSnapshot.docs) {
      UserData user = UserData();
      user.fromMap(userDoc.data() as Map<String, dynamic>);

      QuerySnapshot tardinessSnapshot = await FirebaseFirestore.instance
          .collection('Tardiness')
          .where('userID', isEqualTo: userDoc.id)
          .get();

      int totalMinutes = 0;
      for (var tardinessDoc in tardinessSnapshot.docs) {
        var tardinessData = tardinessDoc.data() as Map<String, dynamic>;
        if (tardinessData.containsKey('tardiness') &&
            tardinessData['tardiness'] is num) {
          totalMinutes += (tardinessData['tardiness'] as num).toInt();
        }
      }

      // Add all users, even those with zero tardiness
      userTardinessList
          .add(UserTardiness(user, Duration(minutes: totalMinutes.abs())));
    }

    return userTardinessList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<UserTardiness>>(
        future: _userTardinessList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching data: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No user data available'));
          }

          List<UserTardiness> userTardinessList = snapshot.data!;
          // Sort users with tardiness to the top
          userTardinessList
              .sort((a, b) => b.totalTardiness.compareTo(a.totalTardiness));

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nom & Prénom')),
                DataColumn(label: Text('Total de retard')),
              ],
              rows: userTardinessList.map((userTardiness) {
                String formattedTardiness = userTardiness
                            .totalTardiness.inMinutes ==
                        0
                    ? '0m'
                    : '${userTardiness.totalTardiness.inHours}h ${userTardiness.totalTardiness.inMinutes.remainder(60)}m';
                return DataRow(cells: [
                  DataCell(Text(
                      '${userTardiness.user.nom} ${userTardiness.user.prenom}')),
                  DataCell(Text(formattedTardiness)),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class UserTardiness {
  final UserData user;
  final Duration totalTardiness;

  UserTardiness(this.user, this.totalTardiness);
}
