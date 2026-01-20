# Auto Update Demo

A Flutter application demonstrating automatic app updates via GitHub Releases for Android devices.

## Features

✨ **Automatic Update Checks** - Checks for new versions on app launch  
📥 **GitHub Integration** - Fetches releases from GitHub API  
🔐 **Private Repository Support** - Optional token authentication for private repos  
📊 **Progress Tracking** - Real-time download progress indicator  
🔒 **Secure Installation** - FileProvider support for Android 7.0+  
🎨 **Material 3 UI** - Modern, clean update dialog  
⚡ **MethodChannel** - Native Android integration for reliable APK installation  

## Quick Start

### 1. Configure Your Repository

Edit `lib/cores/constants/github_references.dart`:

```dart
class GitHubReferences {
  static const String owner = 'your_username';      // Your GitHub username
  static const String repo = 'your_repo_name';      // Your repository name
  static const String apkKey = 'prod';              // APK filename filter, if empty it will pick first apk file on release
  static const String token = '';                   // GitHub token (optional, for private repos)
}
```

> [!NOTE]
> For **public repositories**, leave the `token` field as an empty string.
> For **private repositories**, provide a GitHub Personal Access Token with `repo` scope.

### 2. Create a GitHub Release

```bash
# Tag your release
git tag v1.0.0
git push origin v1.0.0

# Build APK
flutter build apk --release

# Upload to GitHub
# Go to Releases → Create new release → Upload APK
```

### 3. Run the App

```bash
flutter pub get
flutter run
```

## How It Works

1. **Launch**: App checks if running on Android
2. **Version Check**: Queries GitHub Releases API for latest version
3. **Comparison**: Compares current version with server version
4. **Dialog**: Shows update prompt if newer version exists
5. **Download**: Downloads APK with progress tracking
6. **Install**: Triggers Android system installer via MethodChannel

## Architecture

```
lib/cores/
├── constants/
│   └── github_references.dart    # Repository configuration
├── services/
│   ├── github_update_service.dart # GitHub API integration
│   └── update_service.dart        # Update orchestration
└── components/
    └── update_dialog.dart         # Update UI

android/.../MainActivity.kt         # Native APK installation
```

## Documentation

📚 **[AUTO_UPDATE_FEATURE.md](docs/AUTO_UPDATE_FEATURE.md)**  
Complete feature guide with configuration, testing, and troubleshooting

📋 **[IMPLEMENTATION_SUMMARY.md](docs/IMPLEMENTATION_SUMMARY.md)**  
Quick reference with code examples and architecture diagrams

🔄 **[IMPLEMENTATION_CHANGES.md](docs/IMPLEMENTATION_CHANGES.md)**  
Detailed changelog from default Flutter app to auto-update implementation

👤 **[USER_EXPERIENCE_FLOW.md](docs/USER_EXPERIENCE_FLOW.md)**  
User scenarios and experience flows

## Requirements

- Flutter SDK ^3.10.4
- Android device/emulator (API 21+)
- GitHub repository with releases

## Dependencies

```yaml
dio: ^5.3.3               # HTTP client
package_info_plus: ^4.2.0 # Version detection
path_provider: ^2.1.1     # File paths
url_launcher: ^6.2.1      # URL utilities
```

## Platform Support

| Platform | Status |
|----------|--------|
| ✅ Android | Full support |
| ❌ iOS | Not supported |
| ❌ Web | Not supported |
| ❌ Desktop | Not supported |

## Configuration Example

**pubspec.yaml**:
```yaml
version: 1.0.0+1  # Update this before each release
```

**GitHub Release**:
```
Tag: v1.0.0
Title: Initial Release
Assets:
  - app-prod-v1.0.0.apk
```

## Private Repository Support

To use auto-updates with a **private GitHub repository**, you'll need to configure a Personal Access Token:

### 1. Generate a GitHub Token

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token (classic)**
3. Give it a name (e.g., "Auto Update Access")
4. Select scopes: ✅ **repo** (Full control of private repositories)
5. Click **Generate token** and copy it immediately

### 2. Configure the Token

Edit `lib/cores/constants/github_references.dart`:

```dart
class GitHubReferences {
  static const String owner = 'your_username';
  static const String repo = 'your_private_repo';
  static const String apkKey = 'prod';
  static const String token = 'ghp_your_token_here';  // Your GitHub token
}
```

> [!WARNING]
> **Security Best Practice**: Do not commit tokens to version control. Consider using environment variables or secure storage for production apps.

### 3. Token Permissions

The token requires:
- ✅ `repo` scope for private repository access
- ✅ Read access to releases

> [!TIP]
> For public repositories, simply leave `token` as an empty string (`''`).

## Testing

```bash
# Build release APK
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Launch app and check for updates
```

## Troubleshooting

### 404 Error
- **Public repos**: Verify GitHub repository exists and is public
- **Private repos**: Ensure token is valid and has `repo` scope
- Check release is marked as "latest"
- Ensure APK is uploaded to release

### No Update Dialog
- Confirm app version is lower than GitHub release version
- Check Platform.isAndroid is true
- Verify network connectivity

### Installation Fails
- Check FileProvider is configured in AndroidManifest.xml
- Ensure REQUEST_INSTALL_PACKAGES permission is added
- Verify provider_paths.xml exists

## Security

- ✅ HTTPS downloads from GitHub CDN
- ✅ FileProvider for secure file sharing
- ✅ User confirmation required
- ✅ Android system installer validation
- ✅ Signature verification by Android OS

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is a demonstration app for educational purposes.

## Learn More

- [Flutter Documentation](https://docs.flutter.dev/)
- [GitHub Releases API](https://docs.github.com/en/rest/releases)
- [Android FileProvider](https://developer.android.com/reference/androidx/core/content/FileProvider)

---

**Built with ❤️ using Flutter**
