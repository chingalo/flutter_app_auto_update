# Auto-Update Feature - Implementation Summary

## Overview
This document provides a quick reference for the auto-update feature implementation using GitHub Releases.

## Files Created

### Core Services
- `lib/cores/services/github_update_service.dart` - GitHub API integration for fetching release info
- `lib/cores/services/update_service.dart` - Update orchestration (version check, download, installation)

### UI Components
- `lib/cores/components/update_dialog.dart` - Update confirmation dialog with markdown-rendered release notes and progress indicator

### Configuration
- `lib/cores/constants/github_references.dart` - Centralized GitHub repository configuration

### Android Native
- `android/app/src/main/kotlin/com/example/auto_update_app/MainActivity.kt` - MethodChannel handler for APK installation
- `android/app/src/main/res/xml/provider_paths.xml` - FileProvider configuration

### Documentation
- `docs/AUTO_UPDATE_FEATURE.md` - Comprehensive feature documentation
- `docs/IMPLEMENTATION_SUMMARY.md` - This file
- `docs/IMPLEMENTATION_CHANGES.md` - Detailed change log from default Flutter app
- `docs/USER_EXPERIENCE_FLOW.md` - User experience documentation

## Files Modified

### Dependencies
- `pubspec.yaml` - Added 5 dependencies:
  - `dio: ^5.3.3` - HTTP client for API calls and downloads
  - `package_info_plus: ^4.2.0` - Current app version detection
  - `path_provider: ^2.1.1` - File system paths
  - `flutter_markdown: ^0.7.4+1` - Markdown rendering for release notes

### App Configuration
- `lib/main.dart` - Integrated update check on app launch with Platform.isAndroid check

### Android Configuration
- `android/app/src/main/AndroidManifest.xml` - Added FileProvider and permissions

## GitHub Configuration

Configure in `lib/cores/constants/github_references.dart`:

```dart
class GitHubReferences {
  static const String owner = 'your_username';
  static const String repo = 'your_repo_name';
  static const String apkKey = 'prod'; // or empty '' for any .apk
  static const String token = ''; // GitHub token (optional, for private repos)
}
```

**Release Requirements**:
1. Semantic version tag (e.g., `v1.2.0`)
2. APK file in release assets
3. APK filename contains `apkKey` (or any .apk if empty)
4. Marked as "latest release"

**Example**:
```
Tag: v1.2.0
Assets: timr-prod-v1.2.0.apk
```

## Update Flow

```
App Launch (Android Only)
    ↓
Platform.isAndroid check
    ↓
Post-frame callback
    ↓
GitHubUpdateService.getLatestGithubRelease()
    ↓
Compare versions
    ↓
[If Update Available]
    ↓
Show UpdateDialog
    ↓
[User Chooses]
    ├── Later → Close dialog
    └── Update Now
            ↓
        Download APK (with progress)
            ↓
        Extract filename from URL
            ↓
        MethodChannel → MainActivity.kt
            ↓
        FileProvider creates content:// URI
            ↓
        Android System Installer
            ↓
        User confirms installation
```

## Key Features

### Version Comparison
```dart
bool _isNewerVersion(String serverVersion, String currentVersion) {
  // Splits versions and compares numerically
  // Handles: 1.2.0 vs 1.1.9 → true
}
```

### MethodChannel Communication
**Flutter → Android**:
```dart
static const platform = MethodChannel('com.example.auto_update_app/installer');
await platform.invokeMethod('installApk', {'filePath': filePath});
```

**Android Handler**:
```kotlin
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
  .setMethodCallHandler { call, result ->
    if (call.method == "installApk") {
      installApk(filePath)
    }
  }
```

### FileProvider for API 24+
```kotlin
val apkUri = FileProvider.getUriForFile(
    this,
    "${applicationContext.packageName}.fileprovider",
    file
)
intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
```

### Filename Preservation
```dart
final uri = Uri.parse(url);
final filename = uri.pathSegments.last; // Preserves original name
```

## Quick Start

### 1. Configure Repository
```dart
// lib/cores/constants/github_references.dart
static const String owner = 'your_username';
static const String repo = 'your_repo';
static const String apkKey = 'prod';
static const String token = ''; // Empty for public repos
```

### 2. Create GitHub Release
```bash
git tag v1.0.0
git push origin v1.0.0

flutter build apk --release
# Upload to GitHub release
```

### 3. Test
```bash
flutter build apk --release
# Install on Android device
# Launch app → update dialog should appear
```

## Architecture

```
lib/
├── cores/
│   ├── constants/
│   │   └── github_references.dart (Config)
│   ├── services/
│   │   ├── github_update_service.dart (API)
│   │   └── update_service.dart (Orchestrator)
│   └── components/
│       └── update_dialog.dart (UI)
└── main.dart (Integration)

android/
└── app/src/main/
    ├── kotlin/.../MainActivity.kt (MethodChannel)
    ├── AndroidManifest.xml (Permissions + Provider)
    └── res/xml/provider_paths.xml (FileProvider)
```

## Error Handling

| Error Type | Handling |
|-----------|----------|
| Version check fails | Silent (no dialog shown) |
| GitHub API unavailable | Silent |
| No APK in release | Silent |
| Download fails | SnackBar shown |
| Installation canceled | User choice (graceful) |

## Permissions

```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
<uses-permission android:name="android.permission.INTERNET" />
```

## Platform Support

- ✅ **Android**: Full support with native MethodChannel
- ❌ **iOS/Web/Desktop**: Disabled (Platform.isAndroid check)

## Testing Checklist

- [ ] Configure correct GitHub repo
- [ ] Create release with higher version
- [ ] Upload APK with matching apkKey
- [ ] Build and install app
- [ ] Launch app → dialog appears
- [ ] Click "Update Now" → download starts
- [ ] Progress bar updates
- [ ] Installer opens
- [ ] Complete installation

## Maintenance

**Releasing New Version**:
1. Update `pubspec.yaml` version
2. Build APK: `flutter build apk --release`
3. Create Git tag: `git tag v1.0.1`
4. Create GitHub release with APK
5. Users auto-prompted on next launch

## Statistics

- **Files Created**: 6 (3 Dart services, 1 UI, 1 config, 1 native)
- **Files Modified**: 4 (pubspec, main, AndroidManifest, build.gradle)
- **Dependencies Added**: 4
- **Lines of Code**: ~400
- **Permissions**: 2

## Private Repository Support

The app now supports private GitHub repositories via token authentication.

### Configuration

Add your GitHub Personal Access Token in `lib/cores/constants/github_references.dart`:

```dart
class GitHubReferences {
  static const String owner = 'your_username';
  static const String repo = 'your_private_repo';
  static const String apkKey = 'prod';
  static const String token = 'ghp_YourGitHubTokenHere'; // Add your token here
}
```

### How It Works

The `UpdateService` automatically passes the token to the GitHub API:

```dart
// In update_service.dart (automatically implemented)
final releaseInfo = await _gitHubUpdateService.getLatestGithubRelease(
  owner: GitHubReferences.owner,
  repo: GitHubReferences.repo,
  apkKey: GitHubReferences.apkKey,
  token: GitHubReferences.token, // Token automatically included
);
```

The `GitHubUpdateService` conditionally adds the Authorization header:
- If token is provided → `Authorization: Bearer {token}`
- If token is empty → Unauthenticated request (public repos only)

### Token Requirements
- **Scope**: `repo` (Full control of private repositories)
- **Generate at**: GitHub → Settings → Developer settings → Personal access tokens

### Security Warning
> **Never commit tokens to version control!** Use environment variables or secure storage in production.

## Troubleshooting

**404 Error**:
- Verify repository exists
- Check repository is public (or add token)
- Ensure release exists and is marked "latest"

**APK Not Found**:
- Check APK filename contains `apkKey`
- Or set `apkKey` to empty string `''`

**Installation Fails**:
- Verify FileProvider is configured
- Check `provider_paths.xml` exists
- Ensure `REQUEST_INSTALL_PACKAGES` permission

---

For detailed documentation, see:
- [AUTO_UPDATE_FEATURE.md](./AUTO_UPDATE_FEATURE.md) - Complete feature guide
- [IMPLEMENTATION_CHANGES.md](./IMPLEMENTATION_CHANGES.md) - Detailed change log
- [USER_EXPERIENCE_FLOW.md](./USER_EXPERIENCE_FLOW.md) - UX documentation
