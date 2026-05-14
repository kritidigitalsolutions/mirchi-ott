import 'dart:io';
import 'package:get/get.dart';
import '../../utils/constants.dart';

class ApiProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = AppConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: 30);
    super.onInit();
  }

  Future<Response> sendOtp(String phoneNumber) {
    return post(AppConstants.sendOtp, {
      'identifier': phoneNumber,
      'type': 'phone',
    });
  }

  Future<Response> verifyOtp(String phoneNumber, String otp) async {
    // Body: {"identifier": "...", "otp": "...", "type": "phone"}
    final res = await post(AppConstants.verifyOtp, {
      'identifier': phoneNumber,
      'otp': otp,
      'type': 'phone',
    });

    print("FULL VERIFY RESPONSE => ${res.body}");
    return res;
  }

  /// Create Profile with Image Upload
  Future<Response> createProfile({
    required String phone,
    required String name,
    required String email,
    String? imagePath,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "phone": phone,
        "name": name,
        "email": email,
      };

      if (imagePath != null) {
        final file = File(imagePath);
        if (file.existsSync()) {
          body["profileImage"] = MultipartFile(
            file.readAsBytesSync(),
            filename: imagePath.split('/').last,
          );
        }
      }

      final formData = FormData(body);
      final response = await post(
        AppConstants.createProfile,
        formData,
      );

      return response;
    } catch (e) {
      print("❌ EXCEPTION IN createProfile Provider: $e");
      return Response(statusCode: 500, statusText: e.toString());
    }
  }
}
