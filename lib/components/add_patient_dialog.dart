import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth.dart';

void showAddPatientDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return _AddPatientDialog();
    },
  );
}

class _AddPatientDialog extends StatefulWidget {
  // ignore: unused_element
  const _AddPatientDialog({super.key});

  @override
  State<_AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<_AddPatientDialog> {
  TextEditingController idController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController indicationController = TextEditingController();
  TextEditingController originController = TextEditingController();
  bool _isButtonEnabled = false;
  String? errorMessage = '';

  @override
  void initState() {
    super.initState();
    idController.addListener(_checkFields);
    emailController.addListener(_checkFields);
    passwordController.addListener(_checkFields);
    ageController.addListener(_checkFields);
    heightController.addListener(_checkFields);
    weightController.addListener(_checkFields);
    indicationController.addListener(_checkFields);
    originController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled = idController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          indicationController.text.isNotEmpty &&
          originController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    idController.dispose();
    emailController.dispose();
    passwordController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    indicationController.dispose();
    originController.dispose();
    super.dispose();
  }

  Future<void> createUser() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = 'Something went wrong';
        debugPrint(e.code);
      });
    }
    await FirebaseFirestore.instance
        .collection('clinicians')
        .doc('C123456')
        .collection('patients')
        .doc(idController.text)
        .set({
      "patientId": idController.text,
      "clinicianId": 'C123456',
      "email": emailController.text,
      "age": int.tryParse(ageController.text) ?? 0,
      "height": int.tryParse(heightController.text) ?? 0,
      "weight": int.tryParse(weightController.text) ?? 0,
      "indication": indicationController.text,
      "originOfPain": originController.text,
      "createdAt": FieldValue.serverTimestamp(), // Firestore timestamp
    });
  }

  void _onCreatePatient() async {
    String email = emailController.text;
    String password = passwordController.text;
    if (!email.contains('@')) {
      setState(() {
        errorMessage = 'Not a valid email';
      });
    } else if (password.length < 6) {
      setState(() {
        errorMessage = 'Password not long enough';
      });
    } else {
      createUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 695,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Create a Patient',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 24),
            Row(children: [
              _buildTextField(
                  context, idController, "Patient Clinical Study ID#"),
              SizedBox(width: 10),
              _buildTextField(context, emailController, "Email"),
            ]),
            SizedBox(height: 20),
            Row(children: [
              _buildTextField(context, passwordController, "New password",
                  isPassword: true),
              SizedBox(width: 10),
              _buildTextField(context, ageController, "Age", isNumber: true),
            ]),
            SizedBox(height: 20),
            Row(children: [
              _buildTextField(context, indicationController, "Indication"),
              SizedBox(width: 10),
              _buildTextField(context, originController, "Origin of pain"),
            ]),
            SizedBox(height: 20),
            Row(children: [
              _buildTextField(context, heightController, "Height (cm)",
                  isNumber: true),
              SizedBox(width: 10),
              _buildTextField(context, weightController, "Weight (kg)",
                  isNumber: true),
            ]),
            SizedBox(height: 60),
            if (errorMessage != '') Text('$errorMessage'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF557A8D),
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFFCCDAE1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isButtonEnabled
                      ? () {
                          _onCreatePatient();
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text("Create a patient"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField(
    BuildContext context, TextEditingController controller, String label,
    {bool isPassword = false, bool isNumber = false}) {
  return Expanded(
    child: Column(children: [
      Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
      const SizedBox(height: 4),
      TextField(
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : [], // Restricts to numbers only
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFE8EDEC))),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
                color: Color(0xFFE8EDEC)), // Border color when not focused
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    ]),
  );
}
