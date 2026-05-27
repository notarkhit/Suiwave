import 'package:flutter/material.dart';

/// Represents a track from either YouTube Music or local library.
class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? albumArtUrl;
  final Duration duration;
  final bool isLocal;
  final String? localPath;
  final String? videoId; // YouTube Music
  final String? browseId; // YouTube Music album/playlist

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.albumArtUrl,
    this.duration = Duration.zero,
    this.isLocal = false,
    this.localPath,
    this.videoId,
    this.browseId,
  });

  String get displayArtist => artist.isEmpty ? 'Unknown artist' : artist;
  String get displayAlbum => album ?? 'Unknown album';

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumArtUrl,
    Duration? duration,
    bool? isLocal,
    String? localPath,
    String? videoId,
    String? browseId,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      duration: duration ?? this.duration,
      isLocal: isLocal ?? this.isLocal,
      localPath: localPath ?? this.localPath,
      videoId: videoId ?? this.videoId,
      browseId: browseId ?? this.browseId,
    );
  }

  @override
  bool operator ==(Object other) => other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
