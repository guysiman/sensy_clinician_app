import 'package:flutter/material.dart';
import '../components/add_patient_dialog.dart';
import '../components/pair_ipg_dialog.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Patients',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80, // Increased spacing from top
        actions: [
          Container(
            width: 200, // Smaller search bar
            padding: EdgeInsets.only(right: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey), // Grey hint text
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 8), // Align height with button
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.add,
                  color: Colors.white, size: 18), // Smaller icon
              label: Text(
                'Add New Patient',
                style: TextStyle(
                    color: Colors.white, fontSize: 14), // Smaller font
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2C5364),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12), // Align height with search
              ),
              onPressed: () {
                showAddPatientDialog(context);
              },
            ),
          ),
        ],
      ),
      body: PatientGridView(),
    );
  }
}

class PatientGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample patient data based on the screenshot
    final patients = [
      {
        'id': '5442',
        'age': 45,
        'pain': '',
        'hasIPG': true,
      },
      {
        'id': '4279',
        'age': 38,
        'pain': 'Right foot',
        'hasIPG': false,
      },
      {
        'id': '3498',
        'age': 32,
        'pain': 'Right calf',
        'hasIPG': true,
      },
      {
        'id': '2865',
        'age': 78,
        'pain': 'Right foot',
        'hasIPG': false,
      },
      {
        'id': '9087',
        'age': 65,
        'pain': 'Right foot, right calf',
        'hasIPG': true,
      },
      {
        'id': '0031',
        'age': 42,
        'pain': 'Left calf, left foot',
        'hasIPG': false,
      },
      {
        'id': '1276',
        'age': 31,
        'pain': 'Left foot',
        'hasIPG': true,
      },
      {
        'id': '3465',
        'age': 28,
        'pain': 'Left calf',
        'hasIPG': false,
      },
      {
        'id': '8765',
        'age': 54,
        'pain': 'Left foot',
        'hasIPG': true,
      },
      {
        'id': '0923',
        'age': 43,
        'pain': 'Right foot, right calf',
        'hasIPG': false,
      },
      {
        'id': '4367',
        'age': 86,
        'pain': 'Right foot',
        'hasIPG': false,
      },
      {
        'id': '3267',
        'age': 43,
        'pain': 'Right calf',
        'hasIPG': true,
      },
    ];

    return Scrollable(
      viewportBuilder: (context, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics:
                NeverScrollableScrollPhysics(), // Disable grid scrolling, use SingleChildScrollView instead
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return PatientCard(
                patientId: patient['id'] as String,
                age: patient['age'] as int,
                painOrigin: patient['pain'] as String,
                hasIPG: patient['hasIPG'] as bool,
              );
            },
          ),
        );
      },
    );
  }
}

class PatientCard extends StatelessWidget {
  final String patientId;
  final int age;
  final String painOrigin;
  final bool hasIPG;

  const PatientCard({
    Key? key,
    required this.patientId,
    required this.age,
    required this.painOrigin,
    required this.hasIPG,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // If the patient doesn't have an IPG, show the pairing popup
          if (!hasIPG) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => PairIPGDialog(
                patientId: patientId,
                age: age,
                painOrigin: painOrigin,
              ),
            );
          } else {
            // Navigate to patient details page
            // For testing purposes:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Patient already has an IPG paired')),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientInfoRow('Patient Clinical Study ID#:', patientId),
              SizedBox(height: 6),
              _buildPatientInfoRow('Age:', '$age y.o.'),
              if (painOrigin.isNotEmpty) ...[
                SizedBox(height: 6),
                _buildPatientInfoRow('Origin of pain:', painOrigin),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF557A8D), // Lighter color for labels
            fontSize: 13, // Smaller font for fitting in card
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Color(0xFF2C5364), // Darker color for values
              fontWeight: FontWeight.w500,
              fontSize: 13, // Smaller font for fitting in card
            ),
            overflow: TextOverflow.ellipsis, // Prevent text overflow
          ),
        ),
      ],
    );
  }
}
