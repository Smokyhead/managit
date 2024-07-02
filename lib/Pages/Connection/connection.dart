// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:managit/pages/Connection/password_recovery.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  final myController1 = TextEditingController();
  final myController2 = TextEditingController();
  bool hidePassword = true;
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
              height: 30,
            ),
            const SizedBox(height: 60),
            TextFieldContainer(
              child: TextFormField(
                obscureText: hidePassword,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    hintText: "Votre Email",
                    border: InputBorder.none,
                    icon: Icon(
                      IconlyLight.profile,
                      color: Colors.indigo,
                    )),
                controller: myController1,
              ),
            ),
            const SizedBox(height: 5),
            TextFieldContainer(
                child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              obscureText: hidePassword,
              decoration: InputDecoration(
                icon: const Icon(
                  IconlyLight.lock,
                  color: Colors.indigo,
                ),
                suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? IconlyLight.hide : IconlyLight.show,
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
              controller: myController2,
            )),
            const SizedBox(height: 25),
            Container(
              margin: const EdgeInsetsDirectional.only(top: 5),
              width: size.width * 0.8,
              height: 60,
              child: TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(10),
                    backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  child: const Text("Se connecter",
                      style: TextStyle(fontSize: 20))),
            ),
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
