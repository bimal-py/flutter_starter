# Image optimizer

`tool/optimize_images.py` makes the PNG, JPEG and WebP files in your assets smaller, so the app download is smaller. By default it is lossless and only reports: nothing changes on disk until you say where to write, and no pixel changes unless you ask for a lossy option.

## Setup

1. Python 3.9 or newer: `python3 --version`. macOS has one with the Xcode command-line tools, or `brew install python`.
2. Install [Pillow](https://pypi.org/project/pillow/), the imaging library the script uses:

   ```sh
   python3 -m pip install pillow
   ```

   If pip refuses with "externally-managed-environment" (Homebrew's Python does), use a virtual environment once and run the script with its Python:

   ```sh
   python3 -m venv ~/.venvs/tools
   ~/.venvs/tools/bin/pip install pillow
   ~/.venvs/tools/bin/python tool/optimize_images.py
   ```

3. Run it from the project root. `python3 tool/optimize_images.py --help` lists every option.

## What it does

With no options it checks `assets/images/` and its sub-folders and prints what it **would** do:

```sh
python3 tool/optimize_images.py
```

```
    before       after  change  file  [what happened]
   19.3 KB     12.1 KB    -37%  assets/images/ads/callbreak.png  [would compress lossless]
   18.4 KB           -          assets/images/ads/pomodoro.png  [skip: lossy source (JPEG data in a .png file), pass --quality to re-encode]
   23.2 KB     23.6 KB     +2%  assets/images/default_image.png  [keep: not smaller]

8 file(s) checked, 6 would change, 0 error(s)
total 5.47 MB -> 5.35 MB  (saved 124.6 KB, 2.2%)

Report only. Add --in-place to replace the files, or --out-dir DIR to write copies.
```

The rules it follows:

| Rule | Why |
|---|---|
| Writes nothing without `--in-place` or `--out-dir` | You see the result before anything changes |
| Lossless unless you ask: PNGs and lossless WebPs are recompressed, then decoded again and compared pixel by pixel with the original. A result that differs is thrown away | Compression alone never changes how an image looks |
| JPEGs and lossy WebPs are left alone unless you pass `--quality`, a resize, `--format`, or `--lossy` | Re-encoding them always loses some detail |
| Keeps each file's format and name unless you pass `--format` | Dart code and `pubspec.yaml` keep working |
| Replaces a file only when the result is at least 1% smaller (`--min-saving`) | No churn in git for nothing |
| Doesn't resize files in `2.0x/`, `3.0x/` folders | Flutter reads their size as a multiple of the 1x image; shrinking one changes its size on screen |
| Skips animated images, 16-bit PNGs, CMYK images (except JPEG to JPEG), and images whose colour profile can't survive a conversion | These are the cases where a re-encode can quietly change the picture |
| Applies EXIF rotation to the pixels, keeps the colour (ICC) profile, drops other metadata (EXIF, camera and GPS data, text chunks) | The image still shows the right way up and in the right colours, and private metadata doesn't ship in the app |

What each file type gets by default, and with options:

| Source | Default | Lossy options |
|---|---|---|
| PNG | Lossless recompression | `--colors N` (palette), `--max-width/--max-height`, `--format jpeg` (only without transparency) |
| JPEG | Skipped | `--quality Q`, a resize, `--format webp` |
| WebP, lossless | Lossless recompression | `--format webp --lossy`, a resize |
| WebP, lossy | Skipped | `--quality Q`, a resize |
| GIF, SVG, fonts, anything else | Ignored | |

## Reading the report

One line per file: size before, size after, the change, the file (and where the result goes, `->`), and what happened in brackets.

| Status | Meaning |
|---|---|
| `compress lossless` / `would compress lossless` | Same pixels, smaller file |
| `compress lossy` | Re-encoded at `--quality` (or reduced to `--colors`) |
| `convert lossless` / `convert lossy` | New format and extension |
| `resize lossy to WxH` | Shrunk to fit `--max-width` / `--max-height` |
| `keep: not smaller` / `keep: saves under 1%` | The result wasn't worth it; the file stays as it is |
| `keep: lossless result differs, not used` | The pixel check failed; the file stays as it is |
| `skip: ...` | Not touched, and the reason |
| `error: ...` | Couldn't be read. The script exits with code 1 if any file errors |

The summary shows the total before and after. With a format change it also lists every renamed file, so you can update the references.

## Options

### What to process

| Option | Default | What it does |
|---|---|---|
| `paths` | `assets/images` | Files, folders or glob patterns. Several are fine |
| `--recursive` / `--no-recursive` | on | Whether a folder argument includes its sub-folders |
| `--exclude PATTERN` | none | Skip files whose path (as printed) or file name matches. `*` also matches `/`. Repeatable |

```sh
python3 tool/optimize_images.py assets/images/onboarding assets/images/logo.png
python3 tool/optimize_images.py 'assets/**/*.png'                 # quote globs; ** goes into sub-folders
python3 tool/optimize_images.py assets/images --no-recursive      # only the top folder
python3 tool/optimize_images.py --exclude '*/ads/*' --exclude 'splash*.png'
```

### How to encode

| Option | Default | What it does |
|---|---|---|
| `--format keep\|png\|jpeg\|webp` | `keep` | Output format. Anything but `keep` changes the extension |
| `--quality Q` | 85 when a lossy encode is needed | 1 to 100, for JPEG and lossy WebP. Passing it also allows JPEGs and lossy WebPs to be re-encoded |
| `--lossless` / `--lossy` | lossless for PNG and lossless WebP sources, lossy for JPEG | Force the WebP mode (with `--format webp`) |
| `--colors N` | off | PNG only: reduce to a palette of at most N colours (2 to 256). Flat UI graphics often get much smaller; gradients and photos can show banding |
| `--max-width PX`, `--max-height PX` | off | Shrink larger images to fit, keeping the aspect ratio. Never enlarges |
| `--resize-variants` | off | Also resize files inside `2.0x/`, `3.0x/` folders |
| `--no-verify` | verify on | Skip the pixel check of lossless results. Faster, but you lose the guarantee |

```sh
python3 tool/optimize_images.py --format webp --in-place              # PNG -> lossless WebP, JPEG -> WebP at 85
python3 tool/optimize_images.py 'assets/**/*.jpg' --quality 80 --in-place
python3 tool/optimize_images.py --format webp --lossy --quality 90 --in-place   # lossy WebP even for PNGs
python3 tool/optimize_images.py --format webp --lossless --in-place   # lossless WebP even for JPEGs (often larger)
python3 tool/optimize_images.py assets/images/illustrations --colors 256 --in-place
python3 tool/optimize_images.py --max-width 1600 --max-height 1600 --in-place
python3 tool/optimize_images.py --max-width 1080 --resize-variants --in-place  # only if you know why
python3 tool/optimize_images.py --in-place --no-verify
```

### Where the results go

| Option | Default | What it does |
|---|---|---|
| `--in-place` | off | Replace the files where they are |
| `--out-dir DIR` | off | Write only the files that got smaller into `DIR`, under their relative path (`DIR/assets/images/...`). Originals stay untouched |
| `--backup-dir DIR` | off | With `--in-place`: copy each original to `DIR` first. An existing backup is never overwritten, so a second run keeps the true original |
| `--keep-original` | off | With `--in-place` and `--format`: keep `logo.png` next to the new `logo.webp` |
| `--min-saving PCT` | 1 | Replace only when at least PCT percent smaller. `0` takes any saving |
| `--dry-run` | off | With `--in-place` or `--out-dir`: show what would be written, write nothing |

```sh
python3 tool/optimize_images.py --in-place
python3 tool/optimize_images.py --out-dir build/optimized_images
python3 tool/optimize_images.py --in-place --backup-dir ~/image-backups/my_app
python3 tool/optimize_images.py --format webp --in-place --keep-original
python3 tool/optimize_images.py --in-place --min-saving 5
python3 tool/optimize_images.py --format webp --in-place --dry-run
```

Without `--in-place` or `--out-dir`, every run is a dry run.

## Recipes

### Compress `assets/images` before a release

Lossless, so it's safe to do on every release.

```sh
git status                                        # start clean: git is your backup
python3 tool/optimize_images.py                   # read the report
python3 tool/optimize_images.py --in-place
flutter run                                       # look at the screens with images
git commit -am "chore: compress image assets"
```

### Convert to WebP

Flutter decodes WebP on every platform it targets. Lossless WebP is usually much smaller than PNG; photos become lossy WebP at `--quality`.

```sh
python3 tool/optimize_images.py --format webp --in-place --dry-run    # see the savings and the renames
python3 tool/optimize_images.py --format webp --in-place
```

Then update every path the summary lists: `lib/core/router/asset_routes.dart` (`AssetRoutes`), module asset constants such as `self_promotion_assets.dart`, and any file listed one by one in `pubspec.yaml` (folders listed as `assets/images/` need no change). Search for the old names to be sure: `grep -rn "default_avatar.png" lib`.

### Shrink large photos

Photos straight from a camera or a designer are often several times larger than any phone screen. Pick the largest size the app shows them at, times the device pixel ratio you care about (for example 1600 px).

```sh
python3 tool/optimize_images.py 'assets/images/**/*.jpg' --max-width 1600 --max-height 1600 --quality 80 --in-place
```

Keep the originals somewhere outside the app (or use `--backup-dir`): run lossy recipes once, from the originals, not again and again on their output.

### Smaller UI graphics, same file names

Flat illustrations and icons often survive a 256-colour palette with no visible change:

```sh
python3 tool/optimize_images.py assets/images/illustrations --colors 256 --out-dir build/palette_test
```

Open the results in `build/palette_test/` next to the originals. If they look right, run again with `--in-place`.

### Store screenshots before a Fastlane upload

Lossless only, and never resize: the App Store identifies the device from each screenshot's exact pixel size.

```sh
python3 tool/optimize_images.py android/fastlane/metadata/android ios/fastlane/screenshots --in-place
```

## Cautions

- **Have a way back before `--in-place`:** a clean git tree, or `--backup-dir`.
- **`--format` renames files.** The old file is deleted unless you pass `--keep-original`, and every Dart reference to it breaks until you update it. The summary lists them.
- **Lossy is one-way.** `--quality`, `--colors`, `--lossy` and resizing discard detail. Each extra run discards a little more, even at the same quality.
- **Resolution variants:** with `--resize-variants`, a shrunk `2.0x/` or `3.0x/` image displays smaller on screen. Resize the 1x image and regenerate the variants instead.
- **Metadata is dropped** (EXIF, camera and GPS data, text chunks). Rotation is applied first and the colour profile is kept, so the picture looks the same.
- **Not for app icons or launch screens.** The default path doesn't include `android/app/src/main/res/` or `ios/Runner/Assets.xcassets/`; leave those to the tool that generates them.
- **Transparency and JPEG:** `--format jpeg` skips images with transparent pixels, because JPEG has no alpha channel.
- **Verify stays on** unless you have a reason. It is what makes "lossless" a guarantee instead of a hope.
