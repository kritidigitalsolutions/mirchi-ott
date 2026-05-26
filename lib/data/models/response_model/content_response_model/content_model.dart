import '../../../../utils/constants.dart';

class ContentModel {
  final String id;
  final String title;
  final String description;
  final List<String> genre;
  final int releaseYear;
  final String? duration;
  final String language;
  final String poster;
  final String banner;
  final String? videoUrl;
  final String? trailerUrl;
  final bool isPremium;
  final double rating;
  final List<Cast>? cast;
  final List<String> category;
  final String slug;
  final String contentType; // 'movie', 'series', 'episode'
  final bool isComingSoon;
  final bool isTrending;
  final String? releaseDate;
  final int? priority;
  
  // Series/Episode specific fields
  final int? totalSeasons;
  final int? totalEpisodes;
  final String? seriesId;
  final int? seasonNumber;
  final int? episodeNumber;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    required this.releaseYear,
    this.duration,
    required this.language,
    required this.poster,
    required this.banner,
    this.videoUrl,
    this.trailerUrl,
    required this.isPremium,
    required this.rating,
    this.cast,
    required this.category,
    required this.slug,
    required this.contentType,
    this.isComingSoon = false,
    this.isTrending = false,
    this.releaseDate,
    this.priority,
    this.totalSeasons,
    this.totalEpisodes,
    this.seriesId,
    this.seasonNumber,
    this.episodeNumber,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    String baseUrl = AppConstants.serverUrl;

    String formatUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      if (url.startsWith('http')) return url;
      return '$baseUrl$url';
    }

    // Determine content type from various possible keys
    String type = json['type'] ?? json['contentType'] ?? '';
    if (type.isEmpty && json['itemModel'] != null) {
      type = json['itemModel'].toString().toLowerCase();
    }
    if (type.isEmpty && json['seriesId'] != null) {
      type = 'episode';
    }

    return ContentModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      genre: List<String>.from(json['genre'] ?? []),
      releaseYear: json['releaseYear'] ?? 0,
      duration: json['duration'],
      language: json['language'] ?? '',
      poster: formatUrl(json['poster'] ?? json['thumbnail']),
      banner: formatUrl(json['banner'] ?? json['poster'] ?? json['thumbnail']),
      videoUrl: formatUrl(json['videoUrl']),
      trailerUrl: formatUrl(json['trailerUrl']),
      isPremium: json['isPremium'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      cast: json['cast'] != null
          ? List<Cast>.from(json['cast'].map((x) => Cast.fromJson(x)))
          : null,
      category: List<String>.from(json['category'] ?? []),
      slug: json['slug'] ?? '',
      contentType: type,
      isComingSoon: json['isComingSoon'] ?? false,
      isTrending: json['isTrending'] ?? false,
      releaseDate: json['releaseDate'],
      priority: json['priority'],
      totalSeasons: json['totalSeasons'],
      totalEpisodes: json['totalEpisodes'],
      seriesId: json['seriesId'],
      seasonNumber: json['seasonNumber'],
      episodeNumber: json['episodeNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'genre': genre,
      'releaseYear': releaseYear,
      'duration': duration,
      'language': language,
      'poster': poster,
      'banner': banner,
      'videoUrl': videoUrl,
      'trailerUrl': trailerUrl,
      'isPremium': isPremium,
      'rating': rating,
      'cast': cast?.map((e) => e.toJson()).toList(),
      'category': category,
      'slug': slug,
      'type': contentType,
      'isComingSoon': isComingSoon,
      'isTrending': isTrending,
      'releaseDate': releaseDate,
      'priority': priority,
      'totalSeasons': totalSeasons,
      'totalEpisodes': totalEpisodes,
      'seriesId': seriesId,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
    };
  }
}

class Cast {
  final String name;
  final String image;
  final String id;

  Cast({
    required this.name,
    required this.image,
    required this.id,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    String baseUrl = AppConstants.serverUrl;
    String formatUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      if (url.startsWith('http')) return url;
      return '$baseUrl$url';
    }

    return Cast(
      name: json['name'] ?? '',
      image: formatUrl(json['image']),
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
    };
  }
}
