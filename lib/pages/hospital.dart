import 'package:flutter/material.dart';
import 'package:arogya/utils/api.dart';

class HospitalsScreen extends StatefulWidget {
  @override
  _HospitalsScreenState createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  List<dynamic> _hospitals = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      List<dynamic> hospitals = await fetchHospitals("Nerul, Navi Mumbai");
      print("HOSPITALS $hospitals");
      setState(() {
        _hospitals = hospitals.take(6).toList(); // Limit to 6 hospitals
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nearby Hospitals",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Text("Failed to fetch hospitals. Try again later."))
              : ListView.builder(
                  itemCount: _hospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = _hospitals[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Icon(Icons.local_hospital, color: Colors.red),
                        title: Text(hospital['name'] ?? "Unknown"),
                        subtitle:
                            Text(hospital['address'] ?? "No address available"),
                      ),
                    );
                  },
                ),
    );
  }
}
