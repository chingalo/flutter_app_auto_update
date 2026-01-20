# Auto-Update Feature

## Overview

The auto-update feature allows the Auto Update Demo app to automatically check for, download, and install new versions from GitHub Releases. This feature is designed for Android devices and provides a seamless update experience for users.

## Architecture

### Components

1. **GitHubUpdateService** (`lib/cores/services/github_update_service.dart`)
   - Fetches latest release information from GitHub API
   - Parses version tags and APK download URLs
   - Handles API communication and error responses
   - Supports optional GitHub token for private repositories

2. **UpdateService** (`lib/cores/services/update_service.dart`)
   - Checks for updates by comparing current and server versions
   - Downloads APK files with progress tracking
   - Triggers Android system installer via MethodChannel

3. **UpdateDialog** (`lib/cores/components/update_dialog.dart`)
   - Displays update confirmation dialog
   - Shows download progress with linear progress indicator
   - Handles user confirmation (Update Now / Later)

4. **GitHubReferences** (`lib/cores/constants/github_references.dart`)
   - Centralized GitHub repository configuration
   - Owner, repo, and APK key constants

5. **MainActivity.kt** (Native Android)
   - MethodChannel handler for APK installation
   - FileProvider support for secure file sharing
   - Handles different Android versions

## Configuration

### GitHub Repository Setup

Configure the repository in `lib/cores/constants/github_references.dart`:

```dart
class GitHubReferences {
  static const String owner = 'your_username';
  static const String repo = 'your_repo';
  static const String apkKey = 'prod'; // Filter by name, or empty '' to pick first .apk in assets
  static const String token = ''; // GitHub token (optional, for private repos)
}
```

**GitHub Release Requirements**:
1. Tag following semantic versioning (e.g., `v1.2.0` or `1.2.0`)
2. APK file attached as release asset
3. APK filename contains the `apkKey` (or first .apk if key is empty)
4. Marked as "latest release" on GitHub

**APK Key Behavior**:
- If `apkKey = 'prod'`: Finds first APK containing "prod" (e.g., `app-prod-v1.0.0.apk`)
- If `apkKey = ''`: Picks the first `.apk` file in the assets list (no filtering)
- Useful when release has multiple APKs (e.g., prod, staging, different architectures)

**Example GitHub Release**:
```
Tag: v1.2.0
Title: Version 1.2.0 Release
Assets:
  - timr-prod-v1.2.0.apk (your APK file)
```

### Android Permissions

Required in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
```

### FileProvider Configuration

The app uses FileProvider for secure APK installation on Android 7.0+:

**AndroidManifest.xml**:
```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths" />
</provider>
```

**res/xml/provider_paths.xml**:
```xml
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="."/>
    <external-cache-path name="external_cache" path="."/>
</paths>
```

## Update Flow

1. **App Launch (Android Only)**
   - App checks if running on Android platform
   - Update check runs automatically after first frame renders

2. **Display Update Dialog** (if newer version available)
   - Dialog appears on top of the current screen
   - Shows new version number
   - Provides "Update Now" and "Later" options
   - Dialog is dismissible before download starts

3. **Download APK** (if user confirms)
   - Downloads APK to external storage
   - Preserves original filename from GitHub release
   - Shows real-time progress bar with percentage
   - Dialog is non-dismissible during download

4. **Install APK**
   - Opens Android system installer via MethodChannel
   - Dialog closes after triggering installer
   - User confirms installation through system dialog
   - App updates after user confirms installation

**Important**: The update process is Android-only and non-blocking. Users can dismiss the dialog or continue using the app.

## Version Comparison

The system compares semantic versions (e.g., "1.0.1" vs "1.2.0"):
- Splits version into major.minor.patch components
- Compares each component numerically from left to right
- Automatically strips 'v' prefix from GitHub tags
- Returns true if server version is newer

**Examples**:
- `1.2.0` > `1.1.9` → Update available
- `2.0.0` > `1.9.9` → Update available
- `1.2.3` = `1.2.3` → No update
- `v1.2.0` is treated as `1.2.0`

## Error Handling

The feature handles various error scenarios:
- Network errors during version check (silent failure)
- GitHub API rate limits or unavailability (silent)
- Missing APK assets in release (silent)
- Download failures (shown via SnackBar)
- Permission denials (installation fails gracefully)
- Installation cancellations (user choice)

Errors during download/installation are displayed to users. Version check errors fail silently to avoid disrupting user experience.

## Private Repository Support

For private GitHub repositories, you need to configure a GitHub Personal Access Token:

### 1. Generate GitHub Token

1. Navigate to **GitHub Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token (classic)**
3. Provide a descriptive name (e.g., "Auto Update Access")
4. Select scopes:
   - ✅ `repo` - Full control of private repositories
5. Generate and copy the token immediately (you won't see it again)

### 2. Configure Token

Update `lib/cores/constants/github_references.dart`:

```dart
class GitHubReferences {
  static const String owner = 'your_username';
  static const String repo = 'your_private_repo';
  static const String apkKey = 'prod';
  static const String token = 'ghp_YourGitHubTokenHere'; // Your GitHub token
}
```

The `UpdateService` automatically passes the token to the GitHub API:

```dart
// In update_service.dart (already implemented)
final releaseInfo = await _gitHubUpdateService.getLatestGithubRelease(
  owner: GitHubReferences.owner,
  repo: GitHubReferences.repo,
  apkKey: GitHubReferences.apkKey,
  token: GitHubReferences.token, // Token is automatically included
);
```

### 3. Security Best Practices

> [!WARNING]
> **Never commit tokens to version control!** 
>
> For production apps, consider:
> - Using environment variables
> - Implementing secure storage (e.g., `flutter_secure_storage`)
> - Using a backend API to proxy GitHub requests
> - Implementing token rotation

### 4. How It Works

The `GitHubUpdateService` checks if a token is provided:
- If token is present and not empty → Adds `Authorization: Bearer {token}` header
- If token is empty → Makes unauthenticated request (public repos only)

**Token Format**:
```
Authorization: Bearer ghp_YourGitHubTokenHere
```

### 5. Token Permissions Required

| Permission | Scope | Required For |
|------------|-------|-------------|
| ✅ Repository access | `repo` | Reading private repository releases |
| ✅ Read releases | Included in `repo` | Fetching release data and assets |

## Testing

### Setup
1. Configure GitHub repository in `GitHubReferences`
2. Create a GitHub release with higher version number
3. Attach APK file that contains the apkKey in filename

### Test on Device
```bash
flutter build apk --release
# Install on Android device
# Launch app to trigger update check
```

## Dependencies

- `dio: ^5.3.3` - HTTP client for API calls and APK downloads
- `package_info_plus: ^4.2.0` - Get current app version
- `path_provider: ^2.1.1` - File system path access

## Usage

The auto-update feature runs automatically on app launch (Android only). No manual trigger is required.

To disable:
```dart
// In main.dart, comment out:
// if (Platform.isAndroid) {
//   _checkForUpdates();
// }
```

## Security Considerations

- ✅ HTTPS downloads from GitHub CDN
- ✅ GitHub API validates release authenticity
- ✅ FileProvider for secure file sharing (Android 7.0+)
- ✅ User confirmation required before download
- ✅ System installer provides final security check
- ✅ Only signed APKs can update the app

## Configuration Quick Start

1. **Update Repository Configuration**:
   ```dart
   // lib/cores/constants/github_references.dart
   static const String owner = 'your_username';
   static const String repo = 'your_repo_name';
   static const String apkKey = 'prod'; // or empty ''
   static const String token = ''; // GitHub token (empty for public repos)
   ```

2. **Create GitHub Release**:
   - Tag: `v1.0.0`
   - Upload APK: `app-prod-v1.0.0.apk`
   - Mark as latest release

3. **Test**:
   ```bash
   flutter build apk --release
   # Install and launch on Android device
   ```

## Future Enhancements

- Release notes display from GitHub release body
- Mandatory vs optional updates based on version rules
- Background update checks at intervals
- Delta updates for smaller downloads
- Multiple APK variants support
