// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<StatefulWidget> createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword> {
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          )),
          backgroundColor: const Color.fromARGB(255, 30, 60, 100),
          foregroundColor: Colors.white,
          title: const Text("Mot de passe"),
        ),
      ),
      backgroundColor: Colors.white,
      body: SizedBox(
        height: size.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  Container(
                    margin:
                        const EdgeInsets.only(right: 20, left: 20, bottom: 100),
                    child: const Text(
                      "Récuperer votre mot de passe",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Color.fromARGB(255, 30, 60, 100)),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(right: 5, left: 5, bottom: 25),
                    child: const Text(
                      "Veuillez saisir votre adresse email",
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                  TextFieldContainer(
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Email",
                        border: InputBorder.none,
                      ),
                      controller: emailController,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(top: 50),
                    width: 150,
                    height: 50,
                    child: TextButton(
                      onPressed: () async {
                        final email = emailController.text;

                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email sent for password reset!'),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.message!),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(5),
                        backgroundColor: WidgetStateProperty.all(
                            const Color.fromARGB(255, 30, 60, 100)),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      child:
                          const Text("Valider", style: TextStyle(fontSize: 19)),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
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
