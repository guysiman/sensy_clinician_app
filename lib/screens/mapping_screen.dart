import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../components/add_sensation_dialog.dart';
import '../services/database.dart';

class MappingScreen extends StatefulWidget {
  final String patientId;
  final String ipgSerial;
  final String ipgFirmware;
  final double ipgBattery;

  const MappingScreen({
    Key? key,
    required this.patientId,
    required this.ipgSerial,
    required this.ipgFirmware,
    required this.ipgBattery,
  }) : super(key: key);

  @override
  State<MappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends State<MappingScreen>
    with SingleTickerProviderStateMixin {
  bool isRunning = false;
  bool inRamp = false;
  String currentStage = "min_sensation";
  int currentAmplitude = 10;
  int currentElectrode = 1;

  int ramp = 1; // 1, 2, or 3 time views
  final int totalElectrodes = 30;

  late TabController _tabController;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void toggleStimulation() {
    setState(() {
      isRunning = !isRunning;
      inRamp = true;
    });
  }

  void adjustAmplitude(int amount) {
    setState(() {
      currentAmplitude += amount;
      if (currentAmplitude < 0) currentAmplitude = 0;
    });
  }

  void navigateElectrode(int direction) {
    if (isRunning) return; // Disabled when running

    setState(() {
      currentElectrode += direction;
      if (currentElectrode < 1) currentElectrode = 1;
      if (currentElectrode > totalElectrodes)
        currentElectrode = totalElectrodes;
    });
  }

  void resetElectrode() {
    // Implement reset functionality
  }

  void discardLastSensation() {
    // Implement discard functionality
  }

  void selectRamp(int newRamp) {
    setState(() {
      ramp = newRamp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50), // Reduced height
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Text(
              'Back',
              style: TextStyle(
                color: Color(0xFF2D4F63),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          titleSpacing: 0,
          centerTitle: false,
          flexibleSpace: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8F0F1),
                    border: Border.all(color: Color(0xFF3D6673), width: 1),
                  ),
                  child: Icon(Icons.check, color: Color(0xFF3D6673), size: 14),
                ),
                Container(
                  width: 25,
                  height: 2,
                  color: Color(0xFF3D6673),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3D6673),
                  ),
                  child: Center(
                    child: Text(
                      "2",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 25,
                  height: 2,
                  color: Color(0xFFE8F0F1),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8F0F1),
                  ),
                  child: Center(
                    child: Text(
                      "3",
                      style: TextStyle(
                        color: Color(0xFF3D6673),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Patient ID
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Color(0xFFE8F0F1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Patient: ${widget.patientId}",
                style: TextStyle(
                  color: Color(0xFF3D6673),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey[300]),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab bar - moved to the left side
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 200, // Fixed width for tab bar
              child: TabBar(
                controller: _tabController,
                labelColor: Color(0xFF3D6673),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF3D6673),
                indicatorWeight: 3,
                dividerColor:
                    Colors.transparent, // Remove the permanent grey line
                tabs: [
                  Tab(text: "Mapping"),
                  Tab(text: "Mapped"),
                ],
              ),
            ),
          ),
          Divider(
              height: 1,
              color: Colors.grey[300]), // Add a separate divider below the tabs

          // Main content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Mapping Tab
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Main content area with blue border
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color(0xFF3D6673),
                              width: 2), // Updated to match Figma
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Control buttons row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left side controls - centered in left half
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly, // Changed to spaceEvenly
                                      children: [
                                        // Start/Stop button
                                        ElevatedButton.icon(
                                          onPressed: toggleStimulation,
                                          icon: Icon(
                                            isRunning
                                                ? Icons.stop
                                                : inRamp
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                          label: Text(isRunning
                                              ? "Stop"
                                              : inRamp
                                                  ? "Resume"
                                                  : "Run"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isRunning
                                                ? Colors.red
                                                : Color(0xFF489F32),
                                            foregroundColor: Colors.white,
                                            minimumSize: Size(
                                                240, 50), // Increased width
                                          ),
                                        ),

                                        // Add Sensation button
                                        ElevatedButton.icon(
                                          onPressed: isRunning
                                              ? () async {
                                                  switch (currentStage) {
                                                    case "add_sensation":
                                                      final result =
                                                          await showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AddSensationDialog(),
                                                      );

                                                      if (result != null) {
                                                        Map<String, dynamic>
                                                            sensationData;

                                                        if (result is Map<
                                                            String, dynamic>) {
                                                          sensationData =
                                                              result;
                                                        } else {
                                                          sensationData = {
                                                            'sensation': result,
                                                            'areas': [],
                                                          };
                                                        }

                                                        bool success =
                                                            await _databaseService
                                                                .savePatientSensation(
                                                          patientID:
                                                              widget.patientId,
                                                          sensation:
                                                              sensationData[
                                                                  'sensation'],
                                                          footAreas:
                                                              sensationData[
                                                                  'areas'],
                                                          electrodeID:
                                                              currentElectrode
                                                                  .toString(),
                                                          amplitude:
                                                              currentAmplitude
                                                                  .toDouble(),
                                                        );

                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(success
                                                                ? 'Sensation data saved successfully'
                                                                : 'Failed to save sensation data'),
                                                            backgroundColor:
                                                                success
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                            duration: Duration(
                                                                seconds: 2),
                                                          ),
                                                        );

                                                        if (success) {
                                                          setState(() {
                                                            currentStage =
                                                                "max_sensation";
                                                          });
                                                        }
                                                      } else {
                                                        print(
                                                            "User skipped adding sensations.");
                                                      }
                                                      break;

                                                    case "min_sensation":
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Minimum sensation was recorded successfully'),
                                                          backgroundColor:
                                                              Colors.green,
                                                          duration: Duration(
                                                              seconds: 2),
                                                        ),
                                                      );
                                                      setState(() {
                                                        currentStage =
                                                            "add_sensation";
                                                      });

                                                      break;

                                                    case "max_sensation":
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Ramp was completed successfully'),
                                                          backgroundColor:
                                                              Colors.green,
                                                          duration: Duration(
                                                              seconds: 2),
                                                        ),
                                                      );
                                                      setState(() {
                                                        inRamp = false;
                                                        isRunning = false;
                                                        selectRamp(2);
                                                        currentStage =
                                                            "min_sensation";
                                                      });
                                                      break;

                                                    default:
                                                      print(
                                                          "Unhandled stage: $currentStage");
                                                  }
                                                }
                                              : null,
                                          icon: Icon(Icons.add,
                                              color: Colors.white),
                                          label: Text(
                                            currentStage == "add_sensation"
                                                ? "Add sensation"
                                                : currentStage ==
                                                        "min_sensation"
                                                    ? "Min sensation"
                                                    : "Max sensation",
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFE18700),
                                            foregroundColor: Colors.white,
                                            minimumSize: Size(240, 50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right side - Time selection centered
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildTimeButton(1),
                                          SizedBox(width: 16),
                                          _buildTimeButton(2),
                                          SizedBox(width: 16),
                                          _buildTimeButton(3),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Parameters link and status indicator
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0), // Increased vertical spacing
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        size: 16, color: Colors.grey),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Manage parameters",
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Color(0xFF3D6673),
                                        ),
                                      ),
                                    ),
                                    if (isRunning) ...[
                                      SizedBox(width: 16),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Running",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              SizedBox(height: 12), // Reduced from 16

                              // Amplitude controls and graph
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left side - amplitude controls (takes up approximately 50% of width)
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Current amplitude display - increased size
                                        Container(
                                          width: 120, // Increased from 80
                                          height: 70, // Reduced from 80
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal:
                                                  20), // Reduced padding
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[400]!),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "$currentAmplitude",
                                              style: TextStyle(
                                                fontSize:
                                                    36, // Increased from 24
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF3D6673),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4), // Reduced from 6
                                        Text("μA",
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize:
                                                    14)), // Increased font size

                                        SizedBox(height: 20), // Reduced from 26

                                        // Amplitude adjustment buttons - increased size and spacing
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceEvenly, // More spacing between buttons
                                          children: [
                                            // Big decrement
                                            _buildAmplitudeButton(
                                                Icons.remove,
                                                !isRunning
                                                    ? null
                                                    : currentAmplitude < 10
                                                        ? null
                                                        : () => adjustAmplitude(
                                                            -10),
                                                "[10 μA]"),
                                            // Small decrement
                                            _buildAmplitudeButton(
                                                Icons.remove,
                                                !isRunning
                                                    ? null
                                                    : currentAmplitude == 0
                                                        ? null
                                                        : () =>
                                                            adjustAmplitude(-2),
                                                "[2 μA]"),
                                            // Small increment
                                            _buildAmplitudeButton(
                                                Icons.add,
                                                !isRunning
                                                    ? null
                                                    : () => adjustAmplitude(2),
                                                "[2 μA]"),
                                            // Big increment
                                            _buildAmplitudeButton(
                                                Icons.add,
                                                !isRunning
                                                    ? null
                                                    : () => adjustAmplitude(10),
                                                "[10 μA]"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right side - Graph (takes up approximately 50% of width)
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: 260, // Reduced from 280
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: LineChart(
                                          LineChartData(
                                            gridData: FlGridData(
                                              show: true,
                                              drawHorizontalLine: true,
                                              drawVerticalLine: true,
                                              horizontalInterval: 10,
                                              verticalInterval: 3,
                                            ),
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  interval: 10,
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    return Text(
                                                      value.toInt().toString(),
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 10,
                                                      ),
                                                    );
                                                  },
                                                  reservedSize: 30,
                                                ),
                                                axisNameWidget: Text(
                                                  'Amplitude',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  interval: 3,
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    return Text(
                                                      value.toInt().toString(),
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 10,
                                                      ),
                                                    );
                                                  },
                                                  reservedSize: 20,
                                                ),
                                                axisNameWidget: Text(
                                                  'Time',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              ),
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false),
                                              ),
                                              topTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false),
                                              ),
                                            ),
                                            borderData:
                                                FlBorderData(show: false),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: [
                                                  FlSpot(0, 50),
                                                  FlSpot(3, 60),
                                                  FlSpot(6, 80),
                                                  FlSpot(9, 90),
                                                ],
                                                isCurved: true,
                                                color: Color(0xFF3D6673),
                                                barWidth: 2,
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent,
                                                      barData, index) {
                                                    return FlDotCirclePainter(
                                                      radius: 4,
                                                      color: Color(0xFF3D6673),
                                                      strokeWidth: 0,
                                                    );
                                                  },
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  color: Color(0xFF3D6673)
                                                      .withOpacity(0.2),
                                                ),
                                              ),
                                            ],
                                            minX: 0,
                                            maxX: 9,
                                            minY: 40,
                                            maxY: 100,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16),

                              // Electrode navigation
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left/Right electrode navigation - centered within its space
                                  _buildElectrodeNavigation(),
                                  // Action buttons - centered within its space
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Reset electrode
                                          OutlinedButton.icon(
                                            onPressed: resetElectrode,
                                            icon: Icon(Icons.refresh),
                                            label: Text("Reset electrode"),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  Color(0xFF3D6673),
                                              side: BorderSide(
                                                  color: Color(0xFF3D6673)),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                            ),
                                          ),

                                          SizedBox(width: 16),

                                          // Discard last sensation
                                          OutlinedButton.icon(
                                            onPressed: discardLastSensation,
                                            icon: Icon(Icons.delete_outline),
                                            label:
                                                Text("Discard last sensation"),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  Color(0xFF3D6673),
                                              side: BorderSide(
                                                  color: Color(0xFF3D6673)),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // IPG Info and Finish button - Removed padding
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
                                      style:
                                          TextStyle(color: Colors.grey[700])),
                                  SizedBox(width: 24),
                                  Text(
                                    "IPG FW version: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700]),
                                  ),
                                  Text(widget.ipgFirmware,
                                      style:
                                          TextStyle(color: Colors.grey[700])),
                                  SizedBox(width: 24),
                                  Text(
                                    "IPG battery status: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700]),
                                  ),
                                  Text("${widget.ipgBattery.toInt()}%",
                                      style:
                                          TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ),

                            // Finish button
                            ElevatedButton(
                              onPressed:
                                  null, // Disabled until mapping is completed
                              child: Text("Finish"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF3D6673),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[400],
                                disabledForegroundColor: Colors.white,
                                minimumSize: Size(120, 48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Mapped Tab (placeholder)
                Center(child: Text("Mapped content will go here")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(int time) {
    final bool isSelected = ramp == time;

    return InkWell(
      onTap: () => selectRamp(time),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Color(0xFF3D6673) : Colors.grey[300],
              border: Border.all(
                color: isSelected ? Color(0xFF3D6673) : Colors.grey[400]!,
                width: 1,
              ),
            ),
          ),
          SizedBox(width: 4),
          Text(
            "$time time",
            style: TextStyle(
              color: isSelected ? Color(0xFF3D6673) : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmplitudeButton(
      IconData icon, VoidCallback? onPressed, String label) {
    // Check if this is a big amplitude change button (10μA)
    final bool isBigChange = label.contains("10");

    return Column(
      children: [
        Material(
          color: onPressed == null ? Colors.grey : Color(0xFF3D6673),
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: isBigChange
                  ? 85
                  : 75, // Bigger width for big amplitude change
              height: isBigChange
                  ? 65
                  : 55, // Bigger height for big amplitude change
              child: Icon(icon,
                  color: Colors.white,
                  size: isBigChange
                      ? 42
                      : 36 // Bigger icon for big amplitude change
                  ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildElectrodeNavigation() {
    return Expanded(
      flex: 1,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left button
            Material(
              color: isRunning ? Colors.grey[300] : Color(0xFFD9E5E7),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: isRunning || currentElectrode == 1
                    ? null
                    : () => navigateElectrode(-1),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.chevron_left,
                    color: isRunning ? Colors.grey : Color(0xFF3D6673),
                  ),
                ),
              ),
            ),

            // Electrode indicator - take up full width
            Expanded(
              child: Container(
                height: 40,
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    "Electrode $currentElectrode / $totalElectrodes",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF3D6673),
                    ),
                  ),
                ),
              ),
            ),

            // Right button
            Material(
              color: isRunning ? Colors.grey[300] : Color(0xFFD9E5E7),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: isRunning || currentElectrode == totalElectrodes
                    ? null
                    : () => navigateElectrode(1),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.chevron_right,
                    color: isRunning ? Colors.grey : Color(0xFF3D6673),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
