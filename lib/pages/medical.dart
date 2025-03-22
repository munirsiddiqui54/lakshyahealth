import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this package to pubspec.yaml

class HealthRecordsWithAnalysis extends StatefulWidget {
  final String hid; // Health ID passed as prop

  const HealthRecordsWithAnalysis({Key? key, required this.hid})
      : super(key: key);

  @override
  _HealthRecordsWithAnalysisState createState() =>
      _HealthRecordsWithAnalysisState();
}

class _HealthRecordsWithAnalysisState extends State<HealthRecordsWithAnalysis>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> patientRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchPatientRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchPatientRecords() async {
    try {
      final snapshot =
          await _database.child('user/${widget.hid}/patientRecords').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

        List<Map<String, dynamic>> records = [];
        values.forEach((key, value) {
          if (value is Map) {
            Map<String, dynamic> record =
                Map<String, dynamic>.from(value as Map);
            record['id'] = key;
            records.add(record);
          }
        });

        // Sort records by appointment date (newest first)
        records.sort((a, b) {
          final dateA = a['appointmentDate'] as String? ?? '';
          final dateB = b['appointmentDate'] as String? ?? '';
          return dateB.compareTo(dateA);
        });

        setState(() {
          patientRecords = records;
          isLoading = false;
        });
      } else {
        setState(() {
          patientRecords = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading records: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Health Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              text: 'Health Records',
              icon: Icon(Icons.medical_information),
            ),
            Tab(
              text: 'Analysis',
              icon: Icon(Icons.analytics),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : TabBarView(
              controller: _tabController,
              children: [
                // Health Records Tab
                patientRecords.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: patientRecords.length,
                        itemBuilder: (context, index) {
                          final record = patientRecords[index];
                          return RecordCard(record: record);
                        },
                      ),
                // Analysis Tab
                patientRecords.isEmpty
                    ? _buildEmptyState()
                    : AnalysisTab(records: patientRecords),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_information_outlined,
              size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No health records found',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

// This stays the same as in your original code
class RecordCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const RecordCard({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordDetailsPage(record: record),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    'Appointment: ${record['appointmentDate'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.person, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    'Doctor: ${record['doctorname'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.medical_services, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Diagnosis: ${record['diagnosis'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.medication, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    'Prescription: ${record['prescription'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green[700],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecordDetailsPage(record: record),
                      ),
                    );
                  },
                  icon: const Text('Learn more'),
                  label: const Icon(Icons.arrow_forward),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// RecordDetailsPage stays the same as in your original code
class RecordDetailsPage extends StatelessWidget {
  final Map<String, dynamic> record;

  const RecordDetailsPage({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Health Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointment Date: ${record['appointmentDate'] ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Doctor: ${record['doctorname'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Diagnosis: ${record['diagnosis'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prescription: ${record['prescription'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Vital Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildVitalCard(
                    context,
                    icon: Icons.monitor_heart_outlined,
                    title: 'Blood Pressure',
                    value: '${record['bp'] ?? 'N/A'} mmHg',
                    color: Colors.red[100]!,
                    iconColor: Colors.red,
                  ),
                  _buildVitalCard(
                    context,
                    icon: Icons.favorite_outline,
                    title: 'Heart Rate',
                    value: '${record['heartRate'] ?? 'N/A'} bpm',
                    color: Colors.purple[100]!,
                    iconColor: Colors.purple,
                  ),
                  _buildVitalCard(
                    context,
                    icon: Icons.water_drop_outlined,
                    title: 'Sugar Level',
                    value: '${record['sugarLevel'] ?? 'N/A'} mg/dL',
                    color: Colors.blue[100]!,
                    iconColor: Colors.blue,
                  ),
                  _buildVitalCard(
                    context,
                    icon: Icons.line_weight,
                    title: 'Weight',
                    value: '${record['weight'] ?? 'N/A'} kg',
                    color: Colors.green[100]!,
                    iconColor: Colors.green[700]!,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// New Analysis Tab
class AnalysisTab extends StatelessWidget {
  final List<Map<String, dynamic>> records;

  const AnalysisTab({Key? key, required this.records}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context),
          const SizedBox(height: 24),
          _buildBPTrendCard(context),
          const SizedBox(height: 24),
          _buildHeartRateTrendCard(context),
          const SizedBox(height: 24),
          _buildSugarLevelTrendCard(context),
          const SizedBox(height: 24),
          _buildWeightTrendCard(context),
          const SizedBox(height: 24),
          _buildVisitFrequencyCard(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    // Calculate some basic statistics
    int totalVisits = records.length;

    // Calculate average BP
    List<double> bpValues = [];
    for (var record in records) {
      if (record['bp'] != null) {
        try {
          double bp = double.parse(
              record['bp'].toString().replaceAll(RegExp(r'[^\d.]'), ''));
          bpValues.add(bp);
        } catch (e) {
          // Skip invalid values
        }
      }
    }

    double avgBP = bpValues.isNotEmpty
        ? bpValues.reduce((a, b) => a + b) / bpValues.length
        : 0;

    // Calculate average heart rate
    List<double> hrValues = [];
    for (var record in records) {
      if (record['heartRate'] != null) {
        try {
          double hr = double.parse(
              record['heartRate'].toString().replaceAll(RegExp(r'[^\d.]'), ''));
          hrValues.add(hr);
        } catch (e) {
          // Skip invalid values
        }
      }
    }

    double avgHR = hrValues.isNotEmpty
        ? hrValues.reduce((a, b) => a + b) / hrValues.length
        : 0;

    // Get latest prescription
    String latestPrescription =
        records.isNotEmpty ? records[0]['prescription'] ?? 'None' : 'None';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              icon: Icons.calendar_month,
              title: 'Total Visits',
              value: totalVisits.toString(),
              color: Colors.indigo,
            ),
            _buildSummaryItem(
              context,
              icon: Icons.monitor_heart,
              title: 'Average Blood Pressure',
              value: '${avgBP.toStringAsFixed(1)} mmHg',
              color: Colors.red,
            ),
            _buildSummaryItem(
              context,
              icon: Icons.favorite,
              title: 'Average Heart Rate',
              value: '${avgHR.toStringAsFixed(1)} bpm',
              color: Colors.purple,
            ),
            _buildSummaryItem(
              context,
              icon: Icons.medication,
              title: 'Current Medication',
              value: latestPrescription,
              color: Colors.green[700]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBPTrendCard(BuildContext context) {
    // Prepare data for the chart
    final bpData = _prepareChartData(
      valueKey: 'bp',
      records: records.reversed.toList(), // To show oldest to newest
    );

    return _buildTrendCard(
      context,
      title: 'Blood Pressure Trend',
      data: bpData,
      color: Colors.red,
      yAxisTitle: 'mmHg',
    );
  }

  Widget _buildHeartRateTrendCard(BuildContext context) {
    // Prepare data for the chart
    final hrData = _prepareChartData(
      valueKey: 'heartRate',
      records: records.reversed.toList(),
    );

    return _buildTrendCard(
      context,
      title: 'Heart Rate Trend',
      data: hrData,
      color: Colors.purple,
      yAxisTitle: 'bpm',
    );
  }

  Widget _buildSugarLevelTrendCard(BuildContext context) {
    // Prepare data for the chart
    final sugarData = _prepareChartData(
      valueKey: 'sugarLevel',
      records: records.reversed.toList(),
    );

    return _buildTrendCard(
      context,
      title: 'Sugar Level Trend',
      data: sugarData,
      color: Colors.blue,
      yAxisTitle: 'mg/dL',
    );
  }

  Widget _buildWeightTrendCard(BuildContext context) {
    // Prepare data for the chart
    final weightData = _prepareChartData(
      valueKey: 'weight',
      records: records.reversed.toList(),
    );

    return _buildTrendCard(
      context,
      title: 'Weight Trend',
      data: weightData,
      color: Colors.green[700]!,
      yAxisTitle: 'kg',
    );
  }

  Widget _buildVisitFrequencyCard(BuildContext context) {
    // Group visits by month
    Map<String, int> visitsByMonth = {};

    for (var record in records) {
      if (record['appointmentDate'] != null) {
        try {
          DateTime date = DateTime.parse(record['appointmentDate']);
          String monthYear =
              '${date.year}-${date.month.toString().padLeft(2, '0')}';
          visitsByMonth[monthYear] = (visitsByMonth[monthYear] ?? 0) + 1;
        } catch (e) {
          // Skip invalid dates
        }
      }
    }

    // Sort chronologically
    var sortedMonths = visitsByMonth.keys.toList()..sort();
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < sortedMonths.length; i++) {
      String month = sortedMonths[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: visitsByMonth[month]!.toDouble(),
              color: Colors.indigo,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visit Frequency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: barGroups.isEmpty
                  ? const Center(child: Text('Not enough data'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            // tooltipBgColor: Colors.indigo.withOpacity(0.8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${sortedMonths[group.x]}\n${rod.toY.toInt()} visits',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < sortedMonths.length) {
                                  final parts =
                                      sortedMonths[value.toInt()].split('-');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${parts[1]}/${parts[0]}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value == value.toInt() && value >= 0) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(
    BuildContext context, {
    required String title,
    required List<FlSpot> data,
    required Color color,
    required String yAxisTitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              yAxisTitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: data.length < 2
                  ? const Center(
                      child: Text('Not enough data for trend analysis'))
                  : LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                              // tooltipBgColor: color.withOpacity(0.8),
                              ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 == 0 &&
                                    value >= 0 &&
                                    value < records.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[400]!),
                            left: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        minX: 0,
                        maxX: data.length.toDouble() - 1,
                        minY: 0,
                        lineBarsData: [
                          LineChartBarData(
                            spots: data,
                            isCurved: true,
                            color: color,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: color.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _prepareChartData({
    required String valueKey,
    required List<Map<String, dynamic>> records,
  }) {
    List<FlSpot> spots = [];

    for (int i = 0; i < records.length; i++) {
      if (records[i][valueKey] != null) {
        try {
          // Clean the value by removing any non-numeric characters except decimal points
          String cleanValue =
              records[i][valueKey].toString().replaceAll(RegExp(r'[^\d.]'), '');
          double value = double.parse(cleanValue);
          spots.add(FlSpot(i.toDouble(), value));
        } catch (e) {
          // Skip invalid values
        }
      }
    }

    return spots;
  }
}

// Example usage:
// Add this to your main.dart or relevant screen
// HealthRecordsWithAnalysis(hid: "patient123")
