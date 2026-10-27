# Codemagic: Play Store and App Store releases

[`codemagic.yaml`](codemagic.yaml) builds a signed Android App Bundle (`.aab`) and a signed iOS archive (`.ipa`) and uploads them to the stores, **without releasing anything**:

| Platform | Goes to | Reaches users? | You then |
|---|---|---|---|
| Android | Google Play, **internal** track, as a **draft** release | No | Play Console, the **Internal testing** page: review the draft, roll it out or promote it |
| iOS | App Store Connect (shows in TestFlight once Apple has processed it) | No, not sent to beta or App Store review | Add it to a TestFlight group, or attach it to an App Store version and submit |

It runs on every push to `main` (in practice, merging the release pull request). Tester builds stay in [Firebase App Distribution](../firebase_app_distribution/README.md) on `main_dev_release`, so the two never build the same push.

The file is a template. Codemagic only reads `codemagic.yaml` from the repository root, so this copy does nothing.

## Before you start

- **Release signing in Gradle.** Do [Release signing](../README.md#release-signing) first. Without it the `.aab` is signed with the debug key and Play rejects it.
- **The app exists in Play Console, and its first `.aab` was uploaded by hand.** Google's API can't create an app or its first release. Upload one build to **Internal testing** in the console (a draft is enough); after that Codemagic can upload.
- **The app exists in App Store Connect**: register the bundle id under **Certificates, Identifiers & Profiles**, **Identifiers**, then **Apps**, **+**, **New App** in App Store Connect.
- **Optional, iOS:** add `ITSAppUsesNonExemptEncryption` = `NO` to `ios/Runner/Info.plist` if the app uses no encryption beyond HTTPS. Without it every build waits in App Store Connect for the export-compliance question.

## Activate it

1. Copy it to the root of your app:

   ```sh
   cp doc/cicd/codemagic/codemagic.yaml codemagic.yaml
   ```

2. Replace the placeholders:

   | Placeholder | Where | Replace with |
   |---|---|---|
   | `my_app` | `vars: APP_NAME` | A short name for artifact files, for example your package name |
   | `com.example.app` | `vars: PACKAGE_NAME` | Your Android `applicationId` |
   | `com.example.app` | `ios_signing: bundle_identifier` | Your iOS bundle id |
   | `3.47.0` | `flutter_version` | The Flutter version you develop with |
   | `you@example.com` | `email: recipients` | Who gets build emails |
   | `upload_keystore` | `android_signing` | The reference name you give the keystore in Codemagic |
   | `Codemagic API Key` | `integrations: app_store_connect` | The name you give the App Store Connect key in Codemagic |

3. In [Codemagic](https://codemagic.io/), **Add application**, connect the GitHub repository, and pick **codemagic.yaml** as the configuration.
4. Do the [one-time setup](#one-time-setup-credentials) below: two variable groups, the keystore, the App Store Connect key and the iOS certificate.
5. Bump `+N` in `pubspec.yaml`, commit, push to `main`. Or start a build by hand: the app, **Start new build**, pick a workflow and branch.

## The three workflows

| Workflow | Starts on | Does | Uploads |
|---|---|---|---|
| `quality-gate` | Manual only (pull requests once you uncomment it) | analyze, test, format check | nothing |
| `android-release` | push to `main` | analyze, test, signed `.aab` | Play internal track, draft |
| `ios-release` | push to `main` | analyze, test, signed `.ipa` | App Store Connect, not submitted |

A push to `main` starts both release workflows, so each release gives you a matched `.aab` and `.ipa` from the same commit. On the free plan only one build runs at a time, so they queue.

```
feature/* ──▶ main_dev ──▶ main_dev_release ──PR──▶ main
                           (GitHub Actions:          (Codemagic: .aab ─▶ Play internal draft,
                            APK to testers)                      .ipa ─▶ App Store Connect)
```

## `definitions`: shared pieces

Everything under `definitions` is a YAML anchor (`&name`), reused with `*name` or `<<: *name`. Change it once, every workflow follows.

| Anchor | What it sets | Alternatives |
|---|---|---|
| `instance` | `mac_mini_m2`, 60-minute limit | The free plan has only `mac_mini_m2` (500 macOS minutes a month, one build at a time). With billing on, `linux_x2` is cheaper and faster for `android-release` and `quality-gate`; `ios-release` must stay on a Mac |
| `flutter_version` | A pinned version | `fvm` reads `.fvmrc`, so CI follows the project file. `stable` always takes the newest stable: builds change under you without a commit, so avoid it for releases |
| `vars` | `APP_NAME`, `PACKAGE_NAME`, optional `APP_STORE_APPLE_ID` | Plain values, not secret. Secrets go in variable groups |
| `scripts` | The steps several workflows share | See each workflow below |
| `email` | Build result emails | Codemagic also supports Slack (`slack:` under `publishing`) |

## Triggers, and what changing them does

```yaml
triggering:
  events:
    - push
  branch_patterns:
    - pattern: main
      include: true
      source: true
  cancel_previous_builds: true
```

- **Why `main`:** a store upload should come from the branch that matches what users will get. Merging the release pull request (`main_dev_release` into `main`) is the push that starts it.
- **Only one include pattern.** Codemagic checks patterns top to bottom and the **last match wins**, so a `'*'` exclude after `main` would exclude `main` too, and every push is skipped with "does not match any branch patterns".
- `cancel_previous_builds: true`: a newer push cancels the older build of the same workflow. Set `false` to let every push finish.

| Trigger | Change to | Effect |
|---|---|---|
| Release on a tag | `events: [tag]` and `tag_patterns: [{ pattern: 'v*', include: true }]` in place of `branch_patterns` | Store builds only when you push a tag such as `v1.4.0`. Merging to `main` alone does nothing |
| Manual only | Delete the `triggering:` block | Builds only from **Start new build**. Useful to stay inside the free minutes |
| iOS by hand, Android on push | Delete `triggering:` from `ios-release` only | Halves the macOS minutes per release |
| Skip docs-only pushes | Add `when: { changeset: { includes: ['.'], excludes: ['**/*.md', 'doc/**'] } }` to the workflow | A push that changes only those files doesn't build |
| Gate pull requests | Uncomment `triggering` in `quality-gate` | Every pull request into `main` runs analyze and test. `source: false` means "match the target branch" |

Automatic triggers need Codemagic's webhook on the repository. Connecting through the Codemagic GitHub app adds it. If a push starts nothing and the app's **Webhooks** tab shows no deliveries, add the webhook by hand with the URL shown on that tab.

## Workflow 1: `quality-gate`

| Step | What it does |
|---|---|
| Show versions | Prints Flutter's version, the branch and the commit, for the log |
| Create .env | Decodes `ENV_FILE_BASE64` into `.env`. Fails if it's missing or empty, because `.env` is a declared asset |
| Create Firebase config files | Decodes `google-services.json`, `GoogleService-Info.plist` and `firebase_options.dart` when their variables are set |
| Install packages | `flutter pub get` |
| Generate code | `dart run build_runner build --delete-conflicting-outputs`, so DI code is current |
| Check formatting | `dart format --set-exit-if-changed lib test`. `ignore_failure: true` reports it without failing the build; delete that line to enforce it |
| Analyze and test | `flutter analyze` then `flutter test` |

## Workflow 2: `android-release`

| Step | What it does | Alternatives |
|---|---|---|
| `environment` | Flutter, Java 21, groups `app_env` and `google_play`, and `android_signing` (the keystore's reference name) | |
| Create .env, Firebase config files | As in the gate; the Firebase files only when their variables are set | Commit the Firebase files and drop the step |
| Set up Android signing | Writes `android/key.properties` from the variables Codemagic exports for the keystore (`CM_KEYSTORE_PATH`, `CM_KEYSTORE_PASSWORD`, `CM_KEY_ALIAS`, `CM_KEY_PASSWORD`), then checks the alias with `keytool` | |
| Install packages, Generate code, Analyze and test | As in the gate | Delete Analyze and test to save minutes if pull requests are gated |
| Build app bundle | `flutter build appbundle --release` | Automatic build number, see [Version numbers](#version-numbers) |
| Build APK (commented) | A directly installable `.apk` as well | A second full release build. Uncomment the `*.apk` artifact with it |
| Name artifacts | Copies the outputs to `build/dist/my_app-1.2.0-14-a1b2c3d.aab` (and the R8 `mapping.txt`) | |
| `publishing: google_play` | Uploads the `.aab` to `track: internal` with `submit_as_draft: true` | `track: alpha`, `beta`, `production` or a custom closed track. `rollout_fraction: 0.1` for a staged rollout (not with `submit_as_draft`). `changes_not_sent_for_review: true` only when Play refuses to send changes for review automatically |

**Why a draft on internal.** Nothing reaches a user by accident. A person checks the release in Play Console and rolls it out or promotes it. Uploading straight to `production` without a draft starts a release as soon as Google approves it.

## Workflow 3: `ios-release`

| Step | What it does | Alternatives |
|---|---|---|
| `integrations: app_store_connect` | Names the App Store Connect API key stored in Codemagic. Used for signing files and the upload | |
| `environment` | Flutter, latest Xcode, CocoaPods, group `app_env`, `ios_signing` | `xcode: 26.0` pins Xcode instead of `latest` |
| `ios_signing` (automatic) | `distribution_type: app_store` + `bundle_identifier`. Codemagic finds the App Store profile and certificate for that id in your code signing identities | Manual form: `certificates` + `provisioning_profiles` by reference name. **Never mix the two forms**: with uploaded files but the automatic keys, Codemagic reports "No matching profiles found for bundle identifier" |
| Install FlutterFire CLI (commented) | Needed only when `flutterfire configure` added the Crashlytics "upload symbols" build phase | |
| Create .env, Firebase files, packages, code, analyze and test | As in the Android workflow | |
| Install pods | `cd ios && pod install`, after `pub get` (which writes the file the Podfile reads). `install`, not `update`, so CI gets the versions in `Podfile.lock` | |
| Apply signing to the Xcode project | `xcode-project use-profiles`: switches the Runner target to the fetched profile and writes `/Users/builder/export_options.plist`. Not optional: the starter's project uses automatic signing, which can't sign on CI | |
| Build IPA | `flutter build ipa --release --export-options-plist=/Users/builder/export_options.plist` | Automatic build number, see [Version numbers](#version-numbers) |
| Name artifacts | Copies the `.ipa` and zips the dSYMs (the iOS symbol files, for readable crash reports) into `build/dist/` | |
| `publishing: app_store_connect` | `auth: integration`, upload only | `submit_to_testflight: true` plus `beta_groups: [Testers]` sends it to TestFlight testers (external groups go through beta review). `submit_to_app_store: true` submits for review; with `release_type: MANUAL` (the default) you still press release |

## One-time setup: credentials

Codemagic keeps secrets in three places: **environment variable groups** (app settings, **Environment variables**), **code signing identities** (team settings), and **integrations** (team settings). Tick **Secure** on every variable that is a secret.

### Group `app_env`

| Variable | Required | Value |
|---|---|---|
| `ENV_FILE_BASE64` | yes | The whole `.env`, base64-encoded |
| `GOOGLE_SERVICES_JSON_BASE64` | if the app uses Firebase | `android/app/google-services.json`, base64 |
| `GOOGLE_SERVICE_INFO_PLIST_BASE64` | if the app uses Firebase | `ios/Runner/GoogleService-Info.plist`, base64 |
| `FIREBASE_OPTIONS_DART_BASE64` | if the app uses Firebase | `lib/firebase_options.dart`, base64 |

Create each value with `base64 -i <file> | pbcopy` (macOS) or `base64 -w0 <file>` (Linux), and paste it. Base64 keeps line breaks and quotes intact, and CI gets the same bytes as your file. Re-encode and update the variable whenever the file changes.

Alternative: one variable per `.env` key, and a script that writes them out (`printf 'API_BASE_URL=%s\n' "$API_BASE_URL" >> .env` for each). Values can then be edited one by one, but every new key needs a new variable and a new line, or CI builds get an empty value while local builds work.

### Group `google_play`

| Variable | Value |
|---|---|
| `GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS` | The whole service-account JSON key, pasted as it is (Secure) |

1. [Google Cloud console](https://console.cloud.google.com/): pick or create a project and enable the **Google Play Android Developer API** in it.
2. **IAM & Admin**, **Service Accounts**, **Create service account**. No Google Cloud role is needed; click **Done**.
3. Open the account, **Keys**, **Add key**, **Create new key**, **JSON**. Keep the file safe; it can't be downloaded again.
4. Play Console, **Users and permissions**, **Invite new users**, paste the service account's email.
5. Under **App permissions**, add your app and grant: **Release apps to testing tracks** and **Manage testing tracks and edit tester lists** (enough for the internal draft). Add **Release to production, exclude devices, and use Play App Signing** only if you change the track to `production`. Admin is not needed.
6. **Invite user**, then paste the JSON into the variable.

The same kind of key drives [Fastlane](../fastlane/README.md). You can reuse one key for both; grant it **Manage store presence** as well if Fastlane will update the listing.

### Android keystore

Team settings, **Code signing identities**, **Android keystores**, upload your upload keystore (`.jks`) with its password, alias and key password. The **reference name** you type is what goes under `android_signing:` (the template uses `upload_keystore`).

If the app is already on Play, use the keystore you uploaded with before: Play checks every upload against that key. Creating one, and what to do if it's lost, is in [Flutter release signing](https://bimalkhatri.com.np/blogs/flutter-release-signing) and [resetting the upload key](https://bimalkhatri.com.np/blogs/reset-upload-key).

### App Store Connect API key (integration)

1. App Store Connect, **Users and Access**, **Integrations**, **App Store Connect API**, **Team Keys**, **+**.
2. Name it (for example `Codemagic`) and choose the role **App Manager**: enough to upload builds and read the signing files, and what Codemagic asks for. An Admin key can also manage users, which CI doesn't need.
3. Download the `.p8` (only possible once) and note the **Issuer ID** and **Key ID**.
4. Codemagic, team settings, **Team integrations**, **Developer Portal**, **Manage keys**, add the key with those three values. Its name must match `integrations: app_store_connect:` exactly.

More on what the three values are: [App Store Connect API key](https://bimalkhatri.com.np/blogs/app-store-connect-api-key).

### iOS certificate and profile

With the automatic `ios_signing` form in the template:

1. **Certificate.** Team settings, **Code signing identities**, **iOS certificates**: upload your Apple Distribution certificate as a `.p12` with its password ([exporting a .p12 from Keychain](https://bimalkhatri.com.np/blogs/export-p12-from-keychain)), or let Codemagic generate a new one through the API key. Generating uses up one of the few distribution certificates Apple allows per account, so reuse the one you have if you can.
2. **Profile.** Same page, **iOS provisioning profiles**, **Fetch profiles**, and pick the **App Store** profile for your bundle id. Create it first in the Apple Developer portal if it doesn't exist.
3. **Check what Codemagic parsed:** the profile's type is App Store, its bundle id matches `bundle_identifier`, the certificate hasn't expired, and the profile includes that certificate. A mismatch here is what later fails as "Provisioning profile doesn't include signing certificate".

With the manual form, upload the `.p12` and `.mobileprovision` the same way and list their reference names in `ios_signing`. Background on how the pieces fit: [provisioning profiles explained](https://bimalkhatri.com.np/blogs/provisioning-profile-explained).

## Version numbers

Both stores reject a build number they have already seen.

- **Default:** bump `+N` in `pubspec.yaml` (`version: 1.2.0+14` to `+15`) on `main_dev_release` before opening the release pull request. Every merge into `main` then uploads a new number, and your local builds use the same one.
- **Automatic:** let Codemagic ask the store for its latest number and add one. In `android-release` replace the build line with the two commented lines (`google-play get-latest-build-number`, using the `google_play` group's key). In `ios-release` set `APP_STORE_APPLE_ID` in `vars` (App Store Connect, **App Information**, **Apple ID**) and use the commented `app-store-connect get-latest-testflight-build-number` lines. `pubspec.yaml` then no longer matches the stores, so the artifact names (taken from `pubspec.yaml`) show the old number.

## Running a build

- **On push:** merge the release pull request into `main`. Both release workflows start.
- **By hand:** the app in Codemagic, **Start new build**, pick the workflow and any branch. Manual starts ignore `triggering`.
- **Reading a failure:** the step log first; for iOS archive failures, the `xcodebuild` log in the build's artifacts.

## Troubleshooting

| Symptom | Cause |
|---|---|
| `ENV_FILE_BASE64 is not set` | The `app_env` group is missing, or not listed under the workflow's `groups` |
| `alias '...' not found in the keystore` | The keystore was uploaded with a wrong alias or password |
| Play: `Version code N has already been used` | `+N` in `pubspec.yaml` wasn't bumped |
| Play: `The caller does not have permission` | The service account lacks the Play Console permissions above, or wasn't added to this app |
| Play: `Package not found` | The app doesn't exist in Play Console yet, or its first `.aab` wasn't uploaded by hand |
| Play: `Changes cannot be sent for review automatically` | Play has changes waiting for manual review; add `changes_not_sent_for_review: true` under `google_play` |
| `No matching profiles found for bundle identifier` | No App Store profile for that id in code signing identities, or the automatic and manual `ios_signing` forms are mixed |
| `Provisioning profile doesn't include signing certificate` | The uploaded `.p12` and the profile don't belong together |
| `flutterfire: command not found` | Uncomment the Install FlutterFire CLI step |
| App Store Connect: build number already used | Bump `+N` |
| Build uploaded but not in TestFlight | Apple is still processing it; Apple emails when it's done |
| A push starts nothing | Missing webhook, or a `branch_patterns` entry after `main` that excludes it |
| `The selected instance type is not available with the current billing plan` | `linux_x2` / `mac_mini_m4` need billing; use `mac_mini_m2` |
