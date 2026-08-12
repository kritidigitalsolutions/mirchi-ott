class WatchlistResponseModel {
  final String message;
  final WatchlistData? data; // 👈 nullable

  WatchlistResponseModel({
    required this.message,
    this.data,
  });

  factory WatchlistResponseModel.fromJson(Map<String, dynamic> json) {
    return WatchlistResponseModel(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? WatchlistData.fromJson(json['data'])
          : null,
    );
  }
}

class WatchlistData {
  final String id;
  final String user;
  final String movie;

  WatchlistData({
    required this.id,
    required this.user,
    required this.movie,
  });

  factory WatchlistData.fromJson(Map<String, dynamic> json) {
    return WatchlistData(
      id: json['_id'],
      user: json['user'],
      movie: json['movie'],
    );
  }
}
