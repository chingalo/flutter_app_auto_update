# Quick Reference Guide

## Table of Contents
- [Setup](#setup)
- [Configuration](#configuration)
- [Creating Releases](#creating-releases)
- [Markdown Examples](#markdown-examples)
- [Troubleshooting](#troubleshooting)

## Setup

### 1. Installation
```bash
# Clone and install dependencies
cd auto_update_app
flutter pub get
```

### 2. Configure GitHub Repository
Edit `lib/cores/constants/github_references.dart`:
```dart
class GitHubReferences {
  static const String owner = 'your_github_username';
  static const String repo = 'your_repository_name';
  static const String apkKey = ''; // Empty for any .apk, or 'prod' for specific
  static const String token = ''; // Empty for public, add token for private
}
```

### 3. Build & Test
```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Configuration

### Public Repository
```dart
static const String owner = 'username';
static const String repo = 'public-repo';
static const String apkKey = '';
static const String token = ''; // Leave empty
```

### Private Repository
```dart
static const String owner = 'username';
static const String repo = 'private-repo';
static const String apkKey = 'prod';
static const String token = 'ghp_YourPersonalAccessToken'; // Add token
```

**Generate Token**:
GitHub → Settings → Developer settings → Personal access tokens → Generate new token → Select `repo` scope

## Creating Releases

### 1. Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.1+2  # Increment version
```

### 2. Build APK
```bash
flutter build apk --release
```

### 3. Create Git Tag
```bash
git tag v1.0.1
git push origin v1.0.1
```

### 4. Create GitHub Release
1. Go to your repository on GitHub
2. Click **Releases** → **Create a new release**
3. Choose tag: `v1.0.1`
4. Write markdown release notes (see examples below)
5. Upload APK file: `app-release.apk`
6. Click **Publish release**

## Markdown Examples

### Basic Release Note
```markdown
## What's New

- Bug fixes and improvements
- Enhanced performance
- Updated UI
```

### Detailed Release Note
```markdown
## 🎉 Version 1.0.1

### ✨ New Features
- **Dark Mode** - Toggle between light and dark themes
- **Offline Support** - Work without internet connection
- **Export Data** - Export your data as CSV

### 🐛 Bug Fixes
- Fixed crash on Android 12
- Resolved download timeout issues
- Fixed UI rendering on tablets

### ⚡ Performance
- 30% faster app startup
- Reduced memory usage by 20%
- Improved battery efficiency

### 📝 Notes
This update requires Android 7.0 or higher.

[View Documentation](https://github.com/yourrepo/wiki)
```

### Simple Release Note
```markdown
### Changes
- Fixed login issue
- Updated app icon
- Performance improvements
```

## Markdown Features Supported

| Feature | Syntax | Example |
|---------|--------|---------|
| **Header 1** | `# H1` | `# Major Update` |
| **Header 2** | `## H2` | `## New Features` |
| **Header 3** | `### H3` | `### Bug Fixes` |
| **Bold** | `**text**` | `**Important**` |
| **Italic** | `*text*` | `*Note*` |
| **Bullet List** | `- item` | `- Fixed bug` |
| **Numbered List** | `1. item` | `1. First step` |
| **Code** | `` `code` `` | `` `version` `` |
| **Link** | `[text](url)` | `[Docs](url)` |
| **Emoji** | Direct | `✨ 🐛 ⚡ 📝` |

## Troubleshooting

### No Update Dialog Appears
**Check**:
- Is the app version in `pubspec.yaml` lower than the GitHub release?
- Is the device running Android?
- Is there internet connectivity?
- Check logs for API errors

**Fix**:
```bash
# View logs
adb logcat | grep flutter
```

### 404 Error
**Public Repo**:
- Verify repository exists and is public
- Check owner and repo names are correct

**Private Repo**:
- Ensure token is valid
- Token must have `repo` scope
- Check token hasn't expired

### APK Not Found
**Check**:
- APK is uploaded to the release
- APK filename matches `apkKey` filter
- Release is marked as "latest"

**Fix**:
- Set `apkKey = ''` to pick any .apk file
- Or ensure APK filename contains the `apkKey` value

### Installation Fails
**Common Issues**:
- FileProvider not configured
- Missing `REQUEST_INSTALL_PACKAGES` permission
- User cancelled installation

**Verify**:
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

### Markdown Not Rendering
**Check**:
- Release has description/body content
- Content is valid markdown
- `flutter_markdown` dependency is installed

**Test**:
```bash
flutter pub get  # Ensure dependencies are installed
```

## Common Commands

```bash
# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Check logs
adb logcat | grep flutter

# Create and push tag
git tag v1.0.0 && git push origin v1.0.0

# Clean build
flutter clean && flutter pub get
```

## Version Naming

**Format**: `MAJOR.MINOR.PATCH+BUILD`

- **MAJOR**: Breaking changes (1.0.0 → 2.0.0)
- **MINOR**: New features (1.0.0 → 1.1.0)
- **PATCH**: Bug fixes (1.0.0 → 1.0.1)
- **BUILD**: Build number (1.0.0+1 → 1.0.0+2)

**Examples**:
```yaml
version: 1.0.0+1   # Initial release
version: 1.0.1+2   # Bug fix
version: 1.1.0+3   # New feature
version: 2.0.0+4   # Major update
```

## Quick Testing Checklist

- [ ] Updated version in `pubspec.yaml`
- [ ] Configured `GitHubReferences` correctly
- [ ] Built release APK
- [ ] Created Git tag (v1.x.x)
- [ ] Created GitHub release with markdown notes
- [ ] Uploaded APK to release
- [ ] Marked release as "latest"
- [ ] Installed older version on test device
- [ ] Launched app
- [ ] Update dialog appeared
- [ ] Markdown rendered correctly
- [ ] Download completed successfully
- [ ] Installation succeeded

---

**Need More Help?**
- 📚 [Full Documentation](./AUTO_UPDATE_FEATURE.md)
- 🔧 [Implementation Summary](./IMPLEMENTATION_SUMMARY.md)
- 👤 [User Experience Flow](./USER_EXPERIENCE_FLOW.md)
