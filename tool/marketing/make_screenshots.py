#!/usr/bin/env python3
"""Store screenshots for the App Store and Google Play, from raw app captures.

    python3 tool/marketing/make_screenshots.py              every shot, every size
    python3 tool/marketing/make_screenshots.py 01_home      one shot (or several)
    python3 tool/marketing/make_screenshots.py --size ios   only some sizes
    python3 tool/marketing/make_screenshots.py --list       show shots and sizes

Reads tool/marketing/shots.json. Each shot is a capture plus a title and a
description. Every size gets a gradient background, the title and description
on top, and the capture in a rounded device frame with a soft shadow, written
to tool/marketing/screenshots/<platform>/<size>/<name>.png.

Needs Python 3.9+ and Pillow (`python3 -m pip install pillow`).
Docs: doc/tools/screenshots.md
"""
from __future__ import annotations

import argparse
import colorsys
import json
import math
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
CONFIG = HERE / "shots.json"
OUT = HERE / "screenshots"
APP_COLORS = ROOT / "lib/core/theme/colors/app_colors.dart"
FALLBACK_SEED = "#1B3A6B"


@dataclass(frozen=True)
class Size:
    key: str       # folder name, and the value for --size and "sizes"
    platform: str  # ios | android
    width: int
    height: int
    tablet: bool   # uses the shot's tablet_image when it has one


# Portrait pixel sizes. To add one, add a line; the layout scales itself.
SIZES = (
    # App Store Connect. Apple requires 6.3" (and 13" for iPad apps) and scales
    # a missing size down from the next larger one: 6.9" -> 6.5" -> 6.3".
    Size("iphone-6.9", "ios", 1320, 2868, tablet=False),
    Size("iphone-6.5", "ios", 1284, 2778, tablet=False),
    Size("iphone-6.3", "ios", 1206, 2622, tablet=False),
    Size("ipad-13", "ios", 2064, 2752, tablet=True),
    # Google Play. 9:16 with the short side >= 1080 qualifies for featuring.
    Size("phone", "android", 1080, 1920, tablet=False),
    Size("tablet-7", "android", 1440, 2560, tablet=True),
    Size("tablet-10", "android", 2160, 3840, tablet=True),
)

FONTS = ROOT / "assets/fonts"
LATIN = {"title": FONTS / "inter/Inter-Bold.ttf",
         "body": FONTS / "inter/Inter-Medium.ttf"}
DEVANAGARI = {"title": FONTS / "noto_sans_devanagari/NotoSansDevanagari-Bold.ttf",
              "body": FONTS / "noto_sans_devanagari/NotoSansDevanagari-Medium.ttf"}
DEVANAGARI_SCALE = 1.10  # same as LocalizedFonts in the app: Devanagari reads small

SHOT_KEYS = {"name", "image", "tablet_image", "images", "title", "description",
             "background", "text_color"}
TOP_KEYS = {"background", "sizes", "shots"}


def _ensure_text_shaping():
    """Re-run once with Homebrew's lib folder on the search path.

    Pillow's wheels ship raqm (proper shaping for Devanagari, and kerning for
    Latin) but load FriBiDi at run time, and macOS doesn't look in
    /opt/homebrew/lib. DYLD_* only counts at start-up, hence the re-exec.
    """
    if sys.platform != "darwin" or os.environ.get("_SCREENSHOTS_REEXEC"):
        return
    from PIL import features
    if features.check("raqm"):
        return
    for lib in ("/opt/homebrew/lib", "/opt/local/lib"):
        if os.path.exists(os.path.join(lib, "libfribidi.0.dylib")):
            env = dict(os.environ, _SCREENSHOTS_REEXEC="1")
            old = env.get("DYLD_FALLBACK_LIBRARY_PATH")
            env["DYLD_FALLBACK_LIBRARY_PATH"] = lib + (":" + old if old else "")
            try:
                os.execve(sys.executable, [sys.executable] + sys.argv, env)
            except OSError:
                return


try:
    from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps, ImageStat
    from PIL import features
except ImportError:
    sys.exit("Pillow is missing. Install it with: python3 -m pip install pillow")

LANCZOS = getattr(Image, "Resampling", Image).LANCZOS
BICUBIC = getattr(Image, "Resampling", Image).BICUBIC


class ConfigError(Exception):
    pass


# --------------------------------------------------------------------- colour

def parse_hex(value: str) -> tuple:
    s = value.strip().lstrip("#")
    if len(s) == 8:          # AARRGGBB, as in Dart's Color(0xFF......)
        s = s[2:]
    if len(s) == 3:
        s = "".join(c * 2 for c in s)
    if not re.fullmatch(r"[0-9a-fA-F]{6}", s):
        raise ConfigError(f'"{value}" is not a colour. Use "#RRGGBB".')
    return tuple(int(s[i:i + 2], 16) for i in (0, 2, 4))


def _to_linear(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def _to_srgb(c):
    c = 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055
    return c * 255


def to_oklab(rgb):
    r, g, b = (_to_linear(c) for c in rgb)
    l = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ** (1 / 3)
    m = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ** (1 / 3)
    s = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ** (1 / 3)
    return (0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
            1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
            0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s)


def _oklab_to_linear(lab):
    L, a, b = lab
    l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3
    return (4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
            -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
            -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)


def from_oklab(lab):
    return tuple(min(255, max(0, round(_to_srgb(min(1.0, max(0.0, c))))))
                 for c in _oklab_to_linear(lab))


def oklch(L, C, h):
    """OKLCH to sRGB, lowering chroma until the colour fits the gamut."""
    L = min(1.0, max(0.0, L))
    lo, hi = 0.0, C
    for _ in range(20):
        c = hi if lo == hi else (lo + hi) / 2
        lin = _oklab_to_linear((L, c * math.cos(h), c * math.sin(h)))
        if all(-1e-4 <= v <= 1 + 1e-4 for v in lin):
            lo = c
            if c == hi:
                break
        else:
            hi = c
    return from_oklab((L, lo * math.cos(h), lo * math.sin(h)))


def lch(rgb):
    L, a, b = to_oklab(rgb)
    return L, math.hypot(a, b), math.atan2(b, a)


WHITE = (255, 255, 255)


def gradient_from(rgb) -> tuple:
    """Two stops around one colour: a touch lighter on top, deeper below,
    with a small hue turn. A colour that carries white text keeps doing so."""
    L, C, h = lch(rgb)
    turn_top, turn_bottom = math.radians(-6), math.radians(8)
    if contrast(WHITE, rgb) >= 4.5:           # dark enough for white text
        L = max(L, 0.22)                      # black becomes charcoal
        lift = 0.08
        while lift > 0 and contrast(WHITE, oklch(L + lift, C, h + turn_top)) < 5.2:
            lift -= 0.01
        top = oklch(L + max(lift, 0), C, h + turn_top)
        bottom = oklch(max(L - 0.10, 0.12), C * 1.08, h + turn_bottom)
    else:                                     # light colour: dark text
        top = oklch(min(L + 0.05, 0.97), C * 0.9, h + turn_top)
        bottom = oklch(max(L - 0.08, 0.5), C * 1.1, h + turn_bottom)
    return top, bottom


def background_stops(value, seed):
    """None/"seed" -> seed gradient, "#hex" -> gradient from it, [a, b] -> as given."""
    if value is None or value == "seed":
        return gradient_from(seed)
    if isinstance(value, str):
        return gradient_from(parse_hex(value))
    if isinstance(value, list) and len(value) == 2 and all(isinstance(v, str) for v in value):
        return parse_hex(value[0]), parse_hex(value[1])
    raise ConfigError(f'background must be "seed", "#RRGGBB" or ["#RRGGBB", "#RRGGBB"], '
                      f"not {json.dumps(value)}")


def luminance(rgb):
    r, g, b = (_to_linear(c) for c in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    la, lb = sorted((luminance(a), luminance(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


def mix(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def read_seed() -> tuple:
    try:
        src = APP_COLORS.read_text(encoding="utf-8")
        m = re.search(r"static\s+const\s+Color\s+seed\s*=\s*Color\(\s*0x([0-9A-Fa-f]{8})\s*\)", src)
        if m:
            return parse_hex(m.group(1))
    except OSError:
        pass
    print(f"  ! no `static const Color seed = Color(0x...)` in {rel(APP_COLORS)}; "
          f"using {FALLBACK_SEED}. Set \"background\" in shots.json to choose.")
    return parse_hex(FALLBACK_SEED)


# ----------------------------------------------------------------- background

def background(w, h, top, bottom):
    """Diagonal gradient (mixed in OKLab) with a soft light behind the text."""
    lw = 96
    lh = max(2, round(lw * h / w))
    a, b = to_oklab(top), to_oklab(bottom)
    small = Image.new("RGB", (lw, lh))
    px = small.load()
    for y in range(lh):
        fy = y / (lh - 1)
        for x in range(lw):
            fx = x / (lw - 1)
            t = (fx * 0.35 + fy) / 1.35
            t = t * t * (3 - 2 * t) * 0.6 + t * 0.4       # gentle ease
            lab = tuple(p + (q - p) * t for p, q in zip(a, b))
            dx, dy = (fx - 0.5) / 0.75, (fy - 0.06) * (h / w) / 0.55
            glow = 0.07 * math.exp(-(dx * dx + dy * dy))
            lab = (lab[0] + (1 - lab[0]) * glow, lab[1] * (1 - glow), lab[2] * (1 - glow))
            px[x, y] = from_oklab(lab)
    return small.resize((w, h), BICUBIC)


# ---------------------------------------------------------------------- text

_font_cache: dict = {}


def font(path, px):
    key = (path, int(px))
    if key not in _font_cache:
        _font_cache[key] = ImageFont.truetype(str(path), max(8, int(px)))
    return _font_cache[key]


def is_devanagari(text):
    return any("ऀ" <= ch <= "ॿ" or "꣠" <= ch <= "ꣿ"
               or "᳐" <= ch <= "᳿" for ch in text)


def face(text, role):
    """Font file and size multiplier. Noto Sans Devanagari covers Latin too."""
    if is_devanagari(text):
        return DEVANAGARI[role], DEVANAGARI_SCALE
    return LATIN[role], 1.0


def _greedy(words, fnt, width):
    lines, cur = [], ""
    for word in words:
        trial = f"{cur} {word}" if cur else word
        if not cur or fnt.getlength(trial) <= width:
            cur = trial
        else:
            lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)
    return lines


def _split_long(word, fnt, width):
    """Break a word wider than the line (URLs, CJK) by characters."""
    parts, cur = [], ""
    for ch in word:
        if cur and fnt.getlength(cur + ch) > width:
            parts.append(cur)
            cur = ch
        else:
            cur += ch
    return parts + ([cur] if cur else [])


def wrap(text, fnt, width):
    """Wrap to `width`, then narrow the measure so lines come out even."""
    lines = []
    for para in text.split("\n"):
        words = []
        for word in para.split():
            words += _split_long(word, fnt, width) if fnt.getlength(word) > width else [word]
        if not words:
            continue
        best = _greedy(words, fnt, width)
        if len(best) > 1:  # balance: the narrowest measure with the same line count
            lo = max(fnt.getlength(w) for w in words)
            hi = width
            for _ in range(12):
                mid = (lo + hi) / 2
                if len(_greedy(words, fnt, mid)) <= len(best):
                    hi = mid
                else:
                    lo = mid
            best = _greedy(words, fnt, hi)
        lines += best
    return lines


def _ellipsize(line, fnt, width):
    while line and fnt.getlength(line + "…") > width:
        line = line[:-1].rstrip()
    return line + "…"


@dataclass
class Block:
    font: object
    lines: list
    line_h: int

    @property
    def height(self):
        if not self.lines:
            return 0
        ascent, descent = self.font.getmetrics()
        return (len(self.lines) - 1) * self.line_h + ascent + descent


def _block(text, role, px, width, leading):
    path, scale = face(text, role)
    fnt = font(path, px * scale)
    ascent, descent = fnt.getmetrics()
    line_h = round(max(fnt.size * leading, (ascent + descent) * 0.98))
    return Block(fnt, wrap(text, fnt, width) if text else [], line_h)


def fit_text(title, desc, width, height, title_px, desc_px, name):
    """Largest sizes where the title takes <= 3 lines, the description <= 4,
    and both fit the box. Long copy shrinks; it never overflows."""
    t = d = None
    gap = 0
    for step in range(13):
        s = 1 - 0.04 * step                       # down to 52 %
        t = _block(title, "title", title_px * s, width, 1.10)
        d = _block(desc, "body", desc_px * max(s, 0.80), width, 1.30)
        gap = round(t.font.size * 0.42) if t.lines and d.lines else 0
        if (len(t.lines) <= 3 and len(d.lines) <= 4
                and t.height + gap + d.height <= height):
            return t, gap, d
    # Still too long at the smallest size: cut lines, description first.
    while t.height + gap + d.height > height and (d.lines or len(t.lines) > 1):
        blk = d if d.lines else t
        blk.lines.pop()
        if blk.lines:
            blk.lines[-1] = _ellipsize(blk.lines[-1], blk.font, width)
        gap = gap if d.lines else 0
    print(f"  ! {name}: text too long for the space, cut with …; shorten it")
    return t, gap, d


# --------------------------------------------------------------------- frame

def rounded_mask(w, h, r, fill=255):
    """Rounded-rectangle mask with anti-aliased corners."""
    r = max(0, min(int(r), w // 2, h // 2))
    mask = Image.new("L", (w, h), fill)
    if r == 0:
        return mask
    ss = 4
    big = Image.new("L", (2 * r * ss, 2 * r * ss), 0)
    ImageDraw.Draw(big).ellipse((0, 0, 2 * r * ss - 1, 2 * r * ss - 1), fill=fill)
    circle = big.resize((2 * r, 2 * r), LANCZOS)
    mask.paste(circle.crop((0, 0, r, r)), (0, 0))
    mask.paste(circle.crop((r, 0, 2 * r, r)), (w - r, 0))
    mask.paste(circle.crop((0, r, r, 2 * r)), (0, h - r))
    mask.paste(circle.crop((r, r, 2 * r, 2 * r)), (w - r, h - r))
    return mask


BEZEL = (14, 15, 19)
RIM = (74, 78, 88)
BEZEL_K = 0.024  # bezel thickness, as a share of the screen's short side


def corner_k(w, h):
    """Corner radius share of the short side: round phones, squarer tablets."""
    ratio = max(w, h) / min(w, h)
    t = min(1.0, max(0.0, (ratio - 1.33) / (2.0 - 1.33)))
    return 0.035 + t * (0.105 - 0.035)


def fit_frame(img_w, img_h, box_w, box_h):
    """Screen size so screen + bezel fits the box, keeping the capture's shape."""
    b = BEZEL_K * min(img_w, img_h)
    s = min(box_w / (img_w + 2 * b), box_h / (img_h + 2 * b))
    sw, sh = max(1, round(img_w * s)), max(1, round(img_h * s))
    return sw, sh, max(4, round(b * s))


def shadow(canvas, x, y, w, h, r, tint):
    """Two soft shadows: a wide ambient one and a tight contact one."""
    cw, ch = canvas.size
    k = 0.25  # blur at quarter size; nobody can tell, and it is 16x faster
    for blur, dy, alpha in ((0.07 * w, 0.035 * h, 0.40), (0.015 * w, 0.006 * h, 0.30)):
        m = Image.new("L", (max(1, round(cw * k)), max(1, round(ch * k))), 0)
        ImageDraw.Draw(m).rounded_rectangle(
            (x * k, (y + dy) * k, (x + w) * k, (y + h + dy) * k),
            radius=r * k, fill=round(255 * alpha))
        m = m.filter(ImageFilter.GaussianBlur(max(1, blur * k))).resize((cw, ch), BICUBIC)
        canvas.paste(Image.new("RGB", canvas.size, tint), (0, 0), m)


def device(canvas, capture, x, y, sw, sh, b, tint):
    """Paste the capture in a rounded frame with a thin rim, over a shadow."""
    r_screen = round(corner_k(sw, sh) * min(sw, sh))
    fw, fh, r_outer = sw + 2 * b, sh + 2 * b, r_screen + b
    shadow(canvas, x, y, fw, fh, r_outer, tint)
    rim = max(1, round(b * 0.12))
    frame = Image.new("RGB", (fw, fh), RIM)
    frame.paste(Image.new("RGB", (fw - 2 * rim, fh - 2 * rim), BEZEL), (rim, rim),
                rounded_mask(fw - 2 * rim, fh - 2 * rim, r_outer - rim))
    screen = capture.resize((sw, sh), LANCZOS)
    frame.paste(screen, (b, b), rounded_mask(sw, sh, r_screen))
    canvas.paste(frame, (x, y), rounded_mask(fw, fh, r_outer))


# -------------------------------------------------------------------- render

def render(size: Size, capture, title, desc, stops, text_color, name):
    W, H = size.width, size.height
    u = math.sqrt(W * H) / 100                       # one layout unit
    img = background(W, H, *stops)

    margin_x = round(W * 0.075)
    top = round(5.5 * u)
    text_h = round(25 * u)                           # same in every shot of a size
    gap = round(4 * u)
    bottom = round(5 * u)

    # Device: centred in what is left under the text. A landscape capture can
    # never fill a portrait canvas, so it gets more of the width.
    zone_top = top + text_h + gap
    zone_h = H - zone_top - bottom
    side = 0.05 if capture.width > capture.height else 0.08
    sw, sh, b = fit_frame(capture.width, capture.height, W - 2 * round(W * side), zone_h)
    if sw > capture.width * 1.5:
        print(f"  ! {name} ({size.key}): image is {capture.width}x{capture.height}, "
              f"scaled up {sw / capture.width:.1f}x; use a full-resolution capture")
    fw, fh = sw + 2 * b, sh + 2 * b
    fx, fy = (W - fw) // 2, zone_top + (zone_h - fh) // 2

    # Text colour from the background behind the text: white when it passes
    # WCAG AA (4.5:1), otherwise whichever of white or a dark tint reads better.
    behind = tuple(round(v) for v in ImageStat.Stat(
        img.crop((margin_x, top, W - margin_x, top + text_h))).mean[:3])
    L, C, h = lch(behind)
    if text_color:
        ink = parse_hex(text_color)
    else:
        dark = oklch(0.23, min(C, 0.05), h)
        on_white = contrast(WHITE, behind)
        ink = WHITE if on_white >= 4.5 or on_white >= contrast(dark, behind) else dark
    sub = mix(ink, behind, 0.14)

    tint = oklch(0.16, min(C, 0.06), h)
    device(img, capture, fx, fy, sw, sh, b, tint)

    t, tgap, d = fit_text(title, desc, W - 2 * margin_x, text_h,
                          5.6 * u, 2.75 * u, f"{name} ({size.key})")
    draw = ImageDraw.Draw(img)
    y = top + (text_h - (t.height + tgap + d.height)) // 2
    for blk, colour in ((t, ink), (d, sub)):
        for i, line in enumerate(blk.lines):
            draw.text((W / 2, y + i * blk.line_h), line, font=blk.font, fill=colour, anchor="ma")
        if blk.lines:
            y += blk.height + tgap
    return img


# -------------------------------------------------------------------- config

def rel(p: Path) -> str:
    """Path from the project root when inside it, else absolute."""
    p = Path(p).resolve()
    try:
        return str(p.relative_to(ROOT))
    except ValueError:
        return str(p)


def load_config(path: Path):
    try:
        cfg = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise ConfigError(f"No config at {rel(path)}.")
    except json.JSONDecodeError as e:
        raise ConfigError(f"{rel(path)} line {e.lineno}: {e.msg}")
    if not isinstance(cfg, dict) or not isinstance(cfg.get("shots"), list):
        raise ConfigError(f'{rel(path)} needs a "shots" list.')
    for k in set(cfg) - TOP_KEYS:
        print(f'  ! unknown field "{k}" in {rel(path)} (ignored)')
    names = set()
    for i, shot in enumerate(cfg["shots"], 1):
        if not isinstance(shot, dict):
            raise ConfigError(f"shot {i} is not an object.")
        for k in set(shot) - SHOT_KEYS:
            print(f'  ! unknown field "{k}" in shot {i} (ignored)')
        name = str(shot.get("name", "")).strip()
        if name.lower().endswith(".png"):
            name = name[:-4]
        if not name or not re.fullmatch(r"[\w.\- ]+", name):
            raise ConfigError(f'shot {i}: "name" must be a file name like "01_home".')
        if name in names:
            raise ConfigError(f'shot {i}: the name "{name}" is used twice.')
        if not shot.get("image"):
            raise ConfigError(f'shot "{name}": "image" is required.')
        if not isinstance(shot.get("images", {}), dict):
            raise ConfigError(f'shot "{name}": "images" must be an object, '
                              f'e.g. {{"tablet-10": "inputs/home_10in.png"}}.')
        names.add(name)
        shot["name"] = name
        for k in ("title", "description"):
            shot[k] = str(shot.get(k) or "").strip()
    if not isinstance(cfg.get("sizes", []), list):
        raise ConfigError('"sizes" must be a list, e.g. ["iphone-6.9", "phone"].')
    return cfg


def size_matches(size: Size, wanted) -> bool:
    return any(w in (size.key, size.platform, f"{size.platform}/{size.key}") for w in wanted)


def pick_sizes(cfg_sizes, cli_sizes):
    sizes = list(SIZES)
    valid = {s.key for s in SIZES} | {s.platform for s in SIZES} | {f"{s.platform}/{s.key}" for s in SIZES}
    for wanted in (cfg_sizes, cli_sizes):
        if not wanted:
            continue
        unknown = [w for w in wanted if w not in valid]
        if unknown:
            raise ConfigError(f"unknown size {', '.join(unknown)}. "
                              f"Sizes: {', '.join(s.key for s in SIZES)} (or ios, android).")
        sizes = [s for s in sizes if size_matches(s, wanted)]
    return sizes


def image_for(shot, size: Size, base: Path) -> Path:
    images = shot.get("images") or {}
    for key in (size.key, f"{size.platform}/{size.key}", size.platform):
        if key in images:
            return base / images[key]
    if size.tablet and shot.get("tablet_image"):
        return base / shot["tablet_image"]
    return base / shot["image"]


def open_capture(path: Path):
    img = ImageOps.exif_transpose(Image.open(path))
    if img.mode in ("RGBA", "LA", "P"):
        img = img.convert("RGBA")
        flat = Image.new("RGB", img.size, (255, 255, 255))
        flat.paste(img, (0, 0), img)
        return flat
    return img.convert("RGB")


# ----------------------------------------------------------------------- cli

def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Make App Store and Google Play screenshots from shots.json.",
        epilog="Docs: doc/tools/screenshots.md")
    ap.add_argument("shots", nargs="*", metavar="NAME", help="only these shots (default: all)")
    ap.add_argument("--size", action="append", metavar="SIZE",
                    help="only this size or platform; repeatable "
                         f"({', '.join(s.key for s in SIZES)}, ios, android)")
    ap.add_argument("--config", type=Path, default=CONFIG, help=f"config file (default: {rel(CONFIG)})")
    ap.add_argument("--out", type=Path, default=OUT, help=f"output folder (default: {rel(OUT)})")
    ap.add_argument("--clean", action="store_true", help="delete old PNGs in the output first")
    ap.add_argument("--list", action="store_true", help="list the shots and sizes, render nothing")
    args = ap.parse_args(argv)

    try:
        cfg = load_config(args.config)
        sizes = pick_sizes(cfg.get("sizes"), args.size)
        seed = read_seed()
        default_bg = cfg.get("background")
        shots = cfg["shots"]
        if args.shots:
            known = {s["name"] for s in shots}
            missing = [n for n in args.shots if n not in known]
            if missing:
                raise ConfigError(f"no shot named {', '.join(missing)}. "
                                  f"Shots: {', '.join(sorted(known))}")
            shots = [s for s in shots if s["name"] in args.shots]
        for shot in shots:   # check colours before spending time on images
            background_stops(shot.get("background", default_bg), seed)
            if shot.get("text_color"):
                parse_hex(shot["text_color"])
    except ConfigError as e:
        sys.exit(f"error: {e}")

    if args.list:
        print("Shots:")
        for s in cfg["shots"]:
            print(f"  {s['name']:<20} {s.get('title', '')}")
        print("Sizes:")
        for s in sizes:
            print(f"  {s.platform + '/' + s.key:<20} {s.width} x {s.height}")
        return 0

    if args.clean:
        for s in SIZES:
            for f in (args.out / s.platform / s.key).glob("*.png"):
                f.unlink()

    texts = " ".join(f"{s['title']} {s['description']}" for s in shots)
    if is_devanagari(texts) and not features.check("raqm"):
        print("  ! Devanagari text needs Pillow's raqm layout, which needs FriBiDi:\n"
              "    macOS: brew install fribidi   Linux: sudo apt install libfribidi0\n"
              "    Without it, vowel signs and conjuncts render in the wrong place.")

    base = args.config.resolve().parent
    made, failed = 0, 0
    for shot in shots:
        stops = background_stops(shot.get("background", default_bg), seed)
        for size in sizes:
            src = image_for(shot, size, base)
            if not src.is_file():
                print(f"  x {shot['name']}: no image at {rel(src)}")
                failed += 1
                break
            capture = open_capture(src)
            img = render(size, capture, shot["title"], shot["description"], stops,
                         shot.get("text_color"), shot["name"])
            dst = args.out / size.platform / size.key / f"{shot['name']}.png"
            dst.parent.mkdir(parents=True, exist_ok=True)
            img.save(dst)
            made += 1
            print(f"  {rel(dst)}  {size.width}x{size.height}")
    print(f"{made} screenshot(s) in {rel(args.out)}" + (f", {failed} shot(s) failed" if failed else ""))
    return 1 if failed else 0


if __name__ == "__main__":
    _ensure_text_shaping()
    sys.exit(main())
