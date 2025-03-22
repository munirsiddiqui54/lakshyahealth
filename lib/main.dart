import 'package:arogya/components/newtable.dart';
import 'package:arogya/pages/login.dart';
import 'package:arogya/pages/medical.dart';
import 'package:flutter/material.dart';
import 'pages/home_screen.dart'; // Import HomeScreen
import 'pages/disease_screen.dart'; // Import DiseaseScreen
import 'pages/pollution_screen.dart'; // Import PollutionScreen
import 'pages/mental_health_screen.dart'; // Import Mental
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart'; // Add this import

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notifications
  print("Handling background message: ${message.messageId}");
}

// Updated to store token in Realtime Database
Future<void> saveTokenToDatabase(String token, String hid) async {
  try {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    await database.child('user').child(hid).child('fcm').set(token);
    print("FCM Token saved to database for user $hid");
  } catch (e) {
    print("Error saving token to database: $e");
  }
}

Future<void> getDeviceToken({String? hid}) async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");

  // Only save token if hid is provided
  if (token != null && hid != null && hid.isNotEmpty) {
    await saveTokenToDatabase(token, hid);
  }
}

// Updated FCM setup to accept hid parameter
Future<void> setupFCM({String? hid}) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permissions for notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
    await getDeviceToken(hid: hid); // Pass hid parameter to getDeviceToken
  } else {
    print('User denied permission');
  }

  // Listen for token refresh events
  FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
    print('FCM Token refreshed');
    if (hid != null && hid.isNotEmpty) {
      saveTokenToDatabase(token, hid);
    }
  });

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received message: ${message.notification?.title}');
  });

  // Handle when user taps notification and opens the app
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('User opened notification: ${message.notification?.title}');
  });

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // We'll call setupFCM without hid parameter first
  // and then call it again after user logs in
  await setupFCM();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(), // Set Login as the home screen
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String hid; // Receive HID

  MyHomePage({required this.hid}); // Constructor to accept HID

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Index to keep track of the selected tab
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    setupFCM(hid: widget.hid);

    // Listen for incoming messages while app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      if (message.notification != null) {
        _showMessageDialog(
            message.notification!.title, message.notification!.body);
      }
    });
  }

  void _showMessageDialog(String? title, String? body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? "New Notification"),
          content: Text(body ?? "No content"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // List of screens to navigate to
  List<Widget> get _screens => [
        HomeScreen(hid: widget.hid), // Pass HID here
        HealthRecordsWithAnalysis(hid: widget.hid),
        DiseaseScreen(hid: widget.hid),
        PollutionScreen(),
        FeedScreen(hid: widget.hid),
      ];

  // Method to change the screen based on selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: Material(
        elevation:
            10.0, // Set the elevation (shadow) of the BottomNavigationBar
        color: Colors.white, // Set the color of the bottom navigation bar
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0), // Rounded top-left corner
          topRight: Radius.circular(30.0), // Rounded top-right corner
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), // Rounded top-left corner
            topRight: Radius.circular(30.0), // Rounded top-right corner
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            showSelectedLabels: true, // Show label for selected item
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            selectedItemColor:
                Color(0xff403DB4), // Set color for the selected label
            selectedIconTheme: IconThemeData(
                color: Colors.blue), // Set icon color to blue when selected
            unselectedItemColor: Color(0xff141414),
            items: [
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/home.png'),
                  size: _selectedIndex == 0 ? 30.0 : 24.0,
                  color: _selectedIndex == 0
                      ? Color(0xff403DB4)
                      : Color(0xff414141),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/summary.png'),
                  size: _selectedIndex == 1 ? 30.0 : 24.0,
                  color: _selectedIndex == 1
                      ? Color(0xff403DB4)
                      : Color(0xff414141),
                ),
                label: 'Summary',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/disease.png'),
                  size: _selectedIndex == 2 ? 30.0 : 24.0,
                  color: _selectedIndex == 2
                      ? Color(0xff403DB4)
                      : Color(0xff414141),
                ),
                label: 'Diagnosis',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/news.png'),
                  size: _selectedIndex == 3 ? 30.0 : 24.0,
                  color: _selectedIndex == 3
                      ? Color(0xff403DB4)
                      : Color(0xff414141),
                ),
                label: 'News n Report',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/personal.png'),
                  size: _selectedIndex == 4 ? 30.0 : 24.0,
                  color: _selectedIndex == 4
                      ? Color(0xff403DB4)
                      : Color(0xff414141),
                ),
                label: 'Explore',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
