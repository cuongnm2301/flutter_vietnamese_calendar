// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vical/pages/home_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting().then((_) => runApp(const MainScreen()));
  requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        primaryColor: Colors.pink,
        hintColor: Colors.red,
        scaffoldBackgroundColor: Colors.white,

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: GoogleFonts.pacificoTextTheme(
          Theme.of(context).textTheme,
        ),

        // Define the default button theme.
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.pink,
          textTheme: ButtonTextTheme.primary,
        ),

        // Other theme settings...
      ),
      home: const CustomTabBarScreen(),
    );
  }
}

class CustomTabBarScreen extends StatefulWidget {
  const CustomTabBarScreen({super.key});

  @override
  CustomTabBarScreenState createState() => CustomTabBarScreenState();
}

class CustomTabBarScreenState extends State<CustomTabBarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          const HomeCalendar(),
          Container(), // Placeholder for the center tab
          const Center(child: Text('Settings')),
        ],
      ),
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            onPressed: () {
              // Action for the button
            },
            shape: const CircleBorder(side: BorderSide.none),
            child: const Icon(Icons.add),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(icon: Icon(Icons.calendar_today)),
            Tab(icon: Container()),
            const Tab(icon: Icon(Icons.settings)),
          ],
        ),
      ),
    );
  }
}

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}
