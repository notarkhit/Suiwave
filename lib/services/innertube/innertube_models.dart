// ---------------------------------------------------------------------------
// InnerTube request / response models (Dart port of vivi-music's Kotlin models)
// ---------------------------------------------------------------------------

// Request context mirrors YouTubeClient.toContext() in the reference
class InnerTubeContext {
  final String clientName;
  final String clientVersion;
  final String? gl;
  final String? hl;

  const InnerTubeContext({
    required this.clientName,
    required this.clientVersion,
    this.gl,
    this.hl,
  });

  Map<String, dynamic> toJson() => {
        'client': {
          'clientName': clientName,
          'clientVersion': clientVersion,
          if (gl != null) 'gl': gl,
          if (hl != null) 'hl': hl,
        },
        'user': {'lockedSafetyMode': false},
      };
}

// ---------------------------------------------------------------------------
// Thumbnails
// ---------------------------------------------------------------------------

class YTThumbnail {
  final String url;
  final int? width;
  final int? height;

  const YTThumbnail({required this.url, this.width, this.height});

  factory YTThumbnail.fromJson(Map<String, dynamic> j) => YTThumbnail(
        url: j['url'] as String,
        width: j['width'] as int?,
        height: j['height'] as int?,
      );

  static List<YTThumbnail> listFromJson(dynamic thumbnails) {
    if (thumbnails == null) return [];
    return (thumbnails as List).map((t) => YTThumbnail.fromJson(t)).toList();
  }

  /// Highest-resolution thumbnail from a list.
  static String? bestUrl(List<YTThumbnail> thumbs) {
    if (thumbs.isEmpty) return null;
    thumbs.sort((a, b) => (b.width ?? 0).compareTo(a.width ?? 0));
    return thumbs.first.url;
  }
}

// ---------------------------------------------------------------------------
// Home feed item (song / album / playlist card from browse FEmusic_home)
// ---------------------------------------------------------------------------

enum YTItemType { song, album, playlist, artist, unknown }

class YTItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? thumbnailUrl;
  final YTItemType type;
  final String? videoId;  // for songs
  final String? browseId; // for albums / artists / playlists

  const YTItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.thumbnailUrl,
    this.type = YTItemType.unknown,
    this.videoId,
    this.browseId,
  });
}

class HomeSection {
  final String title;
  final List<YTItem> items;

  const HomeSection({required this.title, required this.items});
}

// ---------------------------------------------------------------------------
// Search result
// ---------------------------------------------------------------------------

class SearchItem {
  final String id;
  final String title;
  final String? artist;
  final String? album;
  final String? thumbnailUrl;
  final String? videoId;
  final int? durationSeconds;
  final YTItemType type;

  const SearchItem({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    this.thumbnailUrl,
    this.videoId,
    this.durationSeconds,
    this.type = YTItemType.song,
  });
}

// ---------------------------------------------------------------------------
// Player stream
// ---------------------------------------------------------------------------

class AudioStream {
  final String url;
  final String mimeType;
  final int bitrate;
  final int? contentLength;

  const AudioStream({
    required this.url,
    required this.mimeType,
    required this.bitrate,
    this.contentLength,
  });
}
