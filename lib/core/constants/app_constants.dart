/// App-wide constants for Suiwave.
class AppConstants {
  AppConstants._();

  static const String appName = 'Suiwave';
  static const String appVersion = '0.1.0';

  // Supported local audio formats
  static const List<String> supportedFormats = [
    'mp3',
    'flac',
    'ogg',
    'm4a',
    'opus',
    'wav',
    'aac',
  ];

  // InnerTube (Phase 2)
  static const String innertubeApiKey = 'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
  static const String innertubeBaseUrl = 'https://music.youtube.com/youtubei/v1';
  static const String innertubeClientName = 'WEB_REMIX';
  static const String innertubeClientVersion = '1.20240101.00.00';

  // LRCLib (Phase 2)
  static const String lrclibBaseUrl = 'https://lrclib.net/api';

  // Default directories
  static const String defaultMusicFolder = 'Music';

  // Database
  static const String databaseName = 'suiwave.db';
  static const int databaseVersion = 1;

  // Sync
  static const String syncBundleExtension = '.suiwave';
  static const int lanSyncPort = 54321;
}
