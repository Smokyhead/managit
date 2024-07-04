// ignore_for_file: file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:managit/pages/Connection/password_recovery.dart';
import 'package:managit/pages/admin/admin_appbar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool hidePassword = true;

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminAppBar()),
        );
      } else {
        setState(() {
          _errorMessage = 'Incorrect email or password';
        });
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
                  color: Colors.indigo,
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
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            hintText: "Votre Email",
                            border: InputBorder.none,
                            icon: Icon(
                              IconlyLight.profile,
                              color: Colors.indigo,
                            )),
                        controller: _emailController,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFieldContainer(
                        child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      textAlignVertical: TextAlignVertical.center,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        icon: const Icon(
                          IconlyLight.lock,
                          color: Colors.indigo,
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
                            color: Colors.indigo),
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
                            backgroundColor:
                                WidgetStateProperty.all(Colors.indigo),
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
                  style: TextStyle(color: Colors.indigo),
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
