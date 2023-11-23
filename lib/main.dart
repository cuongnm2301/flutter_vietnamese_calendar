// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:vical/pages/home_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting().then((_) => runApp(const MainScreen()));
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
