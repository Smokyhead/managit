import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _LeaveHomeState();
}

class _LeaveHomeState extends State<Home> {
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: const Color.fromARGB(255, 30, 60, 100),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('User')
                    .where('role', isEqualTo: 'employee')
                    .snapshots(),
                builder: (context, snapshots) {
                  if (snapshots.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 30, 60, 100),
                      ),
                    );
                  }
                  final docs = snapshots.data?.docs;
                  if (docs == null || docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aucun utilisateur à afficher",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return ListView.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: snapshots.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshots.data!.docs[index].data()
                              as Map<String, dynamic>;
                          return ListTile(
                            title: Text("${data['Nom']} ${data['Prénom']}",
                                style: TextStyle(fontSize: size.width * 0.05)),
                            trailing: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.more_vert)),
                          );
                        });
                  }
                })
          ],
        ),
      ),
    );
  }
}
