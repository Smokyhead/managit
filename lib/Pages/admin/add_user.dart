// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/hotmail.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<StatefulWidget> createState() => AddUserState();
}

class AddUserState extends State<AddUser> {
  final _formKeyy = GlobalKey<FormState>();
  final TextEditingController _nom = TextEditingController();
  final TextEditingController _prenom = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  bool isEightDigits(String input) {
    final RegExp regExp = RegExp(r'^\d{8}$');
    return regExp.hasMatch(input);
  }

  final smtpServer = hotmail("swconsulting01@hotmail.com", "Swconsulting2024");
  // final smtpServer = gmail(dotenv.env['EMAIL']!, dotenv.env['PASSWORD']!);

  sendMail() async {
    final message = Message()
      ..from = const Address("saidane.sirine2001@gmail.com", 'Confirmation bot')
      ..recipients.add('lefewob854@mfunza.com')
      ..subject = 'Test Dart Mailer library'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e);
    }
  }

  String generateDefaultPassword({int length = 12}) {
    const String upperCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowerCaseLetters = 'abcdefghijklmnopqrstuvwxyz';
    const String digits = '0123456789';
    const String specialCharacters = '@#\$%^&*()_+[]{}|;:,.<>?';

    // Combine all character sets into one
    const String allCharacters =
        '$upperCaseLetters$lowerCaseLetters$digits$specialCharacters';
    final Random random = Random();

    // Generate a random password of the given length
    List<String> passwordChars = List.generate(length, (index) {
      return allCharacters[random.nextInt(allCharacters.length)];
    });

    // Ensure the password contains at least one character from each set
    passwordChars
        .add(upperCaseLetters[random.nextInt(upperCaseLetters.length)]);
    passwordChars
        .add(lowerCaseLetters[random.nextInt(lowerCaseLetters.length)]);
    passwordChars.add(digits[random.nextInt(digits.length)]);
    passwordChars
        .add(specialCharacters[random.nextInt(specialCharacters.length)]);

    // Shuffle the characters to avoid predictable patterns
    passwordChars.shuffle(random);

    // Truncate to the desired length and convert to string
    return passwordChars.take(length).join();
  }

  void addUser() {
    try {
      if (_formKeyy.currentState!.validate()) {
        FirebaseFirestore.instance.collection("User").doc().set({});
      }
    } catch (e) {
      print(e);
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
            'Nouveau utilisateur',
            style: TextStyle(fontSize: size.width * 0.0475),
          ),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Form(
              key: _formKeyy,
              child: Column(
                children: [
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        hintText: 'Nom',
                        hintStyle: TextStyle(fontSize: size.width * 0.05)),
                    controller: _nom,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: size.height * 0.04),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        hintText: 'Prénom',
                        hintStyle: TextStyle(fontSize: size.width * 0.05)),
                    controller: _prenom,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le prénom';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: size.height * 0.04),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(fontSize: size.width * 0.05)),
                    controller: _email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer l'adresse e-mail";
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Veuillez entrer une adresse e-mail valide';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: size.height * 0.04),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        hintText: 'Téléphone',
                        hintStyle: TextStyle(fontSize: size.width * 0.05)),
                    controller: _phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer le numéro de téléphone";
                      }
                      if (!isEightDigits(_phone.text)) {
                        return 'Veuillez entrer un numéro valide';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: size.height * 0.04),
                  Container(
                    margin: const EdgeInsetsDirectional.only(top: 5),
                    width: size.width * 0.4,
                    height: 60,
                    child: TextButton(
                        onPressed: () {
                          sendMail();
                        },
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(10),
                          backgroundColor: WidgetStateProperty.all(
                              const Color.fromARGB(255, 30, 60, 100)),
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        child: Text("Valider",
                            style: TextStyle(fontSize: size.width * 0.05))),
                  ),
                ],
              )),
        )));
  }
}
