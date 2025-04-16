import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // collection reference
  final CollectionReference clincianData =
      FirebaseFirestore.instance.collection('clinician_data');

  final CollectionReference clinicians =
      FirebaseFirestore.instance.collection('clinicians');

  Future<String?> getClinicianIDByEmail(String email) async {
    try {
      // Query Firestore to find a document where 'email' matches
      QuerySnapshot snapshot =
          await clincianData.where('email', isEqualTo: email).get();

      if (snapshot.docs.isEmpty) {
        return null; // No user found with the given email
      } else {
        // Assuming there's only one user with this email
        return snapshot.docs.first['clinicianID'];
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPatientsByClincianID(
      String clinicianID) async {
    try {
      CollectionReference patientsRef =
          clinicians.doc(clinicianID).collection('patients');
      QuerySnapshot snapshot = await patientsRef.get();
      if (snapshot.docs.isEmpty) {
        return []; // No patients found
      }

      // Extract patient data from each document
      List<Map<String, dynamic>> patients = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return {
          'patientID': doc.id, // Document ID
          'age': data['age'] ?? 0, // Handle missing fields gracefully
          'originOfPain': data['originOfPain'] ?? 'Unknown',
        };
      }).toList();

      return patients;
    } catch (e) {
      return [];
    }
  }
}
