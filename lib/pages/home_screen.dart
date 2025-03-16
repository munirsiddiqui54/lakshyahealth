import 'package:arogya/components/healthmetrics.dart';
import 'package:flutter/material.dart';
import 'package:arogya/components/tablescreen.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showEmergencyContacts = false;
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    DatabaseReference userRef =
        databaseRef.child("user/196b35b9-d917-4039-bfed-64ef6bd05982");

    DatabaseEvent event = await userRef.once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        userData = Map<String, dynamic>.from(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/homebg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        // Header Section
                        Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(20)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 30),
                              Text(
                                "Aarogya",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Hello ${userData?['personalInfo']['firstName']}! ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Your Virtual Health Card",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                  height: 50), // Extra space for card overlap
                            ],
                          ),
                        ),

                        SizedBox(height: 80), // Extra space after header
                      ],
                    ),

                    // Profile Card (Overlapping)
                    Positioned(
                      top: 240,
                      left: 20,
                      right: 20,
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey[300],
                                    child: Icon(Icons.person,
                                        size: 40, color: Colors.white),
                                  ),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${userData?['personalInfo']['firstName']} ${userData?['personalInfo']['middleName']} ${userData?['personalInfo']['lastName']}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          "${userData?['personalInfo']['dob']}"),
                                      Text(
                                          "${userData?['personalInfo']['gender']}"),
                                      Text("B-Positive"),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    horizontal:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text("Age: 20"),
                                    Text("Height: 160cm"),
                                    Text("Weight: 50kg"),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Address:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      "Saptarshi CHS LTD B-47/2/10 Plot No-21\nSector 10, Sanpada\nNear Ryan International School, Thane\nSanpada, Maharashtra 400705",
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              // Added images in a row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/others/dglock.png',
                                    height: 60,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: 20),
                                  Image.asset(
                                    'assets/others/qr.png',
                                    height: 80,
                                    fit: BoxFit.contain,
                                  ), // Space between images
                                ],
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 250), // Ensures scrolling past the card

                // Additional Components Below Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      HealthMetrics(),
                      TableScreen(
                        jsonData: {
                          "Demographics": "20 - year-old female",
                          "Chief Complaint":
                              "Persistent headaches for 2 months",
                          "Past Medical History": [
                            "Seasonal allergies (diagnosed 2016)",
                            "Mild asthma (diagnosed age 7)",
                            "Anxiety disorder (diagnosed 2022)"
                          ],
                          "Current Medications": {
                            "Loratadine": "10mg daily PRN",
                            "Albuterol inhaler": "PRN",
                            "Sertraline": "50mg daily",
                            "Multivitamin": "daily"
                          },
                          "Family History": {
                            "Father": "Hypertension",
                            "Mother": ["Migraine headaches", "Depression"],
                            "Maternal grandmother": "Breast cancer at age 62",
                            "Paternal grandfather": "Type 2 diabetes"
                          },
                        },
                      ),
                      _buildSection("Medical Reports", Colors.indigo, false),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showEmergencyContacts = !_showEmergencyContacts;
                          });
                        },
                        child: _buildSection("Emergency Contacts", Colors.red,
                            _showEmergencyContacts),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Color color, bool expanded) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      height: expanded ? 120 : 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("+91 9547854725",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 5),
                  Text("+91 9447854525",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
