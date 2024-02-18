import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../utils/ThemeNotifier.dart';
import 'AuthService.dart';
import 'VerificationEmailPage.dart';
import 'LoginPage..dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //Variable pour la progressbar
  bool _isLoading = false;

  //Variable pour afficher ou masquer le mot de passe
  bool _obscureText = true;

  final AuthService _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fonction pour créer un utilisateur avec son email et son mot de passe
  Future<void> createUser(BuildContext context, String username, String email,
      String password) async {
    try {
      setState(() {
        _isLoading = true; // Afficher la barre de progression
      });
      //Appel de la fonction pour vérifier si un utilisateur avec le même nom existe déjà
      bool cannotSaveUserDetails = await isUsernameTaken(username);

      if (cannotSaveUserDetails) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Le nom d'utilisateur est déjà pris .")));
        setState(() {
          _isLoading = false;
        });
      } else {
        // Création de l'utilisateur
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        // Appel à la fonction pour enregistrer les détails de l'utilisateur dans Firestore
        User? user = userCredential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          Map<String, dynamic> userData = {
            'username': username.trim(),
            'usernameToLowerCase': username.trim().toLowerCase(),
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
            'uid': user.uid
            // Vous pouvez ajouter plus de champs ici si nécessaire
          };

          // Naviguer vers VerificationEmailPage avec les données utilisateur
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerificationEmailPage(userData: userData),
            ),
          );
        }
      } // Assurez-vous de remplacer '/home' par le chemin correct
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Une erreur est survenue. Veuillez réessayer.";
      if (e.code == 'weak-password') {
        errorMessage = 'Le mot de passe fourni est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage =
            'Un compte existe déjà pour cet email. Si c\'est le votre , connectez vous plutôt .';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'L\'email fourni est invalide.';
      }
      // Afficher l'erreur à l'utilisateur via un SnackBar
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      // Gérer toute autre erreur qui pourrait survenir
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur inattendue est survenue.')));
    } finally {
      setState(() {
        _isLoading = false; // Cacher la barre de progression
      });
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    // Référence à la collection 'Users' dans Firestore
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    // Exécutez une requête pour récupérer les utilisateurs avec le nom d'utilisateur spécifique
    QuerySnapshot querySnapshot = await usersRef
        .where('usernameToLowerCase', isEqualTo: username.toLowerCase())
        .get();

    // Vérifiez si la requête a retourné des résultats
    return querySnapshot.docs.isNotEmpty;
  }

  void _loginWithGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        // Utilisateur connecté, peut-être rediriger vers une autre page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bienvenue ${user.displayName}!")),
        );
      } else {
        // L'opération a retourné null, gérer ce cas
        print("Connexion Google annulée par l\'utilisateur'");
      }
    } on FirebaseAuthException catch (e) {
      // Erreurs spécifiques à FirebaseAuth
      if (e.code == "email-already-in-use")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adresse email déjà utilisée .}')),
        );
      if (e.code == "account-exists-with-different-credential")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adresse email déjà utilisée.}')),
        );
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion ')),
        );
      }
    } catch (error) {
      // Afficher l'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la connexion")),
      );
      print("Erreur lors de la connexion: $error");
    }
  }

  void _loginWithFacebook() async {
    try {
      final User? user = await _authService.signInWithFacebook();
      if (user != null) {
        // Connexion réussie, naviguer vers une autre page ou simplement afficher un succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connexion réussie avec Facebook')),
        );
      } else {
        // L'utilisateur a annulé la connexion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Connexion Facebook annulée par l\'utilisateur')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Erreurs spécifiques à FirebaseAuth
      if (e.code == "email-already-in-use")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adresse email déjà utilisée .}')),
        );
      if (e.code == "account-exists-with-different-credential")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adresse email déjà utilisée.')),
        );
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion ')),
        );
      }
      print("Erreur FirebaseAuth: ${e.message}");
    } catch (e) {
      // Autres erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion .')),
      );
      print("Erreur de connexion: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) => Scaffold(
        appBar: AppBar(
          title: Text("Share"),
          actions: <Widget>[
            // Icône changeante en fonction du thème
            IconButton(
              icon: Icon(themeNotifier.getTheme().brightness == Brightness.dark
                  ? Icons.nightlight_round // Icône de lune pour le thème sombre
                  : Icons.wb_sunny), // Icône de soleil pour le thème clair
              onPressed: () {
                // Basculer le thème lorsque l'icône est appuyée
                bool isDark =
                    themeNotifier.getTheme().brightness == Brightness.dark;
                if (isDark) {
                  themeNotifier.setTheme(ThemeData.light(), "light");
                } else {
                  themeNotifier.setTheme(ThemeData.dark(), "dark");
                }
              },
            ),
            // Switch pour basculer entre les thèmes
            Switch(
              value: themeNotifier.getTheme().brightness == Brightness.dark,
              onChanged: (value) {
                if (value) {
                  themeNotifier.setTheme(ThemeData.dark(), "dark");
                } else {
                  themeNotifier.setTheme(ThemeData.light(), "light");
                }
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                Text(
                  "Inscris-toi !",
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                        // Naviguer vers la page de connexion
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text("Déjà un compte ?"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Assurez-vous que les champs ne sont pas vides avant de procéder
                        if (_usernameController.text.isNotEmpty &&
                            _emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty) {
                          // Appel de la fonction createUser
                          createUser(context, _usernameController.text,
                              _emailController.text, _passwordController.text);
                        } else {
                          // Afficher un message d'erreur si l'un des champs est vide
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Veuillez remplir tous les champs !"),
                          ));
                        }
                      },
                      child: Text('S\'inscrire'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text("ou"),
                SizedBox(
                  height: 20,
                ),
                SignInButton(
                  Buttons.google,
                  mini: false,
                  text: "Connexion avec Google",
                  onPressed: () async {
                    _loginWithGoogle();
                  },
                ),
                SignInButton(
                  Buttons.facebook,
                  mini: false,
                  text: "Connexion avec Facebook",
                  onPressed: () async {
                    // Implémentation de l'authentification Facebook
                    _loginWithFacebook();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
