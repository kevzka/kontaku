import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ImageCacheService {
  /// Generates cache directory path for images
  static Future<String?> getCachePath({
    required String cacheKey,
  }) async {
    if (cacheKey.isEmpty) {
      return null;
    }

    final dir = Directory('${Directory.systemTemp.path}/kontaku_image_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '${dir.path}/image_$cacheKey.bin';
  }

  /// Validates if bytes look like valid image data
  static bool looksLikeImageBytes(Uint8List bytes) {
    if (bytes.length < 12) {
      return false;
    }

    final isJpg = bytes[0] == 0xFF && bytes[1] == 0xD8;
    final isPng = bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final isWebp = bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;

    return isJpg || isPng || isWebp;
  }

  /// Downloads image bytes from remote URL
  /// Handles ISP blocks and redirects
  static Future<Uint8List?> downloadImageBytes(Uri uri) async {
    try {
      // Create HTTP client with proper headers to bypass ISP blocks
      final client = http.Client();
      
      try {
        final request = http.Request('GET', uri);
        
        // Add User-Agent to avoid ISP block
        request.headers['User-Agent'] =
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
        request.headers['Accept'] = 'image/*';
        request.headers['Connection'] = 'keep-alive';
        
        final response = await client.send(request).timeout(
          const Duration(seconds: 10),
        );

        // Check content type and status
        final contentType = response.headers['content-type'] ?? '';
        final isImageContent = contentType.contains('image');
        
        if (!isImageContent) {
          debugPrint('[ImageCache] Not image content: $contentType');
          return null;
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final bytes = await response.stream.toBytes();
          if (looksLikeImageBytes(bytes)) {
            debugPrint('[ImageCache] Successfully downloaded image: $uri');
            return bytes;
          }
        }
        return null;
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('[ImageCache] Error downloading image: $e');
      return null;
    }
  }

  /// Reads image bytes from local cache
  static Future<Uint8List?> readFromCache({
    required String cacheKey,
  }) async {
    final path = await getCachePath(cacheKey: cacheKey);
    if (path == null) {
      return null;
    }

    final file = File(path);
    if (!await file.exists()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    if (!looksLikeImageBytes(bytes)) {
      return null;
    }
    return bytes;
  }

  /// Writes image bytes to local cache
  static Future<void> writeToCache({
    required String cacheKey,
    required Uint8List bytes,
  }) async {
    if (!looksLikeImageBytes(bytes)) {
      return;
    }

    final path = await getCachePath(cacheKey: cacheKey);
    if (path == null) {
      return;
    }

    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  /// Downloads image from remote URL and caches it
  /// Returns null if download fails
  static Future<Uint8List?> downloadAndCache({
    required String? imageUrl,
    required String cacheKey,
  }) async {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      debugPrint('[ImageCache] Invalid URL: $url');
      return null;
    }

    // Only accept https for security
    if (uri.scheme != 'https') {
      debugPrint('[ImageCache] Non-HTTPS URL rejected: $url');
      return null;
    }

    try {
      final bytes = await downloadImageBytes(uri);
      if (bytes == null) {
        return null;
      }

      await writeToCache(cacheKey: cacheKey, bytes: bytes);
      return bytes;
    } catch (e) {
      debugPrint('[ImageCache] Download and cache failed: $e');
      return null;
    }
  }

  /// Gets cached image or downloads it if not cached
  /// Returns MemoryImage if successful, null otherwise
  static Future<ImageProvider<Object>?> getImageProvider({
    required String? imageUrl,
    required String cacheKey,
  }) async {
    // Try to read from cache first
    var bytes = await readFromCache(cacheKey: cacheKey);

    // If not in cache, download it
    if (bytes == null) {
      bytes = await downloadAndCache(imageUrl: imageUrl, cacheKey: cacheKey);
      debugPrint("image download");
    }

    if (bytes == null) {
      return null;
    }

    return MemoryImage(bytes);
  }
}
