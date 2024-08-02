import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:managit/pages/admin/absence_management.dart';
import 'package:managit/pages/admin/daily_attendance.dart';
import 'package:managit/pages/admin/dashboard.dart';
import 'package:managit/pages/admin/global_leave_overview.dart';
import 'package:managit/pages/admin/global_permission_overview.dart';
import 'package:managit/pages/admin/month_sythesis.dart';
import 'package:managit/pages/admin/notifications.dart';
import 'package:managit/pages/admin/penalty_management.dart';
import 'package:managit/pages/admin/projects.dart';
import 'package:managit/pages/admin/settings.dart';
import 'package:managit/pages/admin/tardiness_management.dart';
import 'package:managit/pages/admin/user_management.dart';
import 'package:managit/pages/connection/connection.dart';
import 'package:badges/badges.dart' as badges;

class AdminAppBar extends StatefulWidget {
  const AdminAppBar({super.key});

  @override
  AdminAppBarState createState() => AdminAppBarState();
}

class AdminAppBarState extends State<AdminAppBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedPageIndex = 1;
  int n = 0;

  Future<void> signOut() async {
    showDialog(
        context: (context),
        builder: (BuildContext context) {
          return Center(
            child: Platform.isAndroid
                ? const CircularProgressIndicator(
                    color: Color.fromARGB(255, 30, 60, 100),
                  )
                : const CupertinoActivityIndicator(),
          );
        });
    try {
      await _auth.signOut();
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const Login();
      }));
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }

  final List<Widget> _pages = [
    const Dashboard(),
    const MonthSythesis(),
    const DailyAttendance(),
    const GlobalLeaveOverview(),
    const GlobalPermissionOverview(),
    const UserManagement(),
    const AbsenceManagement(),
    const TardinessManagement(),
    const PenaltyManagement(),
    const Projects(),
    const AdminSettings()
  ];

  final List<String> _pageTitles = [
    'Dashboard',
    'Sythèse de mois',
    'Pointage quotidient',
    'Vue globale de congés',
    'Vue globale de permissions',
    'Gestion utilisateurs',
    'Gestion des absences',
    'Gestion des retards',
    'Gestion des pénalités',
    'Gestion des projets',
    'Paramêtres'
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('User')
            .where('role', isEqualTo: 'employee')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Platform.isAndroid
                  ? const CircularProgressIndicator(
                      color: Color.fromARGB(255, 30, 60, 100),
                    )
                  : const CupertinoActivityIndicator(),
            );
          }
          final user = snapshot.data?.docs.first;
          final userd = user!.data();
          int rest = userd['resteConge'];
          int sanc = 0;
          if (userd['Sanctions'] - userd['Sanctions'].truncate() < 0.6) {
            sanc = userd['Sanctions'].truncate();
          } else {
            sanc = userd['Sanctions'].ceil();
          }
          if (DateTime.now().month == (user['NbMois'] + 1)) {
            FirebaseFirestore.instance
                .collection('User')
                .doc(userd['id'])
                .update({
              'NbMois': userd['NbMois'] + 1,
              'Solde congé': ((userd['NbMois'] + 1) * 1.75).truncate(),
              'resteConge': userd['Solde congé'] +
                  userd['Solde congé année prec'] -
                  sanc -
                  userd['Congé pris']
            });
          }
          if (userd['NbMois'] == 12 && DateTime.now().month == 1) {
            userd['year'] = userd['year'] + 1;
            FirebaseFirestore.instance
                .collection('User')
                .doc(userd['id'])
                .update({
              'NbMois': 1,
              'Solde congé': 1.75.truncate(),
              'resteConge': 1,
              'Solde congé année prec': rest,
              'Sanctions': 0
            });
          }
          return const SizedBox.shrink();
        });
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 60, 100),
        foregroundColor: Colors.white,
        title: Text(
          _pageTitles[_selectedPageIndex],
          style: TextStyle(fontSize: size.width * 0.0475),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Notification')
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshots) {
              if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
                return IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const Notifications();
                    }));
                  },
                  icon: const Icon(Icons.notifications),
                );
              }

              int unreadCount = snapshots.data!.docs.length;

              return badges.Badge(
                position: badges.BadgePosition.custom(end: 5),
                badgeContent: Text(
                  unreadCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const Notifications();
                    }));
                  },
                  icon: const Icon(Icons.notifications),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        width: size.width * 0.7,
        backgroundColor: const Color.fromARGB(255, 30, 60, 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                    decoration: const BoxDecoration(
                        border: BorderDirectional(
                            bottom:
                                BorderSide(color: Colors.white, width: 0.3))),
                    padding: EdgeInsets.only(
                        top: size.height * 0.025,
                        left: size.width * 0.05,
                        bottom: size.height * 0.025),
                    margin: EdgeInsets.only(bottom: size.height * 0.01),
                    child: const Text(
                      'Menu',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    )),
                ListTile(
                  title: Text('Dashboard',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 0 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 0 ? Colors.grey[300] : null,
                  onTap: () => _selectPage(0),
                ),
                ListTile(
                  title: Text('Synthèse de mois',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 1 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 1 ? Colors.grey[300] : null,
                  onTap: () => _selectPage(1),
                ),
                ListTile(
                  title: Text('Pointage quotidient',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 2 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 2 ? Colors.grey[300] : null,
                  onTap: () => _selectPage(2),
                ),
                ListTile(
                  title: Text('Vue globale de congés',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 3 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 3 ? Colors.grey[300] : null,
                  onTap: () => _selectPage(3),
                ),
                ListTile(
                  title: Text('Vue globale de permissions',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 4 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 4 ? Colors.grey[300] : null,
                  onTap: () => _selectPage(4),
                ),
                ListTile(
                  title: Text('Gestion des utilisateurs',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 5 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 5 ? Colors.grey[300] : null,
                  onTap: () => _selectPage(5),
                ),
                ListTile(
                  title: Text('Gestion des absences',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 6 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 6 ? Colors.grey[300] : null,
                  onTap: () => _selectPage(6),
                ),
                ListTile(
                  title: Text('Gestion des retards',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 7 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 7 ? Colors.grey[300] : null,
                  onTap: () => _selectPage(7),
                ),
                ListTile(
                  title: Text('Gestion des pénalités',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 8 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 8 ? Colors.grey[300] : null,
                  onTap: () => _selectPage(8),
                ),
                ListTile(
                  title: Text('Gestion des projets',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 9 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 9 ? Colors.grey[300] : null,
                  onTap: () => _selectPage(9),
                )
              ],
            ),
            Column(
              children: [
                ListTile(
                  title: Text('Paramêtres',
                      style: TextStyle(
                          color:
                              _selectedPageIndex == 10 ? null : Colors.white)),
                  tileColor: _selectedPageIndex == 10 ? Colors.grey[300] : null,
                  trailing: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onTap: () => _selectPage(10),
                ),
                ListTile(
                  title: const Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onTap: () {
                    signOut();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: _pages[_selectedPageIndex],
    );
  }
}
