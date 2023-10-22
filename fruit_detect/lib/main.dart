// ignore_for_file: prefer_const_constructors, camel_case_types, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upload_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(fruitDetect());
}

class fruitDetect extends StatelessWidget {
  const fruitDetect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'FruitDetect',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto Slab',
                color: Colors.white,
                fontSize: 22,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    try {
                      await FirebaseAuth.instance.signInAnonymously();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadPage(),
                        ),
                      );
                    } on FirebaseAuthException {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Error"),
                            content: Text("Please connect to the network !"),
                            actions: [
                              TextButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Image.asset(
                    'assets/Logo.png',
                    width: constraints.maxWidth * 0.8,
                    height: constraints.maxHeight * 0.8,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
