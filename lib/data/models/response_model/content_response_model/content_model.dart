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
  final int? position;
  final bool is18Plus;
  final bool isHide;
  final bool isPublished;
  final bool allAges;
  final int likes;
  final int dislikes;

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
    this.is18Plus = false,
    this.isHide = false,
    this.isPublished = true,
    this.allAges = false,
    this.likes = 0,
    this.dislikes = 0,
    this.releaseDate,
    this.priority,
    this.position,
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
    String type = (json['type'] ?? json['contentType'] ?? '').toString().toLowerCase();
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
      is18Plus: json['is18+'] ?? json['is18'] ?? json['is18plus'] ?? false,
      isHide: json['isHide'] ?? false,
      isPublished: json['isPublished'] ?? true,
      allAges: json['allAges'] ?? false,
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      releaseDate: json['releaseDate'],
      priority: json['priority'],
      position: json['position'],
      totalSeasons: json['totalSeasons'] ?? (json['seasons'] as List?)?.length,
      totalEpisodes: json['totalEpisodes'] ?? (json['seasons'] as List?)?.fold<int>(0, (sum, season) => sum + ((season['episodes'] as List?)?.length ?? 0)),
      seriesId: json['seriesId'],
      seasonNumber: json['seasonNumber'],
      episodeNumber: json['episodeNumber'],
    );
  }

  ContentModel copyWith({
    List<String>? category,
  }) {
    return ContentModel(
      id: id,
      title: title,
      description: description,
      genre: genre,
      releaseYear: releaseYear,
      duration: duration,
      language: language,
      poster: poster,
      banner: banner,
      videoUrl: videoUrl,
      trailerUrl: trailerUrl,
      isPremium: isPremium,
      rating: rating,
      cast: cast,
      category: category ?? this.category,
      slug: slug,
      contentType: contentType,
      isComingSoon: isComingSoon,
      isTrending: isTrending,
      is18Plus: is18Plus,
      isHide: isHide,
      isPublished: isPublished,
      allAges: allAges,
      likes: likes,
      dislikes: dislikes,
      releaseDate: releaseDate,
      priority: priority,
      position: position,
      totalSeasons: totalSeasons,
      totalEpisodes: totalEpisodes,
      seriesId: seriesId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
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
      'is18+': is18Plus,
      'isHide': isHide,
      'isPublished': isPublished,
      'allAges': allAges,
      'likes': likes,
      'dislikes': dislikes,
      'releaseDate': releaseDate,
      'priority': priority,
      'position': position,
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

  Cast({required this.name, required this.image, required this.id});

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
    return {'_id': id, 'name': name, 'image': image};
  }
}

class WebSectionModel {
  final String categorySlug;
  final String title;
  final List<ContentModel> items;

  WebSectionModel({
    required this.categorySlug,
    required this.title,
    required this.items,
  });

  factory WebSectionModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<ContentModel> parsedItems = itemsList.map((item) {
      var itemJson = Map<String, dynamic>.from(item);
      if (itemJson['category'] == null) {
        itemJson['category'] = [json['categorySlug']];
      }
      return ContentModel.fromJson(itemJson);
    }).where((c) {
      if (c.isHide || !c.isPublished) return false;
      return true;
    }).toList();

    return WebSectionModel(
      categorySlug: json['categorySlug'] ?? '',
      title: json['title'] ?? '',
      items: parsedItems,
    );
  }
}

