import 'package:flutter/material.dart';

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

class FootSelectionWidget extends StatefulWidget {
  final ValueChanged<List<String>> onSelectionChanged;
  final List<String> initialSelection;

  const FootSelectionWidget({
    Key? key,
    required this.onSelectionChanged,
    this.initialSelection = const [],
  }) : super(key: key);

  @override
  State<FootSelectionWidget> createState() => _FootSelectionWidgetState();
}

class _FootSelectionWidgetState extends State<FootSelectionWidget> {
  late List<String> _selectedAreas;

  // Original foot area coordinates
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
    _selectedAreas = List<String>.from(widget.initialSelection);
  }

  void clearSelection() {
    setState(() {
      _selectedAreas.clear();
    });
    widget.onSelectionChanged(_selectedAreas);
  }

  void _onAreaTapped(String areaId) {
    setState(() {
      if (_selectedAreas.contains(areaId)) {
        _selectedAreas.remove(areaId);
      } else {
        _selectedAreas.add(areaId);
      }
    });
    widget.onSelectionChanged(_selectedAreas);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final actualWidth = constraints.maxWidth;
        final actualHeight = constraints.maxHeight;

        final scaleX = actualWidth / 343;
        final scaleY = actualHeight / 364;

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/foot_diagram.png',
              fit: BoxFit.contain,
            ),
            ..._footAreas.map((area) {
              final double left = area.left * scaleX;
              final double top = area.top * scaleY;
              final double w = area.width * scaleX;
              final double h = area.height * scaleY;

              return Positioned(
                left: left,
                top: top,
                width: w,
                height: h,
                child: GestureDetector(
                  onTap: () => _onAreaTapped(area.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedAreas.contains(area.id)
                          ? Colors.blue.withOpacity(0.4)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

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
  // Add these state variables
  final GlobalKey<_FootSelectionWidgetState> _footKey = GlobalKey<_FootSelectionWidgetState>();
  List<String> _selectedAreas = [];

  void clearFootSelection() {
    setState(() {
      _selectedAreas = [];
    });
    _footKey.currentState?.clearSelection();
  }

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
                // Foot diagram in gray box - MODIFIED PART
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
                            TextButton(
                              onPressed: _selectedAreas.isNotEmpty
                                  ? () => clearFootSelection()
                                  : null,
                              child: Text("Erase"),
                            ),
                          ],
                        ),
                        // Dynamic sized foot diagram with selection functionality
                        AspectRatio(
                          aspectRatio: 1,
                          child: FootSelectionWidget(
                            initialSelection: _selectedAreas,
                            key: _footKey,
                            onSelectionChanged: (List<String> newSelection) {
                              setState(() {
                                _selectedAreas = newSelection;
                              });
                            },
                          ),
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
                  onPressed: selectedSensation != null
                      ? () {
                    // Return both sensation and selected areas
                    Navigator.pop(context, {
                      'sensation': selectedSensation,
                      'areas': _selectedAreas,
                    });
                  }
                      : null,
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
              child: Text("Don't add anything and continue the stimulation"),
            ),
          ],
        ),
      ),
    );
  }
}