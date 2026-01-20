# Auto-Update Feature - User Experience Flow

## Scenario 1: Update Available

### User Journey
1. **App Launch**: User opens the app and sees the main screen
2. **Home Page Load**: App displays the Auto Update Demo home page
3. **Background Check**: App silently checks GitHub Releases for updates (after first frame)
4. **Dialog Appears**: Update dialog appears on home screen (non-blocking)
5. **User Decision**:
   - **Option A: Click "Later"**
     - Dialog closes immediately
     - User continues using the app normally
     - Update will be checked again on next launch
   
   - **Option B: Click "Update Now"**
     - Download starts with progress bar
     - User sees real-time download percentage (0% → 100%)
     - After download completes, Android system installer opens
     - Dialog automatically closes
     - User can continue using the app
     - User completes installation via system dialog
     - App restarts with new version

## Scenario 2: No Update Available

1. **App Launch**: User opens the app
2. **Home Page Load**: App displays the home screen
3. **Background Check**: App checks GitHub Releases API
4. **Version Match**: Current version matches or is newer than GitHub release
5. **No Dialog**: No update dialog appears
6. **Normal Flow**: User continues using the app normally

## Scenario 3: Update Check Fails

1. **App Launch**: User opens the app
2. **Home Page Load**: App displays the home screen
3. **Background Check**: App tries to check GitHub API but fails (network error, API down, etc.)
4. **Silent Failure**: Error is caught and logged silently
5. **Normal Flow**: User continues using the app normally (no error dialog shown)

**Failure Scenarios**:
- Network unavailable
- GitHub API rate limit exceeded
- Repository not found (misconfigured)
- Release has no APK asset
- Invalid JSON response

## Scenario 4: Download Fails

1. **App Launch & Check**: Update is found and user clicks "Update Now"
2. **Download Starts**: Progress bar appears
3. **Download Fails**: Network interruption or server error
4. **Error Shown**: SnackBar message: "Failed to download update"
5. **Dialog Closes**: User can retry later
6. **Normal Flow**: App continues working

## Dialog States

### State 1: Initial Prompt
```
┌─────────────────────────────────┐
│ New Update Available            │
├─────────────────────────────────┤
│                                 │
│ A new version (1.2.0) is        │
│ available. Would you like to    │
│ download and install the update?│
│                                 │
├─────────────────────────────────┤
│        [Later]  [Update Now]    │
└─────────────────────────────────┘
```
- ✅ Back button: Closes dialog
- ✅ "Later" button: Closes dialog
- ✅ "Update Now": Starts download

### State 2: Downloading
```
┌─────────────────────────────────┐
│ New Update Available            │
├─────────────────────────────────┤
│                                 │
│ A new version (1.2.0) is        │
│ available. Would you like to    │
│ download and install the update?│
│                                 │
│ ████████████░░░░░░░ 65%        │
│ 65%                             │
│                                 │
│ Downloading...                  │
├─────────────────────────────────┤
└─────────────────────────────────┘
```
- ❌ Back button: Disabled during download
- ❌ Buttons: Hidden during download
- ✅ Progress: Real-time percentage updates

### State 3: Installation Triggered
```
System installer dialog appears
App dialog closes automatically
User can continue using the app
```
- Android system takes over
- User sees standard "Install APK?" dialog
- App continues running in background

## Technical Flow

```
┌─────────────────────────────────────────┐
│          App Launch (main.dart)         │
│          runApp(MyApp())                │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│       MyHomePage Initialized            │
│    (StatefulWidget with _MyHomePageState│
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│    initState() Executes                 │
│    Registers post-frame callback        │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│    First Frame Rendered                 │
│    Callback Triggered                   │
└──────────────┬──────────────────────────┘
               │
               ↓ (Non-blocking)
┌─────────────────────────────────────────┐
│    _checkForUpdates()                   │
│    • Call UpdateService.checkUpdate()  │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│    GitHubUpdateService                  │
│    • GET /repos/{owner}/{repo}/releases │
│    • Parse tag_name → version          │
│    • Find .apk asset → apk_url         │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│    Version Comparison                   │
│    • Get current: PackageInfo           │
│    • Compare: _isNewerVersion()        │
└──────────────┬──────────────────────────┘
               │
        ┌──────┴──────┐
        │             │
        ↓             ↓
  ┌──────────┐  ┌─────────────┐
  │No Update │  │Update Found │
  └────┬─────┘  └──────┬──────┘
       │               │
       ↓               ↓
  Continue       ┌──────────────┐
  Normal Flow    │ showDialog() │
                 │ UpdateDialog │
                 └──────┬───────┘
                        │
                 ┌──────┴──────┐
                 │             │
                 ↓             ↓
           ┌──────────┐  ┌──────────┐
           │  Later   │  │Update Now│
           └────┬─────┘  └─────┬────┘
                │              │
                ↓              ↓
           Close Dialog   StreamController<double>
           Continue            │
           Using App           ↓
                          Download APK
                          (Dio with progress)
                               │
                               ↓
                          Save to External Storage
                          path_provider
                               │
                               ↓
                          open_filex.open()
                          (Triggers installer)
                               │
                               ↓
                          Navigator.pop()
                          (Close dialog)
                               │
                               ↓
                          User Continues
                          Using App
                               │
                               ↓
                     ┌─────────────────┐
                     │ System Installer│
                     │ (User Action)   │
                     └────────┬────────┘
                              │
                              ↓
                         App Restarts
                         New Version
```

## Key Benefits

1. **Non-Intrusive**: App never blocks, update check is background
2. **User Control**: Users decide when to update (dismissible dialog)
3. **Flexibility**: Users can continue app while installer runs
4. **Graceful Degradation**: Check failures don't show errors
5. **Clear Feedback**: Real-time download progress
6. **Professional UX**: Follows Android Material Design guidelines
7. **Simple**: No authentication, no complex server setup

## Configuration Notes

- **Trigger**: `WidgetsBinding.instance.addPostFrameCallback` in `initState()`
- **Check Timing**: Immediately after first frame (no artificial delay)
- **Dialog Dismissible**: Yes (before download), No (during download)
- **Background Operation**: Yes (doesn't block UI)
- **Error Handling**: Silent for checks, visible for downloads
- **Auto-close**: Yes (after installer triggered)

## GitHub API Details

**Endpoint**: `https://api.github.com/repos/{owner}/{repo}/releases/latest`

**Rate Limits**:
- Unauthenticated: 60 requests/hour
- Authenticated: 5,000 requests/hour (possible enhancement)

**Response Parsing**:
```json
{
  "tag_name": "v1.2.0",
  "assets": [
    {
      "name": "app-release.apk",
      "browser_download_url": "https://github.com/.../app-release.apk"
    }
  ]
}
```

## Testing Checklist

### Basic Flow
- [ ] Launch app with no internet → Should work normally (silent failure)
- [ ] Launch app with no update → Should go to Home normally
- [ ] Launch app with update → Should show dialog
- [ ] Click "Later" → Dialog closes, app works normally
- [ ] Click back button (before download) → Dialog closes
- [ ] Click "Update Now" → Download starts with progress

### Download Flow
- [ ] During download → Progress bar updates (0% → 100%)
- [ ] During download → Back button disabled
- [ ] During download → Buttons hidden
- [ ] Download completes → Installer opens
- [ ] Installer opens → Dialog closes
- [ ] Installer opens → Can use app normally

### Error Cases
- [ ] Network error during check → No dialog, app works
- [ ] Wrong repo configured → No dialog, app works
- [ ] Release has no APK → No dialog, app works  
- [ ] Download fails → Error shown via SnackBar
- [ ] Download fails → Dialog closes, app works

### Installation Flow
- [ ] Use app while installer open → App should work normally
- [ ] Complete installation → App restarts with new version
- [ ] Cancel installation → Current app continues working
- [ ] Permission denied → Installation fails gracefully

## Comparison to Original Pattern (DHIS2)

| Aspect | This Implementation | Original (Duka Mkononi) |
|--------|---------------------|-------------------------|
| **Update Source** | GitHub Releases API | DHIS2 Datastore |
| **State Management** | None (direct calls) | Provider pattern |
| **Model Class** | None (Map) | AppVersionInfo model |
| **Trigger** | Post-frame callback | After splash/login |
| **Delay** | None | 1.5 seconds |
| **Tests** | None yet | Unit tests included |
| **Complexity** | Lower | Higher |
| **Flexibility** | High (public repos) | Medium (needs DHIS2) |

## Recommended Enhancements

Based on the original implementation pattern, consider adding:

1. **Model Class**: `AppVersionInfo` for type safety
2. **State Management**: Provider/Riverpod for cleaner state
3. **Unit Tests**: Test version comparison logic
4. **Delay Option**: Configurable delay before showing dialog
5. **GitHub Token**: For higher API rate limits
6. **Release Notes**: Display changelog from GitHub release body

---

For implementation details, see: `docs/IMPLEMENTATION_SUMMARY.md`
