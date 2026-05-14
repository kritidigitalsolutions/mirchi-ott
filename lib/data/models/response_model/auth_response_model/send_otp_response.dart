class SendOtpResponse {
  final String message;
  final String? sessionId;
  final String? otp;

  SendOtpResponse({
    required this.message,
    this.sessionId,
    this.otp,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      message: json['message'] ?? '',
      sessionId: json['sessionId'],
      otp: json['otp'],
    );
  }
}
