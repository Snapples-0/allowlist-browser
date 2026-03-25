import 'package:firebase_auth/firebase_auth.dart';

class ParentAuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign-in failed';
    }
  }

  static Future<void> signOut() => _auth.signOut();

  static User? get currentUser => _auth.currentUser;

  static bool get isSignedIn => _auth.currentUser != null;
}
