import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_data');

  Future<String?> getEmailByUsername(String username) async {
    try {
      // Query Firestore to find a document where 'username' matches
      QuerySnapshot snapshot =
          await userCollection.where('username', isEqualTo: username).get();

      if (snapshot.docs.isEmpty) {
        return null; // No user found with the given username
      } else {
        // Assuming there's only one user with this username
        return snapshot.docs.first['email'];
      }
    } catch (e) {
      return null;
    }
  }
}
