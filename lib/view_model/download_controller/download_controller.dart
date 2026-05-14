import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../utils/custom_snackbar.dart';

class DownloadController extends GetxController {
  final storage = GetStorage();
  final Dio dio = Dio();

  var downloadedContent = <ContentModel>[].obs;

  var isDownloading = <String, bool>{}.obs;
  var downloadProgress = <String, double>{}.obs;
  var localPaths = <String, String>{}.obs;

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

    try {
      isDownloading[content.id] = true;
      downloadProgress[content.id] = 0;

      Directory dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/${content.id}.mp4";

      await dio.download(
        content.videoUrl!,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress[content.id] = received / total;
          }
        },
      );

      localPaths[content.id] = filePath;

      if (!downloadedContent.any((e) => e.id == content.id)) {
        downloadedContent.add(content);
      }

      _saveToStorage();

      CustomSnackbar.show(
        title: "Downloaded",
        message: "${content.title} saved offline ✅",
        isSuccess: true,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: "Error",
        message: "Download failed",
        isError: true,
      );
    } finally {
      isDownloading[content.id] = false;
    }
  }

  void removeDownload(String contentId) {
    // delete file also
    if (localPaths.containsKey(contentId)) {
      File(localPaths[contentId]!).deleteSync();
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
