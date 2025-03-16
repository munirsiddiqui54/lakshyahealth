import 'package:arogya/tabs/diseasenews.dart';
import 'package:flutter/material.dart';
import 'package:arogya/pages/chatscreen.dart'; // Assuming SpeechScreen is in chatscreen.dart

class DiseaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Arogya Melody",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.indigo,
          bottom: TabBar(
            labelColor: Colors.white, // Text color of the selected tab
            unselectedLabelColor:
                Colors.white.withOpacity(0.6), // Text color of unselected tabs
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: "Arogya.ai",
              ), // First tab
              Tab(text: "News"), // Second tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Content for the first tab (Arogya.ai)
            SpeechScreen(), // Replace with your Arogya.ai component

            // Content for the second tab (News)
            DisNewsScreen() // Replace with your News component
          ],
        ),
      ),
    );
  }
}
