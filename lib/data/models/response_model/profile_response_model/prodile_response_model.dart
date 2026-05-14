class CreateProfileResponse {
  final bool success;
  final String message;
  final String token;

  CreateProfileResponse({
    required this.success,
    required this.message,
    required this.token,
  });

  factory CreateProfileResponse.fromJson(Map<String, dynamic> json) {
    return CreateProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? json['data']?['token'] ?? '',
    );
  }
}
