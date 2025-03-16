import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ReportsListScreen extends StatefulWidget {
  @override
  _ReportsListScreenState createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  void _fetchReports() {
    _database.ref("reports").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        List<Map<String, dynamic>> reports = [];
        data.forEach((key, value) {
          reports.add({
            'id': key,
            'imageUrl': value['imageUrl'],
            'description': value['description'],
            'location': value['location'],
            'timestamp': value['timestamp'],
          });
        });

        reports.sort((a, b) =>
            b['timestamp'].compareTo(a['timestamp'])); // Sort by latest first

        setState(() {
          _reports = reports;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(thickness: 2, height: 20), // Separation line
        Text(
          "Submitted Reports",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        _reports.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true, // Makes ListView fit inside Column
                physics:
                    NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (report['imageUrl'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(report['imageUrl'],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover),
                            ),
                          SizedBox(height: 10),
                          Text("Description: ${report['description']}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Location: ${report['location']}"),
                          Text(
                            "Date: ${DateTime.parse(report['timestamp']).toLocal()}",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
