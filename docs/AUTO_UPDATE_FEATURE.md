# Auto-Update Feature

## Overview

The auto-update feature allows the Auto Update Demo app to automatically check for, download, and install new versions from GitHub Releases. This feature is designed for Android devices and provides a seamless update experience for users.

## Architecture

### Components

1. **GitHubUpdateService** (`lib/services/github_update_service.dart`)
   - Fetches latest release information from GitHub API
   - Parses version tags and APK download URLs
   - Handles API communication and error responses

2. **UpdateService** (`lib/services/update_service.dart`)
   - Checks for updates by comparing current and server versions
   - Downloads APK files with progress tracking
   - Triggers Android system installer

3. **UpdateDialog** (`lib/widgets/update_dialog.dart`)
   - Displays update confirmation dialog
   - Shows download progress with linear progress indicator
   - Handles user confirmation (Update Now / Later)

## Configuration

### GitHub Repository Setup

The app fetches update information from GitHub Releases API:

- **API Endpoint**: `https://api.github.com/repos/{owner}/{repo}/releases/latest`
- **Owner**: Configure in `lib/services/github_update_service.dart` (line 14)
- **Repo**: Configure in `lib/services/github_update_service.dart` (line 15)

The GitHub release should:
1. Have a tag following semantic versioning (e.g., `v1.2.0` or `1.2.0`)
2. Include an `.apk` file in the release assets
3. Be marked as "latest release" on GitHub

**Example GitHub Release**:
```
Tag: v1.2.0
Title: Version 1.2.0 Release
Assets:
  - app-release.apk (your APK file)
```

### Android Permissions

The following permissions are required in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
```

Additional storage permissions may be required for Android < 10:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

## Update Flow

1. **App Launch**
   - User opens the app and sees main screen
   - Update check runs automatically after first frame renders

2. **Display Update Dialog** (if newer version available)
   - Dialog appears on top of the current screen
   - Shows new version number
   - Provides "Update Now" and "Later" options
   - Dialog is dismissible - user can tap "Later"

3. **Download APK** (if user confirms)
   - Downloads the APK file to external storage
   - Shows progress bar with real-time percentage
   - Dialog is not dismissible during download

4. **Install APK**
   - Opens Android system installer automatically
   - Dialog closes after triggering installer
   - User confirms installation through system dialog
   - User can continue using the app while installer runs
   - App updates with new version after user confirms

**Important**: The update process is non-blocking. Users can:
- Dismiss the dialog and continue using the app
- Use the app while the system installer is running
- Complete the installation at their convenience

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
- GitHub API rate limits or unavailability
- Missing APK assets in release
- Download failures (shown to user)
- Permission denials (shown to user)
- Installation cancellations (user choice)

Errors during download/installation are displayed via `SnackBar`. Version check errors fail silently to avoid disrupting user experience.

## Testing

To test the auto-update feature:

1. **Configure GitHub Repository**
   - Update `example_owner` and `example_repo` in `github_update_service.dart`
   - Create a GitHub release with a higher version number
   - Attach an APK file to the release

2. **Build and Install Current Version**
   ```bash
   flutter build apk
   # Install on device
   ```

3. **Launch App**
   - App should check for updates automatically
   - Dialog should appear if newer version is found

4. **Test Update Flow**
   - Click "Update Now" to test download and installation
   - Click "Later" to test dismissal

## Dependencies

- `dio: ^5.3.3` - HTTP client for API calls and APK downloads
- `package_info_plus: ^4.2.0` - Get current app version
- `path_provider: ^2.1.1` - File system path access
- `open_filex: ^4.3.4` - Opening APK files with system installer
- `url_launcher: ^6.2.1` - URL handling utilities

## Usage

The auto-update feature runs automatically on app launch in `main.dart`. No manual trigger is required.

To disable the feature, comment out the update check in `_MyHomePageState.initState()`:
```dart
// WidgetsBinding.instance.addPostFrameCallback((_) {
//   _checkForUpdates();
// });
```

## Security Considerations

- APK downloads use HTTPS from GitHub CDN
- GitHub API validates release authenticity
- User confirmation required before download
- System installer provides final security check
- Only signed APKs can update the app

## Configuration Steps

1. **Set GitHub Repository**
   - Open `lib/services/github_update_service.dart`
   - Replace `example_owner` with your GitHub username/org
   - Replace `example_repo` with your repository name

2. **Create GitHub Release**
   - Tag your release with semantic version
   - Upload APK as release asset
   - Mark as latest release

3. **Update App Version**
   - Update `version` in `pubspec.yaml` before building
   - Build APK: `flutter build apk --release`
   - Upload to GitHub release

## Future Enhancements

Possible improvements:
- GitHub Personal Access Token for higher rate limits
- Support for release notes display
- Mandatory vs optional updates based on version rules
- Background update checks at intervals
- Delta updates for smaller downloads
- Multiple APK variants (architecture-specific)
