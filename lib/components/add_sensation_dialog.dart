import 'package:flutter/material.dart';

class AddSensationDialog extends StatefulWidget {
  const AddSensationDialog({Key? key}) : super(key: key);

  @override
  _AddSensationDialogState createState() => _AddSensationDialogState();
}

class _AddSensationDialogState extends State<AddSensationDialog> {
  final List<String> sensations = [
    "Touch",
    "Movement",
    "Temperature",
    "Unpleasant"
  ];

  String? selectedSensation;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      child: Container(
        width: 700,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add sensations",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sensations list with gray box
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Sensations",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: Color(0xFF3A6470),
                                    )),
                            Spacer(),
                            TextButton(
                              onPressed: () =>
                                  setState(() => selectedSensation = null),
                              child: Text("Erase"),
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        ...sensations.map((sensation) => RadioListTile<String>(
                              title: Text(sensation,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Color(0xFF3A6470),
                                      )),
                              value: sensation,
                              groupValue: selectedSensation,
                              onChanged: (value) {
                                setState(() {
                                  selectedSensation = value;
                                });
                              },
                            )),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                // Foot diagram in gray box
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Spacer(),
                            TextButton(onPressed: () {}, child: Text("Grid")),
                            TextButton(onPressed: () {}, child: Text("Erase")),
                          ],
                        ),
                        AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset('assets/foot_diagram.png',
                              fit: BoxFit.contain),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedSensation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF345B63),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: Text("Add sensation"),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Don’t add anything and continue the stimulation"),
            ),
          ],
        ),
      ),
    );
  }
}
