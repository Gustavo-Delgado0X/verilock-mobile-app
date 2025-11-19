import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraFeed extends StatelessWidget {
  const CameraFeed({super.key});

  Future<String> _getVideoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final base = prefs.getString('custom_base_url') ?? 
                 dotenv.env['BASE_URL'] ?? 
                 'http://192.168.1.100:8000';
    return '$base/video_feed';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getVideoUrl(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          height: 220,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            headers: const {'Connection': 'keep-alive'},
            errorBuilder: (ctx, err, stack) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, color: Colors.white54, size: 48),
                    SizedBox(height: 8),
                    Text('Camera Offline', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
