#!/data/data/com.termux/files/usr/bin/python3
"""
Generador de animaciones TrueColor con bloques medios (CSAN2).
Diseñado para Code Stack Sh.
"""

import argparse
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile
import zlib

MAGIC = b"CSAN2\x00\r\n"
RESET = "\033[0m"

PROFILES = (
    ("intro_xlarge.ans.z", 96, 20),
    ("intro_large.ans.z", 82, 17),
    ("intro_medium.ans.z", 68, 14),
    ("intro_small.ans.z", 52, 11),
    ("intro_compact.ans.z", 36, 8),
    ("banner_large.ans.z", 80, 9),
    ("banner_medium.ans.z", 66, 8),
    ("banner_small.ans.z", 52, 7),
    ("banner_compact.ans.z", 44, 6),
    ("banner_tiny.ans.z", 36, 4),
)

def positive_float(value):
    result = float(value)
    if result <= 0:
        raise argparse.ArgumentTypeError("Debe ser mayor que cero.")
    return result

def positive_int(value):
    result = int(value)
    if result <= 0:
        raise argparse.ArgumentTypeError("Debe ser mayor que cero.")
    return result

def read_exact_or_eof(stream, count):
    chunks = []
    remaining = count
    while remaining:
        chunk = stream.read(remaining)
        if not chunk:
            if remaining == count:
                return None
            raise RuntimeError(
                f"ffmpeg entregó un fotograma incompleto: "
                f"{count - remaining}/{count} bytes."
            )
        chunks.append(chunk)
        remaining -= len(chunk)
    return b"".join(chunks)

def quantize_rgb(raw, offset, step):
    if step <= 1:
        return (raw[offset], raw[offset + 1], raw[offset + 2])
    return (
        (raw[offset] // step) * step,
        (raw[offset + 1] // step) * step,
        (raw[offset + 2] // step) * step,
    )

def encode_half_block(raw, cols, rows, quantization=8):
    lines = []
    stride = cols * 3

    for row in range(rows):
        upper_start = row * 2 * stride
        lower_start = upper_start + stride

        parts = [RESET]
        prev_fg = None
        prev_bg = None

        for col in range(cols):
            x = col * 3
            fg = quantize_rgb(raw, upper_start + x, quantization)
            bg = quantize_rgb(raw, lower_start + x, quantization)

            fg_dark = (fg[0] < 14 and fg[1] < 14 and fg[2] < 14)
            bg_dark = (bg[0] < 14 and bg[1] < 14 and bg[2] < 14)

            if fg_dark and bg_dark:
                if prev_fg is not None or prev_bg is not None:
                    parts.append(RESET)
                    prev_fg = None
                    prev_bg = None
                parts.append(' ')
                continue

            if fg_dark and not bg_dark:
                params = []
                if bg != prev_fg:
                    params.extend(["38", "2", str(bg[0]), str(bg[1]), str(bg[2])])
                    prev_fg = bg
                if prev_bg is not None:
                    params.append("49")
                    prev_bg = None
                if params:
                    parts.append("\033[" + ";".join(params) + "m")
                parts.append("▄")
                continue

            params = []
            if fg != prev_fg:
                params.extend(["38", "2", str(fg[0]), str(fg[1]), str(fg[2])])
                prev_fg = fg

            if bg_dark:
                if prev_bg is not None:
                    params.append("49")
                    prev_bg = None
            else:
                if bg != prev_bg:
                    params.extend(["48", "2", str(bg[0]), str(bg[1]), str(bg[2])])
                    prev_bg = bg

            if params:
                parts.append("\033[" + ";".join(params) + "m")
            parts.append("▀")

        parts.append(RESET)
        lines.append("".join(parts))

    return "\n".join(lines).encode("utf-8")

def build_filter(cols, rows, fps, crop=None, cell_aspect=2.0):
    pixel_height = rows * 2
    filters = []

    if crop:
        filters.append(f"crop={crop}")

    aspect_correction = 2.0 / cell_aspect
    filters.append(f"scale=w='max(1,round(iw*sar*{aspect_correction:.12g}))':h=ih")
    filters.append("setsar=1")

    filters.extend([
        f"fps={fps:.12g}",
        f"scale={cols}:{pixel_height}:force_original_aspect_ratio=decrease:flags=lanczos",
        f"pad={cols}:{pixel_height}:(ow-iw)/2:(oh-ih)/2:color=black",
        "setsar=1",
    ])

    return ",".join(filters)

def generate_profile(args, filename, cols, rows):
    destination = args.output / filename
    frame_size = cols * rows * 2 * 3
    offsets = []
    uncompressed_total = 0

    command = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-nostdin"]

    if args.image_seconds is not None:
        command += ["-loop", "1"]

    command += ["-i", str(args.input)]

    if args.image_seconds is not None:
        command += ["-t", str(args.image_seconds)]
    elif args.duration is not None:
        command += ["-t", str(args.duration)]

    command += [
        "-map", "0:v:0",
        "-an", "-sn", "-dn",
        "-vf", build_filter(cols, rows, args.fps, args.crop, args.cell_aspect),
        "-f", "rawvideo",
        "-pix_fmt", "rgb24",
        "pipe:1",
    ]

    print(f"Generando {filename}: {cols}x{rows} celdas ({cols}x{rows * 2} px) @ {args.fps:g} FPS...", flush=True)

    with tempfile.TemporaryFile(dir=args.output) as payload:
        with tempfile.TemporaryFile() as errors:
            process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=errors)

            try:
                while True:
                    raw = read_exact_or_eof(process.stdout, frame_size)
                    if raw is None:
                        break

                    encoded = encode_half_block(raw, cols, rows, args.quantize)
                    compressed = zlib.compress(encoded, args.level)

                    offsets.append([payload.tell(), len(compressed)])
                    payload.write(compressed)
                    uncompressed_total += len(encoded)

                return_code = process.wait()
                if return_code:
                    errors.seek(0)
                    detail = errors.read().decode("utf-8", "replace").strip()
                    raise RuntimeError(f"ffmpeg falló con código {return_code}:\n{detail}")

                if not offsets:
                    raise RuntimeError("El video no produjo fotogramas.")

            finally:
                if process.stdout:
                    process.stdout.close()
                if process.poll() is None:
                    process.terminate()
                    try:
                        process.wait(timeout=2)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait()

        header = {
            "version": 2,
            "mode": "half-block",
            "cols": cols,
            "rows": rows,
            "fps": args.fps,
            "cellaspect": args.cell_aspect,
            "quantization": args.quantize,
            "frames": offsets,
        }

        header_bytes = json.dumps(header, separators=(",", ":"), ensure_ascii=True).encode("utf-8")
        temporary_name = None

        try:
            with tempfile.NamedTemporaryFile(
                mode="wb",
                prefix=destination.name + ".",
                suffix=".tmp",
                dir=args.output,
                delete=False,
            ) as output:
                temporary_name = output.name
                output.write(MAGIC)
                output.write(struct.pack(">I", len(header_bytes)))
                output.write(header_bytes)

                payload.seek(0)
                shutil.copyfileobj(payload, output, length=1024 * 1024)

                output.flush()
                os.fsync(output.fileno())

            os.replace(temporary_name, destination)
            temporary_name = None
        finally:
            if temporary_name:
                try:
                    os.unlink(temporary_name)
                except FileNotFoundError:
                    pass

    size = destination.stat().st_size
    print(f"  [✓] {len(offsets)} fotogramas; {size:,} bytes comprimidos ({uncompressed_total:,} bytes ANSI).", flush=True)

def main():
    default_output = Path(__file__).resolve().parents[1] / "assets" / "ascii_v2"

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("--output", type=Path, default=default_output)
    parser.add_argument("--fps", type=positive_float, default=12.0)
    parser.add_argument("--crop", help="Recorte ffmpeg: ancho:alto:x:y")
    parser.add_argument("--duration", type=positive_float)
    parser.add_argument("--image-seconds", type=positive_float)
    parser.add_argument("--cell-aspect", type=positive_float, default=2.0)
    parser.add_argument("--quantize", type=positive_int, default=8)
    parser.add_argument("--level", type=int, choices=range(1, 10), default=6)
    parser.add_argument("--single-profile", help="Solo generar un perfil específico (ej. banner_large.ans.z)")
    args = parser.parse_args()

    if not shutil.which("ffmpeg"):
        parser.error("No se encontró ffmpeg en PATH.")

    if not args.input.is_file():
        parser.error(f"No existe el archivo: {args.input}")

    if args.quantize > 256:
        parser.error("--quantize debe estar entre 1 y 256.")

    if args.image_seconds is not None and args.duration is not None:
        parser.error("Usa --duration o --image-seconds, no ambos.")

    args.output.mkdir(parents=True, exist_ok=True)

    profiles_to_run = PROFILES
    if args.single_profile:
        profiles_to_run = [p for p in PROFILES if p[0] == args.single_profile]
        if not profiles_to_run:
            parser.error(f"Perfil desconocido: {args.single_profile}")

    for filename, cols, rows in profiles_to_run:
        generate_profile(args, filename, cols, rows)

    print("\n[✓] ¡Perfiles generados con éxito!")

if __name__ == "__main__":
    main()
