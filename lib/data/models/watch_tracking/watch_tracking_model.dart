class WatchStartRequest {
  final String episodeId;
  final String sessionId;
  final String? platform;
  final String deviceId;
  final int? durationSec;

  WatchStartRequest({
    required this.episodeId,
    required this.sessionId,
    this.platform,
    required this.deviceId,
    this.durationSec,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'episodeId': episodeId,
      'sessionId': sessionId,
      'deviceId': deviceId,
    };
    if (platform != null) map['platform'] = platform;
    if (durationSec != null) map['durationSec'] = durationSec;
    return map;
  }
}

class WatchProgressRequest {
  final String sessionId;
  final int positionSec;
  final int deltaSec;

  WatchProgressRequest({
    required this.sessionId,
    required this.positionSec,
    required this.deltaSec,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'positionSec': positionSec,
    'deltaSec': deltaSec,
  };
}

class WatchShareRequest {
  final String seriesId;
  final String? episodeId;
  final String? platform;
  final String deviceId;

  WatchShareRequest({
    required this.seriesId,
    this.episodeId,
    this.platform,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'seriesId': seriesId,
      'deviceId': deviceId,
    };
    if (episodeId != null && episodeId!.isNotEmpty) {
      map['episodeId'] = episodeId;
    }
    if (platform != null) map['platform'] = platform;
    return map;
  }
}

class ContinueWatchingResponse {
  final bool success;
  final List<ContinueWatchingItem> items;
  final String? message;

  ContinueWatchingResponse({
    required this.success,
    required this.items,
    this.message,
  });

  factory ContinueWatchingResponse.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingResponse(
      success: json['success'] ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ContinueWatchingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}

class ContinueWatchingItem {
  final ContinueWatchingSeries? series;
  final ContinueWatchingEpisode? episode;
  final int positionSec;
  final int durationSec;
  final double progress;
  final String? lastWatchedAt;

  ContinueWatchingItem({
    this.series,
    this.episode,
    required this.positionSec,
    required this.durationSec,
    required this.progress,
    this.lastWatchedAt,
  });

  factory ContinueWatchingItem.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingItem(
      series: json['series'] != null
          ? ContinueWatchingSeries.fromJson(json['series'] as Map<String, dynamic>)
          : null,
      episode: json['episode'] != null
          ? ContinueWatchingEpisode.fromJson(json['episode'] as Map<String, dynamic>)
          : null,
      positionSec: (json['positionSec'] as num?)?.toInt() ?? 0,
      durationSec: (json['durationSec'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      lastWatchedAt: json['lastWatchedAt']?.toString(),
    );
  }
}

class ContinueWatchingSeries {
  final String id;
  final String title;
  final String slug;
  final String poster;
  final String banner;

  ContinueWatchingSeries({
    required this.id,
    required this.title,
    required this.slug,
    required this.poster,
    required this.banner,
  });

  factory ContinueWatchingSeries.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingSeries(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      poster: json['poster']?.toString() ?? '',
      banner: json['banner']?.toString() ?? '',
    );
  }
}

class ContinueWatchingEpisode {
  final String id;
  final String title;
  final int seasonNumber;
  final int episodeNumber;
  final String thumbnail;

  ContinueWatchingEpisode({
    required this.id,
    required this.title,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.thumbnail,
  });

  factory ContinueWatchingEpisode.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingEpisode(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      seasonNumber: (json['seasonNumber'] as num?)?.toInt() ?? 1,
      episodeNumber: (json['episodeNumber'] as num?)?.toInt() ?? 1,
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }
}
