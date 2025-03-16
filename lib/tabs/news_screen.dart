import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrendingNewsScreen(),
    );
  }
}

class TrendingNewsScreen extends StatelessWidget {
  final List<Map<String, String>> trendingNews = [
    {
      "category": "Traffic-Pollution",
      "title":
          "Air Quality drops by 15% due to rise in number of vehicles in the city.",
      "time": "2 hours ago",
      "image": "assets/others/traffic.png",
    },
    {
      "category": "Top Media",
      "title": "Mumbai's Infrastructure Projects Contribute to Pollution",
      "time": "2 hours ago",
      "image": "assets/others/construct.png",
    },
    {
      "category": "Transportation",
      "title": "Chefs Oppose Proposed Ban on Traditional Tandoors",
      "time": "4 hours ago",
      "image": "assets/others/chicken.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/homebg.png", // Replace with your actual image path
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryFilter(),
                  SizedBox(height: 16),
                  CarouselSlider(
                    options: CarouselOptions(
                        height: 200, autoPlay: true, enlargeCenterPage: true),
                    items: trendingNews
                        .map((news) => NewsCard(news: news))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: trendingNews.length,
                    itemBuilder: (context, index) {
                      return NewsListItem(news: trendingNews[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryFilter extends StatelessWidget {
  final List<String> categories = [
    "All",
    "Traffic",
    "Transportation",
    "Health",
    "Future"
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map((category) => CategoryChip(category: category))
            .toList(),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String category;
  const CategoryChip({required this.category});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Chip(
        label: Text(
          category,
          style: category == "All"
              ? TextStyle(color: Colors.white)
              : TextStyle(color: Colors.indigo),
        ),
        backgroundColor: category == "All" ? Colors.indigo : Colors.grey[300],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final Map<String, String> news;
  const NewsCard({required this.news});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Image.asset(news["image"]!,
              fit: BoxFit.cover, width: double.infinity, height: 200),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter)),
          ),
          Positioned(
            left: 10,
            bottom: 30,
            child: Chip(
                label: Text(news["category"]!,
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.indigo),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Text(news["title"]!,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class NewsListItem extends StatelessWidget {
  final Map<String, String> news;
  const NewsListItem({required this.news});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(news["image"]!,
                width: 100, height: 100, fit: BoxFit.cover),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChipTheme(
                  data: ChipTheme.of(context).copyWith(
                    padding: EdgeInsets.all(0.0), // Adjust padding as needed
                  ),
                  child: Chip(
                    label: Text(
                      news["category"]!,
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.indigo,
                  ),
                ),
                Text(news["title"]!,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 1),
                Text(news["time"]!, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
