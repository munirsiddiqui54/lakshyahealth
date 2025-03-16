import 'package:arogya/pages/login.dart';
import 'package:flutter/material.dart';
import 'pages/home_screen.dart'; // Import HomeScreen
import 'pages/disease_screen.dart'; // Import DiseaseScreen
import 'pages/pollution_screen.dart'; // Import PollutionScreen
import 'pages/mental_health_screen.dart'; // Import MentalH
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notifications
  print("Handling background message: ${message.messageId}");
}

Future<void> getDeviceToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permissions for notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
    await getDeviceToken(); // Fetch FCM token when permission is granted
  } else {
    print('User denied permission');
  }

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
  await setupFCM();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(), // Set MyHomePage as the home screen
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Index to keep track of the selected tab
  int _selectedIndex = 0;

  // List of screens to navigate to
  final List<Widget> _screens = [
    HomeScreen(),
    DiseaseScreen(),
    PollutionScreen(),
    MentalHealthScreen(),
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
                  AssetImage('assets/icons/disease.png'),
                  size: _selectedIndex == 1 ? 30.0 : 24.0,
                  color: _selectedIndex == 1
                      ? Color(0xff403DB4)
                      : Color(0xff414141),
                ),
                label: 'Disease',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/pollution.png'),
                  size: _selectedIndex == 2 ? 30.0 : 24.0,
                  color: _selectedIndex == 2
                      ? Color(0xff403DB4)
                      : Color(0xff414141),
                ),
                label: 'Pollution',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/icons/mental.png'),
                  size: _selectedIndex == 3 ? 30.0 : 24.0,
                  color: _selectedIndex == 3
                      ? Color(0xff403DB4)
                      : Color(0xff414141),
                ),
                label: 'Mental Health',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
