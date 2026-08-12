import '../../utils/constants.dart';

class ShortDrama {
  final String id;
  final String title;
  final String description;
  final List<String> genre;
  final String language;
  final String poster;
  final String banner;
  final String? trailerUrl;
  final int totalEpisodes;
  final List<ShortCast>? cast;
  final List<String> category;
  final String slug;
  final bool is18Plus;
  final bool isHide;

  ShortDrama({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    required this.language,
    required this.poster,
    required this.banner,
    this.trailerUrl,
    required this.totalEpisodes,
    this.cast,
    required this.category,
    required this.slug,
    this.is18Plus = false,
    this.isHide = false,
  });

  factory ShortDrama.fromJson(Map<String, dynamic> json) {
    String formatUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      if (url.startsWith('http')) return url;
      String path = url.startsWith('/') ? url : '/$url';
      return '${AppConstants.serverUrl}$path';
    }

    return ShortDrama(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      genre: List<String>.from(json['genre'] ?? []),
      language: json['language']?.toString().replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').replaceAll(',', ', ') ?? '',
      poster: formatUrl(json['poster']),
      banner: formatUrl(json['banner']),
      trailerUrl: formatUrl(json['trailerUrl']),
      totalEpisodes: json['totalEpisodes'] ?? 0,
      cast: json['cast'] != null
          ? List<ShortCast>.from(json['cast'].map((x) => ShortCast.fromJson(x)))
          : null,
      category: List<String>.from(json['category'] ?? []),
      slug: json['slug'] ?? '',
      is18Plus: json['is18+'] ?? json['is18'] ?? json['is18plus'] ?? false,
      isHide: json['isHide'] ?? false,
    );
  }
}

class ShortCast {
  final String name;
  final String image;
  final String id;

  ShortCast({
    required this.name,
    required this.image,
    required this.id,
  });

  factory ShortCast.fromJson(Map<String, dynamic> json) {
    String formatUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      if (url.startsWith('http')) return url;
      String path = url.startsWith('/') ? url : '/$url';
      return '${AppConstants.serverUrl}$path';
    }

    return ShortCast(
      name: json['name'] ?? '',
      image: formatUrl(json['image']),
      id: json['_id'] ?? '',
    );
  }
}

class ShortEpisode {
  final String id;
  final String shortDramaId;
  final int episodeNumber;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnail;
  final String duration;
  final bool isLocked;
  final bool isVertical;
  final bool is18Plus;
  final bool isHide;

  ShortEpisode({
    required this.id,
    required this.shortDramaId,
    required this.episodeNumber,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnail,
    required this.duration,
    required this.isLocked,
    required this.isVertical,
    this.is18Plus = false,
    this.isHide = false,
  });

  factory ShortEpisode.fromJson(Map<String, dynamic> json) {
    String formatUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      if (url.startsWith('http')) return url;
      String path = url.startsWith('/') ? url : '/$url';
      return '${AppConstants.serverUrl}$path';
    }

    return ShortEpisode(
      id: json['_id'] ?? '',
      shortDramaId: json['shortDramaId'] ?? '',
      episodeNumber: json['episodeNumber'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: formatUrl(json['videoUrl']),
      thumbnail: formatUrl(json['thumbnail']),
      duration: json['duration'] ?? '',
      isLocked: json['isLocked'] ?? false,
      isVertical: json['isVertical'] ?? true,
      is18Plus: json['is18+'] ?? json['is18'] ?? json['is18plus'] ?? false,
      isHide: json['isHide'] ?? false,
    );
  }
}
