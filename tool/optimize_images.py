#!/usr/bin/env python3
"""Shrink the PNG, JPEG and WebP images in a Flutter project's assets.

Safe by default:

* Report only. Nothing is written until you pass --in-place or --out-dir.
* Lossless only. PNGs (and lossless WebPs) are recompressed, decoded again and
  compared pixel by pixel with the original; a result that differs is thrown
  away. JPEGs and lossy WebPs are left alone unless you ask for a lossy
  re-encode (--quality, --lossy, --colors, a resize or a format change).
* Same names. The format only changes with --format, so Dart code and
  pubspec.yaml keep working.
* Smaller or nothing. A file is replaced only when the result is at least
  --min-saving percent smaller.
* Resolution variants kept intact. Files in Flutter's 2.0x/3.0x folders are
  not resized (that would change their on-screen size) unless you pass
  --resize-variants.
* Animated images, 16-bit PNGs and unusual colour modes are skipped.

Setup:  pip install pillow

Examples:
    python3 tool/optimize_images.py                              # report on assets/images
    python3 tool/optimize_images.py --in-place                   # lossless, in place
    python3 tool/optimize_images.py --in-place --backup-dir /tmp/img-backup
    python3 tool/optimize_images.py assets/images --format webp --in-place
    python3 tool/optimize_images.py "assets/**/*.jpg" --quality 80 --max-width 1600 --in-place
    python3 tool/optimize_images.py assets/images --out-dir build/optimized_images

Docs: doc/tools/optimize_images.md
"""
from __future__ import annotations

import argparse
import fnmatch
import glob
import io
import os
import re
import shutil
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

try:
    from PIL import Image, ImageOps, UnidentifiedImageError, features
except ImportError:  # pragma: no cover
    sys.exit("Pillow is not installed. Run: pip install pillow")

SUPPORTED = {".png", ".jpg", ".jpeg", ".webp"}
EXTENSIONS = {"png": ".png", "jpeg": ".jpg", "webp": ".webp"}
PIL_FORMAT = {"png": "PNG", "jpeg": "JPEG", "webp": "WEBP"}
SOURCE_FORMAT = {"PNG": "png", "JPEG": "jpeg", "MPO": "jpeg", "WEBP": "webp"}
SUFFIXES = {"png": {".png"}, "jpeg": {".jpg", ".jpeg"}, "webp": {".webp"}}
DEFAULT_QUALITY = 85
VARIANT_DIR = re.compile(r"^\d+(\.\d+)?x$")  # Flutter's 1.5x, 2.0x, 3.0x folders

LANCZOS = getattr(Image, "Resampling", Image).LANCZOS
QUANTIZE = getattr(Image, "Quantize", None)
FASTOCTREE = QUANTIZE.FASTOCTREE if QUANTIZE else 2
MEDIANCUT = QUANTIZE.MEDIANCUT if QUANTIZE else 0
LIBIMAGEQUANT = QUANTIZE.LIBIMAGEQUANT if QUANTIZE else 3


@dataclass
class Item:
    path: Path  # the file on disk
    rel: Path  # where it goes under --out-dir / --backup-dir


@dataclass
class Result:
    item: Item
    status: str
    before: int
    after: int | None = None
    target: Path | None = None
    changed: bool = False
    error: bool = False


# --------------------------------------------------------------------------
# Command line
# --------------------------------------------------------------------------


def percentage(value: str) -> float:
    number = float(value)
    if not 0 <= number < 100:
        raise argparse.ArgumentTypeError("must be between 0 and 100")
    return number


def quality(value: str) -> int:
    number = int(value)
    if not 1 <= number <= 100:
        raise argparse.ArgumentTypeError("must be between 1 and 100")
    return number


def positive(value: str) -> int:
    number = int(value)
    if number < 1:
        raise argparse.ArgumentTypeError("must be 1 or more")
    return number


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="optimize_images.py",
        description=__doc__.split("\n\n")[0],
        epilog="Full documentation: doc/tools/optimize_images.md",
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="files, folders or glob patterns (quote globs, e.g. 'assets/**/*.png'); "
        "default: assets/images",
    )
    parser.add_argument(
        "--recursive",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="look inside sub-folders of a folder argument",
    )
    parser.add_argument(
        "--exclude",
        action="append",
        default=[],
        metavar="PATTERN",
        help="skip files whose path or name matches this pattern; repeatable",
    )

    encode = parser.add_argument_group("encoding")
    encode.add_argument(
        "--format",
        choices=["keep", "png", "jpeg", "webp"],
        default="keep",
        help="output format (default: keep each file's format and name)",
    )
    encode.add_argument(
        "--quality",
        type=quality,
        metavar="Q",
        help=f"1-100 for JPEG and lossy WebP; allows re-encoding lossy sources "
        f"(default when a lossy encode is needed: {DEFAULT_QUALITY})",
    )
    mode = encode.add_mutually_exclusive_group()
    mode.add_argument(
        "--lossless",
        action="store_true",
        help="WebP output: always lossless (default: lossless for PNG sources, lossy for JPEG)",
    )
    mode.add_argument(
        "--lossy", action="store_true", help="WebP output: always lossy, at --quality"
    )
    encode.add_argument(
        "--colors",
        type=positive,
        metavar="N",
        help="PNG output: reduce to a palette of at most N colours (2-256, lossy)",
    )
    encode.add_argument("--max-width", type=positive, metavar="PX", help="shrink wider images to this width")
    encode.add_argument("--max-height", type=positive, metavar="PX", help="shrink taller images to this height")
    encode.add_argument(
        "--resize-variants",
        action="store_true",
        help="also resize files inside 2.0x / 3.0x resolution folders",
    )
    encode.add_argument(
        "--no-verify",
        dest="verify",
        action="store_false",
        help="skip the pixel-by-pixel check of lossless results",
    )

    output = parser.add_argument_group("output")
    where = output.add_mutually_exclusive_group()
    where.add_argument("--in-place", action="store_true", help="replace the files where they are")
    where.add_argument(
        "--out-dir",
        type=Path,
        metavar="DIR",
        help="write the smaller files to DIR, keeping their relative paths",
    )
    output.add_argument(
        "--backup-dir",
        type=Path,
        metavar="DIR",
        help="with --in-place: copy each original here before replacing it",
    )
    output.add_argument(
        "--keep-original",
        action="store_true",
        help="with --in-place and a new --format: keep the old file next to the new one",
    )
    output.add_argument(
        "--min-saving",
        type=percentage,
        default=1.0,
        metavar="PCT",
        help="replace only when at least PCT%% smaller (default: 1)",
    )
    output.add_argument("--dry-run", action="store_true", help="report what would change, write nothing")

    args = parser.parse_args(argv)
    if args.colors is not None and not 2 <= args.colors <= 256:
        parser.error("--colors must be between 2 and 256")
    if args.backup_dir and not args.in_place:
        parser.error("--backup-dir only makes sense with --in-place")
    if args.keep_original and not args.in_place:
        parser.error("--keep-original only makes sense with --in-place")
    if args.colors is not None and args.format not in ("keep", "png"):
        parser.error("--colors applies to PNG output only")
    if (args.lossless or args.lossy) and args.format != "webp":
        parser.error("--lossless / --lossy apply to --format webp only")
    if not (args.in_place or args.out_dir):
        args.dry_run = True
        args.report_only = True
    else:
        args.report_only = False
    return args


# --------------------------------------------------------------------------
# Finding files
# --------------------------------------------------------------------------


def relative_to_cwd(path: Path) -> Path | None:
    try:
        return path.resolve().relative_to(Path.cwd().resolve())
    except ValueError:
        return None


def collect(args: argparse.Namespace) -> tuple[list[Item], list[str]]:
    inputs = args.paths or ["assets/images"]
    found: dict[Path, Item] = {}
    problems: list[str] = []

    def add(path: Path, base: Path) -> None:
        key = path.resolve()
        if key in found:
            return
        rel = relative_to_cwd(path)
        if rel is None:
            try:
                rel = path.resolve().relative_to(base.resolve())
            except ValueError:
                rel = Path(path.name)
        found[key] = Item(path, rel)

    for raw in inputs:
        if any(ch in raw for ch in "*?["):
            matches = sorted(glob.glob(raw, recursive=True))
            files = [Path(m) for m in matches if Path(m).is_file()]
            if not files:
                problems.append(f"no files match {raw}")
            for file in files:
                add(file, Path.cwd())
            continue
        path = Path(raw)
        if path.is_dir():
            pattern = "**/*" if args.recursive else "*"
            for file in sorted(path.glob(pattern)):
                if file.is_file() and file.suffix.lower() in SUPPORTED:
                    add(file, path.parent)
        elif path.is_file():
            add(path, path.parent)
        else:
            problems.append(f"not found: {raw}")

    items = []
    for item in found.values():
        text = item.rel.as_posix()
        if any(fnmatch.fnmatch(text, p) or fnmatch.fnmatch(item.path.name, p) for p in args.exclude):
            continue
        items.append(item)
    items.sort(key=lambda i: i.rel.as_posix())
    return items, problems


# --------------------------------------------------------------------------
# Inspecting a source image
# --------------------------------------------------------------------------


def png_bit_depth(data: bytes) -> int:
    if data[:8] == b"\x89PNG\r\n\x1a\n" and data[12:16] == b"IHDR":
        return data[24]
    return 8


def webp_is_lossless(data: bytes) -> bool:
    """True when the WebP's image data is a VP8L (lossless) chunk."""
    offset = 12  # "RIFF" <size> "WEBP"
    while offset + 8 <= len(data):
        fourcc = data[offset : offset + 4]
        size = int.from_bytes(data[offset + 4 : offset + 8], "little")
        if fourcc == b"VP8L":
            return True
        if fourcc == b"VP8 ":
            return False
        offset += 8 + size + (size & 1)
    return False


def icc_colour_space(icc: bytes | None) -> bytes | None:
    return icc[16:20] if icc and len(icc) >= 20 else None


def has_transparency(im: Image.Image) -> bool:
    if im.mode in ("RGBA", "LA", "PA") or "transparency" in im.info:
        alpha = im.convert("RGBA").getchannel("A")
        return alpha.getextrema()[0] < 255
    return False


def rgba(im: Image.Image) -> tuple[tuple[int, int], bytes]:
    converted = im.convert("RGBA")
    return converted.size, converted.tobytes()


# --------------------------------------------------------------------------
# Encoding
# --------------------------------------------------------------------------


def encode(im: Image.Image, target: str, *, lossless: bool, q: int, colors: int | None, icc: bytes | None) -> bytes:
    buffer = io.BytesIO()
    extra = {"icc_profile": icc} if icc else {}

    if target == "png":
        if colors:
            source = im if im.mode in ("RGB", "RGBA") else im.convert("RGBA" if has_transparency(im) else "RGB")
            if features.check_feature("libimagequant"):
                method = LIBIMAGEQUANT
            else:
                method = FASTOCTREE if source.mode == "RGBA" else MEDIANCUT
            im = source.quantize(colors=colors, method=method)
        im.save(buffer, "PNG", optimize=True, **extra)

    elif target == "jpeg":
        if im.mode not in ("L", "RGB", "CMYK"):
            im = im.convert("RGB")
        im.save(buffer, "JPEG", quality=q, optimize=True, progressive=True, **extra)

    else:  # webp
        if im.mode not in ("RGB", "RGBA"):
            im = im.convert("RGBA" if has_transparency(im) else "RGB")
        if lossless:
            # Same settings as `cwebp -lossless -z 9 -exact`: smallest file,
            # and the colour under transparent pixels is kept, so the result
            # decodes to exactly the source's RGBA bytes.
            im.save(buffer, "WEBP", lossless=True, quality=100, method=6, exact=True, **extra)
        else:
            im.save(buffer, "WEBP", quality=q, method=6, **extra)
    return buffer.getvalue()


def in_variant_dir(path: Path) -> bool:
    return any(VARIANT_DIR.match(part) for part in path.parent.parts)


def new_size(size: tuple[int, int], max_w: int | None, max_h: int | None) -> tuple[int, int] | None:
    width, height = size
    scale = 1.0
    if max_w and width > max_w:
        scale = min(scale, max_w / width)
    if max_h and height > max_h:
        scale = min(scale, max_h / height)
    if scale >= 1.0:
        return None
    return max(1, round(width * scale)), max(1, round(height * scale))


# --------------------------------------------------------------------------
# One file
# --------------------------------------------------------------------------


def process(item: Item, args: argparse.Namespace) -> Result:
    data = item.path.read_bytes()
    before = len(data)
    result = Result(item, "", before)

    if item.path.suffix.lower() not in SUPPORTED:
        result.status = "skip: not a PNG, JPEG or WebP"
        return result

    try:
        im = Image.open(io.BytesIO(data))
        im.load()
    except UnidentifiedImageError:
        result.status, result.error = "error: not an image, or a damaged file", True
        return result
    except Exception as error:  # noqa: BLE001 - report any decoder failure
        result.status, result.error = f"error: cannot read ({error.__class__.__name__}: {error})", True
        return result

    source = SOURCE_FORMAT.get(im.format or "")
    if source is None:
        result.status = f"skip: {im.format} data with a {item.path.suffix} name"
        return result
    # A file whose name doesn't match its data (JPEG bytes in a .png file)
    # keeps its name; the report says what it really is.
    actual = ""
    if item.path.suffix.lower() not in SUFFIXES[source]:
        actual = f" ({source.upper()} data in a {item.path.suffix} file)"
    if getattr(im, "is_animated", False):
        result.status = "skip: animated"
        return result
    if source == "png" and png_bit_depth(data) == 16:
        result.status = "skip: 16-bit PNG"
        return result
    if im.mode not in ("1", "L", "LA", "P", "PA", "RGB", "RGBA", "CMYK"):
        result.status = f"skip: unsupported colour mode {im.mode}"
        return result

    target = source if args.format == "keep" else args.format
    converting = target != source
    if im.mode == "CMYK" and target != "jpeg":
        result.status = "skip: CMYK image (convert it in an image editor)"
        return result

    # --colors only means something for PNG output, and not at all for a
    # palette that already fits.
    colors = args.colors if target == "png" else None
    if colors and im.mode in ("1", "L", "P") and im.getcolors(colors) is not None:
        colors = None

    icc = im.info.get("icc_profile")
    if (converting or colors) and icc and icc_colour_space(icc) != b"RGB ":
        result.status = "skip: non-RGB colour profile, can't convert safely"
        return result
    if target == "jpeg" and source != "jpeg" and has_transparency(im):
        result.status = "skip: has transparency, JPEG can't keep it"
        return result

    # EXIF is dropped, so apply its rotation to the pixels first (this also
    # makes --max-width/--max-height act on the image as it is displayed).
    working = im
    if im.getexif().get(0x0112, 1) != 1:
        working = ImageOps.exif_transpose(im)
    reference = working

    # Resize?
    size = None
    note = ""
    if args.max_width or args.max_height:
        size = new_size(working.size, args.max_width, args.max_height)
        if size and in_variant_dir(item.path) and not args.resize_variants:
            size, note = None, " (resize skipped: resolution variant)"

    # Lossless or lossy output?
    source_lossless = source == "png" or (source == "webp" and webp_is_lossless(data))
    if target == "png":
        lossless = colors is None
    elif target == "jpeg":
        lossless = False
    else:
        lossless = args.lossless or (not args.lossy and source_lossless)
    lossless_result = lossless and size is None

    asked_for_loss = (
        args.quality is not None or args.lossy or colors is not None or size is not None or converting
    )
    if not lossless_result and not source_lossless and not asked_for_loss:
        result.status = f"skip: lossy source{actual}, pass --quality to re-encode"
        return result

    if size:
        if working.mode in ("1", "P", "PA"):
            # Palette and 1-bit images can only be resized pixel by pixel;
            # convert first so the filter can blend.
            working = working.convert("RGBA" if has_transparency(working) else "RGB")
        working = working.resize(size, LANCZOS)

    try:
        encoded = encode(
            working,
            target,
            lossless=lossless,
            q=args.quality or DEFAULT_QUALITY,
            colors=colors,
            icc=icc,
        )
    except Exception as error:  # noqa: BLE001 - report any encoder failure
        result.status, result.error = f"error: cannot encode ({error})", True
        return result

    after = len(encoded)
    result.after = after

    if lossless_result and args.verify:
        with Image.open(io.BytesIO(encoded)) as check:
            if rgba(check) != rgba(reference):
                result.status = "keep: lossless result differs, not used"
                return result

    if after > before * (1 - args.min_saving / 100):
        result.status = "keep: not smaller" if after >= before else f"keep: saves under {args.min_saving:g}%"
        return result

    # Where does it go?
    ext = EXTENSIONS[target] if converting else item.path.suffix
    if args.out_dir:
        destination = args.out_dir / item.rel.with_suffix(ext)
    else:
        destination = item.path.with_suffix(ext)
    result.target = destination
    if args.in_place and converting and destination.exists():
        result.status = f"skip: {destination.name} already exists"
        result.after = None
        result.target = None
        return result

    action = "convert" if converting else ("resize" if size else "compress")
    detail = f"{action} {'lossless' if lossless_result else 'lossy'}"
    if size:
        detail += f" to {size[0]}x{size[1]}"
    result.changed = True
    if args.dry_run:
        result.status = f"would {detail}{note}{actual}"
        return result

    if args.in_place and args.backup_dir:
        backup = args.backup_dir / item.rel
        if not backup.exists():  # never overwrite an older, truer original
            backup.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(item.path, backup)
    write_atomically(destination, encoded)
    if args.in_place and converting and not args.keep_original:
        item.path.unlink()
    result.status = f"{detail}{note}{actual}"
    return result


def write_atomically(destination: Path, data: bytes) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=destination.parent, prefix=".opt-", suffix=destination.suffix)
    try:
        with os.fdopen(fd, "wb") as handle:
            handle.write(data)
        os.replace(tmp, destination)
    except BaseException:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise


# --------------------------------------------------------------------------
# Report
# --------------------------------------------------------------------------


def human(size: int) -> str:
    if size < 1024:
        return f"{size} B"
    if size < 1024 * 1024:
        return f"{size / 1024:.1f} KB"
    return f"{size / (1024 * 1024):.2f} MB"


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)

    if args.format == "webp" and not features.check("webp"):
        sys.exit("This Pillow build has no WebP support. Reinstall it: pip install --force-reinstall pillow")

    items, problems = collect(args)
    for problem in problems:
        print(f"warning: {problem}", file=sys.stderr)
    if not items:
        print("No PNG, JPEG or WebP files found.")
        return 1 if problems else 0

    results = [process(item, args) for item in items]

    print(f"{'before':>10}  {'after':>10}  {'change':>6}  file  [what happened]")
    for r in results:
        after = human(r.after) if r.after is not None else "-"
        change = f"{(r.after - r.before) / r.before * 100:+.0f}%" if r.after is not None and r.before else ""
        shown = relative_to_cwd(r.target) or r.target if r.target else None
        target = f" -> {shown}" if r.target and r.target != r.item.path else ""
        print(f"{human(r.before):>10}  {after:>10}  {change:>6}  {r.item.path}{target}  [{r.status}]")

    changed = [r for r in results if r.changed]
    errors = [r for r in results if r.error]
    total_before = sum(r.before for r in results)
    saved = sum(r.before - (r.after or r.before) for r in changed)
    total_after = total_before - saved
    share = saved / total_before * 100 if total_before else 0.0

    print()
    verb = "would change" if args.dry_run else "changed"
    print(f"{len(results)} file(s) checked, {len(changed)} {verb}, {len(errors)} error(s)")
    print(f"total {human(total_before)} -> {human(total_after)}  (saved {human(saved)}, {share:.1f}%)")

    renamed = [r for r in changed if r.target and r.target.suffix != r.item.path.suffix]
    if renamed:
        print("\nNew file extensions. Update the Dart references (and pubspec.yaml if it lists files):")
        for r in renamed:
            print(f"  {r.item.rel.as_posix()}  ->  {r.item.rel.with_suffix(r.target.suffix).as_posix()}")
    if args.report_only:
        print("\nReport only. Add --in-place to replace the files, or --out-dir DIR to write copies.")
    elif args.dry_run:
        print("\nDry run: nothing was written.")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
