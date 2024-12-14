import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/video_grid_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List videos = [];
  List displayedVideos = [];
  bool isLoading = true;
  int currentPage = 1;
  String searchQuery = "";
  String currentFilter = 'landscape';
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        currentFilter = 'landscape';
      } else {
        currentFilter = 'portrait';
      }
      applyFilters();
    });
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    const String apiKey = '0tKEc1NXEtWX584xsKGiMkgEEe4yir4iD7vBaLPd4jPrGJMzyFbNxLsn'; // Ganti dengan API Key Anda
    final String url = 'https://api.pexels.com/videos/popular?page=$currentPage&per_page=20'; // Meningkatkan per_page

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          videos.addAll(data['videos']);
          applyFilters();
          isLoading = false;
        });
      } else {
        print('Error fetching videos: ${response.body}');
      }
    } catch (e) {
      print('Error fetching videos: $e');
    }
  }

  void applyFilters() {
    setState(() {
      displayedVideos = videos.where((video) {
        bool matchesOrientation = currentFilter == 'landscape'
            ? video['width'] > video['height']
            : video['width'] < video['height'];

        bool matchesSearch = searchQuery.isEmpty ||
            video['user']['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            video['description'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            video['tags'].any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));

        return matchesOrientation && matchesSearch;
      }).toList();
    });
  }

  void loadMoreVideos() {
    setState(() {
      currentPage++;
      fetchVideos();
    });
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ProTube', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Landscape'),
                  Tab(text: 'Portrait'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search videos...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            loadMoreVideos();
          }
          return true;
        },
        child: GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: displayedVideos.length,
          itemBuilder: (context, index) {
            return VideoGridItem(video: displayedVideos[index]);
          },
        ),
      ),
    );
  }
}
