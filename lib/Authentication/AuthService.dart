import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        return authResult.user;
      }
    } catch (error) {
      print("Error signing in with Google: $error");
      throw error; // Throw l'erreur pour la capturer plus tard
    }
    return null;
  }


  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Signed Out");
  }

  // Méthode pour se connecter avec Facebook
  Future<User?> signInWithFacebook() async {
    try {
      // Démarrer le processus de login
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Vérifier si le login est réussi
      if (loginResult.status == LoginStatus.success) {
        // Obtenir le token d'accès
        final AccessToken facebookAccessToken = loginResult.accessToken!;

        // Créer un credential pour Firebase
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(facebookAccessToken.token);

        // Se connecter à Firebase
        final UserCredential authResult = await _auth.signInWithCredential(facebookAuthCredential);
        return authResult.user;
      }
    } catch (error) {
      print("Error signing in with Facebook: $error");
      throw error; // Pour permettre la gestion de l'erreur à un niveau supérieur
    }
    return null;
  }

  // Méthode pour se déconnecter de Facebook
  Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
    print("User Signed Out from Facebook");
  }
}
