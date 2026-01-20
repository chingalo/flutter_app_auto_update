import 'package:auto_update_app/cores/constants/github_references.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'github_update_service.dart';

class UpdateService {
  final GitHubUpdateService _gitHubUpdateService = GitHubUpdateService();
  final Dio _dio = Dio();

  //this is link to channel for access native codes
  static const platform = MethodChannel(
    'com.example.auto_update_app/installer',
  );

  Future<Map<String, dynamic>?> checkUpdate() async {
    // Replace with correctly informations
    final releaseInfo = await _gitHubUpdateService.getReleaseInfo(
      owner: GitHubReferences.owner,
      repo: GitHubReferences.repo,
      apkKey: GitHubReferences.apkKey,
    );

    if (releaseInfo == null) return null;

    final serverVersion = releaseInfo['version'] as String?;
    final apkUrl = releaseInfo['apk_url'] as String?;

    if (serverVersion == null || apkUrl == null) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    if (_isNewerVersion(serverVersion, currentVersion)) {
      return {'version': serverVersion, 'apk_url': apkUrl};
    }

    return null;
  }

  bool _isNewerVersion(String serverVersion, String currentVersion) {
    List<int> serverVersions = serverVersion.split('.').map(int.parse).toList();
    List<int> currentVersions = currentVersion
        .split('.')
        .map(int.parse)
        .toList();
    for (
      int versionIndex = 0;
      versionIndex < serverVersions.length;
      versionIndex++
    ) {
      if (versionIndex >= currentVersions.length) return true;
      if (serverVersions[versionIndex] > currentVersions[versionIndex]) {
        return true;
      }
      if (serverVersions[versionIndex] < currentVersions[versionIndex]) {
        return false;
      }
    }
    return false;
  }

  Future<String?> downloadAPK(String url, Function(int, int) onProgress) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return null;

      final filePath = '${directory.path}/app-release.apk';

      await _dio.download(url, filePath, onReceiveProgress: onProgress);

      return filePath;
    } catch (e) {
      debugPrint('Error downloading APK: $e');
      return null;
    }
  }

  Future<void> installAPK(String filePath) async {
    try {
      await platform.invokeMethod('installApk', {'filePath': filePath});
    } on PlatformException catch (e) {
      debugPrint('Error triggering installation: ${e.message}');
    } catch (e) {
      debugPrint('Error triggering installation: $e');
    }
  }
}
