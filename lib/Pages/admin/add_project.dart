// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProject extends StatefulWidget {
  const AddProject({super.key});

  @override
  State<StatefulWidget> createState() => AddProjectState();
}

class AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<String> selectedEmployees = [];
  List<String> allEmployees = [];
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchAllEmployees();
  }

  Future<void> _fetchAllEmployees() async {
    QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
        .collection('User')
        .where('role', isEqualTo: 'employee')
        .get();

    setState(() {
      allEmployees = employeeSnapshot.docs.map((doc) {
        return '${doc['Nom']} ${doc['Prénom']}';
      }).toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = 'projects/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading image: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  String generateId() {
    final random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const length = 20;

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  void _addProject() async {
    final String id = generateId();
    if (_formKey.currentState!.validate()) {
      try {
        String imageUrl = '';
        if (_imageFile != null) {
          imageUrl = await _uploadImage(_imageFile!);
        }
        if (imageUrl.isNotEmpty) {
          FirebaseFirestore.instance.collection('Projects').doc(id).set({
            'id': id,
            'title': _titleController.text,
            'description': _descriptionController.text,
            'employees': selectedEmployees,
            'imageUrl': imageUrl,
          }).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Projet ajouté avec succès')),
            );
            Navigator.pop(context);
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Erreur lors de l\'ajout du projet')),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez séléctionnez une image')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout du projet')),
        );
      }
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
          'Nouveau Projet',
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
                      ? Container(
                          width: size.width * 0.8,
                          height: size.height * 0.3,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.camera_alt, size: 50),
                        )
                      : Image.file(
                          _imageFile!,
                          width: size.width * 0.8,
                          height: size.height * 0.3,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(height: size.height * 0.04),
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
                  items: allEmployees.map((String employee) {
                    return DropdownMenuItem<String>(
                      value: employee,
                      child: Text(employee),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null &&
                        !selectedEmployees.contains(newValue)) {
                      setState(() {
                        selectedEmployees.add(newValue);
                      });
                    }
                  },
                ),
                SizedBox(height: size.height * 0.04),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: selectedEmployees.map((employee) {
                    return Chip(
                      label: Text(employee),
                      onDeleted: () {
                        setState(() {
                          selectedEmployees.remove(employee);
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
                    onPressed: _addProject,
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
                      "Ajouter",
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
