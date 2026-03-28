# Production Build & Release Guide

## Step 1: Create Signing Key (One-time setup)

### Generate Keystore
Run this ONCE and SAVE THE OUTPUT:

```bash
cd frontend/android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalias upload-key \
  -keyalg RSA -keysize 2048 -validity 10000
```

When prompted:
```
Keystore password: [CREATE A STRONG PASSWORD - REMEMBER THIS!]
Key password: [SAME AS KEYSTORE OR DIFFERENT - REMEMBER THIS!]
What is your first and last name? [Your Name]
What is the name of your organizational unit? [Your Company/Personal]
What is the name of your organization? [Your Company/Personal]
What is the name of your City or Locality? [Your City]
What is the name of your State or Province? [Your State]
What is the two-letter country code for this unit? [US]
```

### Save These Details (You'll need them forever to update this app)
- Keystore password: ___________
- Key password: ___________
- upload-keystore.jks location: `frontend/android/app/upload-keystore.jks`

**BACKUP THIS FILE SOMEWHERE SAFE!**

---

## Step 2: Create Key Configuration File

Create `frontend/android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload-key
storeFile=upload-keystore.jks
```

Replace YOUR_KEYSTORE_PASSWORD and YOUR_KEY_PASSWORD with actual values.

**DO NOT COMMIT THIS FILE TO GIT!** (It's in .gitignore)

---

## Step 3: Update build.gradle.kts for Production

Replace `frontend/android/app/build.gradle.kts` with:

```kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing key configuration
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.petcare.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.petcare.app"
        minSdk = 21  // Android 5.0 or higher
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
    }

    // Signing configuration for release
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
        debug {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source = "../.."
}
```

---

## Step 4: Update pubspec.yaml Version

In `frontend/pubspec.yaml`:

```yaml
version: 1.0.0+1
```

Format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`
- First release: `1.0.0+1`
- First update: `1.0.1+2` or `1.1.0+2`
- Increment BUILD_NUMBER for every upload to Play Store

---

## Step 5: Update API Configuration

In `frontend/lib/config/api_config.dart`:

Change:
```dart
const bool useProductionBackend = false;
const String apiBaseUrlProduction = 'http://localhost:4000';
```

To (after you deploy backend):
```dart
const bool useProductionBackend = true;
const String apiBaseUrlProduction = 'https://your-firebase-project.run.app';
```

---

## Step 6: Build Release APK

```bash
cd frontend

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

Output: `build/app/outputs/flutter-app/release/app-release.apk`

### Verify APK
```bash
# Check APK exists
ls -lh build/app/outputs/flutter-app/release/app-release.apk

# Size should be ~50-100 MB (depending on dependencies)
```

---

## Step 7: Test Release APK Locally

```bash
# Install on emulator/device
flutter install --release

# Or manually:
adb install -r build/app/outputs/flutter-app/release/app-release.apk
```

### Test Checklist
- [ ] App starts without crashing
- [ ] Can register new account
- [ ] Can login
- [ ] Can add pet
- [ ] Can add reminder
- [ ] Can see dashboard
- [ ] Backend connection works
- [ ] Notifications request appears

---

## Step 8: Create Proguard Rules (Optional but Recommended)

Create `frontend/android/app/proguard-rules.pro`:

```
# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.firebase.** { *; }

# Keep Dart classes
-keep class com.example.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
```

---

## Summary: Commands for Production Build

```bash
# 1. ONE-TIME: Generate signing key
cd frontend/android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalias upload-key \
  -keyalg RSA -keysize 2048 -validity 10000

# 2. ONE-TIME: Create key.properties file
cat > ../key.properties << EOF
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload-key
storeFile=upload-keystore.jks
EOF

# 3. Update build.gradle.kts (copy from above)

# 4. Update version in pubspec.yaml if needed

# 5. Build release APK
cd ../..
flutter clean
flutter pub get
flutter build apk --release

# Result: app-release.apk ready for Play Store
```

---

## Troubleshooting

### Error: "upload-keystore.jks not found"
- Make sure you ran keytool command
- Make sure key.properties has correct storeFile path

### Error: "Keystore was tampered with"
- Keystore is corrupted
- Delete upload-keystore.jks and regenerate

### APK Build Fails
- Run `flutter clean`
- Run `flutter pub get`
- Check Java version (should be 17)
- Check Gradle cache isn't corrupted

---

## Files Changed/Created

- `frontend/android/app/upload-keystore.jks` (NEW - created by keytool, DO NOT COMMIT)
- `frontend/android/key.properties` (NEW - created by you, DO NOT COMMIT)
- `frontend/android/app/build.gradle.kts` (UPDATED - signing config)
- `frontend/android/app/proguard-rules.pro` (OPTIONAL)
- `frontend/pubspec.yaml` (version updated to 1.0.0+1)
- `frontend/lib/config/api_config.dart` (API endpoint configured)

---

## What's Next

1. ✅ Build release APK (you are here)
2. ⬜ Deploy backend to Firebase
3. ⬜ Upload to Google Play Store
4. ⬜ Get app review (24-48 hours)
5. ⬜ Publish to store

Estimated time: 30-45 minutes

