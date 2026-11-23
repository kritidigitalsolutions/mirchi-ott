import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../view_model/analytics_controller/analytics_controller.dart';

class ShareService {
  static Future<void> shareContent({
    required String title,
    required String imageUrl,
    Rect? sharePositionOrigin,
    String? seriesId,
    String? episodeId,
  }) async {
    // 📊 Track share analytics if seriesId is provided
    if (seriesId != null && Get.isRegistered<AnalyticsController>()) {
      AnalyticsController.to.trackShare(
        seriesId: seriesId,
        episodeId: episodeId,
      );
    }
    try {
      // 1. Download the image
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      // 2. Get temporary directory
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/shared_image.jpg';
      
      // 3. Save the image to the path
      File(path).writeAsBytesSync(bytes);

      // 4. Share the file with text
      await Share.shareXFiles(
        [XFile(path)],
        text: "Check out $title on Mirchi OTT App 🎬🔥\n\nDownload now to watch the latest movies and series!",
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      print("❌ Error sharing content: $e");
      // Fallback to text sharing if image fails
      await Share.share(
        "Check out $title on Mirchi OTT App 🎬🔥",
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  }
}
