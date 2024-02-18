import 'package:flutter/material.dart';

import 'ResetPasswordPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true ;
  final TextEditingController _emailUsernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Connecte toi !",
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _emailUsernameController,
                decoration: InputDecoration(
                  labelText: 'Adresse email ou nom d\'utilisateur',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                // Utilisation de la variable d'état pour contrôler la visibilité
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    // Exemple de couleur, ajustez selon vos besoins
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Changement d'icône en fonction de la visibilité du mot de passe
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        // Mise à jour de l'état pour basculer la visibilité du mot de passe
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Action pour mot de passe oublié
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                      );
                    },
                    child: Text('Mot de passe oublié ?'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Action de connexion
                      if (_emailUsernameController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty) {


                      } else {
                        // Afficher un message d'erreur si l'un des champs est vide
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Veuillez remplir tous les champs !"),
                        ));
                      }
                    },
                    child: Text('Se connecter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _emailUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
