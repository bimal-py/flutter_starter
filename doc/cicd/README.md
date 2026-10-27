# CI/CD templates

Ready-made pipelines for an app made from this starter: tester builds, store uploads and store listings. **Nothing here runs where it is.** Each part is a template you copy into place (`.github/workflows/`, the repository root, `android/` and `ios/`) when your app needs it, and fill in with your own ids and secrets.

## What's here

| Folder | Tool | What it does | Runs |
|---|---|---|---|
| [`firebase_app_distribution/`](firebase_app_distribution/README.md) | GitHub Actions | Checks the code, builds a signed Android APK, sends it to tester groups in Firebase App Distribution | on push to `main_dev_release`, or by hand |
| [`codemagic/`](codemagic/README.md) | Codemagic | Builds a signed `.aab` and `.ipa`, uploads them to the Play internal track (draft) and App Store Connect, releases nothing | on push to `main`, or by hand |
| [`fastlane/`](fastlane/README.md) | Fastlane | Keeps the Play and App Store listing (text, icon, screenshots, release notes) as files and uploads them | on your machine, when the listing changes |

## Which one fits when

- **Testers need the latest build on their phones** (QA, a client, the team): Firebase App Distribution. Fast to set up, no store review, the APK installs directly. Android only as shipped.
- **A build should go to the stores:** Codemagic. It runs on Macs, so iOS works without owning one in CI, and its free plan covers a small app's releases. Uploads stay drafts until a person promotes them.
- **The store listing changes** (new screenshots, descriptions in more languages, release notes): Fastlane. It doesn't touch builds here, so it doesn't overlap with Codemagic.

They're meant to be used together, one branch each:

```
feature/* ──▶ main_dev ──▶ main_dev_release ──PR──▶ main
                           │                        │
                           GitHub Actions           Codemagic
                           APK ─▶ Firebase testers  .aab ─▶ Play internal (draft)
                                                    .ipa ─▶ App Store Connect
Fastlane (by hand): metadata/ + screenshots/ ─▶ Play and App Store listings
```

Use only the parts you need. Each README says how to activate its part and what to change if your branches differ.

## Release signing

Every Android pipeline here needs release signing in Gradle. The starter signs release builds with the **debug** key so that `flutter run --release` works out of the box; Google Play rejects those builds, and testers can't update from them to a Play build.

1. Create an upload keystore, once per app, and keep it (and its passwords) somewhere safe outside the repository. Losing it means asking Google to reset the upload key.

   ```sh
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
     -storetype JKS -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties` (gitignored in the starter) for local release builds:

   ```properties
   storePassword=<keystore password>
   keyPassword=<key password>
   keyAlias=upload
   storeFile=/Users/you/upload-keystore.jks
   ```

3. In `android/app/build.gradle.kts`, load `key.properties` and use it for release builds. Add the imports at the top and the `keystoreProperties` lines before `android {`:

   ```kotlin
   import java.io.FileInputStream
   import java.util.Properties

   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }

   android {
       // ... existing settings

       signingConfigs {
           create("release") {
               keyAlias = keystoreProperties.getProperty("keyAlias")
               keyPassword = keystoreProperties.getProperty("keyPassword")
               storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
               storePassword = keystoreProperties.getProperty("storePassword")
           }
       }

       buildTypes {
           release {
               // Release key when key.properties exists (your machine, CI);
               // debug key otherwise, so a fresh clone still runs in release mode.
               signingConfig = if (keystorePropertiesFile.exists()) {
                   signingConfigs.getByName("release")
               } else {
                   signingConfigs.getByName("debug")
               }
           }
       }
   }
   ```

   Replace the starter's `signingConfig = signingConfigs.getByName("debug")` line; don't keep both. The fallback is convenient but can hide a missing `key.properties`, which is why the Firebase workflow checks the APK's certificate and Codemagic writes the file before every build.

4. Check: `flutter build appbundle --release`, then `keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab` should show your certificate, not `CN=Android Debug`.

Each step, the Groovy version and what to do in CI are explained in [Flutter release signing](https://bimalkhatri.com.np/blogs/flutter-release-signing). Why Play has a second key of its own: [Play App Signing](https://bimalkhatri.com.np/blogs/play-app-signing).

## Secrets: the rules for every part

- Never commit a key, keystore, password or token. Secrets live in GitHub (Settings, Secrets and variables, Actions), in Codemagic (environment variable groups, code signing identities, integrations), or for Fastlane in gitignored files on your machine.
- `.env` ships inside the app, so the pipelines recreate it from a secret, but anything in it can be read out of the APK or IPA. Real secrets stay on your server.
- Give each credential the smallest role that works: Firebase App Distribution Admin for the Firebase service account, release permissions (not Admin) for the Play service account, App Manager (not Admin) for the App Store Connect key used by CI.
