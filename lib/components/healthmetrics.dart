import 'package:flutter/material.dart';

class HealthMetrics extends StatelessWidget {
  final List<HealthCardData> healthCards;

  // Constructor to accept dynamic data
  HealthMetrics({required this.healthCards});

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
        children: healthCards.map((cardData) {
          return _buildCard(
            title: cardData.title,
            items: cardData.items,
            colors: cardData.colors,
            isBorder: cardData.isBorder, // New parameter
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<String> items,
    required List<Color> colors,
    required bool isBorder, // New parameter
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isBorder
            ? null
            : LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(12),
        border: isBorder
            ? Border.all(color: colors.last, width: 1.5) // Solid curved border
            : null,
        color: isBorder
            ? Colors.white.withOpacity(0.4)
            : null, // Transparent if border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isBorder
                  ? colors.last
                  : Colors.white, // Border color for text
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
                          style: TextStyle(
                            color: isBorder ? Colors.black : Colors.white,
                            fontSize: 12,
                          ),
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

// Model class to represent the data for each card
class HealthCardData {
  final String title;
  final List<String> items;
  final List<Color> colors;
  final bool isBorder; // New parameter

  HealthCardData({
    required this.title,
    required this.items,
    required this.colors,
    required this.isBorder,
  });
}
