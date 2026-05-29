import '../models/response_model/auth_response_model/send_otp_response.dart';
import '../models/response_model/auth_response_model/verify_otp_response.dart';
import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class AuthRepository {
  final BaseApiService apiProvider;

  AuthRepository(this.apiProvider);

  Future<SendOtpResponse> sendOtp(String identifier) async {
    try {
      final response = await apiProvider.postApi(AppConstants.sendOtp, {
        'identifier': identifier,
        'phone': identifier,   // 🔥 ADD THIS
        'type': 'phone',
      });
      return SendOtpResponse.fromJson(response);
    } catch (e) {
      return SendOtpResponse(message: e.toString());
    }
  }

  Future<VerifyOtpResponse?> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await apiProvider.postApi(AppConstants.verifyOtp, {
        'identifier': phoneNumber,
        'phone': phoneNumber,   // 🔥 ADD THIS
        'otp': otp,
        'type': 'phone',
      });
      return VerifyOtpResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<VerifyOtpResponse?> googleLogin(String idToken) async {
    try {
      final response = await apiProvider.postApi(AppConstants.googleLogin, {
        'idToken': idToken,
      });
      return VerifyOtpResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createProfile({
    required String phone,
    required String name,
    String? profileImage,
  }) async {
    try {
      if (profileImage != null && profileImage.isNotEmpty) {
        final response = await apiProvider.postMultipartApi(
          AppConstants.createProfile,
          {
            'phone': phone,
            'name': name,
          },
          {'profileImage': profileImage},
        );
        return response;
      } else {
        final response = await apiProvider.postApi(AppConstants.createProfile, {
          'phone': phone,
          'name': name,
        });
        return response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getProfile() async {
    try {
      final response = await apiProvider.getApi(AppConstants.getProfile);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
