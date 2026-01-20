import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GitHubUpdateService {
  final Dio _dio = Dio();
  Future<Map<String, dynamic>?> getLatestGithubRelease({
    required String owner,
    required String repo,
    required String apkKey,
  }) async {
    try {
      final url = 'https://api.github.com/repos/$owner/$repo/releases/latest';
      final response = await _dio.get(
        url,
        options: Options(headers: {'Accept': 'application/vnd.github.v3+json'}),
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tagName = data['tag_name'] as String;
        final version = tagName.startsWith('v')
            ? tagName.substring(1)
            : tagName;
        final assets = data['assets'] as List<dynamic>;
        String? apkUrl;
        for (final asset in assets) {
          final String name = asset['name'];
          if (apkKey.isEmpty) {
            if (name.endsWith('.apk')) {
              apkUrl = asset['browser_download_url'];
              break;
            }
          } else {
            if (name.endsWith('.apk') && name.contains(apkKey)) {
              apkUrl = asset['browser_download_url'];
              break;
            }
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
