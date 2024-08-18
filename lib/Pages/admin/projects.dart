import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:managit/pages/admin/add_project.dart';

class Projects extends StatefulWidget {
  const Projects({super.key});

  @override
  State<StatefulWidget> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 215, 230, 245),
        foregroundColor: const Color.fromARGB(255, 30, 60, 100),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return const AddProject();
          }));
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Projects').snapshots(),
          builder: (context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(
                child: Platform.isAndroid
                    ? const CircularProgressIndicator(
                        color: Color.fromARGB(255, 30, 60, 100),
                      )
                    : const CupertinoActivityIndicator(),
              );
            }

            if (snapshots.hasError) {
              return Center(
                child: Text('Error: ${snapshots.error}'),
              );
            }

            final docs = snapshots.data?.docs;
            if (docs == null || docs.isEmpty) {
              return const Center(
                child: Text(
                  "Aucun projet à afficher",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.grey),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final projectData =
                      docs[index].data() as Map<String, dynamic>;

                  return ListTile(
                    leading: Image.network(projectData['imageUrl']),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectData['title'] ?? 'Titre',
                          style: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          projectData['description'] ?? 'Description',
                          style: TextStyle(fontSize: size.width * 0.04),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Scaffold(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
