import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationEmailPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  VerificationEmailPage({Key? key, required this.userData}) : super(key: key);

  @override
  _VerificationEmailPageState createState() => _VerificationEmailPageState();
}

class _VerificationEmailPageState extends State<VerificationEmailPage> {
  final _auth = FirebaseAuth.instance;



  Future<void> saveUserToFirestore(
      String userId, Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .set(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vérifier votre email"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Un email de vérification a été envoyé. Veuillez vérifier votre email et cliquer sur le lien de vérification. Vous devrez peut-être actualiser cette page après avoir vérifié pour continuer.",
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              child: Text('Email vérifié, Continuer'),
              onPressed: () async {
                User? user = _auth.currentUser;
                await user?.reload();
                user = _auth.currentUser;

                if (user!.emailVerified) {
                  saveUserToFirestore(user.uid, widget.userData);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email vérifié avec succès .')));
                } else {
                  // Afficher un message indiquant que l'email n'est pas encore vérifié
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Email non vérifié"),
                        content: Text(
                            "Veuillez vérifier votre email avant de continuer."),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Ferme la boîte de dialogue
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
