import 'package:arogya/pages/disease_screen.dart';
import 'package:arogya/tabs/diseasenews.dart';
import 'package:arogya/tabs/report_screen.dart';
import 'package:arogya/tabs/reportretrive.dart';
import 'package:flutter/material.dart';

class PollutionScreen extends StatefulWidget {
  @override
  _PollutionScreenState createState() => _PollutionScreenState();
}

class _PollutionScreenState extends State<PollutionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Aarogya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: "Report",
              // icon: Icon(Icons.report, color: Colors.white),
            ),
            Tab(
              text: "News",
              // icon: Icon(Icons.newspaper, color: Colors.white),
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [ReportScreen(), DisNewsScreen()],
      ),
    );
  }
}
