import 'package:firebase_auth/firebase_auth.dart';
import 'package:sensy_clinician_app/services/database.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> getClincianID() async {
    // Get the current user
    User? u = _firebaseAuth.currentUser;

    // Check if the user is null or the email is null
    if (u != null && u.email != null) {
      // Now we know the user and email are not null, so we can safely call the method
      String? clinicianID =
          await DatabaseService().getClinicianIDByEmail(u.email!);
      // Return the clinicianID if it's not null, otherwise return an empty string
      return clinicianID ?? '';
    } else {
      // Return an empty string or some default value if the user or email is null
      print('hello');
      return '';
    }
  }
}
