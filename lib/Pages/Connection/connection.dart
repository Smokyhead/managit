// ignore_for_file: file_names, use_build_context_synchronously, avoid_print
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:managit/pages/admin/admin_appbar.dart';
import 'package:managit/pages/connection/password_recovery.dart';
import 'package:managit/pages/employee/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  final appCheck = FirebaseAppCheck.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool hidePassword = true;
  late User appUser;

  Future<String> getRole(String id) async {
    late Map<String, dynamic> data;
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('User').doc(id).get();
      if (snapshot.exists) {
        data = snapshot.data() as Map<String, dynamic>;
      } else {
        print('user not found');
        _errorMessage = 'Une erreur est survenue';
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e.toString());
      print("something went wrong!!");
    }
    return data['role'];
  }

  Future<User?> signInWithEmailPassword(String email, String password) async {
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
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e.toString());
      _errorMessage = 'Une erreur est survenue';
      Navigator.of(context).pop();

      return null;
    }
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      User? user = await signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        print(await getRole(user.uid));
        appUser = user;
        if (await getRole(user.uid) == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminAppBar()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Incorrect email or password';
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            const Text(
              "Connectez-vous",
              style: TextStyle(
                  fontSize: 30,
                  color: Color.fromARGB(255, 30, 60, 100),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 60),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFieldContainer(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre adresse e-mail';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Veuillez verifier votre e-mail';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            hintText: "Votre Email",
                            border: InputBorder.none,
                            icon: Icon(
                              IconlyLight.profile,
                              color: Color.fromARGB(255, 30, 60, 100),
                            )),
                        controller: _emailController,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFieldContainer(
                        child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                      textAlignVertical: TextAlignVertical.center,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        icon: const Icon(
                          IconlyLight.lock,
                          color: Color.fromARGB(255, 30, 60, 100),
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? IconlyLight.hide
                                  : IconlyLight.show,
                            ),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            color: const Color.fromARGB(255, 30, 60, 100)),
                        border: InputBorder.none,
                        hintText: "Votre Mot de passe",
                      ),
                      controller: _passwordController,
                    )),
                    const SizedBox(height: 25),
                    Container(
                      margin: const EdgeInsetsDirectional.only(top: 5),
                      width: size.width * 0.8,
                      height: 60,
                      child: TextButton(
                          onPressed: () {
                            _signIn();
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
                          child: const Text("Se connecter",
                              style: TextStyle(fontSize: 20))),
                    ),
                  ],
                )),
            const SizedBox(height: 10),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ResetPassword();
                  }));
                },
                child: const Text(
                  'Récupérez Mot de passe',
                  style: TextStyle(color: Color.fromARGB(255, 30, 60, 100)),
                )),
            const SizedBox(height: 50),
          ],
        ),
      )),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 224, 227, 241),
          borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }
}
