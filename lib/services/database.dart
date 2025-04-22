import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  // Method to save sensation data with date-based document IDs
  Future<bool> savePatientSensation({
    required String patientID,
    required String sensation,
    required List<String> footAreas,
    String? electrodeID,
    double? amplitude,
  }) async {
    try {
      // Reference to the sensations collection under the patient's document
      CollectionReference sensationsCollection =
      FirebaseFirestore.instance
          .collection('patient_mapping')
          .doc(patientID)
          .collection('sensations');

      // Generate a date-based ID for the document
      DateTime now = DateTime.now();
      String dateId = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);

      // Create the document with the date-based ID
      await sensationsCollection.doc(dateId).set({
        'sensation': sensation,
        'footAreas': footAreas,
        'electrodeID': electrodeID ?? 'unknown',
        'amplitude': amplitude ?? 0.0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Also update the main patient document with some basic info
      await FirebaseFirestore.instance
          .collection('patient_mapping')
          .doc(patientID)
          .set({
        'patientID': patientID,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true; // Return true if document was created successfully
    } catch (e) {
      print('Error saving sensation data: $e');
      return false;
    }
  }
}