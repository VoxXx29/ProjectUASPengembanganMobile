import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/video_detail_screen.dart';

class VideoGridItem extends StatelessWidget {
  final Map video;

  VideoGridItem({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDetailScreen(
              video: video,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: video['image'],
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              video['user']['name'] ?? 'Unknown Creator',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.black,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
