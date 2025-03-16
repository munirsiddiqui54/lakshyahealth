import 'package:flutter/material.dart';

class TableScreen extends StatelessWidget {
  final Map<dynamic, dynamic> jsonData;

  TableScreen({required this.jsonData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero, // No margin to ensure full-width header
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: _buildTableRows(jsonData),
            ),
          ),
        ],
      ),
    );
  }

  // Full-width green header
  Widget _buildHeader() {
    return Container(
      width: double.infinity, // Ensures full width
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green, // Green background
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(10)), // Rounded top corners
      ),
      child: Text(
        'Category         Details', // Spacing to match the format
        style: TextStyle(
          color: Colors.white, // White text
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  List<Widget> _buildTableRows(Map<dynamic, dynamic> data) {
    List<Widget> rows = [];

    data.forEach((key, value) {
      rows.add(_buildRow(key, value));
      rows.add(Divider(thickness: 1, color: Colors.grey[300]));
    });

    return rows;
  }

  Widget _buildRow(String key, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              key,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 5,
            child: _buildValueWidget(value),
          ),
        ],
      ),
    );
  }

  Widget _buildValueWidget(dynamic value) {
    if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text("• $item", style: TextStyle(fontSize: 14)),
                ))
            .toList(),
      );
    } else if (value is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "${entry.key}: ${entry.value}",
                    style: TextStyle(fontSize: 14),
                  ),
                ))
            .toList(),
      );
    } else {
      return Text(value.toString(), style: TextStyle(fontSize: 14));
    }
  }
}
