import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FeedScreen extends StatefulWidget {
  final String hid;

  const FeedScreen({Key? key, required this.hid}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _isLoading = true;
  String _disease = "";
  List<Map<String, dynamic>> _videos = [];
  List<Map<String, dynamic>> _articles = [];
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      final response = await http.post(
        Uri.parse('https://healthbot.pythonanywhere.com/api/get-content/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'hid': widget.hid}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _disease = data['disease'] ?? "Unknown";
          _videos = List<Map<String, dynamic>>.from(data['videos'] ?? []);
          _articles = List<Map<String, dynamic>>.from(data['articles'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load content: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  String _extractVideoId(String url) {
    return YoutubePlayer.convertUrlToId(url) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text("Feed",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_videos.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No videos available"),
          )
        else
          ..._videos.map((video) => _buildVideoCard(video)).toList(),
        const SizedBox(height: 24),
        const Text(
          "Articles",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_articles.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No articles available"),
          )
        else
          ..._articles.map((article) => _buildArticleCard(article)).toList(),
      ],
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final videoId = _extractVideoId(video['url'] ?? "");

    if (videoId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VideoPlayer(videoId: videoId),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video['title'] ?? "No Title",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (video['description'] != null &&
                    video['description'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      video['description'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] ?? "No Title",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (article['snippet'] != null &&
                article['snippet'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  article['snippet'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            Text(
              "Source: ${article['source'] ?? 'Unknown'}",
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayer extends StatefulWidget {
  final String videoId;

  const VideoPlayer({Key? key, required this.videoId}) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return !_isPlaying
        ? GestureDetector(
            onTap: () {
              setState(() {
                _isPlaying = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    YoutubePlayer.getThumbnail(videoId: widget.videoId),
                    fit: BoxFit.cover,
                  ),
                ),
                const Icon(
                  Icons.play_circle_fill,
                  size: 60,
                  color: Colors.white,
                ),
              ],
            ),
          )
        : YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
              onReady: () {
                _controller.addListener(() {});
              },
            ),
            builder: (context, player) {
              return player;
            },
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
