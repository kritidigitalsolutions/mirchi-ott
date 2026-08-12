class VerifyOtpResponse {
  final bool success;
  final bool isNewUser;
  final String? phone;
  final String? message;
  final String? token;
  final Map<String, dynamic>? user;

  VerifyOtpResponse({
    required this.success,
    required this.isNewUser,
    this.phone,
    this.message,
    this.token,
    this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] ?? false,
      isNewUser: json['isNewUser'] ?? false,
      phone: json['phone'],
      message: json['message'],
      token: json['token'],
      user: json['user'],
    );
  }
}
