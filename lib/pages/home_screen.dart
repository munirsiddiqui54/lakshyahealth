import 'package:arogya/components/healthmetrics.dart';
import 'package:arogya/pages/medicalrecords.dart';
import 'package:flutter/material.dart';
import 'package:arogya/components/tablescreen.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  final String hid; // Receive HID

  HomeScreen({required this.hid}); // Constructor to accept HID

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showEmergencyContacts = false;
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  Map<String, dynamic>? userData;

  bool _loading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    DatabaseReference userRef = databaseRef.child("user/${widget.hid}");

    DatabaseEvent event = await userRef.once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        userData = Map<String, dynamic>.from(data);
        _loading = false; // Data fetched, stop loading
      });
    } else {
      setState(() {
        _loading = false; // No data, stop loading
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
          _loading
              ? Center(child: CircularProgressIndicator())
              : userData == null
                  ? Center(child: Text("No user data found"))
                  : SingleChildScrollView(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          "Hello ${userData?['firstName']}! ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Your health, your data – securely accessible anytime, anywhere.",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
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
                                            height:
                                                50), // Extra space for card overlap
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                      height: 80), // Extra space after header
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
                                                  size: 40,
                                                  color: Colors.white),
                                            ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${userData?['firstName']} ${userData?['middleName']} ${userData?['lastName']}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 2,
                                                    overflow: TextOverflow
                                                        .visible, // Ensures text wraps instead of being clipped
                                                    softWrap: true,
                                                  ),
                                                  // Text("${userData?['dob']}"),
                                                  Text(
                                                      "${userData?['gender']}"),
                                                  Text(
                                                      "${userData?['bloodGroup']}"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                              horizontal: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // Note: Age calculation would ideally use DOB
                                              Text(
                                                  "Height: ${userData?['height']}"),
                                              Text(
                                                  "Weight: ${userData?['weight']}"),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Address:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                "${userData?['address'] ?? 'No address provided'}",
                                                style: TextStyle(
                                                    color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        // Added images in a row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/others/dglock.png',
                                              height: 60,
                                              fit: BoxFit.contain,
                                            ),
                                            SizedBox(width: 20),
                                            Positioned(
                                              top: 240,
                                              left: 20,
                                              right: 20,
                                              child: GestureDetector(
                                                onTap: () {
                                                  print(
                                                      "GestureDetector tapped!");
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text("QR Code",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              SizedBox(
                                                                  height: 10),
                                                              Image.network(
                                                                userData?[
                                                                        'qrCodeURL'] ??
                                                                    '',
                                                                height: 450,
                                                                fit: BoxFit
                                                                    .contain,
                                                                loadingBuilder:
                                                                    (context,
                                                                        child,
                                                                        loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null)
                                                                    return child;
                                                                  return Center(
                                                                      child:
                                                                          CircularProgressIndicator());
                                                                },
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Text(
                                                                      "Failed to load QR Code");
                                                                },
                                                              ),
                                                              SizedBox(
                                                                  height: 10),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child: Text(
                                                                    "Close"),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Image.network(
                                                  userData?['qrCodeURL'] ?? '',
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                        'assets/others/qr.png',
                                                        height: 80,
                                                        fit: BoxFit.contain);
                                                  },
                                                ),
                                              ),
                                            )
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

                          SizedBox(
                              height: 250), // Ensures scrolling past the card

                          // Additional Components Below Card
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                HealthMetrics(
                                  healthCards: [
                                    HealthCardData(
                                      title: "Allergies",
                                      items: [
                                        userData?['allergies'] == "None"
                                            ? "None"
                                            : userData?['allergies'] ??
                                                "Not specified"
                                      ],
                                      colors: [
                                        Colors.orange.shade800,
                                        Colors.orange.shade400
                                      ],
                                      isBorder: false,
                                    ),
                                    HealthCardData(
                                        title: "Vaccines",
                                        items: [
                                          userData?['vaccines'] ??
                                              "Not specified"
                                        ],
                                        colors: [
                                          Colors.green.shade800,
                                          Colors.green.shade400
                                        ],
                                        isBorder: false),
                                    HealthCardData(
                                        title: "Chronic Disease",
                                        items: [
                                          userData?['chronicDiseases'] ?? "None"
                                        ],
                                        colors: [
                                          Colors.purple.shade800,
                                          Colors.purple.shade400
                                        ],
                                        isBorder: false),
                                    HealthCardData(
                                        title: "Preventive Care",
                                        items: [
                                          userData?['preventiveCare'] ??
                                              "Not specified"
                                        ],
                                        colors: [
                                          Colors.pink.shade800,
                                          Colors.pink.shade400
                                        ],
                                        isBorder: false),
                                  ],
                                ),
                                TableScreen(
                                  jsonData: {
                                    "Gender":
                                        userData?['gender'] ?? "Not specified",
                                    "Height":
                                        userData?['height'] ?? "Not specified",
                                    "Weight":
                                        userData?['weight'] ?? "Not specified",
                                    "Blood Group": userData?['bloodGroup'] ??
                                        "Not specified",
                                    "Date of Birth":
                                        userData?['dob'] ?? "Not specified",
                                    "Address":
                                        userData?['address'] ?? "Not specified",
                                    "Allergies": userData?['allergies'] ??
                                        "Not specified",
                                    "Preventive Care":
                                        userData?['preventiveCare'] ??
                                            "Not specified",
                                    "Vaccinations": userData?['vaccines'] ??
                                        "Not specified",
                                    "Chronic Diseases":
                                        userData?['chronicDiseases'] ??
                                            "Not specified",
                                  },
                                ),
                                _buildSection("Medical Reports", Colors.indigo,
                                    false, widget.hid, context)
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

  Widget _buildSection(String title, Color color, bool expanded, String hid,
      BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicalReportsPage(hid: hid),
          ),
        );
      },
      child: AnimatedContainer(
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
          ],
        ),
      ),
    );
  }
}
