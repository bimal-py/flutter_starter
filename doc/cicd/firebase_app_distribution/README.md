# Firebase App Distribution with GitHub Actions

[`firebase_app_distribution.yml`](firebase_app_distribution.yml) builds a signed release APK and sends it to your testers through Firebase App Distribution. Testers get an email (or a notification in the Firebase App Tester app) and install the build on their phones. Nothing goes to Google Play.

It runs on every push to `main_dev_release` and on demand. It checks the code first (`flutter analyze`, `flutter test`), so a build that fails either never reaches testers.

The file is a template. It does nothing until you copy it into `.github/workflows/`.

Android only, like the pipelines it was taken from. See [Adding iOS](#adding-ios) for what an iOS version needs.

## Before you start

- **Release signing in Gradle.** The starter signs release builds with the debug key. Do [Release signing](../README.md#release-signing) first, or the workflow stops at its signature check.
- **A Firebase project with your Android app in it**, registered with the same package name as `applicationId` in `android/app/build.gradle.kts`. You need this even if the app itself doesn't use Firebase.
- **At least one tester group**: Firebase console, **App Distribution**, **Testers & Groups**, **Add group**. Add the testers' emails to it.

## Activate it

1. Copy the workflow into place:

   ```sh
   mkdir -p .github/workflows
   cp doc/cicd/firebase_app_distribution/firebase_app_distribution.yml .github/workflows/
   ```

2. Set `TESTER_GROUPS` in the file's `env:` block to your group alias (see [Tester groups](#tester-groups)).
3. Add the secrets below: GitHub repository, **Settings**, **Secrets and variables**, **Actions**, **New repository secret**.
4. Commit, push to your default branch, then create the release branch: `git push origin HEAD:main_dev_release`. That push starts the first run.

From then on, merging into `main_dev_release` and pushing sends a build to testers.

## Secrets

| Secret | Required | What it is |
|---|---|---|
| `ENV_FILE` | yes | The whole `.env` file |
| `KEYSTORE_BASE64` | yes | The upload keystore (`.jks`), base64-encoded |
| `KEYSTORE_PASSWORD` | yes | The keystore password |
| `KEY_ALIAS` | yes | The key's alias inside the keystore (often `upload`) |
| `KEY_PASSWORD` | yes | The key password (often the same as the keystore password) |
| `FIREBASE_SERVICE_ACCOUNT_KEY` | yes | A Google Cloud service-account key (JSON) allowed to upload to App Distribution |
| `FIREBASE_ANDROID_APP_ID` | yes | The Firebase Android app id, `1:<project number>:android:<hash>` |
| `GOOGLE_SERVICES_JSON` | only if the app uses Firebase | The contents of `android/app/google-services.json` |
| `FIREBASE_OPTIONS_DART` | only if the app uses Firebase | The contents of `lib/firebase_options.dart` |

The [GitHub CLI](https://cli.github.com/) sets a secret straight from a file, which avoids copy-paste mistakes with multi-line values:

```sh
gh secret set ENV_FILE < .env
base64 -i android/app/upload-keystore.jks | gh secret set KEYSTORE_BASE64
gh secret set FIREBASE_SERVICE_ACCOUNT_KEY < ~/Downloads/your-service-account.json
gh secret set GOOGLE_SERVICES_JSON < android/app/google-services.json
gh secret set FIREBASE_OPTIONS_DART < lib/firebase_options.dart
gh secret set KEYSTORE_PASSWORD     # prompts for the value
```

### `ENV_FILE`

Paste the whole `.env` file as one secret. The workflow writes it back as `.env`, because `pubspec.yaml` lists `.env` as an asset and nothing builds without it. Use the values the tester build should have (for example the production `API_BASE_URL`).

Alternative: one secret per key, assembled in the step (`echo "API_BASE_URL=${{ secrets.API_BASE_URL }}" >> .env` for each key). Each value can then be edited alone, but every new key in `.env_example` needs a new secret and a new line in the workflow, or CI builds quietly get an empty value.

`.env` ships inside the APK. Put only public values in it, as [Getting started](../../getting_started.md#hidden-details) says.

### Keystore: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`

Use the same upload keystore you use (or will use) for Google Play. Creating one is covered in [Release signing](../README.md#release-signing).

A secret holds text, so the binary `.jks` is stored base64-encoded:

| OS | Command |
|---|---|
| macOS | `base64 -i android/app/upload-keystore.jks \| pbcopy` (now on the clipboard) |
| Linux | `base64 -w0 android/app/upload-keystore.jks` |
| Windows (PowerShell) | `[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\upload-keystore.jks"))` |

The workflow decodes it into the runner's temp folder (outside the checkout), writes `android/key.properties` pointing at it, and runs `keytool` to check the alias and password before the build starts. A wrong alias then fails in seconds instead of deep inside Gradle.

### `FIREBASE_SERVICE_ACCOUNT_KEY`

A service account is a robot Google account that the workflow signs in as.

1. Open [Google Cloud console](https://console.cloud.google.com/), pick the project with the same name as your Firebase project.
2. **IAM & Admin**, **Service Accounts**, **Create service account**. Name it, for example `github-app-distribution`.
3. Grant it the role **Firebase App Distribution Admin**. Nothing more is needed to upload builds.
4. Open the account, **Keys**, **Add key**, **Create new key**, **JSON**. A `.json` file downloads.
5. Paste the whole file into the secret, then delete the download.

Why not a Firebase token (`firebase login:ci`): the action marks the `token` input as deprecated, and the Firebase CLI warns that these tokens will be removed. A token also acts as your personal Google account; the service account can do only one job and can be revoked alone.

### `FIREBASE_ANDROID_APP_ID`

Firebase console, **Project settings**, **General**, **Your apps**, your Android app, **App ID**. It looks like `1:123456789012:android:0a1b2c3d4e5f6a7b`. It isn't secret; keeping it with the other secrets just keeps the setup in one place. To make it a variable instead, add it under the **Variables** tab and change the workflow to `${{ vars.FIREBASE_ANDROID_APP_ID }}`.

### `GOOGLE_SERVICES_JSON` and `FIREBASE_OPTIONS_DART`

Only for apps that turned on Firebase ([Getting started, step 3](../../getting_started.md#3-set-up-firebase-only-if-you-use-it)). The starter gitignores both files, so CI has to recreate them. The step skips a file whose secret isn't set. If you commit the files instead, leave both secrets out.

### Tester groups

Firebase console, **App Distribution**, **Testers & Groups**. Each group has a display name and an **alias** (lowercase, with dashes). The workflow needs the alias. Several groups are comma-separated: `TESTER_GROUPS: "qa-team, clients"`.

## The workflow, block by block

### `on:` (when it runs)

```yaml
on:
  push:
    branches: [main_dev_release]
  workflow_dispatch:
```

**Why a dedicated release branch.** Testers get a build only when you decide a set of changes is ready: you merge `main_dev` (or whatever your work branch is) into `main_dev_release` and push. Everyday commits don't flood testers with builds, and you don't spend CI minutes on every push. It also keeps tester builds apart from store builds: the [Codemagic](../codemagic/README.md) workflows run on `main`, so the two pipelines never build the same push.

```
feature/* ──▶ main_dev ──▶ main_dev_release ──PR──▶ main
                           (this workflow:          (Codemagic:
                            APK to testers)          Play Store + App Store)
```

Alternatives, and what changing to them does:

| Trigger | Runs | Choose it when |
|---|---|---|
| `branches: [main_dev_release]` (default) | on a push to the release branch | you want to choose when testers get a build |
| `branches: [main]` | on every merge to `main` | you have no release branch and testers should get everything that lands. Collides with the Codemagic store workflows, which also run on `main` |
| `branches: [main_dev_release, main]` | on both | testers should also get the exact build that went to the stores. Every release is then built twice (here and in Codemagic) |
| `tags: ['v*']` (in place of `branches`) | when you push a tag such as `v1.4.0` | tester builds should match versions. Release notes come from the tagged commit |
| `workflow_dispatch` only (delete `push:`) | only when started by hand | builds are rare, or minutes are tight |

Keep `workflow_dispatch` in every case: it adds the **Run workflow** button, with fields for release notes and tester groups.

Don't use `pull_request` for this workflow. Secrets aren't passed to pull requests from forks, and a tester build per pull request is rarely what you want. Run only the `check` job on pull requests, in a separate workflow, if you want a gate there.

To skip runs for documentation-only pushes, add under `push:`:

```yaml
    paths-ignore: ['**.md', 'doc/**']
```

### `permissions`, `concurrency`, `env`

- `permissions: contents: read`: the run's built-in token can read the code and do nothing else. Nothing in this workflow writes to the repository.
- `concurrency` with `cancel-in-progress: true`: a new push to the same branch cancels the run still going, so testers get the newest build and you don't pay for an outdated one. Set it to `false` if every push must reach testers.
- `FLUTTER_VERSION`: empty means "use the project's version": `.fvmrc` if there is one, otherwise the number in `pubspec.yaml` under `environment: flutter:` (the starter has `">=3.47.0"`, so CI uses 3.47.0, the minimum). For builds that match your machine exactly, pin the version you develop with, here or in `.fvmrc`.
- `JAVA_VERSION: "21"`: the Android Gradle plugin needs JDK 17 or newer; 17 works too.
- `TESTER_GROUPS`: the default group aliases, used when a run doesn't name others.

### Job 1: `check`

Runs first and alone. If it fails, `distribute` never starts.

| Step | What it does |
|---|---|
| `actions/checkout` | Gets the code at the pushed commit |
| Resolve Flutter version | Picks the version as described above and fails with a clear message if none is found |
| `subosito/flutter-action` | Installs that Flutter. `cache: true` keeps the SDK and pub packages between runs, so later runs start faster |
| Create .env | Writes `.env` from `ENV_FILE`. Fails if the secret is empty, because the app would throw at start-up anyway |
| Create firebase_options.dart | Writes it from `FIREBASE_OPTIONS_DART` when that secret is set: once the app imports the file, analyze and test need it |
| Install packages | `flutter pub get` |
| Generate code | `dart run build_runner build --delete-conflicting-outputs`. The starter commits `injection.config.dart`, but a stale one (a class added without re-running build_runner) breaks DI at run time; regenerating catches it |
| Analyze | `flutter analyze`. Fails on errors, warnings and infos, the same "clean" the project expects locally |
| Test | `flutter test` |

Uncomment **Check formatting** to also fail on code that `dart format` would change.

Alternative: delete the `check` job and the `needs: check` line. One Flutter setup less per run, but a build that doesn't analyze or pass its tests then reaches testers.

### Job 2: `distribute`

| Step | What it does | Alternatives |
|---|---|---|
| `environment:` (commented) | Moves the secrets into a GitHub Environment | Uncomment it to require a reviewer's approval before each tester build, or to use different secrets than other workflows |
| `subosito/flutter-action` | Same Flutter as `check` (it reuses the version `check` resolved) | |
| `actions/setup-java` | Installs JDK 21 and caches Gradle downloads | |
| Create .env | As in `check` | |
| Create Firebase config files | Writes `google-services.json` and `firebase_options.dart` when their secrets are set | Commit both files and delete the step |
| Set up release signing | Decodes the keystore to the runner's temp folder, writes `android/key.properties`, checks the alias | |
| Install packages, Generate code | As in `check` | |
| Build release APK | `flutter build apk --release`. Version name and code come from `version: X.Y.Z+N` in `pubspec.yaml` | See [Version numbers](#version-numbers). Add `--obfuscate --split-debug-info=build/symbols` to obfuscate Dart code |
| Check the APK is signed with the release key | Reads the APK's certificate with `apksigner` and fails if it's the Android debug key | |
| Name the APK | Renames it to `<name>-<version>-<build>-<commit>.apk`, for example `my_shop-1.2.0-14-a1b2c3d.apk`, so a tester or you can tell builds apart | |
| Write release notes | The text from the manual-run form if given, otherwise the last commit message, plus a `branch @ commit` line | See [Release notes](#release-notes) |
| `actions/upload-artifact` | Keeps the APK downloadable from the run's page for 14 days | Change `retention-days`, or delete the step |
| Upload to Firebase App Distribution | Uploads the APK to the app (`appId`), signs in with the service account, sends it to `groups` with the notes | Add `testers: "a@example.com, b@example.com"` to invite people outside the groups |
| Remove signing files | Deletes the keystore, `key.properties` and `.env` | Only matters on a self-hosted runner; GitHub's runners are thrown away after the job |

**Why an APK and not an AAB.** App Distribution accepts both, but an AAB only works once the Firebase app is linked to the same app in Google Play and the app is on a Play track. An APK needs nothing extra. Don't add `--split-per-abi`: the upload step takes one file.

### Version numbers

Testers can install a build over their current one only if its versionCode (the `+N` in `pubspec.yaml`) is the same or higher. Two ways to handle it:

- **Default: from `pubspec.yaml`.** Bump `+N` before merging into `main_dev_release` when you want testers to see a new build number. Store uploads need a new `+N` anyway.
- **One build number per run:** add `--build-number=${{ github.run_number }}` to the build step. Every tester build then gets a new versionCode with no bump. The catch: `run_number` counts this workflow's runs (1, 2, 3...), so it can be lower than the `+N` of a store build a tester already has, and Android refuses the downgrade. To start above your current `+N`, add an offset: `--build-number=$(( 1000 + ${{ github.run_number }} ))`. Store builds then need a `+N` above the tester builds too.

### Release notes

The notes come from the last commit message, so write merge commits (or squash commits) that make sense to a tester. A manual run's **Release notes** field overrides it.

To list every commit in a push instead of only the last one, check out with history (`fetch-depth: 0` under `actions/checkout`) and replace the `git log -1` line with:

```sh
git log --pretty=format:'- %s' "${{ github.event.before }}..${{ github.sha }}" > "$RUNNER_TEMP/release_notes.txt"
```

On the first push of a new branch, and on manual runs, `github.event.before` is empty or all zeros; keep the `git log -1` line as the fallback for those.

The form's text reaches the script through an environment variable, not pasted into the script, so whatever someone types there can't run as a shell command.

## Running it

- **Automatically:** merge into `main_dev_release` and push.

  ```sh
  git checkout main_dev_release
  git merge main_dev
  git push
  ```

- **By hand:** **Actions**, **Firebase App Distribution (Android)**, **Run workflow**, pick the branch, optionally type notes and groups. Or from a terminal:

  ```sh
  gh workflow run firebase_app_distribution.yml --ref main_dev_release -f release_notes="Fixes the login crash"
  ```

GitHub shows the **Run workflow** button only for workflow files on the default branch, and a push runs the copy of the file on the pushed branch. Keep the file on both.

## Troubleshooting

| Symptom | Cause |
|---|---|
| `Secret ENV_FILE is empty` | The secret is missing, or misspelled |
| `Secret KEYSTORE_BASE64 is empty` (or another keystore secret) | Same, for that secret |
| `Alias '...' not found in the keystore, or the password is wrong` | `KEY_ALIAS` or `KEYSTORE_PASSWORD` doesn't match the keystore. List the aliases with `keytool -list -keystore upload-keystore.jks` |
| `The APK is signed with the debug key` | `android/app/build.gradle.kts` still uses `signingConfigs.getByName("debug")` for release. See [Release signing](../README.md#release-signing) |
| `No Flutter version found` | Pin `FLUTTER_VERSION` in the workflow or add `.fvmrc` |
| Analyze fails on CI but not locally | CI used another Flutter version (pin it), or `.env` / generated files differ |
| Firebase: `403` / `The caller does not have permission` | The service account lacks **Firebase App Distribution Admin**, or belongs to another Google Cloud project |
| Firebase: `404` / app not found | `FIREBASE_ANDROID_APP_ID` is wrong, or from another Firebase project |
| Upload succeeds, nobody gets an email | `TESTER_GROUPS` holds a display name instead of the alias, or the group is empty |
| Tester sees "App not installed" | The phone has a build signed with another key, or with a higher versionCode. Uninstall it first, then install |
| No **Run workflow** button | The workflow file isn't on the default branch |

## Adding iOS

The source pipelines distribute Android only, so this template does too. An iOS job needs:

- A **macOS runner** (`runs-on: macos-latest`). GitHub bills macOS minutes at about ten times the Linux rate on private repositories.
- An **Ad Hoc** provisioning profile that lists every tester's device UDID (App Distribution can collect UDIDs from testers), plus the distribution certificate as a `.p12`. Store both base64-encoded as secrets and import them into a temporary keychain with the `security` command before building.
- `flutter build ipa --release --export-method ad-hoc`.
- The upload: the Firebase action used here is a Docker action, and Docker actions don't run on macOS runners. Upload the `.ipa` as an artifact and send it from a second `ubuntu-latest` job with the same Firebase step, or call the Firebase CLI on the Mac (`firebase appdistribution:distribute build/ios/ipa/*.ipa --app <iOS app id> --groups <aliases>`).

For most teams [TestFlight through Codemagic](../codemagic/README.md) is simpler: no device UDIDs, and Codemagic handles the signing.
