// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProject extends StatefulWidget {
  final String id;

  const EditProject({super.key, required this.id});

  @override
  State<StatefulWidget> createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, String>> allEmployees = [];
  List<String> selectedEmployeeIds = [];
  File? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchProjectDetails();
    _fetchAllEmployees();
  }

  Future<void> _fetchProjectDetails() async {
    DocumentSnapshot projectDoc = await FirebaseFirestore.instance
        .collection('Projects')
        .doc(widget.id)
        .get();

    setState(() {
      _titleController.text = projectDoc['title'];
      _descriptionController.text = projectDoc['description'];
      selectedEmployeeIds = List<String>.from(projectDoc['employees']);
      _existingImageUrl = projectDoc['imageUrl'];
    });
  }

  Future<void> _fetchAllEmployees() async {
    QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
        .collection('User')
        .where('role', isEqualTo: 'employee')
        .get();

    setState(() {
      allEmployees = employeeSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': '${doc['Nom']} ${doc['Prénom']}',
        };
      }).toList();
    });
  }

  void _editProject() async {
    if (_formKey.currentState!.validate()) {
      try {
        String imageUrl = _existingImageUrl ?? '';
        if (_imageFile != null) {
          imageUrl = await _uploadImage(_imageFile!);
        }

        if (imageUrl.isNotEmpty) {
          // Get the list of employees currently assigned to the project
          DocumentSnapshot projectDoc = await FirebaseFirestore.instance
              .collection('Projects')
              .doc(widget.id)
              .get();
          List<String> currentEmployeeIds =
              List<String>.from(projectDoc['employees']);

          // Identify employees who have been removed from the project
          List<String> removedEmployeeIds = currentEmployeeIds
              .where((id) => !selectedEmployeeIds.contains(id))
              .toList();

          // Update the project in the Projects collection
          await FirebaseFirestore.instance
              .collection('Projects')
              .doc(widget.id)
              .update({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'employees': selectedEmployeeIds,
            'imageUrl': imageUrl,
          });

          // Add project ID to the 'projects' list of newly added employees
          for (String employeeId in selectedEmployeeIds) {
            DocumentReference userDocRef =
                FirebaseFirestore.instance.collection('User').doc(employeeId);

            await userDocRef.update({
              'projects': FieldValue.arrayUnion([widget.id]),
            });
          }

          // Remove project ID from the 'projects' list of removed employees
          for (String removedEmployeeId in removedEmployeeIds) {
            DocumentReference userDocRef = FirebaseFirestore.instance
                .collection('User')
                .doc(removedEmployeeId);

            await userDocRef.update({
              'projects': FieldValue.arrayRemove([widget.id]),
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Projet modifié avec succès')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez séléctionnez une image')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la modification')),
        );
      }
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    String fileName = 'projects/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('projects/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 60, 100),
        foregroundColor: Colors.white,
        title: Text(
          'Modifier projet',
          style: TextStyle(fontSize: size.width * 0.0475),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: _imageFile == null
                      ? (_existingImageUrl != null
                          ? Image.network(
                              _existingImageUrl!,
                              width: size.width * 0.8,
                              height: size.height * 0.3,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: size.width * 0.8,
                              height: size.height * 0.3,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.camera_alt, size: 50),
                            ))
                      : Image.file(
                          _imageFile!,
                          width: size.width * 0.8,
                          height: size.height * 0.3,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(height: size.height * 0.01),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _imageFile = null;
                        _existingImageUrl = null;
                      });
                    },
                    child: const Text(
                      'Retirer l\'image',
                      style: TextStyle(color: Colors.red),
                    )),
                SizedBox(height: size.height * 0.01),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Titre',
                    hintStyle: TextStyle(fontSize: size.width * 0.05),
                  ),
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le titre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.04),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(fontSize: size.width * 0.05),
                  ),
                  controller: _descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer la description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.04),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Sélectionner des employés',
                    hintStyle: TextStyle(fontSize: size.width * 0.05),
                  ),
                  items: allEmployees.map((Map<String, String> employee) {
                    return DropdownMenuItem<String>(
                      value: employee['id'],
                      child: Text(employee['name']!),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null &&
                        !selectedEmployeeIds.contains(newValue)) {
                      setState(() {
                        selectedEmployeeIds.add(newValue);
                      });
                    }
                  },
                ),
                SizedBox(height: size.height * 0.04),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: selectedEmployeeIds.map((id) {
                    String employeeName = allEmployees.firstWhere(
                        (employee) => employee['id'] == id)['name']!;
                    return Chip(
                      label: Text(employeeName),
                      onDeleted: () {
                        setState(() {
                          selectedEmployeeIds.remove(id);
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: size.height * 0.04),
                Container(
                  margin: const EdgeInsetsDirectional.only(top: 5),
                  width: size.width * 0.4,
                  height: 60,
                  child: TextButton(
                    onPressed: _editProject,
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
                    child: Text(
                      "Enregistrer",
                      style: TextStyle(fontSize: size.width * 0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
