# Shortly – Firebase Test Lab Integration Guide

## Overview

This document explains how to run Shortly's integration tests both **locally** and on **Firebase Test Lab**.

---

## File Structure

```
Shortly/
├── integration_test/
│   ├── app_test.dart        ← All integration test groups (8 groups, 20+ tests)
│   └── test_main.dart       ← Test-safe app entry point (no ads/IAP/update service)
├── test_driver/
│   └── integration_test.dart ← Flutter test driver (required by FTL)
├── scripts/
│   └── firebase_test_lab.ps1 ← One-shot PowerShell build + upload script
└── .github/workflows/
    └── firebase_test_lab.yml ← CI pipeline (runs on every push to main)
```

---

## What Is Tested

| Group | Coverage |
|---|---|
| **Onboarding** | Fresh launch shows page 1; Next advances pages; Skip goes to MainScreen; Get Started marks seen |
| **Bottom Navigation** | All 4 tabs render without crashing |
| **ShortenerView** | Input field, empty-URL SnackBar, text entry, paste button, provider dropdown, Recent Links header, empty state |
| **ExpanderView** | Input field present on Expand & Verify tab |
| **HistoryView** | Empty/populated state, search field, search filtering, refresh button |
| **Navigation Drawer** | Opens via swipe, closes on outside tap, Help & FAQ item tappable |
| **MenuScreen** | Settings tab renders without error |
| **Smoke – All Screens** | Cycles all 4 tabs asserting no exceptions |

---

## Running Locally

### Prerequisites

- Flutter SDK installed and on PATH  
- Android device connected (or emulator running)

### Steps

```powershell
# 1. Install dependencies
flutter pub get

# 2. Run all integration tests on the connected device
flutter test integration_test/app_test.dart -d <device-id>

# Tip: list connected devices
flutter devices
```

---

## Running on Firebase Test Lab

### One-time Setup

#### 1 – Enable Firebase Test Lab

1. Go to [Firebase Console](https://console.firebase.google.com/) → your project
2. Navigate to **Test Lab** → ensure the API is enabled
3. The free Spark plan allows a limited number of virtual device minutes per day

#### 2 – Create a Service Account (for CI)

```bash
# Create the service account
gcloud iam service-accounts create ftl-sa \
  --display-name "Firebase Test Lab SA"

# Grant required roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:ftl-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudtestservice.testAdmin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:ftl-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Download JSON key
gcloud iam service-accounts keys create ftl-sa-key.json \
  --iam-account ftl-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

> [!CAUTION]
> Never commit `ftl-sa-key.json` to source control. Add it to `.gitignore`.

#### 3 – Add GitHub Secrets (for CI workflow)

In your GitHub repo → **Settings → Secrets and variables → Actions**, add:

| Secret name | Value |
|---|---|
| `GCP_PROJECT_ID` | Your Firebase / GCP project ID (e.g. `shortly-app-12345`) |
| `GCP_SA_KEY` | Entire contents of `ftl-sa-key.json` |

---

### Manual Run (PowerShell)

```powershell
# Authenticate gcloud first (one-time)
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Build APKs and upload to Firebase Test Lab
.\scripts\firebase_test_lab.ps1 -ProjectId "YOUR_PROJECT_ID"

# Test on multiple devices (semicolon-separated)
.\scripts\firebase_test_lab.ps1 `
  -ProjectId "YOUR_PROJECT_ID" `
  -Devices "model=Pixel2,version=28,locale=en,orientation=portrait;model=Pixel6,version=33,locale=en,orientation=portrait"

# Build only – no upload (validates APK builds are healthy)
.\scripts\firebase_test_lab.ps1 -ProjectId "YOUR_PROJECT_ID" -LocalOnly
```

---

### Manual Run (bash / macOS / Linux)

```bash
# Build debug APK
flutter build apk --debug

# Build instrumentation test APK
cd android && ./gradlew app:assembleAndroidTest && cd ..

# Upload to Firebase Test Lab
gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --project YOUR_PROJECT_ID \
  --timeout 10m \
  --environment-variables clearPackageData=true \
  --device model=MediumPhone.arm,version=34,locale=en,orientation=portrait
```

---

## CI / CD Pipeline

The `.github/workflows/firebase_test_lab.yml` workflow triggers automatically on:

- Push to `main`
- Pull request targeting `main`
- Manual trigger from the **Actions** tab

### Pipeline Steps

```mermaid
flowchart LR
    A[Checkout] --> B[Setup Java 17]
    B --> C[Setup Flutter]
    C --> D[flutter pub get]
    D --> E[Build debug APK]
    E --> F[Build test APK]
    F --> G[GCP Auth]
    G --> H[gcloud FTL run]
    H --> I[Download results]
    I --> J[Upload artifact]
```

---

## Adding New Tests

1. Open `integration_test/app_test.dart`
2. Add a new `group(...)` block following the established pattern
3. Use `setUp(skipOnboarding)` to land directly on MainScreen  
   (or `setUp(resetPrefs)` if you are testing the onboarding flow)
4. Call `await pumpApp(tester)` at the start of each `testWidgets` callback

```dart
group('My New Feature', () {
  setUp(skipOnboarding);

  testWidgets('does something useful', (tester) async {
    await pumpApp(tester);

    // navigate to feature
    await tester.tap(find.byIcon(Icons.my_icon).first);
    await tester.pumpAndSettle();

    expect(find.text('Expected text'), findsOneWidget);
  });
});
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `No connected devices` | Start an emulator or connect a phone in USB debugging mode |
| Test APK not found | Run `cd android && gradlew app:assembleAndroidTest` manually and check for Gradle errors |
| `PERMISSION_DENIED` on gcloud | Ensure the service account has `cloudtestservice.testAdmin` and `storage.admin` roles |
| Tests time out | Increase `--timeout` or reduce the number of `pumpAndSettle` durations |
| Onboarding shows up unexpectedly | Ensure `setUp(skipOnboarding)` is called in the test group |
| Ad/IAP crash in tests | Tests use `test_main.dart` which skips those services — never call `app.main()` |
