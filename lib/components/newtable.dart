import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class TableScreen2 extends StatefulWidget {
  // final Map<dynamic, dynamic> jsonData;
  final String hid;

  TableScreen2({required this.hid});

  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  late DatabaseReference _dbRef;
  Map<dynamic, dynamic> jsonData = {};

  // Fetch data from Firebase Realtime Database
  void _fetchSummaryData() async {
    DatabaseReference ref = _dbRef.child('user/${widget.hid}/summary');
    DatabaseEvent event =
        await ref.once(); // Use .once() which returns a DatabaseEvent

    if (event.snapshot.exists) {
      setState(() {
        jsonData = Map<String, dynamic>.from(event.snapshot.value as Map);
      });
    } else {
      // Handle case when the summary data doesn't exist
      print("No data found for the given path");
    }
  }

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance
        .ref(); // Use .ref() instead of .reference() which is deprecated.
    _fetchSummaryData();
    _tabController = TabController(length: 3, vsync: this);
    // Simulate loading data
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Health Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[700],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green[400],
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.dashboard_rounded),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.table_chart_rounded),
              text: 'Details',
            ),
            Tab(
              icon: Icon(Icons.insights_rounded),
              text: 'Analytics',
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDetailsTab(),
                _buildAnalyticsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[600],
        child: Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            isLoading = true;
          });

          // Simulate refreshing data
          Future.delayed(Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          });
        },
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildMetricCard(
              'Heart Rate',
              _getRandomValue('heartRate', '72 bpm'),
              Icons.favorite,
              Colors.red[400]!,
            ),
            _buildMetricCard(
              'BP',
              _getRandomValue('bloodPressure', '120/80'),
              Icons.speed,
              Colors.indigo[400]!,
            ),
            _buildMetricCard(
              'Blood Sugar',
              _getRandomValue('bloodSugar', '90 mg/dL'),
              Icons.opacity,
              Colors.blue[400]!,
            ),
            _buildMetricCard(
              'Sleep',
              _getRandomValue('sleep', '7.5 hrs'),
              Icons.nightlight_round,
              Colors.purple[400]!,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  'Medication Taken',
                  'Completed morning medication routine',
                  '08:30 AM',
                  Icons.medication,
                  Colors.green[600]!,
                ),
                Divider(),
                _buildActivityItem(
                  'Blood Pressure Check',
                  'Measured blood pressure: 120/80',
                  '09:15 AM',
                  Icons.speed,
                  Colors.indigo[600]!,
                ),
                Divider(),
                _buildActivityItem(
                  'Doctor Appointment',
                  'Scheduled follow-up with Dr. Smith',
                  '11:00 AM',
                  Icons.calendar_today,
                  Colors.orange[600]!,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String description, String time,
      IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChips(),
          SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: _buildDataTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: Text('All Data'),
          selected: true,
          selectedColor: Colors.green[100],
          checkmarkColor: Colors.green[700],
          onSelected: (bool selected) {},
        ),
        FilterChip(
          label: Text('Heart Rate'),
          selected: false,
          backgroundColor: Colors.grey[200],
          onSelected: (bool selected) {},
        ),
        FilterChip(
          label: Text('Blood Pressure'),
          selected: false,
          backgroundColor: Colors.grey[200],
          onSelected: (bool selected) {},
        ),
        FilterChip(
          label: Text('Medications'),
          selected: false,
          backgroundColor: Colors.grey[200],
          onSelected: (bool selected) {},
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          SizedBox(height: 16),
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.grey[300],
              dataTableTheme: DataTableThemeData(
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[800],
                ),
              ),
            ),
            child: DataTable(
              columns: [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Metric')),
                DataColumn(label: Text('Value')),
                DataColumn(label: Text('Status')),
              ],
              rows: _generateTableRows(),
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _generateTableRows() {
    // This would normally come from your JSON data
    final List<Map<String, dynamic>> tableData = [
      {
        'date': '2025-03-21',
        'metric': 'Heart Rate',
        'value': '72 bpm',
        'status': 'Normal',
      },
      {
        'date': '2025-03-21',
        'metric': 'Blood Pressure',
        'value': '120/80',
        'status': 'Normal',
      },
      {
        'date': '2025-03-20',
        'metric': 'Blood Sugar',
        'value': '90 mg/dL',
        'status': 'Normal',
      },
      {
        'date': '2025-03-20',
        'metric': 'Sleep',
        'value': '7.5 hrs',
        'status': 'Good',
      },
      {
        'date': '2025-03-19',
        'metric': 'Heart Rate',
        'value': '82 bpm',
        'status': 'Elevated',
      },
      {
        'date': '2025-03-19',
        'metric': 'Blood Pressure',
        'value': '130/85',
        'status': 'Elevated',
      },
    ];

    // Try to use actual data from jsonData if it exists and has the appropriate structure
    if (jsonData.containsKey('records') && jsonData['records'] is List) {
      try {
        final records = jsonData['records'] as List;
        return records.map<DataRow>((record) {
          return DataRow(
            cells: [
              DataCell(Text(record['date'] ?? 'N/A')),
              DataCell(Text(record['metric'] ?? 'N/A')),
              DataCell(Text(record['value'] ?? 'N/A')),
              DataCell(_buildStatusCell(record['status'] ?? 'N/A')),
            ],
          );
        }).toList();
      } catch (e) {
        print('Error parsing records from JSON: $e');
      }
    }

    // Default to sample data if JSON doesn't contain appropriate structure
    return tableData.map<DataRow>((row) {
      return DataRow(
        cells: [
          DataCell(Text(row['date'])),
          DataCell(Text(row['metric'])),
          DataCell(Text(row['value'])),
          DataCell(_buildStatusCell(row['status'])),
        ],
      );
    }).toList();
  }

  Widget _buildStatusCell(String status) {
    Color statusColor = Colors.grey;

    if (status.toLowerCase() == 'normal') {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == 'good') {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == 'elevated') {
      statusColor = Colors.orange;
    } else if (status.toLowerCase() == 'high') {
      statusColor = Colors.red;
    } else if (status.toLowerCase() == 'low') {
      statusColor = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24),
          _buildProgressIndicators(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicators() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Goals Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            SizedBox(height: 16),
            _buildProgressItem(
              'Daily Steps',
              '8,432',
              '10,000',
              0.84,
              Colors.indigo[600]!,
            ),
            SizedBox(height: 16),
            _buildProgressItem(
              'Water Intake',
              '1.8L',
              '2.5L',
              0.72,
              Colors.blue[600]!,
            ),
            SizedBox(height: 16),
            _buildProgressItem(
              'Sleep',
              '7.5 hrs',
              '8 hrs',
              0.94,
              Colors.purple[600]!,
            ),
            SizedBox(height: 16),
            _buildProgressItem(
              'Medication Adherence',
              '90%',
              '100%',
              0.9,
              Colors.green[600]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String current, String target,
      double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            Text(
              '$current / $target',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  // Utility method to get a value from jsonData or default to a fallback value
  String _getRandomValue(String key, String defaultValue) {
    if (jsonData.containsKey(key)) {
      return jsonData[key].toString();
    }
    return defaultValue;
  }
}
