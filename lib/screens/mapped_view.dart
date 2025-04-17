import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A simple data class for each tappable foot area.
class _FootArea {
  final String id;
  final double left;
  final double top;
  final double width;
  final double height;

  const _FootArea({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class MappedView extends StatefulWidget {
  final String patientId;
  final String ipgSerial;
  final String ipgFirmware;
  final double ipgBattery;

  const MappedView({
    Key? key,
    required this.patientId,
    required this.ipgSerial,
    required this.ipgFirmware,
    required this.ipgBattery,
  }) : super(key: key);

  @override
  State<MappedView> createState() => _MappedViewState();
}

class _MappedViewState extends State<MappedView> {
  Set<String> mappedAreas = {};
  Map<String, String> areaToSensation = {};
  bool isLoading = true;
  String? errorMessage;

  // Define foot areas - same as in FootSelectionWidget
  final List<_FootArea> _footAreas = const [
    _FootArea(id: 'F0', left: 127, top: 60, width: 24, height: 13),
    _FootArea(id: 'F1', left: 127, top: 75, width: 24, height: 13),
    //
    _FootArea(id: 'F2', left: 157, top: 65, width: 12, height: 10),
    _FootArea(id: 'F3', left: 173, top: 71, width: 12, height: 9),
    _FootArea(id: 'F4', left: 185, top: 85, width: 12, height: 9),
    _FootArea(id: 'F5', left: 202, top: 97, width: 12, height: 9),
    //
    _FootArea(id: 'F6', left: 128, top: 104, width: 24, height: 33),
    _FootArea(id: 'F7', left: 156, top: 104, width: 26, height: 33),
    _FootArea(id: 'F8', left: 187, top: 119, width: 26, height: 20),
    //
    _FootArea(id: 'F9', left: 156, top: 143, width: 26, height: 82),
    _FootArea(id: 'F10', left: 185, top: 143, width: 26, height: 27),
    _FootArea(id: 'F11', left: 185, top: 172, width: 20, height: 27),
    _FootArea(id: 'F12', left: 185, top: 201, width: 20, height: 27),
    //
    _FootArea(id: 'F13', left: 154, top: 235, width: 26, height: 30),
    _FootArea(id: 'F14', left: 154, top: 268, width: 26, height: 35),
    _FootArea(id: 'F15', left: 185, top: 250, width: 18, height: 40),
  ];

  @override
  void initState() {
    super.initState();
    _loadMappedAreas();
  }

  // Load mapped areas from Firestore
  Future<void> _loadMappedAreas() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Reference to the sensations collection under the patient's document
      CollectionReference sensationsCollection =
      FirebaseFirestore.instance
          .collection('patient_mapping')
          .doc(widget.patientId)
          .collection('sensations');

      // Get all sensation documents
      QuerySnapshot snapshot = await sensationsCollection.get();

      // Clear and prepare to store unique foot areas
      Set<String> uniqueAreas = {};
      Map<String, String> areaToSensationMap = {};

      // Collect all foot areas from all sensations
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> footAreasList = data['footAreas'] ?? [];
        String sensation = data['sensation'] ?? 'Unknown';

        for (var area in footAreasList) {
          String areaId = area.toString();
          uniqueAreas.add(areaId);

          // Map each area to its sensation type
          // In case of multiple sensations for same area, the last one wins
          areaToSensationMap[areaId] = sensation;
        }
      }

      setState(() {
        mappedAreas = uniqueAreas;
        areaToSensation = areaToSensationMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading mapped areas: $e';
        isLoading = false;
      });
      print('Error loading mapped areas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Main content area with blue border
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF3D6673), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: isLoading
                              ? CircularProgressIndicator(color: Color(0xFF3D6673))
                              : errorMessage != null
                              ? Text(errorMessage!, style: TextStyle(color: Colors.red))
                              : mappedAreas.isEmpty
                              ? Text('No mapped areas found for this patient',
                              style: TextStyle(color: Colors.grey[600]))
                              : AspectRatio(
                            aspectRatio: 1, // Keep foot diagram in a square aspect ratio
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Foot background image
                                    Positioned.fill(
                                      child: Image.asset(
                                        'assets/foot_diagram.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),

                                    // Use FractionallySizedBox for more precise positioning relative to the image
                                    for (var area in _footAreas)
                                      if (mappedAreas.contains(area.id))
                                        Builder(
                                          builder: (context) {
                                            final String? sensationType = areaToSensation[area.id];

                                            // Determine color based on sensation type
                                            Color areaColor = Colors.blue.withOpacity(0.4); // Default for Movement

                                            if (sensationType != null) {
                                              switch (sensationType) {
                                                case 'Touch':
                                                  areaColor = Colors.green.withOpacity(0.4);
                                                  break;
                                                case 'Movement':
                                                  areaColor = Colors.blue.withOpacity(0.4);
                                                  break;
                                                case 'Temperature':
                                                  areaColor = Colors.red.withOpacity(0.4);
                                                  break;
                                                case 'Unpleasant':
                                                  areaColor = Colors.purple.withOpacity(0.4);
                                                  break;
                                                default:
                                                  areaColor = Colors.blue.withOpacity(0.4);
                                              }
                                            }

                                            // Convert fixed pixel positions to relative positions in the 0-1 range
                                            final relLeft = area.left / 343;
                                            final relTop = area.top / 364;
                                            final relWidth = area.width / 343;
                                            final relHeight = area.height / 364;

                                            return Positioned(
                                              left: constraints.maxWidth * relLeft,
                                              top: constraints.maxHeight * relTop,
                                              width: constraints.maxWidth * relWidth,
                                              height: constraints.maxHeight * relHeight,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: areaColor,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Legend for sensation types
                    if (!isLoading && errorMessage == null && mappedAreas.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem('Touch', Colors.green),
                            SizedBox(width: 16),
                            _buildLegendItem('Movement', Colors.blue),
                            SizedBox(width: 16),
                            _buildLegendItem('Temperature', Colors.red),
                            SizedBox(width: 16),
                            _buildLegendItem('Unpleasant', Colors.purple),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // IPG Info and Finish button
          Container(
            padding: EdgeInsets.only(top: 16),
            child: Row(
              children: [
                // IPG information
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "IPG serial number: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700]),
                      ),
                      Text(widget.ipgSerial,
                          style: TextStyle(color: Colors.grey[700])),
                      SizedBox(width: 24),
                      Text(
                        "IPG FW version: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700]),
                      ),
                      Text(widget.ipgFirmware,
                          style: TextStyle(color: Colors.grey[700])),
                      SizedBox(width: 24),
                      Text(
                        "IPG battery status: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700]),
                      ),
                      Text("${widget.ipgBattery.toInt()}%",
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),

                // Finish button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Finish"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3D6673),
                    foregroundColor: Colors.white,
                    minimumSize: Size(120, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build legend items
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.4),
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF3D6673),
          ),
        ),
      ],
    );
  }
}