import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('clinician_data');

  Future<String?> getClinicianIDByEmail(String email) async {
    try {
      // Query Firestore to find a document where 'username' matches
      QuerySnapshot snapshot =
          await userCollection.where('email', isEqualTo: email).get();

      if (snapshot.docs.isEmpty) {
        return null; // No user found with the given username
      } else {
        // Assuming there's only one user with this username
        return snapshot.docs.first['clinicianID'];
      }
    } catch (e) {
      return null;
    }
  }
}
