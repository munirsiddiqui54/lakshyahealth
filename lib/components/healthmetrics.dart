import 'package:flutter/material.dart';

class HealthMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2, // Two columns
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.80, // Adjust aspect ratio for better fit
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildCard(
            title: "Allergies",
            items: ["Sulfa drugs (rash)", "Pollen (rhinitis)"],
            colors: [Colors.orange.shade800, Colors.orange.shade400],
          ),
          _buildCard(
            title: "Immunizations",
            items: [
              "HPV: Completed series (2019)",
              "COVID-19: Fully vaccinated (last: Sept 2023)",
              "Meningococcal: 2021",
              "Influenza: Oct 2024",
              "Tdap: 2020",
            ],
            colors: [Colors.green.shade800, Colors.green.shade400],
          ),
          _buildCard(
            title: "Gynecological History",
            items: [
              "Menarche: Age 12",
              "Last menstrual period: Oct 28, 2024",
            ],
            colors: [Colors.purple.shade800, Colors.purple.shade400],
          ),
          _buildCard(
            title: "Preventive Care",
            items: [
              "Last physical exam: Aug 2024",
              "Last eye exam: Jan 2023",
              "Last dental exam: July 2024",
              "Last gynecological exam: Sept 2024",
            ],
            colors: [Colors.pink.shade800, Colors.pink.shade400],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<String> items,
    required List<Color> colors,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 14),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                        child: Text(
                          "• $item",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
