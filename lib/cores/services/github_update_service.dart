import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GitHubUpdateService {
  final Dio _dio = Dio();

  /// Fetches the latest release info from GitHub.
  /// Returns a map with 'version' and 'apk_url' if successful.
  Future<Map<String, dynamic>?> getReleaseInfo({
    required String owner,
    required String repo,
    required String apkKey,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/$owner/$repo/releases/latest',
        options: Options(headers: {'Accept': 'application/vnd.github.v3+json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tagName = data['tag_name'] as String;
        // Remove 'v' prefix if present (e.g., 'v1.2.0' -> '1.2.0')
        final version = tagName.startsWith('v')
            ? tagName.substring(1)
            : tagName;

        final assets = data['assets'] as List<dynamic>;
        String? apkUrl;

        // Find the first .apk file in the assets that contains the apkKey
        for (final asset in assets) {
          final String name = asset['name'];
          if (name.endsWith('.apk') && name.contains(apkKey)) {
            apkUrl = asset['browser_download_url'];
            break;
          }
        }

        if (apkUrl != null) {
          return {'version': version, 'apk_url': apkUrl};
        }
      }
    } catch (e) {
      debugPrint('Error fetching release info from GitHub: $e');
    }
    return null;
  }
}
