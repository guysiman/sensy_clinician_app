import 'package:flutter/material.dart';

class PairIPGDialog extends StatelessWidget {
  final String patientId;
  final int age;
  final String painOrigin;

  const PairIPGDialog({
    Key? key,
    required this.patientId,
    required this.age,
    required this.painOrigin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10), // Increased vertical padding at top
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Center(
                child: Text(
                  'Pair an IPG',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F7F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Patient Clinical Study ID#:', patientId),
                    SizedBox(height: 8),
                    _buildInfoRow('Age:', '$age y.o.'),
                    SizedBox(height: 8),
                    _buildInfoRow('Origin of pain:', painOrigin),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 36), // Increased bottom padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150, // Decreased button width from 175 to 150
                    height: 44,
                    child: OutlinedButton(
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
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 150, // Decreased button width from 175 to 150
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Initiating IPG pairing process for patient $patientId'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2C5364),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Pair an IPG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF677E88),
            fontSize: 12, // Decreased font size from 13 to 12
          ),
        ),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: Color(0xFF2C5364),
            fontWeight: FontWeight.bold,
            fontSize: 13, // Decreased font size from 14 to 13
          ),
        ),
      ],
    );
  }
}