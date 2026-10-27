# Store screenshots

`tool/marketing/make_screenshots.py` turns raw app captures into App Store and Google Play screenshots, every size in one run.
The rule: edit `tool/marketing/shots.json`, run the script, upload what lands in `tool/marketing/screenshots/`.

## What it makes

One PNG per shot and size. Each has:

- a gradient background: the app's seed colour by default, or the shot's own colour;
- the title and description on top, centred, in the app's bundled fonts;
- the capture in a rounded device frame with a thin rim and a soft shadow.

How it behaves:

- Text wraps into even lines. The title gets up to 3 lines, the description up to 4. Long copy shrinks to fit. If it still doesn't fit at the smallest size, it is cut with `…` and the script warns.
- Text is white or dark, whichever reads on the background (see [Colours](#colours)).
- The capture is scaled to fit, never stretched or cropped. The frame takes the capture's shape: portrait, landscape or square.
- The text area has the same height in every shot of a size, so the frames line up across a set.
- Fonts come from `assets/fonts/`: Inter for Latin, Noto Sans Devanagari for any text that contains Devanagari (it covers Latin too). Output looks the same on every machine.
- PNGs are RGB without alpha. Both stores reject transparency.

## Where it lives

```
tool/marketing/make_screenshots.py   the script; the sizes are at the top
tool/marketing/shots.json            the shots: capture, name, title, description, colour
tool/marketing/inputs/               raw captures (example_home.png is a sample)
tool/marketing/screenshots/          output, git-ignored
```

## Setup

You need Python 3.9 or newer and Pillow.

```sh
python3 -m pip install pillow
```

If pip refuses with `externally-managed-environment` (Homebrew Python), use a virtual env outside the repo:

```sh
python3 -m venv ~/.venvs/screenshots
~/.venvs/screenshots/bin/pip install pillow
~/.venvs/screenshots/bin/python tool/marketing/make_screenshots.py
```

Devanagari needs FriBiDi for correct shaping:

- macOS: `brew install fribidi`. The script finds Homebrew's copy itself.
- Debian or Ubuntu: `sudo apt install libfribidi0`.

Without FriBiDi the script warns, and vowel signs and conjuncts land in the wrong place. Latin text works without it; with it, kerning is better.

## Make your screenshots

1. Capture each screen raw: no frame, no text. Use a clean status bar.

   ```sh
   xcrun simctl status_bar booted override --time 9:41 --batteryState charged --batteryLevel 100
   xcrun simctl io booted screenshot tool/marketing/inputs/home.png
   adb exec-out screencap -p > tool/marketing/inputs/home_android.png
   ```

2. Capture the same screens on an iPad simulator and an Android tablet emulator, and list them as `tablet_image`. The stores expect tablet screenshots to show the tablet layout.
3. List the shots in `tool/marketing/shots.json`.
4. Run `python3 tool/marketing/make_screenshots.py`.
5. Open the PNGs in `tool/marketing/screenshots/`, then upload them.

## Config: shots.json

```json
{
  "background": "seed",
  "sizes": ["iphone-6.9", "iphone-6.5", "iphone-6.3", "ipad-13", "phone", "tablet-7", "tablet-10"],
  "shots": [
    {
      "name": "01_home",
      "image": "inputs/home.png",
      "tablet_image": "inputs/home_ipad.png",
      "title": "Everything you need, on one screen",
      "description": "Your day at a glance: progress, quick actions and what is coming up next."
    },
    {
      "name": "02_search",
      "image": "inputs/search.png",
      "title": "Find anything\nin a second",
      "description": "Search as you type.",
      "background": "#0F766E"
    },
    {
      "name": "03_nepali",
      "image": "inputs/home.png",
      "title": "नेपालीमा पनि राम्रो देखिन्छ",
      "background": ["#6D28D9", "#DB2777"]
    }
  ]
}
```

Top level:

| Field | Needed | Meaning |
|---|---|---|
| `background` | no | Default background for every shot: `"seed"` (the default), `"#RRGGBB"`, or `["#RRGGBB", "#RRGGBB"]`. |
| `sizes` | no | Sizes to make. Default: all. Use size keys (below), `ios` or `android`. Drop `ipad-13` if the app doesn't run on iPad. |
| `shots` | yes | The shots, in store order. |

Per shot:

| Field | Needed | Meaning |
|---|---|---|
| `name` | yes | Output file name, without `.png`. Start with a number (`01_home`) so the file order is the store order. |
| `image` | yes | The capture. Paths are relative to `tool/marketing/`. |
| `tablet_image` | no | The capture for `ipad-13`, `tablet-7` and `tablet-10`. Without it, the phone capture is framed on the tablet canvas. |
| `images` | no | A capture for one size or platform, e.g. `{"tablet-10": "inputs/home_10in.png", "android": "inputs/home_android.png"}`. Wins over `tablet_image`. |
| `title` | no | The headline. `\n` forces a line break. |
| `description` | no | One or two short lines under the title. |
| `background` | no | This shot's background. Same forms as the top-level field. |
| `text_color` | no | `"#RRGGBB"` to force the text colour. Default: picked from the background. |

JSON has no comments. The script reports unknown fields, so typos don't pass silently.

## Commands

Run from the project root (any folder works):

```sh
python3 tool/marketing/make_screenshots.py                     # every shot, every size
python3 tool/marketing/make_screenshots.py 01_home             # one shot
python3 tool/marketing/make_screenshots.py 01_home 02_search   # several shots
python3 tool/marketing/make_screenshots.py --size iphone-6.9   # one size (repeatable)
python3 tool/marketing/make_screenshots.py --size android      # one platform
python3 tool/marketing/make_screenshots.py --clean             # delete old PNGs first
python3 tool/marketing/make_screenshots.py --list              # show shots and sizes, render nothing
```

Use `--clean` after renaming or removing a shot, so the old file doesn't get uploaded.

For a second language, copy the config and give it its own output folder:

```sh
python3 tool/marketing/make_screenshots.py --config tool/marketing/shots.ne.json --out tool/marketing/screenshots/ne
```

The script exits with 1 when a shot fails (missing capture) or the config is wrong.

## Colours

- **No colour:** the script reads `static const Color seed = Color(0xFF......)` from `lib/core/theme/colors/app_colors.dart`. Change the seed and the screenshots follow. If the line isn't there, it uses `#1B3A6B` and warns.
- **One colour** (`"#0F766E"`): a diagonal gradient around it, a little lighter at the top left, deeper at the bottom right, with a small hue turn. If white text reads on the colour, it still reads on the gradient.
- **Two colours** (`["#6D28D9", "#DB2777"]`): used exactly, the first at the top left, the second at the bottom right.

Set the colour for all shots with the top-level `background`, or per shot.

Text colour: white when it reaches 4.5:1 contrast (WCAG AA) against the background behind the text. Otherwise the script uses whichever of white or a dark tint of the background has more contrast. Set `text_color` to override.

## Sizes

All portrait. Checked against the store rules in October 2026.

| Key | Folder | Pixels | Store slot |
|---|---|---|---|
| `iphone-6.9` | `screenshots/ios/iphone-6.9/` | 1320 × 2868 | iPhone 6.9" (Dynamic Island, large display) |
| `iphone-6.5` | `screenshots/ios/iphone-6.5/` | 1284 × 2778 | iPhone 6.5" (Face ID, large display) |
| `iphone-6.3` | `screenshots/ios/iphone-6.3/` | 1206 × 2622 | iPhone 6.3" (Dynamic Island, medium display) |
| `ipad-13` | `screenshots/ios/ipad-13/` | 2064 × 2752 | iPad 13" |
| `phone` | `screenshots/android/phone/` | 1080 × 1920 | Phone screenshots |
| `tablet-7` | `screenshots/android/tablet-7/` | 1440 × 2560 | 7-inch tablet screenshots |
| `tablet-10` | `screenshots/android/tablet-10/` | 2160 × 3840 | 10-inch tablet screenshots |

[App Store](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications):

- 1 to 10 screenshots per size. PNG or JPEG, no transparency.
- Required: at least one iPhone 6.3" screenshot, and iPad 13" if the app runs on iPad.
- A missing size is scaled down from the next larger one: 6.3" from 6.5", 6.5" from 6.9". Upload all three iPhone sets and each slot gets a native image.
- Smaller devices get scaled copies of these.

[Google Play](https://support.google.com/googleplay/android-developer/answer/9866151):

- Up to 8 per device type. PNG or JPEG, no alpha.
- Each side is 320 to 3840 px. The long side is at most twice the short side.
- You need at least 2 screenshots to publish. Tablets need at least 4.
- 9:16 with the short side at 1080 px or more qualifies for Play's large-format placements. All three Android sizes are 9:16.

## Upload

- **App Store Connect:** open the app version, go to Previews and Screenshots, pick the display size (iPhone 6.9", 6.5", 6.3", iPad 13"), and drag in the PNGs from the matching folder in file-name order.
- **Play Console:** open the main store listing. Under Graphics, add `android/phone/` to Phone screenshots, `android/tablet-7/` to 7-inch tablet screenshots and `android/tablet-10/` to 10-inch tablet screenshots.

**Fastlane `deliver` (iOS):** one folder per language holds every size. deliver tells devices apart by pixel size and orders by file name. Prefix the size so names don't collide:

```sh
mkdir -p ios/fastlane/screenshots/en-US
for size in iphone-6.9 iphone-6.5 iphone-6.3 ipad-13; do
  for f in tool/marketing/screenshots/ios/$size/*.png; do
    cp "$f" "ios/fastlane/screenshots/en-US/${size}_$(basename "$f")"
  done
done
```

**Fastlane `supply` (Android):** one folder per device type, ordered by file name:

```sh
dst=android/fastlane/metadata/android/en-US/images
mkdir -p $dst/phoneScreenshots $dst/sevenInchScreenshots $dst/tenInchScreenshots
cp tool/marketing/screenshots/android/phone/*.png     $dst/phoneScreenshots/
cp tool/marketing/screenshots/android/tablet-7/*.png  $dst/sevenInchScreenshots/
cp tool/marketing/screenshots/android/tablet-10/*.png $dst/tenInchScreenshots/
```

## Add a size

1. Add a line to `SIZES` at the top of `make_screenshots.py`:

   ```python
   Size("ipad-11", "ios", 1668, 2420, tablet=True),
   ```

   - The key (`ipad-11`) is the folder name and the `--size` value.
   - The platform (`ios` or `android`) is the parent folder.
   - `tablet=True` makes the size use the shot's `tablet_image`.

2. If `shots.json` has a `sizes` list, add the key there too.

Margins, text and frame scale with the canvas, so a new portrait size needs no tuning. The layout isn't designed for landscape canvases.

## Warnings

| Message | Fix |
|---|---|
| `text too long for the space, cut with …` | Shorten the title or description. |
| `image is W x H, scaled up Nx` | Use a full-resolution capture. |
| `Devanagari text needs Pillow's raqm layout` | Install FriBiDi (see [Setup](#setup)). |
| `unknown field "..."` | Fix the typo in `shots.json`. |
| `no image at ...` | Check the path. It is relative to `tool/marketing/`. |
