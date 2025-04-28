import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

import '../components/add_sensation_dialog.dart';
import '../services/database.dart';
import './mapped_view.dart'; // Import our new mapped view

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
  bool ramping = false;
  bool hasStarted = false;
  double currentAmplitude = 0;
  double storedCurrentAmplitude = 0;
  int currentElectrode = 1;
  int ramp = 1; // 1, 2, or 3 time views
  final int totalElectrodes = 30;

  late TabController _tabController;

  final DatabaseService _databaseService = DatabaseService();

  final double finalAmplitude = 600.0;
  final List<double> increments = [1.33, 3.33, 3.33, 2.22, 4, 2.67];
  final List<double> ampMarks = [50, 100, 150, 250, 400, 600];
  final Duration interval = Duration(milliseconds: 100);

  Timer? timer;
  List<FlSpot> chartData = [FlSpot(0, 0)];
  int step = 0;
  bool running = false;
  bool notStarted = true;
  bool paused = false;
  bool clinicianMode = false;

  bool minSensationRecorded = false;
  bool meanSensationRecorded = false;
  double minSensationValue = 0.0;
  double meanSensationValue = 0.0;
  double maxSensationValue = 0.0;

  Map<String, dynamic> sensationData = {
    'sensation': 'None',
    'areas': [],
  };

  void startRampUp() {
    setState(() {
      chartData = [FlSpot(0, 0)];
    });

    timer = Timer.periodic(interval, (timer) {
      if (!running) {
        timer.cancel();
        return;
      }
      setState(() {
        double increment = 0.0;
        for (int i = 0; i < increments.length; i++) {
          if (currentAmplitude < ampMarks[i]) {
            increment = increments[i];
            break;
          }
        }
        currentAmplitude =
            (currentAmplitude + increment).clamp(0, finalAmplitude);
        step++;
        chartData.add(FlSpot(getTime(currentAmplitude), currentAmplitude));
        if (currentAmplitude >= finalAmplitude) {
          recordMaxSensation();
          resetElectrode();
          incrementRamp();
          timer.cancel();
        }
      });
    });
  }

  List<FlSpot> getSpots(double amplitude) {
    List<FlSpot> result = [];
    result.add(FlSpot(0, 0));
    if (amplitude > 50) {
      result.add(FlSpot(3.75, 50));
    }
    if (amplitude > 100) {
      result.add(FlSpot(5.25, 100));
    }
    if (amplitude > 150) {
      result.add(FlSpot(6.75, 150));
    }
    if (amplitude > 250) {
      result.add(FlSpot(11.25, 250));
    }
    if (amplitude > 400) {
      result.add(FlSpot(15, 400));
    }
    result.add(FlSpot(getTime(amplitude), amplitude));
    return result;
  }

  Future<void> recordResults() async {
    bool success = await _databaseService.savePatientSensation(
      a_1: minSensationValue,
      a_mean: meanSensationValue,
      a_2: maxSensationValue,
      patientID: widget.patientId,
      sensation: sensationData['sensation'],
      footAreas: sensationData['areas'],
      electrodeID: currentElectrode.toString(),
      ramp: ramp,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Data saved successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));

      // Show success message if needed
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save sensation data'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
  }

  void newElectrode() {
    stopStimulation();
    setState(() {
      minSensationRecorded = false;
      meanSensationRecorded = false;
    });
  }

  double getTime(double amplitude) {
    double time = 0.0;
    if (amplitude > 400) {
      time = 15 + (amplitude - 400) / (26.6);
    } else if (amplitude > 250) {
      time = 11.25 + (amplitude - 250) / (40);
    } else if (amplitude > 150) {
      time = 6.75 + (amplitude - 150) / (22.2);
    } else if (amplitude > 100) {
      time = 5.25 + (amplitude - 100) / (33.3);
    } else if (amplitude > 50) {
      time = 3.75 + (amplitude - 50) / (33.3);
    } else {
      time = 0 + (amplitude) / (13.3);
    }
    return time;
  }

  void stopStimulation() {
    timer?.cancel();
    setState(() {
      setNotStarted();
      currentAmplitude = 0;
      storedCurrentAmplitude = 0;
      step = 0;
      ramping = false;
    });
  }

  void recordMinSensation() {
    setState(() {
      minSensationValue = currentAmplitude;
      minSensationRecorded = true;
    });
  }

  void recordMeanSensation() {
    setState(() {
      meanSensationRecorded = true;
      meanSensationValue = currentAmplitude;
    });
  }

  void recordMaxSensation() {
    setState(() {
      maxSensationValue = currentAmplitude;
    });
  }

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
      if (notStarted) {
        setRunning();
      } else if (running) {
        setPaused();
      } else if (paused) {
        setRunning();
      } else if (clinicianMode) {
        setPaused();
      }
    });
  }

  void storeCurrentAmplitude() {
    setState(() {
      storedCurrentAmplitude = currentAmplitude;
    });
  }

  void loadCurrentAmplitude() {
    setState(() {
      currentAmplitude = storedCurrentAmplitude;
    });
  }

  void exitCustom() {
    loadCurrentAmplitude();
    toggleStimulation();
  }

  void setRunning() {
    setState(() {
      running = true;
      notStarted = false;
      paused = false;
      clinicianMode = false;
    });
    startRampUp();
  }

  void setPaused() {
    storeCurrentAmplitude();
    setState(() {
      running = false;
      notStarted = false;
      paused = true;
      clinicianMode = false;
    });
  }

  void setNotStarted() {
    setState(() {
      running = false;
      notStarted = true;
      paused = false;
      clinicianMode = false;
    });
  }

  void setClinician() {
    if (clinicianMode) return;
    storeCurrentAmplitude();
    setState(() {
      storedCurrentAmplitude = currentAmplitude;
      running = false;
      notStarted = false;
      paused = false;
      clinicianMode = true;
    });
  }

  void adjustAmplitude(int amount) {
    setClinician();
    setState(() {
      currentAmplitude += amount;
      if (currentAmplitude < 0) currentAmplitude = 0;
    });
  }

  void incrementRamp() {
    setState(() {
      if (ramp < 3) {
        ramp += 1;
      }
    });
  }

  void navigateElectrode(int direction) {
    if (running) return; // Disabled when running
    newElectrode();
    setState(() {
      currentElectrode += direction;
      if (currentElectrode < 1) currentElectrode = 1;
      if (currentElectrode > totalElectrodes)
        currentElectrode = totalElectrodes;
    });
  }

  void resetElectrode() {
    setState(() {
      ramp = 1;
      newElectrode();
    });
  }

  void discardLastSensation() {
    setState(() {
      if (meanSensationRecorded) {
        meanSensationRecorded = false;
      } else if (minSensationRecorded) {
        minSensationRecorded = false;
      }
    });
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
                                          onPressed: running
                                              ? toggleStimulation
                                              : paused
                                                  ? toggleStimulation
                                                  : notStarted
                                                      ? toggleStimulation
                                                      : clinicianMode
                                                          ? exitCustom
                                                          : exitCustom,
                                          icon: Icon(
                                            running
                                                ? Icons.pause
                                                : paused
                                                    ? Icons.play_arrow
                                                    : notStarted
                                                        ? Icons.play_arrow
                                                        : clinicianMode
                                                            ? Icons.stop
                                                            : Icons.stop,
                                            color: Colors.white,
                                          ),
                                          label: Text(running
                                              ? "Pause"
                                              : paused
                                                  ? "Resume"
                                                  : notStarted
                                                      ? "Run"
                                                      : clinicianMode
                                                          ? "Exit Custom"
                                                          : "Exit Custom"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: running
                                                ? Colors.orange
                                                : paused
                                                    ? Color(0xFF489F32)
                                                    : notStarted
                                                        ? Color(0xFF489F32)
                                                        : Color.fromARGB(
                                                            255, 255, 89, 0),
                                            foregroundColor: Colors.white,
                                            minimumSize: Size(
                                                240, 50), // Increased width
                                          ),
                                        ),

                                        // Add Sensation button
                                        ElevatedButton.icon(
                                          onPressed: !notStarted
                                              ? !minSensationRecorded
                                                  ? () async {
                                                      setPaused();
                                                      recordMinSensation();
                                                    }
                                                  : !meanSensationRecorded
                                                      ? () async {
                                                          setPaused();
                                                          final result =
                                                              await showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                AddSensationDialog(),
                                                          );

                                                          if (result != null) {
                                                            // Extract data from result
                                                            if (result is Map<
                                                                String,
                                                                dynamic>) {
                                                              sensationData =
                                                                  result;
                                                            } else {
                                                              // Handle the case where only sensation string is returned (backward compatibility)
                                                              sensationData = {
                                                                'sensation':
                                                                    result,
                                                                'areas': [],
                                                              };
                                                            }

                                                            // Save the data to Firebase

                                                            recordMeanSensation();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                              content: Text(
                                                                  'Data saved successfully'),
                                                              backgroundColor:
                                                                  Colors.green,
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                            ));
                                                          } else {
                                                            print(
                                                                "User skipped adding sensations.");
                                                          }
                                                        }
                                                      : () async {
                                                          setPaused();
                                                          recordMaxSensation();
                                                          recordResults();
                                                          incrementRamp();
                                                          navigateElectrode(1);
                                                        }
                                              : null,
                                          icon: Icon(Icons.add,
                                              color: Colors.white),
                                          label: Text(!minSensationRecorded
                                              ? "Min sensation"
                                              : !meanSensationRecorded
                                                  ? "Mean sensation"
                                                  : "Max sensation"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF3D6673),
                                            foregroundColor: Colors.white,
                                            minimumSize: Size(
                                                240, 50), // Increased width
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
                                    if (running) ...[
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
                                          width: 120,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[400]!),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${currentAmplitude.toInt()}",
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
                                                () => adjustAmplitude(-10),
                                                "[10 μA]",
                                                true),
                                            // Small decrement
                                            _buildAmplitudeButton(
                                                Icons.remove,
                                                () => adjustAmplitude(-2),
                                                "[2 μA]",
                                                true),
                                            // Small increment
                                            _buildAmplitudeButton(
                                                Icons.add,
                                                () => adjustAmplitude(2),
                                                "[2 μA]",
                                                false),
                                            // Big increment
                                            _buildAmplitudeButton(
                                                Icons.add,
                                                () => adjustAmplitude(10),
                                                "[10 μA]",
                                                false),
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
                                              horizontalInterval: 100,
                                              verticalInterval: 5,
                                            ),
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  interval: 100,
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
                                                  interval: 5,
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
                                              // Highlighted ramp-up area
                                              LineChartBarData(
                                                spots: clinicianMode
                                                    ? getSpots(
                                                        storedCurrentAmplitude)
                                                    : getSpots(
                                                        currentAmplitude),
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
                                                      .withOpacity(
                                                          0.5), // More emphasized shade
                                                ),
                                              ),

                                              // Full line, lightly shaded
                                              LineChartBarData(
                                                spots: [
                                                  FlSpot(0, 0),
                                                  FlSpot(3.75, 50),
                                                  FlSpot(5.25, 100),
                                                  FlSpot(6.75, 150),
                                                  FlSpot(11.25, 250),
                                                  FlSpot(15, 400),
                                                  FlSpot(22.5, 600)
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
                                                      .withOpacity(
                                                          0.2), // Less emphasized shade
                                                ),
                                              ),
                                            ],
                                            minX: 0,
                                            maxX: 24,
                                            minY: 0,
                                            maxY: 700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16), // Reduced from 24

                              // Electrode navigation
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left/Right electrode navigation - centered within its space
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Left button
                                          Material(
                                            color: !notStarted
                                                ? Colors.grey[300]
                                                : Color(0xFFD9E5E7),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: InkWell(
                                              onTap: !notStarted
                                                  ? null
                                                  : () => navigateElectrode(-1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                child: Icon(
                                                  Icons.chevron_left,
                                                  color: !notStarted
                                                      ? Colors.grey
                                                      : Color(0xFF3D6673),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Electrode indicator - take up full width
                                          Expanded(
                                            child: Container(
                                              height: 40,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey[300]!),
                                                borderRadius:
                                                    BorderRadius.circular(4),
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
                                            color: !notStarted
                                                ? Colors.grey[300]
                                                : Color(0xFFD9E5E7),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: InkWell(
                                              onTap: !notStarted
                                                  ? null
                                                  : () => navigateElectrode(1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                child: Icon(
                                                  Icons.chevron_right,
                                                  color: !notStarted
                                                      ? Colors.grey
                                                      : Color(0xFF3D6673),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Action buttons - centered within its space
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: stopStimulation,
                                            icon: Icon(Icons.stop),
                                            label: Text("Stop"),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              iconColor: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              backgroundColor: Color.fromARGB(
                                                  199, 255, 0, 0),
                                              side: BorderSide(
                                                  color: Color.fromARGB(
                                                      0, 255, 255, 255)),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                            ),
                                          ),

                                          SizedBox(width: 16),
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

                // Mapped Tab with the Foot mapping view
                MappedView(
                  patientId: widget.patientId,
                  ipgSerial: widget.ipgSerial,
                  ipgFirmware: widget.ipgFirmware,
                  ipgBattery: widget.ipgBattery,
                ),
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
      IconData icon, VoidCallback onPressed, String label, bool isDecrement) {
    // Check if this is a big amplitude change button (10μA)
    final bool isBigChange = label.contains("10");

    return Column(
      children: [
        Material(
          color: isDecrement && currentAmplitude == 0
              ? Color(0xFF3D6673).withOpacity(0.25)
              : Color(0xFF3D6673),
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
}
