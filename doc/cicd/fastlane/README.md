# Fastlane for the store listings

Fastlane keeps your Google Play and App Store **listing** (name, descriptions, keywords, release notes, icon, screenshots) as plain files in the repository, and uploads them with one command. You edit text in your editor, review it in a pull request, and stop clicking through two consoles in every language.

This setup uses Fastlane **only for the listing**. Builds are uploaded by CI ([Codemagic](../codemagic/README.md)), so the lanes here never build or upload an app binary. Fastlane runs on your machine; nothing in this folder runs on CI.

The files in [`templates/`](templates/) are templates, not wired into the project. You copy them into `android/` and `ios/` in the steps below.

The full walkthrough, with screenshots of each console screen: [Fastlane store listings for a Flutter app, step by step](https://bimalkhatri.com.np/blogs/fastlane-store-listing-flutter).

## What you end up with

```
android/
  Gemfile, Gemfile.lock
  fastlane/
    Appfile                 package name + path to the Play key
    Fastfile                upload_listing, upload_images
    play-store-key.json     Google Play service-account key (gitignored)
    metadata/android/       the Play listing, one folder per language
ios/
  Gemfile, Gemfile.lock
  fastlane/
    Appfile                 bundle id
    Deliverfile             sign-in + safety switches for deliver
    Fastfile                upload_listing
    appstore_api_key.json   App Store Connect API key (gitignored)
    metadata/               the App Store listing, one folder per language
    screenshots/            App Store screenshots, one folder per language
```

The two platforms are separate on purpose: each folder has its own Gemfile and runs on its own, the same layout `fastlane init` creates in a Flutter project.

## 1. Install Ruby, Bundler and Fastlane

Fastlane needs **Ruby 3.2 or newer** (3.3+ preferred). The Ruby that ships with macOS is older and its gem folder isn't writable, so don't use it.

```sh
brew install ruby          # or rbenv / asdf, if you already use one
ruby --version             # must print 3.2 or newer; fix PATH if it still shows the system Ruby
gem install bundler
```

Then, in **each** of `android/` and `ios/`:

```sh
cp ../cicd/fastlane/templates/Gemfile .
bundle config set --local path vendor/bundle   # install gems inside the project, no sudo
bundle install
```

Commit `Gemfile` and `Gemfile.lock`, so everyone runs the same Fastlane version. Always run it as `bundle exec fastlane ...`. Update later with `bundle update fastlane`.

Alternative: `brew install fastlane` brings its own Ruby and needs no Gemfile, but every machine then runs whatever version Homebrew has.

Add this to the project's `.gitignore` before anything else:

```gitignore
# Fastlane: keys and generated files. metadata/ and screenshots/ ARE committed.
**/fastlane/play-store-key.json
**/fastlane/appstore_api_key.json
**/fastlane/*.p8
**/fastlane/report.xml
**/fastlane/Preview.html
**/fastlane/test_output
**/fastlane/metadata/review_information/demo_password.txt
**/.bundle/
**/vendor/bundle/
```

`demo_password.txt` is the App Review demo account's password; keep it out of git and add it by hand before an upload that needs it.

## 2. Get the credentials

### Google Play: service-account JSON key

1. [Google Cloud console](https://console.cloud.google.com/): pick or create a project and enable the **Google Play Android Developer API**.
2. **IAM & Admin**, **Service Accounts**, **Create service account**. Give it a name, then **Done** (no Google Cloud role is needed).
3. Open the account, **Keys**, **Add key**, **Create new key**, **JSON**. Save it as `android/fastlane/play-store-key.json`.
4. Play Console, **Users and permissions**, **Invite new users**, paste the service account's email. Under **App permissions** add your app and grant:

   | Permission | Needed for |
   |---|---|
   | **View app information (read-only)** | downloading the listing |
   | **Manage store presence** | uploading text, graphics, screenshots |
   | **Release apps to testing tracks** | `whats_new:true` on an internal or closed release |
   | **Release to production, exclude devices, and use Play App Signing** | `whats_new:true` on a production release |

   Fastlane's guide suggests **Admin (all permissions)**. It works, but the key can then do anything in your account; grant only what the lanes use.

5. **Invite user**. Then check the key works:

   ```sh
   cd android
   bundle exec fastlane run validate_play_store_json_key json_key:fastlane/play-store-key.json
   ```

The same key can drive Codemagic's Play upload; that only needs the release permissions.

### App Store Connect: API key

1. App Store Connect, **Users and Access**, **Integrations**, **App Store Connect API**, **Team Keys**, **+**.
2. Name it and pick a role. **App Manager** can edit the listing and upload builds; **Admin** can also manage users, which Fastlane doesn't need.
3. Download the `.p8` (possible once only) and note the **Issuer ID** (top of the page) and **Key ID** (in the key's row).
4. Write `ios/fastlane/appstore_api_key.json` in the format Fastlane reads. This one-liner reads the `.p8` and escapes it correctly:

   ```sh
   cd ios
   ruby -rjson -e 'puts JSON.pretty_generate(key_id: ARGV[0], issuer_id: ARGV[1], key: File.read(ARGV[2]), in_house: false)' \
     A1B2C3D4E5 00000000-0000-0000-0000-000000000000 ~/keys/AuthKey_A1B2C3D4E5.p8 \
     > fastlane/appstore_api_key.json
   ```

   Replace the Key ID, Issuer ID and path with yours. Keep the `.p8` outside the repository.

More on the three values: [App Store Connect API key](https://bimalkhatri.com.np/blogs/app-store-connect-api-key).

## 3. The app must exist in both consoles first

Fastlane edits a listing; it can't create the app.

- **Google Play needs at least one `.aab` uploaded through Play Console before `supply` works for the app.** Create the app in Play Console, build `flutter build appbundle --release`, and upload it to **Internal testing**. Saving it as a draft release is enough; you don't have to roll it out. Until then every call fails with a "package not found" style error, because the Play API only knows apps that have a build.
- **App Store:** register the bundle id (Apple Developer, **Certificates, Identifiers & Profiles**, **Identifiers**) and create the app in App Store Connect (**Apps**, **+**, **New App**). A new app starts with version 1.0 in Prepare for Submission, which is what `deliver` writes into.

## 4. `fastlane init` in each platform folder

### Android

```sh
cd android
bundle exec fastlane init
```

It asks for:

- **Package name:** your `applicationId`, for example `com.example.app`.
- **Path to the json secret file:** `fastlane/play-store-key.json`.
- **Download existing metadata and set up metadata management?** Answer **y** if the key and the first upload (step 3) are done; it then runs `supply init` for you. Answer **n** to do it in step 5.

Then replace the generated `Appfile` and `Fastfile` with the templates and set your package name in `Appfile`:

```sh
cp ../cicd/fastlane/templates/android/fastlane/Appfile ../cicd/fastlane/templates/android/fastlane/Fastfile fastlane/
```

### iOS

```sh
cd ios
bundle exec fastlane init
```

Choose **Manual setup**. The other choices sign in with an Apple ID and set up build lanes this setup doesn't use. Then copy the `Appfile` and `Fastfile` templates and set your bundle id in `Appfile`. Copy the `Deliverfile` **after** step 5, because `deliver init` writes its own:

```sh
cp ../cicd/fastlane/templates/ios/fastlane/Appfile ../cicd/fastlane/templates/ios/fastlane/Fastfile fastlane/
```

## 5. First time: download the current listing

Start from what the stores have now, so your first upload doesn't wipe anything.

**Android**, from `android/`:

```sh
bundle exec fastlane supply init
```

It fills `fastlane/metadata/android/` with every language's text, images, screenshots and changelogs. It refuses to run when that folder already exists; to download again later, move the folder away first (`mv fastlane/metadata/android /tmp/old_listing`).

**iOS**, from `ios/`:

```sh
bundle exec fastlane deliver init --api_key_path fastlane/appstore_api_key.json
cp ../cicd/fastlane/templates/ios/fastlane/Deliverfile fastlane/
```

`deliver init` creates `fastlane/metadata/` and `fastlane/screenshots/` from App Store Connect, plus a `Deliverfile`, which the second line replaces with the template. To download again later (or if a `Deliverfile` already exists), use:

```sh
bundle exec fastlane deliver download_metadata --api_key_path fastlane/appstore_api_key.json
bundle exec fastlane deliver download_screenshots --api_key_path fastlane/appstore_api_key.json
```

Between releases there is no editable version, so add `--use_live_version true` to read the live one.

Commit `metadata/` and `screenshots/`. From here on, they are the source of your listing.

## 6. Folder layout

### Google Play (`android/fastlane/metadata/android/`)

```
en-US/
  title.txt                     app name, up to 30 characters
  short_description.txt         up to 80 characters
  full_description.txt          up to 4,000 characters
  video.txt                     YouTube URL, optional
  changelogs/
    default.txt                 "What's new", used when no file matches
    15.txt                      "What's new" for versionCode 15 (the +15 in pubspec.yaml)
  images/
    icon.png                    512 x 512, 32-bit PNG
    featureGraphic.png          1024 x 500, JPEG or 24-bit PNG (no alpha)
    phoneScreenshots/           1.png, 2.png ... uploaded in file-name order
    sevenInchScreenshots/
    tenInchScreenshots/
ne-NP/
  ...
```

Play screenshots: JPEG or 24-bit PNG without transparency, each side between 320 and 3,840 px, the long side at most twice the short one, up to 8 per device type. Changelog files hold up to 500 characters.

### App Store (`ios/fastlane/`)

```
metadata/
  copyright.txt
  primary_category.txt, secondary_category.txt
  review_information/           contact details and notes for App Review
    first_name.txt, last_name.txt, phone_number.txt, email_address.txt
    demo_user.txt, demo_password.txt (gitignored), notes.txt
  en-US/
    name.txt                    up to 30 characters
    subtitle.txt                up to 30 characters
    description.txt             up to 4,000 characters
    keywords.txt                comma-separated, up to 100 characters
    promotional_text.txt        up to 170 characters, can change without a review
    release_notes.txt           "What's New" of the version being edited
    support_url.txt, marketing_url.txt, privacy_url.txt
screenshots/
  en-US/
    1_home.png, 2_detail.png ...  device detected from pixel size, ordered by file name
```

App Store screenshots: PNG or JPEG without transparency, 1 to 10 per device size. Provide the largest iPhone size (6.9-inch, 1320 x 2868; App Store Connect also accepts 6.5-inch, 1284 x 2778) and, if the app runs on iPad, 13-inch (2064 x 2752). Smaller devices are scaled from those. Apple adds sizes with new devices; check [Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications) before a shoot.

Language folder names must match each store's codes (`en-US`, `ne-NP` on Play; `en-US`, `hi` on the App Store). The download in step 5 creates the right ones; copy one of those to add a language.

## 7. Later releases

### Google Play, from `android/`

| You changed | Run |
|---|---|
| Title or descriptions | `bundle exec fastlane upload_listing validate:true`, then without `validate:true` |
| "What's new" for the new build | Write `changelogs/<versionCode>.txt`. After CI has uploaded the build, run `bundle exec fastlane upload_listing whats_new:true` |
| Icon, feature graphic or screenshots | `bundle exec fastlane upload_images validate:true`, then without it |

- `validate:true` asks Google to check the change and commits nothing. Use it every time.
- Every real upload is **sent to Google's review at once**. The Play API has no draft for listing changes. To decide when approved changes go live, turn on **Managed publishing** in Play Console (it's a console setting; Fastlane can't set it).
- Don't rely on `changes_not_sent_for_review` to hold changes back. Google's API describes it for apps with rejected changes; on an app in good standing it has been seen accepted without an error while the changes still went to review.
- Local screenshots **replace** a language's set on Play. Make sure the folder holds every screenshot you want, not only the new one.

Without the template lanes, the same text upload is:

```sh
bundle exec fastlane supply --skip_upload_apk true --skip_upload_aab true \
  --skip_upload_images true --skip_upload_screenshots true --skip_upload_changelogs true \
  --validate_only true
```

### App Store, from `ios/`

1. Create the new version: in App Store Connect (**+** next to the iOS app's versions), or let the lane do it with `version:1.3.0`.
2. Edit `metadata/<locale>/release_notes.txt` (Apple requires "What's New" on every update) and anything else that changed.
3. Upload:

   | You changed | Run |
   |---|---|
   | Text only | `bundle exec fastlane upload_listing text:true` |
   | Text and screenshots | `bundle exec fastlane upload_listing` |
   | Not sure what will change | add `preview:true` to see the HTML preview and confirm first |
   | New version and text | `bundle exec fastlane upload_listing version:1.3.0 text:true` |

4. Review the version in App Store Connect, attach the build CI uploaded, and submit it yourself. The Deliverfile never submits.

- `deliver` re-sends every field in `metadata/`, including the name and subtitle. That's harmless when they haven't changed.
- `promotional_text.txt` can be updated on the live app without a new version or review.
- With `overwrite_screenshots(true)` the local folder replaces each language's screenshots in App Store Connect. Download first if your copy may be out of date.

Without the template lane, a text-only upload is:

```sh
bundle exec fastlane deliver --skip_binary_upload true --skip_screenshots true --force true
```

## Troubleshooting

| Symptom | Cause |
|---|---|
| `supply init`: package not found / app not found | No build uploaded in Play Console yet (step 3), or `package_name` is wrong |
| `The caller does not have permission` | The service account wasn't invited in Play Console, or lacks the permission for that action |
| `validate_play_store_json_key` fails | Wrong file, or the Google Play Android Developer API isn't enabled in that Google Cloud project |
| `supply init` refuses to start | `fastlane/metadata/android` already exists; move it away first |
| `deliver`: no editable version found | No version in Prepare for Submission; create one or pass `version:` |
| `deliver init`: Deliverfile already exists | Use `deliver download_metadata` and `download_screenshots` instead |
| `deliver` asks for an Apple ID | The API key JSON wasn't found: run from `ios/`, check `api_key_path` |
| Screenshot rejected for its size | Its pixel size matches no App Store device; export at an exact size from the table above |
| `bundle: command not found`, or gems need sudo | You're on the system Ruby; install Ruby 3.2+ and `gem install bundler` |
