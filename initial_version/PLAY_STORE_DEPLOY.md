# Deploying Prism to Google Play Store

## Prerequisites

- Google Play Developer account ($25 one-time fee): https://play.google.com/console
- App signing key (or use Google Play App Signing)
- App icons (512x512 PNG), feature graphic (1024x500), screenshots

## Phase 1: Prepare the App

### 1.1 Update App Identity

Edit `android/app/build.gradle.kts`:
```kotlin
android {
    namespace = "com.yourname.prism"
    defaultConfig {
        applicationId = "com.yourname.prism"
        minSdk = 26          // Android 8.0+
        targetSdk = 34
        versionCode = 1      // Increment each release
        versionName = "0.1.0"
    }
}
```

### 1.2 Set App Name

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="Prism" ...>
```

### 1.3 Add App Icon

```powershell
# Use flutter_launcher_icons package
flutter pub add dev:flutter_launcher_icons

# Add to pubspec.yaml:
# flutter_launcher_icons:
#   android: true
#   ios: true
#   image_path: "assets/icon/icon.png"

flutter pub run flutter_launcher_icons
```

### 1.4 Add Splash Screen (native)

```powershell
flutter pub add dev:flutter_native_splash

# Add to pubspec.yaml:
# flutter_native_splash:
#   color: "#0C0C16"
#   android_12:
#     color: "#0C0C16"
#     icon_background_color: "#0C0C16"

flutter pub run flutter_native_splash:create
```

## Phase 2: Build Release APK/AAB

### 2.1 Create Upload Key

```powershell
# Generate keystore (one-time, keep this file safe!)
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Move to android/ folder
move upload-keystore.jks android/
```

### 2.2 Configure Signing

Create `android/key.properties` (DO NOT commit this!):
```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

Update `android/app/build.gradle.kts`:
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}
```

### 2.3 Build Release Bundle

```powershell
# Clean and build
flutter clean
flutter pub get

# Build Android App Bundle (required for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

## Phase 3: Play Store Setup

### 3.1 Create App Listing

1. Go to https://play.google.com/console
2. **Create App** → Fill in:
   - App name: **Prism**
   - Default language: English
   - App type: App (not game)
   - Free or Paid: Free
3. Accept Developer Agreement

### 3.2 Store Listing

- **Short description** (80 chars): "Your AI personal assistant. Private, local, intelligent."
- **Full description** (4000 chars): Describe features, privacy focus, local AI
- **Screenshots**: At least 2 phone screenshots (take from running app)
- **Feature graphic**: 1024x500 banner image
- **App icon**: 512x512 (auto-generated from flutter_launcher_icons)

### 3.3 Content Rating

1. Go to **Policy → App content → Content rating**
2. Fill out the IARC questionnaire
3. Select categories: Social/Communication, Productivity

### 3.4 Pricing & Distribution

1. Set **Free**
2. Select **Countries** (all or specific)
3. Accept **Developer Distribution Agreement**

### 3.5 App Signing

1. Go to **Release → App signing**
2. Choose **Google Play App Signing** (recommended)
3. Upload your upload key certificate

## Phase 4: Release

### 4.1 Internal Testing (recommended first)

1. Go to **Release → Testing → Internal testing**
2. Create new release
3. Upload the `.aab` file
4. Add tester emails
5. Publish → Testers get link within minutes

### 4.2 Production Release

1. Go to **Release → Production**
2. Create new release
3. Upload `.aab`
4. Add release notes
5. Submit for review (takes 1-7 days for first app)

## Phase 5: Post-Launch

- Monitor **Android Vitals** for crashes
- Respond to user reviews
- Update regularly via same process (increment `versionCode`)

## Quick Reference Commands

```powershell
# Check everything is ready
flutter doctor -v

# Build release APK (for direct install)
flutter build apk --release

# Build AAB (for Play Store)
flutter build appbundle --release

# Install release APK on device
flutter install --release

# Analyze app size
flutter build apk --analyze-size
```

## Important Files to NOT Commit

Add to `.gitignore`:
```
android/key.properties
*.jks
*.keystore
```

## Timeline Estimate

| Step | Time |
|------|------|
| Developer account setup | 1 hour |
| App identity + icons | 2 hours |
| First release build | 30 minutes |
| Store listing | 2 hours |
| Review process | 1-7 days |
| **Total to first publish** | **~1 day + review** |
