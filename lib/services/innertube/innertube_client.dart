import 'dart:convert';
import 'package:dio/dio.dart';
import 'innertube_models.dart';

/// Low-level InnerTube HTTP client.
///
/// Mirrors InnerTube.kt from vivi-music:
/// - Base URL: https://music.youtube.com/youtubei/v1/
/// - Client: WEB_REMIX (clientId 67, version 1.20260213.01.00)
class InnerTubeClient {
  InnerTubeClient._();

  static const _baseUrl = 'https://music.youtube.com/youtubei/v1';
  static const _origin = 'https://music.youtube.com';
  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0';

  // WEB_REMIX — same values as YouTubeClient.WEB_REMIX in vivi-music reference
  static const _clientName = 'WEB_REMIX';
  static const _clientId = '67';
  static const _clientVersion = '1.20260213.01.00';

  static final _dio = Dio(
    BaseOptions(
      baseUrl: '$_baseUrl/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Goog-Api-Format-Version': '1',
        'X-YouTube-Client-Name': _clientId,
        'X-YouTube-Client-Version': _clientVersion,
        'X-Origin': _origin,
        'Referer': '$_origin/',
        'User-Agent': _userAgent,
      },
    ),
  );

  static String? _visitorData;

  static void _updateVisitorData(Map<String, dynamic> response) {
    final vData = response.m('responseContext')?.s('visitorData');
    if (vData != null && vData.isNotEmpty) {
      _visitorData = vData;
    }
  }

  static Map<String, dynamic> get _context => {
        'context': {
          'client': {
            'clientName': _clientName,
            'clientVersion': _clientVersion,
            'hl': 'en',
            'gl': 'US',
            if (_visitorData != null) 'visitorData': _visitorData,
          },
          'user': {'lockedSafetyMode': false},
        }
      };

  // -------------------------------------------------------------------------
  // browse — home feed, albums, artists, playlists
  // -------------------------------------------------------------------------

  static Future<Map<String, dynamic>> browse(
    String browseId, {
    String? params,
    String? continuation,
  }) async {
    final body = {
      ..._context,
      if (browseId.isNotEmpty) 'browseId': browseId,
      if (params != null) 'params': params,
      if (continuation != null) 'continuation': continuation,
    };
    final qp = <String, String>{'prettyPrint': 'false'};
    if (continuation != null) {
      qp['ctoken'] = continuation;
      qp['continuation'] = continuation;
    }
    final resp = await _dio.post<Map<String, dynamic>>(
      'browse',
      data: body,
      queryParameters: qp,
    );
    _updateVisitorData(resp.data!);
    return resp.data!;
  }

  // -------------------------------------------------------------------------
  // search
  // -------------------------------------------------------------------------

  static Future<Map<String, dynamic>> search(
    String query, {
    String? params,
    String? continuation,
  }) async {
    final body = {
      ..._context,
      if (query.isNotEmpty) 'query': query,
      if (params != null) 'params': params,
      if (continuation != null) 'continuation': continuation,
    };
    final resp = await _dio.post<Map<String, dynamic>>(
      'search',
      data: body,
      queryParameters: {'prettyPrint': 'false'},
    );
    _updateVisitorData(resp.data!);
    return resp.data!;
  }

  // -------------------------------------------------------------------------
  // player — stream URLs
  // -------------------------------------------------------------------------

  static Future<Map<String, dynamic>> player(String videoId) async {
    const vrUserAgent = 'com.google.android.apps.youtube.vr.oculus/1.43.32 (Linux; U; Android 12; en_US; Quest 3; Build/SQ3A.220605.009.A1; Cronet/107.0.5284.2)';
    final body = {
      'context': {
        'client': {
          'clientName': 'ANDROID_VR',
          'clientVersion': '1.43.32',
          'osName': 'Android',
          'osVersion': '12',
          'deviceMake': 'Oculus',
          'deviceModel': 'Quest 3',
          'androidSdkVersion': '32',
          'hl': 'en',
          'gl': 'US',
          if (_visitorData != null) 'visitorData': _visitorData,
        },
        'user': {'lockedSafetyMode': false},
      },
      'videoId': videoId,
    };

    final resp = await _dio.post<Map<String, dynamic>>(
      'player',
      data: body,
      queryParameters: {'prettyPrint': 'false'},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Goog-Api-Format-Version': '1',
          'X-YouTube-Client-Name': '28',
          'X-YouTube-Client-Version': '1.43.32',
          'X-Origin': 'https://music.youtube.com',
          'Referer': 'https://music.youtube.com/',
          'User-Agent': vrUserAgent,
          if (_visitorData != null) 'X-Goog-Visitor-Id': _visitorData!,
        },
      ),
    );
    _updateVisitorData(resp.data!);
    return resp.data!;
  }
}

// ---------------------------------------------------------------------------
// JSON helpers — safe nested access
// ---------------------------------------------------------------------------

extension _MapEx on Map<String, dynamic> {
  Map<String, dynamic>? m(String key) => this[key] as Map<String, dynamic>?;
  List<dynamic>? l(String key) => this[key] as List<dynamic>?;
  String? s(String key) => this[key] as String?;
  int? i(String key) => this[key] as int?;
}

// ---------------------------------------------------------------------------
// Response parsers
// ---------------------------------------------------------------------------

class InnerTubeParser {
  // -------------------------------------------------------------------------
  // Home feed: browse FEmusic_home
  // -------------------------------------------------------------------------

  static List<HomeSection> parseHomeFeed(Map<String, dynamic> response) {
    if (response.containsKey('error')) {
      print('InnerTube API Error: ${response['error']}');
      throw Exception('API Error: ${response['error']}');
    }
    
    final sections = <HomeSection>[];
    try {
      final tabs = response
          .m('contents')
          ?.m('singleColumnBrowseResultsRenderer')
          ?.l('tabs');
      if (tabs == null || tabs.isEmpty) {
        print('No tabs found in home response. Keys: ${response.keys}');
        return sections;
      }

      final contents = (tabs.first as Map<String, dynamic>)
          .m('tabRenderer')
          ?.m('content')
          ?.m('sectionListRenderer')
          ?.l('contents');
      if (contents == null) {
        print('No sectionListRenderer contents found.');
        return sections;
      }

      for (final content in contents) {
        final c = content as Map<String, dynamic>;
        final shelf = c.m('musicCarouselShelfRenderer');
        if (shelf == null) continue;

        final runs = shelf
            .m('header')
            ?.m('musicCarouselShelfBasicHeaderRenderer')
            ?.m('title')
            ?.l('runs');
        final title = (runs?.firstOrNull as Map<String, dynamic>?)?.s('text');
        if (title == null) continue;

        final items = _parseTwoRowItems(shelf.l('contents'));
        if (items.isNotEmpty) {
          sections.add(HomeSection(title: title, items: items));
        }
      }
    } catch (e, st) {
      print('parseHomeFeed Exception: $e\\n$st');
      rethrow;
    }
    return sections;
  }

  static List<YTItem> _parseTwoRowItems(List<dynamic>? contents) {
    if (contents == null) return [];
    final items = <YTItem>[];
    for (final c in contents) {
      final m = (c as Map<String, dynamic>).m('musicTwoRowItemRenderer');
      if (m == null) continue;

      final runs = m.m('title')?.l('runs');
      final title = (runs?.firstOrNull as Map<String, dynamic>?)?.s('text');
      if (title == null) continue;

      final subtitle = m.m('subtitle')?.l('runs')
          ?.map((r) => (r as Map<String, dynamic>).s('text') ?? '')
          .join('');

      final thumbs = YTThumbnail.listFromJson(
        m.m('thumbnailRenderer')
            ?.m('musicThumbnailRenderer')
            ?.m('thumbnail')
            ?.l('thumbnails'),
      );

      final nav = m.m('navigationEndpoint');
      final browseId = nav?.m('browseEndpoint')?.s('browseId');

      // videoId from overlay play button (most reliable for songs)
      final overlayVideoId = m
          .m('overlay')
          ?.m('musicItemThumbnailOverlayRenderer')
          ?.m('content')
          ?.m('musicPlayButtonRenderer')
          ?.m('playNavigationEndpoint')
          ?.m('watchEndpoint')
          ?.s('videoId');

      final videoId = overlayVideoId ?? nav?.m('watchEndpoint')?.s('videoId');

      final type = _inferTypeFromBrowseId(browseId) ??
          (videoId != null ? YTItemType.song : YTItemType.unknown);

      items.add(YTItem(
        id: videoId ?? browseId ?? title,
        title: title,
        subtitle: subtitle,
        thumbnailUrl: YTThumbnail.bestUrl(thumbs),
        type: type,
        videoId: videoId,
        browseId: browseId,
      ));
    }
    return items;
  }

  static String? _visitorData;

  static void _updateVisitorData(Map<String, dynamic> response) {
    final vData = response.m('responseContext')?.s('visitorData');
    if (vData != null && vData.isNotEmpty) {
      _visitorData = vData;
    }
  }

  // -------------------------------------------------------------------------
  // Search results
  // -------------------------------------------------------------------------

  static List<SearchItem> parseSearch(Map<String, dynamic> response) {
    if (response.containsKey('error')) {
      print('InnerTube API Error: ${response['error']}');
      throw Exception('API Error: ${response['error']}');
    }

    final items = <SearchItem>[];
    try {
      final tabs = response
          .m('contents')
          ?.m('tabbedSearchResultsRenderer')
          ?.l('tabs');
      if (tabs == null || tabs.isEmpty) {
        print('No tabs found in search response. Keys: ${response.keys}');
        return items;
      }

      final contents = (tabs.first as Map<String, dynamic>)
          .m('tabRenderer')
          ?.m('content')
          ?.m('sectionListRenderer')
          ?.l('contents');
      if (contents == null) {
        print('No sectionListRenderer contents found in search.');
        return items;
      }

      for (final section in contents) {
        final shelf =
            (section as Map<String, dynamic>).m('musicShelfRenderer');
        if (shelf == null) continue;

        for (final c in (shelf.l('contents') ?? [])) {
          final renderer =
              (c as Map<String, dynamic>).m('musicResponsiveListItemRenderer');
          if (renderer == null) continue;

          final item = _parseResponsiveListItem(renderer);
          if (item != null) items.add(item);
        }
      }
    } catch (e, st) {
      print('parseSearch Exception: $e\\n$st');
      rethrow;
    }
    return items;
  }

  static SearchItem? _parseResponsiveListItem(Map<String, dynamic> r) {
    try {
      final flexColumns = r.l('flexColumns') ?? [];
      if (flexColumns.isEmpty) return null;

      String? col(int idx) {
        if (flexColumns.length <= idx) return null;
        return ((flexColumns[idx] as Map<String, dynamic>)
                .m('musicResponsiveListItemFlexColumnRenderer')
                ?.m('text')
                ?.l('runs')
                ?.firstOrNull as Map<String, dynamic>?)
            ?.s('text');
      }

      final title = col(0);
      if (title == null) return null;

      final thumbs = YTThumbnail.listFromJson(
        r.m('thumbnail')
            ?.m('musicThumbnailRenderer')
            ?.m('thumbnail')
            ?.l('thumbnails'),
      );

      final videoId = r.m('playlistItemData')?.s('videoId') ??
          r.m('navigationEndpoint')?.m('watchEndpoint')?.s('videoId') ??
          r.m('overlay')
              ?.m('musicItemThumbnailOverlayRenderer')
              ?.m('content')
              ?.m('musicPlayButtonRenderer')
              ?.m('playNavigationEndpoint')
              ?.m('watchEndpoint')
              ?.s('videoId');

      int? durationSeconds;
      final fixed = r.l('fixedColumns');
      if (fixed != null && fixed.isNotEmpty) {
        final dur = ((fixed.first as Map<String, dynamic>)
                .m('musicResponsiveListItemFixedColumnRenderer')
                ?.m('text')
                ?.l('runs')
                ?.firstOrNull as Map<String, dynamic>?)
            ?.s('text');
        if (dur != null) {
          final parts = dur.split(':');
          if (parts.length == 2) {
            durationSeconds =
                int.parse(parts[0]) * 60 + int.parse(parts[1]);
          }
        }
      }

      return SearchItem(
        id: videoId ?? title,
        title: title,
        artist: col(1),
        album: col(2),
        thumbnailUrl: YTThumbnail.bestUrl(thumbs),
        videoId: videoId,
        durationSeconds: durationSeconds,
        type: YTItemType.song,
      );
    } catch (e, st) {
      print('_parseResponsiveListItem exception: $e\\n$st');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Player — extract best audio stream
  // -------------------------------------------------------------------------

  static AudioStream? parseBestAudioStream(Map<String, dynamic> response) {
    try {
      final formats =
          response.m('streamingData')?.l('adaptiveFormats') ?? [];
      final audioFormats = formats
          .cast<Map<String, dynamic>>()
          .where((f) => (f.s('mimeType') ?? '').startsWith('audio/'))
          .toList()
        ..sort((a, b) =>
            (b.i('bitrate') ?? 0).compareTo(a.i('bitrate') ?? 0));

      if (audioFormats.isEmpty) return null;

      final best = audioFormats.first;
      final url = best.s('url');
      if (url == null) return null;

      return AudioStream(
        url: url,
        mimeType: best.s('mimeType') ?? 'audio/webm',
        bitrate: best.i('bitrate') ?? 0,
        contentLength: int.tryParse(best.s('contentLength') ?? ''),
      );
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  static YTItemType? _inferTypeFromBrowseId(String? id) {
    if (id == null) return null;
    if (id.startsWith('MPREb_')) return YTItemType.album;
    if (id.startsWith('UC') || id.startsWith('FE')) return YTItemType.artist;
    if (id.startsWith('VL') || id.startsWith('PL') || id.startsWith('RDCL')) {
      return YTItemType.playlist;
    }
    return null;
  }
}

extension _Ex<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
