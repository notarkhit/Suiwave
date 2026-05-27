import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song.dart';
import 'innertube/innertube_client.dart';
import 'innertube/innertube_models.dart';

// ---------------------------------------------------------------------------
// Home feed
// ---------------------------------------------------------------------------

final homeFeedProvider = FutureProvider<List<HomeSection>>((ref) async {
  final response = await InnerTubeClient.browse('FEmusic_home');
  return InnerTubeParser.parseHomeFeed(response);
});

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------


final searchResultsProvider =
    FutureProvider.family<List<SearchItem>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  // Use the FILTER_SONG param to get a clean list of songs
  final response = await InnerTubeClient.search(
    query,
    params: 'EgWKAQIIAWoMEAMQBBAJEA4QChAFEBEQEBAU',
  );
  return InnerTubeParser.parseSearch(response);
});

// ---------------------------------------------------------------------------
// Stream URL (for a given videoId)
// ---------------------------------------------------------------------------

final streamUrlProvider =
    FutureProvider.family<AudioStream?, String>((ref, videoId) async {
  final response = await InnerTubeClient.player(videoId);
  return InnerTubeParser.parseBestAudioStream(response);
});

// ---------------------------------------------------------------------------
// Converter: YTItem / SearchItem → Song
// ---------------------------------------------------------------------------

extension YTItemToSong on YTItem {
  Song toSong() => Song(
        id: videoId ?? id,
        title: title,
        artist: subtitle ?? '',
        albumArtUrl: thumbnailUrl,
        videoId: videoId,
        browseId: browseId,
      );
}

extension SearchItemToSong on SearchItem {
  Song toSong() => Song(
        id: videoId ?? id,
        title: title,
        artist: artist ?? '',
        album: album,
        albumArtUrl: thumbnailUrl,
        duration: durationSeconds != null
            ? Duration(seconds: durationSeconds!)
            : Duration.zero,
        videoId: videoId,
      );
}
