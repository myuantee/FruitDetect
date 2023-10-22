import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResultPage extends StatelessWidget {
  final String imageUrl;
  final String predictedClass;

  const ResultPage({
    Key? key,
    required this.imageUrl,
    required this.predictedClass,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Align(
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
      body: Column(
        children: [
          Expanded(
            child: Image.network(
              imageUrl,
              fit: BoxFit.fitWidth,
            ),
          ),
          Text(
            'Predicted class: $predictedClass',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30, // specify the font size here
              fontStyle: FontStyle.italic, // specify the font style here
              fontWeight: FontWeight.bold, // specify the font weight here
              fontFamily: 'Roboto Slab', // specify the font family here
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: const Text('HomePage'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
