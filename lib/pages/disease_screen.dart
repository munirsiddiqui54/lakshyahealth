import 'package:arogya/pages/medicalrecords.dart';
import 'package:arogya/tabs/diseasenews.dart';
import 'package:flutter/material.dart';
import 'package:arogya/pages/chatscreen.dart'; // Assuming SpeechScreen is in chatscreen.dart
import 'package:arogya/pages/hospital.dart'; // Import for HospitalsScreen

class DiseaseScreen extends StatelessWidget {
  final String hid;

  DiseaseScreen({required this.hid});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Arogya",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.indigo,
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'hospitals') {
                  _navigateToHospitals(context);
                } else if (value == 'reports') {
                  _navigateToMedicalReports(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'hospitals',
                  child: Row(
                    children: [
                      Icon(Icons.local_hospital, color: Colors.indigo),
                      SizedBox(width: 10),
                      Text('Explore Nearby Hospitals'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'reports',
                  child: Row(
                    children: [
                      Icon(Icons.description, color: Colors.indigo),
                      SizedBox(width: 10),
                      Text('Previous Medical Reports'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SpeechScreen(
          hid: hid,
        ),
      ),
    );
  }

  void _navigateToHospitals(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HospitalsScreen(hid: hid),
      ),
    );
  }

  void _navigateToMedicalReports(BuildContext context) {
    // Navigate to medical reports page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalReportsPage(hid: hid),
      ),
    );
  }
}

// This is a placeholder - you'll need to create this screen
class MedicalReportsScreen extends StatelessWidget {
  final String hid;

  MedicalReportsScreen({required this.hid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Previous Medical Reports"),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Text("Medical Reports will be displayed here"),
      ),
    );
  }
}
