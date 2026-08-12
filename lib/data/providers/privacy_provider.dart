import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mirchi_ott/utils/constants.dart';

class PrivacyService {
  static Future<Map<String, dynamic>?> getPrivacyPolicy() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.privacyPolicyUrl),
      );

      print("API STATUS: ${response.statusCode}");
      print("API BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("ERROR: $e");
    }
    return null;
  }

/// terms and conditions
  static Future<Map<String, dynamic>?> getTerms() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.termsAndConditionsUrl),
      );

      print("TERMS STATUS: ${response.statusCode}");
      print("TERMS BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("ERROR TERMS: $e");
    }
    return null;
  }
/// refund policy
  static Future<Map<String, dynamic>?> getRefundPolicy() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.refundPolicy),
      );

      print("REFUND STATUS: ${response.statusCode}");
      print("REFUND BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("ERROR REFUND: $e");
    }
    return null;
  }
/// help & support
  static Future<List<dynamic>> getHelpData() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.helpSupport),
      );

      print("HELP STATUS: ${response.statusCode}");
      print("HELP BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['helpData'] ?? [];
      }
    } catch (e) {
      print("ERROR HELP: $e");
    }
    return [];
  }
}
