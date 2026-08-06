import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../utils/custom_snackbar.dart';

class DownloadController extends GetxController {
  final storage = GetStorage();
  final Dio dio = Dio();

  var downloadedContent = <ContentModel>[].obs;

  var isDownloading = <String, bool>{}.obs;
  var downloadProgress = <String, double>{}.obs;
  var localPaths = <String, String>{}.obs;

  /// 🔥 HEADERS to bypass 403 Forbidden
  final Map<String, String> _headers = {
    'User-Agent': kIsWeb
        ? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        : 'Mozilla/5.0 (Linux; Android 10; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.162 Mobile Safari/537.36',
    'Accept': '*/*',
    'Connection': 'keep-alive',
  };

  @override
  void onInit() {
    super.onInit();
    loadDownloadedContent();
  }

  void loadDownloadedContent() {
    var saved = storage.read<List>('downloads') ?? [];
    downloadedContent.assignAll(
      saved.map((e) => ContentModel.fromJson(e)).toList(),
    );

    localPaths.value = Map<String, String>.from(
      storage.read('paths') ?? {},
    );
  }

  Future<void> downloadVideo(ContentModel content) async {
    if (isDownloading[content.id] == true) return;
    if (content.videoUrl == null || content.videoUrl!.isEmpty) {
      CustomSnackbar.show(
        title: "Error",
        message: "Video URL not found",
        isError: true,
      );
      return;
    }

    try {
      isDownloading[content.id] = true;
      downloadProgress[content.id] = 0;

      if (content.videoUrl!.toLowerCase().contains('.m3u8')) {
        await _downloadHls(content);
      } else {
        await _downloadMp4(content);
      }

      if (!downloadedContent.any((e) => e.id == content.id)) {
        downloadedContent.add(content);
      }

      _saveToStorage();

      CustomSnackbar.show(
        title: "Downloaded",
        message: "${content.title} downloaded offline ✅",
        isSuccess: true,
      );
    } catch (e) {
      debugPrint("Download Error: $e");
      String errorMessage = "Download failed";
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          errorMessage = "Access denied by server (403)";
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = "Connection timeout";
        }
      }

      CustomSnackbar.show(
        title: "Error",
        message: errorMessage,
        isError: true,
      );
    } finally {
      isDownloading[content.id] = false;
    }
  }

  Future<void> _downloadMp4(ContentModel content) async {
    Directory dir = await getApplicationDocumentsDirectory();
    // Ensure the filename is safe
    String fileName = content.id.replaceAll(RegExp(r'[^\w\s.-]'), '_');
    String filePath = "${dir.path}/$fileName.mp4";

    final uri = Uri.parse(content.videoUrl!);
    final headers = Map<String, String>.from(_headers);
    try {
      headers['Referer'] = "${uri.scheme}://${uri.host}/";
      headers['Origin'] = "${uri.scheme}://${uri.host}";
    } catch (_) {}

    await dio.download(
      content.videoUrl!,
      filePath,
      options: Options(headers: headers),
      onReceiveProgress: (received, total) {
        if (total != -1) {
          downloadProgress[content.id] = received / total;
        }
      },
    );

    localPaths[content.id] = filePath;
  }

  Future<void> _downloadHls(ContentModel content) async {
    final masterUrl = content.videoUrl!;
    final masterUri = Uri.parse(masterUrl);
    final headers = Map<String, String>.from(_headers);
    try {
      headers['Referer'] = "${masterUri.scheme}://${masterUri.host}/";
      headers['Origin'] = "${masterUri.scheme}://${masterUri.host}";
    } catch (_) {}

    // 1. Fetch Master Playlist
    final masterResponse = await http.get(masterUri, headers: headers);
    if (masterResponse.statusCode != 200) throw Exception("Failed to fetch master playlist");

    String? variantUrl;
    final lines = masterResponse.body.split(RegExp(r'\r?\n'));
    
    // 2. Find 480p variant or any available
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('RESOLUTION=') && lines[i].contains('480')) {
        for (int j = i + 1; j < lines.length; j++) {
          if (lines[j].trim().isNotEmpty && !lines[j].startsWith('#')) {
            variantUrl = lines[j].trim();
            break;
          }
        }
        if (variantUrl != null) break;
      }
    }

    // Fallback to first variant if 480p not found
    if (variantUrl == null) {
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('#EXT-X-STREAM-INF')) {
          for (int j = i + 1; j < lines.length; j++) {
            if (lines[j].trim().isNotEmpty && !lines[j].startsWith('#')) {
              variantUrl = lines[j].trim();
              break;
            }
          }
          if (variantUrl != null) break;
        }
      }
    }

    if (variantUrl == null) variantUrl = masterUrl; // If not a master playlist, treat as variant

    Uri variantUri = variantUrl.startsWith('http') ? Uri.parse(variantUrl) : masterUri.resolve(variantUrl);

    // 3. Fetch Variant Playlist
    final variantResponse = await http.get(variantUri, headers: headers);
    if (variantResponse.statusCode != 200) throw Exception("Failed to fetch variant playlist");

    final variantLines = variantResponse.body.split(RegExp(r'\r?\n'));
    List<String> segments = [];
    for (var line in variantLines) {
      if (line.trim().isNotEmpty && !line.startsWith('#')) {
        segments.add(line.trim());
      }
    }

    if (segments.isEmpty) throw Exception("No segments found in playlist");

    // 4. Create Directory for Segments
    Directory appDir = await getApplicationDocumentsDirectory();
    String folderName = content.id.replaceAll(RegExp(r'[^\w\s.-]'), '_');
    Directory downloadDir = Directory("${appDir.path}/downloads/$folderName");
    if (!downloadDir.existsSync()) downloadDir.createSync(recursive: true);

    // 5. Download Segments
    List<String> localLines = [];
    int downloadedCount = 0;

    for (var line in variantLines) {
      if (line.trim().isNotEmpty && !line.startsWith('#')) {
        String segmentUrl = line.trim();
        Uri segmentUri = segmentUrl.startsWith('http') ? Uri.parse(segmentUrl) : variantUri.resolve(segmentUrl);
        String segmentFileName = segmentUri.pathSegments.last;
        // Strip query params for local filename
        if (segmentFileName.contains('?')) segmentFileName = segmentFileName.split('?').first;
        
        String localSegmentPath = "${downloadDir.path}/$segmentFileName";
        
        await dio.download(
          segmentUri.toString(),
          localSegmentPath,
          options: Options(headers: headers),
        );

        localLines.add(segmentFileName);
        downloadedCount++;
        downloadProgress[content.id] = downloadedCount / segments.length;
      } else {
        localLines.add(line);
      }
    }

    // 6. Create Local M3U8
    String localM3u8Content = localLines.join('\n');
    File localM3u8File = File("${downloadDir.path}/playlist.m3u8");
    await localM3u8File.writeAsString(localM3u8Content);

    localPaths[content.id] = localM3u8File.path;
  }

  void removeDownload(String contentId) {
    // delete file also
    if (localPaths.containsKey(contentId)) {
      String path = localPaths[contentId]!;
      File file = File(path);
      if (file.existsSync()) {
        if (path.endsWith('.m3u8')) {
          // It's an HLS folder
          file.parent.deleteSync(recursive: true);
        } else {
          file.deleteSync();
        }
      }
      localPaths.remove(contentId);
    }

    downloadedContent.removeWhere((e) => e.id == contentId);
    _saveToStorage();

    CustomSnackbar.show(
      title: "Deleted",
      message: "Download removed",
    );
  }

  void _saveToStorage() {
    storage.write('downloads', downloadedContent.map((e) => e.toJson()).toList());
    storage.write('paths', localPaths);
  }

  bool isDownloaded(String id) => localPaths.containsKey(id);

  String? getLocalPath(String id) => localPaths[id];
}
