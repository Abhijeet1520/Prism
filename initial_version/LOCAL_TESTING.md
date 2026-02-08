# Testing Prism on Your Local Device

## Prerequisites

1. **Flutter SDK** installed and in PATH
2. **Android Studio** with Android SDK (API 34+)
3. **USB cable** connecting your phone to PC
4. **Developer Options** enabled on your phone

## Step 1: Enable Developer Options

1. Go to **Settings → About Phone**
2. Tap **Build Number** 7 times
3. Go back to **Settings → Developer Options**
4. Enable **USB Debugging**
5. Connect phone via USB and tap **Allow** on the permission prompt

## Step 2: Verify Connection

```powershell
# Check Flutter sees your device
flutter devices

# You should see something like:
# Pixel 7 (mobile) • XXXXXX • android-arm64 • Android 14 (API 34)
```

## Step 3: Run the App

```powershell
# Navigate to the project
cd "C:\Users\abhij\Documents\Projects\gemma\Gemmie\ux_preview"

# Get dependencies
flutter pub get

# Run on your connected device
flutter run

# Or specify device if multiple connected
flutter run -d <device-id>
```

## Step 4: Hot Reload During Development

Once the app is running:
- Press **r** in terminal for **hot reload** (preserves state)
- Press **R** for **hot restart** (resets state)
- Press **q** to quit

## Step 5: Build a Debug APK (optional)

```powershell
# Build debug APK for sharing/testing
flutter build apk --debug

# Output at: build/app/outputs/flutter-apk/app-debug.apk
# Transfer to phone and install (enable "Install from Unknown Sources")
```

## Step 6: Run on Web (alternative)

```powershell
# Run on Chrome (no device needed)
flutter run -d chrome

# Or edge
flutter run -d edge
```

## Step 7: Run on Windows Desktop

```powershell
# Run as native Windows app
flutter run -d windows
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "No devices found" | Check USB cable, enable USB debugging, install device drivers |
| "License not accepted" | Run `flutter doctor --android-licenses` and accept all |
| Build fails on first run | Run `flutter clean` then `flutter pub get` |
| App crashes on launch | Check `flutter logs` for error details |
| Slow first build | Normal — Gradle downloads dependencies (5-10 min first time) |

## Recommended IDE Setup

For the best development experience:
1. **VS Code** with Flutter/Dart extensions (you have this)
2. Use **Debug panel** (F5) for breakpoints and hot reload
3. Use **Flutter DevTools** for widget inspector: `flutter pub global activate devtools`
