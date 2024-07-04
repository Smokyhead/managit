import 'package:flutter/material.dart';
import 'package:managit/pages/admin/absence_management.dart';
import 'package:managit/pages/admin/dashboard.dart';
import 'package:managit/pages/admin/global_leave_overview.dart';
import 'package:managit/pages/admin/month_sythesis.dart';
import 'package:managit/pages/admin/penalty_management.dart';
import 'package:managit/pages/admin/tardiness_management.dart';
import 'package:managit/pages/admin/user_management.dart';

class AdminAppBar extends StatefulWidget {
  const AdminAppBar({super.key});

  @override
  AdminAppBarState createState() => AdminAppBarState();
}

class AdminAppBarState extends State<AdminAppBar> {
  int _selectedPageIndex = 0;

  final List<Widget> _pages = [
    const Dashboard(),
    const MonthSythesis(),
    const GlobalLeaveOverview(),
    const UserManagement(),
    const AbsenceManagement(),
    const TardinessManagement(),
    const PenaltyManagement(),
  ];

  final List<String> _pageTitles = [
    'Dashboard',
    'Sythèse de mois',
    'Vue globale de congés',
    'Gestion utilisateurs',
    'Gestion des absences',
    'Gestion des reatrds',
    'Gestion des pénalités'
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(_pageTitles[_selectedPageIndex]),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.indigo,
        child: ListView(
          children: <Widget>[
            Container(
                decoration: const BoxDecoration(
                    border: BorderDirectional(
                        bottom: BorderSide(color: Colors.white, width: 0.3))),
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
                      color: _selectedPageIndex == 0 ? null : Colors.white)),
              tileColor: _selectedPageIndex == 0 ? Colors.grey[300] : null,
              onTap: () => _selectPage(0),
            ),
            ListTile(
              title: Text('Synthèse de mois',
                  style: TextStyle(
                      color: _selectedPageIndex == 1 ? null : Colors.white)),
              tileColor: _selectedPageIndex == 1 ? Colors.grey[300] : null,
              onTap: () => _selectPage(1),
            ),
            ListTile(
              title: Text('Vue globale de congé',
                  style: TextStyle(
                      color: _selectedPageIndex == 2 ? null : Colors.white)),
              tileColor: _selectedPageIndex == 2 ? Colors.grey[300] : null,
              onTap: () => _selectPage(2),
            ),
            ListTile(
              title: Text('Gestion des utilisateurs',
                  style: TextStyle(
                      color: _selectedPageIndex == 3 ? null : Colors.white)),
              tileColor: _selectedPageIndex == 3 ? Colors.grey[300] : null,
              onTap: () => _selectPage(3),
            ),
            ListTile(
              title: Text('Gestion des absences',
                  style: TextStyle(
                      color: _selectedPageIndex == 3 ? null : Colors.white)),
              tileColor: _selectedPageIndex == 3 ? Colors.grey[300] : null,
              onTap: () => _selectPage(3),
            ),
            ListTile(
              title: Text('Gestion des retards',
                  style: TextStyle(
                      color: _selectedPageIndex == 3 ? null : Colors.white)),
              tileColor: _selectedPageIndex == 3 ? Colors.grey[300] : null,
              onTap: () => _selectPage(3),
            ),
            ListTile(
              title: Text('Gestion des pénalites',
                  style: TextStyle(
                      color: _selectedPageIndex == 3 ? null : Colors.white)),
              tileColor: _selectedPageIndex == 3 ? Colors.grey[300] : null,
              onTap: () => _selectPage(3),
            ),
          ],
        ),
      ),
      body: _pages[_selectedPageIndex],
    );
  }
}
