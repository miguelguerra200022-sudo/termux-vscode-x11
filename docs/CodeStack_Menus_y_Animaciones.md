# CODE STACK SH: SISTEMA INTEGRAL DE MENÚS Y MOTOR DE ANIMACIONES ULTRA-DETALLADAS

> **Documento de Contexto Completo y Código Fuente.**
> Diseñado para ChatGPT 6 Astra: Presupuesto optimizado < 170.000 caracteres para lectura 100% completa sin cortes.

## 1. MAPA ARQUITECTÓNICO Y CONEXIÓN ENTRE COMPONENTES


El subsistema de interfaz de usuario (TUI) y animaciones de Code Stack Sh consta de 6 módulos interconectados:

1. **`bin/code-stack-ascii` (Motor Gráfico Principal)**:
   - **`play_intro(fps=12)`**: Cinemática 3D a pantalla completa al encender. Detecta teclado interactivo (`/dev/tty` / `sys.stdin`), reproduce audio estéreo sin bloqueos y soporta salto instantáneo (< 1ms).
   - **`get_formatted_banner_lines(frame_idx, cols, rows)`**: Extrae fotogramas en streaming desde archivos zlib (`.ans.z`) y los centra con márgenes calculados para incrustarse en los menús interactivos sin provocar parpadeo.
   - **`run_split_command(cmd, title)`**: Modo pantalla dividida usando secuencias DECSTBM (`\033[top;bot r`). El banner animado corre en el panel superior a 15 FPS en un bucle select/PTY asíncrono mientras el script de instalación emite sus logs en el panel inferior sin tocar la cabecera.

2. **`scratch/generate_all_ascii.py` (Generador de Fotogramas desde Video/Imágenes)**:
   - Extrae video con `ffmpeg` en formato raw rgb24.
   - Mapea brillo a caracteres ASCII y cuantiza colores a 24-bit TrueColor (`\033[38;2;R;G;Bm`).
   - Comprime los fotogramas en un solo flujo binario delimitado por `\x00` usando `zlib` nivel 9.

3. **`bin/encender` (Menú Principal y Explorador de Proyectos)**:
   - Punto de entrada de la estación de trabajo.
   - Muestra el banner animado en cabecera si la terminal tiene >= 20 líneas de alto.
   - Pestaña 0: Explorador interactivo del almacenamiento del teléfono (`/storage/emulated/0`) con filtrado por búsqueda en tiempo real, detección de repositorios `[git]`, descripciones personalizadas y paginación.
   - Pestaña 1: Historial de proyectos abiertos recientemente.
   - Teclas de acceso directo: `c` para conmutar identidad (Líder), `tab` para alternar pestañas, `e` para editar descripciones, `0-9` para salto rápido, `esc` o `backspace` para subir nivel.

4. **`Programas/menu-instalador.sh` (Centro de Software Oficial con +110 Aplicaciones)**:
   - Categorías dinámicas (Navegadores, Editores, Multimedia, Gráficos, Utilidades, etc.).
   - Motor de búsqueda global multicriterio por nombre y tagline.
   - Caché en memoria ultrarrápida de programas instalados (cero subshells innecesarios).
   - Desinstalador inteligente: Opción 1 (Conservar datos/credenciales) vs Opción 2 (Purgado total con respaldo previo cifrado vía `vault-manager`).
   - Muestra el banner animado dinámico en cabecera invocando `code-stack-ascii banner "$frame"`.
   - Ejecuta las instalaciones a través de `code-stack-ascii run` para visualización Split-Screen.

5. **`bin/switch-identity` (Conmutador Multi-Dispositivo Exclusivo del Líder)**:
   - Consulta flota en Cloudflare Edge (`/api/v1/fleet/devices`) y bóvedas locales.
   - Permite al Líder alternar instantáneamente la identidad del dispositivo, desempaquetando la bóveda cifrada en memoria y actualizando la sesión activa.

6. **`bin/flota` (Centro de Comando y Control de la Flota)**:
   - Menú de administración de dispositivos: listar dispositivos, estados de aprobación en D1, desvinculación remota y auditoría.

## 2. OBJETIVOS DE MODERNIZACIÓN SOLICITADOS


### A. Adaptabilidad Total a Cualquier Pantalla (TUI 100% Responsiva)
- **Detección dinámica**: Usar `shutil.get_terminal_size()` en Python y `tput cols` / `tput lines` en Bash.
- **Auto-escalado de marcos y cajas**: Los bordes de cuadros (`╔═══╗`, `─`, `═`) y títulos deben adaptarse fluidamente al ancho exacto disponible (desde terminales móviles angostas de 40-50 columnas hasta tablets y escritorios de 120-200 columnas).
- **Protección contra desbordamiento y saltos de línea**: Las descripciones y nombres largos deben truncarse inteligentemente con elipsis (`...`) preservando secuencias de escape ANSI sin romper estilos ni provocar saltos de línea indeseados.
- **Paginación vertical adaptativa**: El número de elementos por página (`page_size`) debe calcularse dinámicamente según la altura del terminal (`rows`), evitando scrolls no deseados en pantallas pequeñas.

### B. Caracteres Más Pequeños y Gráficos Ultra-Detallados (Half-Block & Sub-Cell Unicode)
- **Técnica del Bloque Medio (`▀` U+2580 y `▄` U+2584)**:
  - En lugar de 1 carácter = 1 píxel alargado (~1:2), un carácter de bloque medio contiene DOS píxeles verticales en la misma celda de texto:
    - Píxel Superior: Color de Primer Plano (`\033[38;2;R_top;G_top;B_top m`)
    - Píxel Inferior: Color de Fondo (`\033[48;2;R_bot;G_bot;B_bot m`)
    - Glifo: `▀`
  - **Ventajas**:
    1. Duplica exactamente la resolución vertical en la misma cantidad de filas del terminal.
    2. Convierte la relación de aspecto de cada píxel a prácticamente 1:1 (cuadrado perfecto), eliminando la distorsión rectangular.
    3. Permite un nivel de detalle fotográfico / pixel-art hiper-detallado con 24-bit TrueColor sin necesidad de agrandar la pantalla.
- **Matriz Braille (`⠀` a `⣿`, U+2800 a U+28FF)**:
  - Matriz de 2x4 puntos por carácter (8 sub-píxeles por celda) para líneas, ondas de audio o bordes de alto contraste.
- **Bloques de Sombreado (`░▒▓█`)**:
  - Para gradientes suaves y efectos de neón/resplandor.

## 3. CÓDIGO FUENTE COMPLETO DE CADA MÓDULO

### Archivo: `bin/code-stack-ascii`

```python
#!/data/data/com.termux/files/usr/bin/python3
# ==============================================================================
# code-stack-ascii: Motor Dinámico de Animación ASCII Matrix y Split-Screen
# ==============================================================================
# - Calcula automáticamente el tamaño de pantalla de cualquier dispositivo.
# - Renderizado de alto contraste Matrix (cero ruido, negros puros, verde neón).
# - Modo Intro: Cinemática 3D fluida a 20 FPS con salto instantáneo sin esperas.
# - Modo Split-Screen (DECSTBM): Bucle de video en panel superior y registros abajo.
# - Cero dependencias externas y consumo < 0.5% CPU en Termux.
# ==============================================================================

import os
import sys
import time
import zlib
import shutil
import subprocess
import select
import pty
import termios
import tty

def find_asset(subpath):
    candidates = [
        os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", subpath),
        os.path.join(os.environ.get("PREFIX", "/data/data/com.termux/files/usr"), "share/code-stack-sh/assets", subpath),
        os.path.expanduser(f"~/termux-vscode-x11/assets/{subpath}")
    ]
    for c in candidates:
        if os.path.isfile(c):
            return c
    return None

def load_frames(subpath):
    path = find_asset(subpath)
    if not path or not os.path.isfile(path):
        return []
    try:
        with open(path, "rb") as f:
            raw = zlib.decompress(f.read())
        return raw.split(b"\x00")
    except Exception:
        return []

def ansi_truncate(s, max_visible):
    """Trunca una cadena ANSI respetando secuencias de escape completas sin romper colores."""
    if max_visible <= 0:
        return ""
    visible = 0
    result = []
    i = 0
    n = len(s)
    while i < n:
        if s[i] == '\033' and i + 1 < n and s[i+1] == '[':
            end = s.find('m', i)
            if end != -1:
                result.append(s[i:end+1])
                i = end + 1
                continue
        if visible >= max_visible:
            break
        result.append(s[i])
        visible += 1
        i += 1
    result.append('\033[0m')
    return ''.join(result)

def get_intro_profile(term_cols, term_rows):
    """Selecciona el perfil óptimo de pantalla completa según las dimensiones reales."""
    candidates = [
        ("ascii/intro_xlarge.ans.z", 96, 20),
        ("ascii/intro_large.ans.z", 82, 17),
        ("ascii/intro_medium.ans.z", 68, 14),
        ("ascii/intro_small.ans.z", 52, 11),
    ]
    for name, w, h in candidates:
        if term_cols >= w + 2 and term_rows >= h + 3:
            return name, w, h
    return "ascii/intro_small.ans.z", 52, 11

def get_banner_profile(term_cols, term_rows):
    """Selecciona el banner panorámico óptimo para pantalla dividida o encabezados."""
    candidates = [
        ("ascii/banner_large.ans.z", 80, 9),
        ("ascii/banner_medium.ans.z", 66, 8),
        ("ascii/banner_small.ans.z", 52, 7),
        ("ascii/banner_compact.ans.z", 44, 6),
    ]
    for name, w, h in candidates:
        if term_cols >= w + 2 and term_rows >= (h + 3):
            return name, w, h
    return "ascii/banner_compact.ans.z", 44, 6

def start_audio():
    """Inicia reproducción de audio sin bloqueos (usando mpv, ffplay o termux-media-player con timeout)."""
    audio_path = find_asset("audio/cyber_intro.aac")
    if not audio_path or not os.path.isfile(audio_path):
        return None
    # 1. MPV nativo de Android (ultrarrápido, driver AAudio/OpenSLES, proceso hijo gestionado)
    if shutil.which("mpv"):
        try:
            return subprocess.Popen(
                ["mpv", "--no-video", "--no-terminal", "--really-quiet", "--loop=inf", audio_path],
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except Exception:
            pass
    # 2. FFplay oficial (arquitectura RipperdocNiladri/ASCII-Art)
    if shutil.which("ffplay"):
        try:
            return subprocess.Popen(
                ["ffplay", "-nodisp", "-vn", "-loop", "0", "-loglevel", "quiet", audio_path],
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except Exception:
            pass
    # 3. Fallback seguro a termux-media-player con timeout estricto de 1.0s para evitar cuelgues
    if shutil.which("termux-media-player"):
        try:
            subprocess.run(
                ["termux-media-player", "play", audio_path],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=1.0
            )
            return "termux-media-player"
        except Exception:
            pass
    return None

def stop_audio(proc):
    """Detiene el proceso de audio de forma 100% segura e instantánea (< 1ms)."""
    if proc is None:
        return
    if isinstance(proc, subprocess.Popen):
        try:
            proc.terminate()
            proc.wait(timeout=0.3)
        except Exception:
            try:
                proc.kill()
            except Exception:
                pass
    elif proc == "termux-media-player":
        if shutil.which("termux-media-player"):
            try:
                subprocess.run(
                    ["termux-media-player", "stop"],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=1.0,
                    check=False
                )
            except Exception:
                pass

def get_controlling_tty_fd():
    """
    Obtiene el descriptor de archivo de la terminal interactiva (teclado),
    incluso si sys.stdin fue canalizado a través de una tubería (pipe) como en 'curl ... | bash'.
    """
    if sys.stdin.isatty():
        return sys.stdin.fileno(), None
    if os.path.exists("/dev/tty"):
        try:
            tty_f = open("/dev/tty", "rb", buffering=0)
            return tty_f.fileno(), tty_f
        except Exception:
            pass
    return None, None

def play_intro(fps=12):
    if not sys.stdout.isatty():
        return 0

    term_cols, term_rows = shutil.get_terminal_size((80, 24))
    subpath, frame_w, frame_h = get_intro_profile(term_cols, term_rows)
    frames = load_frames(subpath)
    if not frames:
        return 0

    pad_left = " " * max(0, (term_cols - frame_w) // 2)
    top_offset = max(0, (term_rows - frame_h - 2) // 2)
    hint_row = min(term_rows, top_offset + frame_h + 2)

    old_settings = None
    fd, tty_f = get_controlling_tty_fd()
    if fd is not None:
        try:
            old_settings = termios.tcgetattr(fd)
            tty.setcbreak(fd)
            termios.tcflush(fd, termios.TCIFLUSH)
        except Exception:
            pass

    audio_proc = start_audio()

    sys.stdout.write("\033[2J\033[?25l")
    sys.stdout.flush()

    frame_duration = 1.0 / fps
    frame_idx = 0
    total_frames = len(frames)

    try:
        while True:
            # Salto instantáneo si ya hay tecla pulsada en buffer tras dibujar el primer frame
            if fd is not None and frame_idx > 0:
                r, _, _ = select.select([fd], [], [], 0)
                if r:
                    try:
                        os.read(fd, 1024)
                        termios.tcflush(fd, termios.TCIFLUSH)
                    except Exception:
                        pass
                    break

            raw_str = frames[frame_idx % total_frames].decode("utf-8", errors="replace")
            lines = raw_str.split("\n")

            buf = []
            max_line_w = max(0, term_cols - len(pad_left))
            for r_idx, line in enumerate(lines[:frame_h]):
                r_pos = top_offset + r_idx + 1
                if r_pos <= term_rows:
                    clipped_line = ansi_truncate(line, max_line_w)
                    buf.append(f"\033[{r_pos};1H\033[2K{pad_left}{clipped_line}")

            if hint_row <= term_rows:
                hint = f"{pad_left}\033[1;36m   [ Pulsa cualquier tecla para entrar a Code Stack Sh ]\033[0m"
                buf.append(f"\033[{hint_row};1H\033[2K{hint}")

            sys.stdout.write("".join(buf))
            sys.stdout.flush()

            # Espera activa: si el usuario pulsa tecla despierta en < 1ms
            if fd is not None:
                r, _, _ = select.select([fd], [], [], frame_duration)
                if r:
                    try:
                        os.read(fd, 1024)
                        termios.tcflush(fd, termios.TCIFLUSH)
                    except Exception:
                        pass
                    break
            else:
                time.sleep(frame_duration)
                if frame_idx >= total_frames:
                    break

            frame_idx += 1
    finally:
        stop_audio(audio_proc)
        if old_settings and fd is not None:
            try:
                termios.tcflush(fd, termios.TCIFLUSH)
                termios.tcsetattr(fd, termios.TCSANOW, old_settings)
            except Exception:
                pass
        if tty_f:
            try:
                tty_f.close()
            except Exception:
                pass
        sys.stdout.write("\033[0m\033[?25h\033[2J\033[H")
        sys.stdout.flush()

    return 0

def run_split_command(cmd, title="INSTALACIÓN"):
    term_cols, term_rows = shutil.get_terminal_size((80, 24))

    # Terminal demasiado pequeña o no interactiva -> Ejecutar normal sin split
    if not sys.stdout.isatty() or term_rows < 18 or term_cols < 48:
        print(f"\033[1;36m[⚡ Code Stack Sh] Iniciando: {title}...\033[0m\n")
        return subprocess.run(cmd).returncode

    subpath, banner_w, banner_h = get_banner_profile(term_cols, term_rows)
    frames = load_frames(subpath)
    if not frames:
        print(f"\033[1;36m[⚡ Code Stack Sh] Iniciando: {title}...\033[0m\n")
        return subprocess.run(cmd).returncode

    split_start = banner_h + 2
    split_end = term_rows

    pad_left = " " * max(0, (term_cols - banner_w) // 2)

    # Preparar terminal: limpiar, ocultar cursor, configurar márgenes VT100
    sys.stdout.write("\033[2J\033[?25l")
    sys.stdout.write(f"\033[{split_start};{split_end}r")

    # 1. Dibujar fotograma inicial del banner
    max_w = max(0, term_cols - len(pad_left))
    lines_init = frames[0].decode("utf-8", errors="replace").split("\n")
    for r_idx, line in enumerate(lines_init[:banner_h]):
        clipped = ansi_truncate(line, max_w)
        sys.stdout.write(f"\033[{r_idx + 1};1H\033[2K{pad_left}{clipped}")

    # 2. Línea divisoria elegante
    tag = f" ⚡ {title} // CODE STACK SH "
    dash_count = max(0, (term_cols - len(tag) - 2) // 2)
    div_line = f"\033[{banner_h + 1};1H\033[1;36m" + "═" * dash_count + f"\033[1;32;40m{tag}\033[1;36;40m" + "═" * max(0, term_cols - dash_count - len(tag)) + "\033[0m"
    sys.stdout.write(div_line)
    sys.stdout.write(f"\033[{split_start};1H")
    sys.stdout.flush()

    # Abrir PTY para ejecutar el comando
    master, slave = pty.openpty()
    proc = subprocess.Popen(cmd, stdin=slave, stdout=slave, stderr=slave, close_fds=True)
    os.close(slave)
    os.set_blocking(master, False)

    old_stdin = None
    input_fd, tty_f = get_controlling_tty_fd()
    if input_fd is not None:
        try:
            old_stdin = termios.tcgetattr(input_fd)
            tty.setcbreak(input_fd)
        except Exception:
            pass

    frame_idx = 0
    total_frames = len(frames)
    last_banner_time = 0
    cursor_initialized = False

    try:
        while proc.poll() is None:
            now = time.perf_counter()
            # Refrescar banner a ~15 FPS
            if now - last_banner_time >= 0.066:
                last_banner_time = now
                frame_bytes = frames[frame_idx % total_frames]
                frame_idx += 1
                lines = frame_bytes.decode("utf-8", errors="replace").split("\n")

                buf = ["\0337"]  # Salvar posición del cursor
                max_w = max(0, term_cols - len(pad_left))
                for r_idx, line in enumerate(lines[:banner_h]):
                    clipped = ansi_truncate(line, max_w)
                    buf.append(f"\033[{r_idx + 1};1H\033[2K{pad_left}{clipped}")
                buf.append("\0338")  # Restaurar posición del cursor

                sys.stdout.write("".join(buf))
                sys.stdout.flush()

            readers = [master]
            if input_fd is not None:
                readers.append(input_fd)

            r, _, _ = select.select(readers, [], [], 0.02)
            if master in r:
                try:
                    data = os.read(master, 2048)
                    if data:
                        if not cursor_initialized:
                            sys.stdout.write(f"\033[{split_start};1H\033[?25h")
                            cursor_initialized = True
                        sys.stdout.write(data.decode("utf-8", errors="replace"))
                        sys.stdout.flush()
                except OSError:
                    break

            if input_fd is not None and input_fd in r:
                try:
                    user_data = os.read(input_fd, 1024)
                    if user_data:
                        os.write(master, user_data)
                except OSError:
                    pass

        proc.wait()
        # Consumir datos restantes
        try:
            trailing = os.read(master, 4096)
            if trailing:
                sys.stdout.write(trailing.decode("utf-8", errors="replace"))
                sys.stdout.flush()
        except OSError:
            pass
    finally:
        if old_stdin and input_fd is not None:
            try:
                termios.tcsetattr(input_fd, termios.TCSADRAIN, old_stdin)
            except Exception:
                pass
        if tty_f:
            try:
                tty_f.close()
            except Exception:
                pass
        try:
            os.close(master)
        except Exception:
            pass
        # Restaurar márgenes normales y cursor
        sys.stdout.write(f"\033[r\033[?25h\033[{term_rows};1H\n")
        sys.stdout.flush()

    return proc.returncode

def get_formatted_banner_lines(frame_index=0, max_cols=None, max_rows=None):
    """Devuelve las líneas del banner adaptadas para incluir en un menú sin desbordar."""
    term_cols, term_rows = shutil.get_terminal_size((80, 24))
    if max_cols is not None:
        term_cols = min(term_cols, max_cols)
    if max_rows is not None:
        term_rows = min(term_rows, max_rows)

    if term_cols < 44:
        compact = [
            "\033[1;36m █▀▀ █▀█ █▀▄ █▀▀   █▀▀ ▀█▀ █▀█ █▀▀ █ █   █▀▀ █ █ \033[0m",
            "\033[1;32m █   █ █ █ █ ██▄   ███  █  █▀█ █▄▄ ██▄   ███ █▀█ \033[0m",
            "\033[1;34m ▀▀▀ ▀▀▀ ▀▀  ▀▀▀   ▀▀▀  ▀  ▀ ▀ ▀▀▀ ▀ ▀   ▀▀▀ ▀ ▀ \033[0m",
        ]
        pad_left = " " * max(0, (term_cols - 49) // 2)
        return [pad_left + ansi_truncate(l, term_cols) for l in compact]

    subpath, banner_w, banner_h = get_banner_profile(term_cols, term_rows)
    frames = load_frames(subpath)
    if not frames:
        return []

    frame_bytes = frames[frame_index % len(frames)]
    lines = frame_bytes.decode("utf-8", errors="replace").split("\n")
    pad_left = " " * max(0, (term_cols - banner_w) // 2)
    max_w = max(0, term_cols - len(pad_left))

    formatted = []
    for line in lines[:banner_h]:
        formatted.append(pad_left + ansi_truncate(line, max_w))
    return formatted

def play_banner_interactive(fps=12):
    """Reproduce el banner flotante animado de Code Stack Sh hasta pulsar cualquier tecla."""
    if not sys.stdout.isatty():
        return 0

    term_cols, term_rows = shutil.get_terminal_size((80, 24))
    subpath, banner_w, banner_h = get_banner_profile(term_cols, term_rows)
    frames = load_frames(subpath)
    if not frames:
        return 0

    old_settings = None
    fd, tty_f = get_controlling_tty_fd()
    if fd is not None:
        try:
            old_settings = termios.tcgetattr(fd)
            tty.setcbreak(fd)
        except Exception:
            pass

    sys.stdout.write("\033[2J\033[?25l")
    sys.stdout.flush()

    pad_left = " " * max(0, (term_cols - banner_w) // 2)
    top_offset = max(0, (term_rows - banner_h - 2) // 2)
    hint_row = min(term_rows, top_offset + banner_h + 2)

    frame_duration = 1.0 / fps
    frame_idx = 0
    total_frames = len(frames)

    try:
        while True:
            if fd is not None:
                r, _, _ = select.select([fd], [], [], 0)
                if r:
                    try:
                        os.read(fd, 1024)
                        termios.tcflush(fd, termios.TCIFLUSH)
                    except Exception:
                        pass
                    break

            raw_str = frames[frame_idx % total_frames].decode("utf-8", errors="replace")
            lines = raw_str.split("\n")

            buf = []
            max_line_w = max(0, term_cols - len(pad_left))
            for r_idx, line in enumerate(lines[:banner_h]):
                r_pos = top_offset + r_idx + 1
                if r_pos <= term_rows:
                    clipped_line = ansi_truncate(line, max_line_w)
                    buf.append(f"\033[{r_pos};1H\033[2K{pad_left}{clipped_line}")

            if hint_row <= term_rows:
                hint = f"{pad_left}\033[1;36m   [ Banner Code Stack Sh • Pulsa cualquier tecla para salir ]\033[0m"
                buf.append(f"\033[{hint_row};1H\033[2K{hint}")

            sys.stdout.write("".join(buf))
            sys.stdout.flush()

            if fd is not None:
                r, _, _ = select.select([fd], [], [], frame_duration)
                if r:
                    try:
                        os.read(fd, 1024)
                        termios.tcflush(fd, termios.TCIFLUSH)
                    except Exception:
                        pass
                    break
            else:
                time.sleep(frame_duration)

            frame_idx += 1
    finally:
        if old_settings and fd is not None:
            try:
                termios.tcflush(fd, termios.TCIFLUSH)
                termios.tcsetattr(fd, termios.TCSANOW, old_settings)
            except Exception:
                pass
        if tty_f:
            try:
                tty_f.close()
            except Exception:
                pass
        sys.stdout.write("\033[0m\033[?25h\033[2J\033[H")
        sys.stdout.flush()

    return 0

def main():
    if len(sys.argv) < 2:
        print("Uso: code-stack-ascii [intro | banner | run <comando> [titulo]]")
        sys.exit(1)

    action = sys.argv[1]

    if action == "intro":
        sys.exit(play_intro())
    elif action == "banner":
        single_frame = None
        for arg in sys.argv[2:]:
            if arg.isdigit():
                single_frame = int(arg)
                break
        if "--frame" in sys.argv:
            idx = sys.argv.index("--frame")
            if idx + 1 < len(sys.argv) and sys.argv[idx + 1].isdigit():
                single_frame = int(sys.argv[idx + 1])

        if single_frame is not None or not sys.stdout.isatty():
            lines = get_formatted_banner_lines(single_frame or 0)
            for line in lines:
                print(line)
            sys.exit(0)
        else:
            sys.exit(play_banner_interactive())
    elif action == "run":
        if len(sys.argv) < 3:
            print("Uso: code-stack-ascii run <comando> [titulo]")
            sys.exit(1)
        title = "PROCESO DE INSTALACIÓN"
        cmd_args = sys.argv[2:]
        if "--title" in cmd_args:
            t_idx = cmd_args.index("--title")
            if t_idx + 1 < len(cmd_args):
                title = cmd_args[t_idx + 1]
                del cmd_args[t_idx:t_idx + 2]

        if cmd_args and cmd_args[0] == "--":
            cmd_args = cmd_args[1:]

        if len(cmd_args) == 1:
            cmd = ["/data/data/com.termux/files/usr/bin/bash", "-c", cmd_args[0]]
        else:
            cmd = cmd_args

        rc = run_split_command(cmd, title=title)
        sys.exit(rc)
    else:
        print(f"Acción desconocida: {action}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### Archivo: `scratch/generate_all_ascii.py`

```python
import subprocess
import zlib
import os
import sys

VIDEO_PATH = "/storage/emulated/0/Antigravity/IdeasMillonarias/gemini_generated_video_0060f4ce.mp4"
OUTPUT_DIR = "/storage/emulated/0/Antigravity/IdeasMillonarias/termux-vscode-x11/assets/ascii"
os.makedirs(OUTPUT_DIR, exist_ok=True)

PROFILES = [
    # (filename, width, height, fps)
    ("intro_xlarge.ans.z", 96, 20, 12),
    ("intro_large.ans.z", 82, 17, 12),
    ("intro_medium.ans.z", 68, 14, 12),
    ("intro_small.ans.z", 52, 11, 12),
    ("banner_large.ans.z", 80, 9, 12),
    ("banner_medium.ans.z", 66, 8, 12),
    ("banner_small.ans.z", 52, 7, 12),
    ("banner_compact.ans.z", 44, 6, 12),
]

ramp = " .:-=+*#%@"
ramp_len = len(ramp)

for filename, cols, rows, fps in PROFILES:
    out_path = os.path.join(OUTPUT_DIR, filename)
    print(f"Generating {filename} ({cols}x{rows} @ {fps}fps)...")
    
    cmd = [
        "ffmpeg", "-loglevel", "error",
        "-i", VIDEO_PATH,
        "-vf", f"crop=840:210:220:255,scale={cols}:{rows},fps={fps}",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-"
    ]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    raw, _ = proc.communicate()
    
    frame_size = cols * rows * 3
    num_frames = len(raw) // frame_size
    print(f"  Total frames: {num_frames}")
    
    encoded_frames = []
    for f in range(num_frames):
        frame_raw = raw[f * frame_size : (f + 1) * frame_size]
        lines = []
        for y in range(rows):
            line_parts = []
            last_color = None
            for x in range(cols):
                idx = (y * cols + x) * 3
                r = frame_raw[idx]
                g = frame_raw[idx+1]
                b = frame_raw[idx+2]
                brightness = int(0.299 * r + 0.587 * g + 0.114 * b)
                char_idx = min(ramp_len - 1, int(brightness * ramp_len / 256))
                ch = ramp[char_idx]
                
                if ch == ' ' or (r < 18 and g < 18 and b < 18):
                    if last_color is not None:
                        line_parts.append("\033[0m")
                        last_color = None
                    line_parts.append(' ')
                else:
                    qr = (r // 8) * 8
                    qg = (g // 8) * 8
                    qb = (b // 8) * 8
                    color_code = f"\033[38;2;{qr};{qg};{qb}m"
                    if color_code != last_color:
                        line_parts.append(color_code)
                        last_color = color_code
                    line_parts.append(ch)
            if last_color is not None:
                line_parts.append("\033[0m")
            lines.append("".join(line_parts))
        encoded_frames.append("\n".join(lines).encode("utf-8"))
    
    compressed = zlib.compress(b"\x00".join(encoded_frames), level=9)
    with open(out_path, "wb") as f_out:
        f_out.write(compressed)
    print(f"  Written {len(compressed)} bytes to {out_path}")

print("All ASCII profiles generated successfully!")
```

### Archivo: `bin/encender`

```python
#!/data/data/com.termux/files/usr/bin/python3
import os
import sys
import json
import tty
import termios
import select
import datetime
import shutil
import subprocess
import time

# Colores ANSI estándar y fondos para resaltado de cursor
BLUE = "\033[1;34m"
GREEN = "\033[1;32m"
CYAN = "\033[1;36m"
YELLOW = "\033[1;33m"
WHITE = "\033[1;37m"
GRAY = "\033[0;90m"
RED = "\033[1;31m"
BOLD = "\033[1m"
NC = "\033[0m"

# Fondos brillantes con texto oscuro para máximo contraste en pantallas táctiles
HL_CYAN = "\033[1;30;46m"
HL_GREEN = "\033[1;30;42m"
HL_YELLOW = "\033[1;30;43m"
HL_TAB = "\033[1;37;44m"

STORAGE_ROOT = "/storage/emulated/0"
TERMUX_HOME = os.path.expanduser("~")
CONFIG_DIR = os.path.expanduser("~/.config/termux-vscode")
DATA_FILE = os.path.join(CONFIG_DIR, "proyectos.json")
LEADER_SEAL = "ums9230-sp_6300-3724801c"

def is_current_device_leader():
    seal = ""
    try:
        seal = subprocess.check_output(["cloud-sentinel", "seal"], stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        pass
    if not seal:
        hw_file = os.path.expanduser("~/.config/termux-vscode/.device_hw_seal")
        if os.path.isfile(hw_file):
            try:
                with open(hw_file, "r") as f:
                    seal = f.read().strip()
            except Exception:
                pass
    return seal == LEADER_SEAL

def check_edge_updates():
    """Verificación ultrarrápida contra Cloudflare Edge para actualizar sin reinstalar."""
    try:
        gitops = shutil.which("gitops-sync")
        if not gitops:
            return
        import urllib.request
        gateway_url = "https://code-stack-gateway.cdn-sys-runtime.workers.dev"
        gw_file = os.path.expanduser("~/.config/termux-vscode/gateway_url")
        if os.path.isfile(gw_file):
            with open(gw_file) as f:
                u = f.read().strip()
                if u: gateway_url = u
        
        current_commit = ""
        cc_file = os.path.expanduser("~/.config/termux-vscode/.current_commit")
        if os.path.isfile(cc_file):
            with open(cc_file) as f:
                current_commit = f.read().strip()
        if not current_commit:
            repo_file = os.path.expanduser("~/.config/termux-vscode/repo_path")
            repo_dir = ""
            if os.path.isfile(repo_file):
                with open(repo_file) as f: repo_dir = f.read().strip()
            if not repo_dir or not os.path.isdir(os.path.join(repo_dir, ".git")):
                repo_dir = "/storage/emulated/0/Antigravity/IdeasMillonarias/termux-vscode-x11"
            if os.path.isdir(os.path.join(repo_dir, ".git")):
                try:
                    current_commit = subprocess.check_output(["git", "-C", repo_dir, "rev-parse", "HEAD"], stderr=subprocess.DEVNULL).decode().strip()
                except Exception:
                    pass
        
        req = urllib.request.Request(f"{gateway_url}/api/v1/release/latest")
        if current_commit:
            req.add_header("If-None-Match", f'"{current_commit}"')
        
        with urllib.request.urlopen(req, timeout=0.8) as resp:
            if resp.status == 200:
                data = json.loads(resp.read().decode())
                remote_commit = data.get("commit", "")
                if remote_commit and remote_commit not in [current_commit, "main", "initial"]:
                    print(f"\033[1;36m[*] Actualización detectada en Cloudflare Edge ({remote_commit[:7]}). Sincronizando...\033[0m")
                    subprocess.run([gitops, "pull", "--quiet"], timeout=20)
    except Exception:
        pass

def get_term_cols():
    """Obtiene el ancho actual de la pantalla del terminal."""
    try:
        return shutil.get_terminal_size((80, 24)).columns
    except Exception:
        return 80

def check_storage_permission():
    """Verifica si Termux tiene acceso a las carpetas de Android (/storage/emulated/0)."""
    if not os.path.exists(STORAGE_ROOT):
        return False
    try:
        os.listdir(STORAGE_ROOT)
        return True
    except Exception:
        return False

def request_storage_permission():
    """Pide permiso de almacenamiento al usuario y monitorea la aprobación en Android."""
    sys.stdout.write("\033[H\033[J")
    cols = min(get_term_cols(), 72)
    print(f"{BLUE}" + "═" * cols + f"{NC}")
    print(f"{GREEN}  📱 PERMISO DE ALMACENAMIENTO DE ANDROID (PRIMER INICIO){NC}")
    print(f"{BLUE}" + "═" * cols + f"{NC}")
    print("Para que Code Stack Sh pueda explorar y abrir las carpetas de tu teléfono")
    print("(como Descargas, Documentos, Proyectos, etc.), Termux necesita permiso.")
    print(f"{GRAY}" + "─" * cols + f"{NC}")
    try:
        resp = input(f"{BOLD}¿Deseas conceder permiso a Termux para ver las carpetas del teléfono? [S/n]: {NC}").strip().lower()
    except (KeyboardInterrupt, EOFError):
        resp = "n"
    
    if resp in ('', 's', 'si', 'y', 'yes'):
        print(f"\n{CYAN}⚡ Solicitando permiso al sistema Android...{NC}")
        print(f"{YELLOW}👉 Pulsa 'PERMITIR' en la ventana emergente en pantalla.{NC}\n")
        try:
            subprocess.run(["termux-setup-storage"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass
        
        for i in range(15):
            time.sleep(1)
            if check_storage_permission():
                print(f"{GREEN}[✓] ¡Permiso concedido con éxito! Entrando a las carpetas del teléfono...{NC}\n")
                time.sleep(1)
                return True
            sys.stdout.write(f"\r{GRAY}Esperando aprobación del sistema ({15 - i}s)...{NC} ")
            sys.stdout.flush()
        
        print(f"\n\n{YELLOW}[!] No se detectó la aprobación o se agotó el tiempo.{NC}")
        print(f"{GRAY}Se continuará en el almacenamiento local de Termux (~).{NC}\n")
        time.sleep(1.5)
        return False
    else:
        print(f"\n{YELLOW}[*] Permiso omitido. Se usará el directorio local de Termux (~).{NC}\n")
        time.sleep(1)
        return False

def load_data():
    """Carga el historial y las descripciones privadas locales."""
    os.makedirs(CONFIG_DIR, exist_ok=True)
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {"descriptions": {}, "history": []}

def save_data(data):
    """Guarda el historial y descripciones en el teléfono (nunca en Git)."""
    os.makedirs(CONFIG_DIR, exist_ok=True)
    try:
        with open(DATA_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    except Exception:
        pass

def normalize_path(path):
    """Evita caer en trampas del sistema como /storage o /storage/emulated."""
    real = os.path.abspath(path)
    if real in ('/storage', '/storage/emulated', '/'):
        return STORAGE_ROOT
    return real

def add_to_history(path, desc=None):
    """Registra una carpeta en el historial de proyectos recientes."""
    data = load_data()
    norm_path = normalize_path(path)
    bname = os.path.basename(norm_path) or norm_path
    
    if desc is not None and desc.strip():
        data["descriptions"][norm_path] = desc.strip()
    
    history = [item for item in data.get("history", []) if item.get("path") != norm_path]
    now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    
    history.insert(0, {
        "path": norm_path,
        "name": bname,
        "last_opened": now_str
    })
    
    data["history"] = history[:30]
    save_data(data)

def get_subdirs(path):
    """Lista subdirectorios legibles, protegiendo contra errores de permisos de Android."""
    try:
        entries = sorted([
            d for d in os.listdir(path)
            if not d.startswith('.') and os.path.isdir(os.path.join(path, d))
        ], key=lambda s: s.lower())
        return entries
    except Exception:
        return []

def ensure_controlling_tty():
    """Si stdin no es una tty (por ejemplo en tuberías curl ... | bash), reconecta stdin a /dev/tty."""
    if not sys.stdin.isatty() and os.path.exists("/dev/tty"):
        try:
            f = open("/dev/tty", "r")
            os.dup2(f.fileno(), 0)
            sys.stdin = open(0, "r")
        except Exception:
            pass

def get_key():
    """Lee una tecla o secuencia de escape directamente desde el descriptor del SO sin buffer de Python."""
    if not sys.stdin.isatty():
        ch = sys.stdin.read(1)
        if not ch:
            time.sleep(0.5)
            return 'QUIT'
        return ch
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        first_b = os.read(fd, 1)
        if not first_b:
            return ''
        if first_b == b'\x1b':
            # Esperar hasta 80ms para recibir los caracteres restantes de la secuencia ANSI
            r, _, _ = select.select([fd], [], [], 0.08)
            if r:
                rest_b = os.read(fd, 32)
                return (first_b + rest_b).decode('utf-8', errors='ignore')
            return '\x1b'
        return first_b.decode('utf-8', errors='ignore')
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

def classify_key(k):
    """Clasifica cualquier combinación de teclas física, virtual o secuencia ANSI sin conflictos."""
    if not k:
        return 'NONE'
    if k in ('\t', '\x1b[Z'):
        return 'TAB'
    if k in ('q', 'Q', '\x03'):
        return 'QUIT'
    # Flecha Arriba, W o K (soporta \x1b[A, \x1bOA, \x1b[1;5A, etc.)
    if k in ('w', 'W', 'k', 'K') or '[A' in k or 'OA' in k or (k.startswith('\x1b') and k.endswith('A')):
        return 'UP'
    # Flecha Abajo, S o J (soporta \x1b[B, \x1bOB, \x1b[1;5B, etc.)
    if k in ('s', 'S', 'j', 'J') or '[B' in k or 'OB' in k or (k.startswith('\x1b') and k.endswith('B')):
        return 'DOWN'
    # ENTER EXCLUSIVO (Entrar a carpeta o abrir proyecto seleccionado)
    if k in ('\r', '\n'):
        return 'ENTER'
    # Flecha Derecha o N: Siguiente página (desplazar hacia siguientes carpetas)
    if k in ('n', 'N') or '[C' in k or 'OC' in k or (k.startswith('\x1b') and k.endswith('C')):
        return 'NEXT'
    # Flecha Izquierda o P: Página anterior (desplazar hacia carpetas anteriores)
    if k in ('p', 'P') or '[D' in k or 'OD' in k or (k.startswith('\x1b') and k.endswith('D')):
        return 'PREV'
    # Volver / Subir nivel: ESC o Backspace (o letra A)
    if k in ('\x7f', '\b', '\x1b', 'a', 'A'):
        return 'BACK'
    # Conmutar Identidad Multi-dispositivo (Exclusivo Líder)
    if k in ('c', 'C', 'i', 'I'):
        if is_current_device_leader():
            return 'SWITCH_IDENTITY'
        return 'OTHER'
    # Búsqueda / Filtro rápido por nombre
    if k in ('/', 'f', 'F'):
        return 'SEARCH'
    # Editar descripción
    if k in ('e', 'E'):
        return 'EDIT'
    # Borrar del historial
    if k in ('d', 'D') or '[3~' in k:
        return 'DELETE'
    # Entrada numérica directa
    if k.isdigit():
        return f'DIGIT_{k}'
    return 'OTHER'

def prompt_text_with_esc(prompt_str):
    """
    Permite ingresar texto en la terminal interceptando la tecla ESC para cancelar.
    Retorna:
      - str: El texto ingresado (puede ser vacío si presionó ENTER).
      - None: Si el usuario presionó ESC o Ctrl+C para volver atrás.
    """
    if not sys.stdin.isatty():
        try:
            return input(prompt_str)
        except Exception:
            return ""
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    buf = []
    cursor_pos = 0

    sys.stdout.write(prompt_str)
    sys.stdout.flush()

    try:
        tty.setraw(fd)
        while True:
            first_b = os.read(fd, 1)
            if not first_b:
                continue

            # Tecla ESC o secuencia de escape
            if first_b == b'\x1b':
                r, _, _ = select.select([fd], [], [], 0.08)
                if r:
                    rest_b = os.read(fd, 32)
                    seq = (first_b + rest_b).decode('utf-8', errors='ignore')
                    if '[D' in seq or 'OD' in seq:
                        if cursor_pos > 0:
                            cursor_pos -= 1
                            sys.stdout.write('\033[D')
                            sys.stdout.flush()
                    elif '[C' in seq or 'OC' in seq:
                        if cursor_pos < len(buf):
                            cursor_pos += 1
                            sys.stdout.write('\033[C')
                            sys.stdout.flush()
                    elif '[3~' in seq:
                        if cursor_pos < len(buf):
                            buf.pop(cursor_pos)
                            tail = ''.join(buf[cursor_pos:]) + ' '
                            sys.stdout.write(tail + '\b' * len(tail))
                            sys.stdout.flush()
                    continue
                else:
                    return None  # ESC presionado solo -> Cancelar

            if first_b in (b'\r', b'\n'):
                return ''.join(buf)

            if first_b == b'\x03':
                return None

            if first_b in (b'\x7f', b'\x08'):
                if cursor_pos > 0:
                    cursor_pos -= 1
                    buf.pop(cursor_pos)
                    tail = ''.join(buf[cursor_pos:]) + ' '
                    sys.stdout.write('\b' + tail + '\b' * len(tail))
                    sys.stdout.flush()
                continue

            try:
                ch = first_b.decode('utf-8', errors='ignore')
                if ch and ord(ch) >= 32:
                    buf.insert(cursor_pos, ch)
                    cursor_pos += 1
                    tail = ''.join(buf[cursor_pos - 1:])
                    sys.stdout.write(tail + ('\b' * (len(tail) - 1) if len(tail) > 1 else ''))
                    sys.stdout.flush()
            except Exception:
                pass
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        sys.stdout.write('\n')
        sys.stdout.flush()

def launch_workspace_with_desc(target_path):
    """Pide descripción si es la primera vez y lanza start-vscode. Retorna False si se canceló con ESC."""
    target_path = normalize_path(target_path)
    data = load_data()
    bname = os.path.basename(target_path) or target_path
    saved_desc = data.get("descriptions", {}).get(target_path, "")

    if not saved_desc:
        sys.stdout.write("\033[H\033[J")
        cols = min(get_term_cols(), 72)
        print(f"{BLUE}" + "═" * cols + f"{NC}")
        print(f"{GREEN}  📝 NUEVO PROYECTO DETECTADO:{NC} {BOLD}{bname}{NC}")
        print(f"{BLUE}" + "═" * cols + f"{NC}")
        print(f"Ruta: {CYAN}{target_path}{NC}\n")
        print("Escribe una breve descripción para recordar de qué trata este proyecto:")
        print(f"{GRAY}(Ejemplo: 'Bot de trading', 'Tienda web con React', 'Scripts de trabajo'){NC}\n")
        print(f" • {YELLOW}ENTER{NC} : Iniciar Code Stack Sh (sin descripción si lo dejas vacío).")
        print(f" • {YELLOW}ESC{NC}   : Volver al explorador (cancelar apertura).\n")
        
        nueva_desc = prompt_text_with_esc(f"{BOLD}👉 Descripción:{NC} ")
        
        # Si canceló con ESC o Ctrl+C
        if nueva_desc is None:
            return False
        
        nueva_desc = nueva_desc.strip()
        if nueva_desc:
            add_to_history(target_path, nueva_desc)
        else:
            add_to_history(target_path)
    else:
        add_to_history(target_path)

    print(f"\n{GREEN}[✓] Iniciando estación de trabajo Code Stack Sh:{NC} {CYAN}{target_path}{NC}\n")
    os.execvp("start-vscode", ["start-vscode", target_path])
    return True

def edit_description_dialog(target_path, item_name):
    """Diálogo interactivo para modificar la descripción de una carpeta o proyecto."""
    data = load_data()
    target_path = normalize_path(target_path)
    current_desc = data.get("descriptions", {}).get(target_path, "")
    
    sys.stdout.write("\033[H\033[J")
    cols = min(get_term_cols(), 72)
    print(f"{BLUE}" + "═" * cols + f"{NC}")
    print(f"{GREEN}  📝 EDITAR DESCRIPCIÓN:{NC} {BOLD}{item_name}{NC}")
    print(f"{BLUE}" + "═" * cols + f"{NC}")
    print(f"Ruta: {CYAN}{target_path}{NC}")
    if current_desc:
        print(f"Descripción actual: {YELLOW}\"{current_desc}\"{NC}")
    else:
        print(f"Descripción actual: {GRAY}(Sin descripción){NC}")
    print(f"\nEscribe la nueva descripción:")
    print(f" • {YELLOW}ENTER{NC} : Guardar nueva descripción.")
    print(f" • {YELLOW}ESC{NC}   : Cancelar sin hacer cambios.\n")
    
    nueva = prompt_text_with_esc(f"{BOLD}👉 Nueva descripción:{NC} ")
    if nueva is None:
        return
    
    nueva = nueva.strip()
    if nueva:
        data["descriptions"][target_path] = nueva
        save_data(data)

def main():
    ensure_controlling_tty()
    check_edge_updates()
    try:
        broker = shutil.which("github-auth-broker")
        if broker:
            res = subprocess.run([broker, "enforce-gate"])
            if res.returncode != 0:
                sys.exit(1)
    except Exception:
        pass

    if '--switch' in sys.argv or '-s' in sys.argv:
        if is_current_device_leader():
            subprocess.run(["switch-identity"])
        else:
            print(f"{RED}[!] Función de conmutación exclusiva del dispositivo Líder.{NC}")
        sys.exit(0)

    # 1. Si se pasó una ruta directa como argumento, abrirla de inmediato
    # 0. Reproducir cinemática 3D Code Stack Sh (Opción A1) si no se usa flag rápida
    if "--no-intro" not in sys.argv and "--fast" not in sys.argv and not [a for a in sys.argv[1:] if not a.startswith('-')]:
        try:
            ascii_bin = shutil.which("code-stack-ascii")
            if not ascii_bin:
                cand = os.path.join(os.path.dirname(os.path.abspath(__file__)), "code-stack-ascii")
                if os.path.isfile(cand):
                    ascii_bin = cand
            if ascii_bin:
                subprocess.run([sys.executable, ascii_bin, "intro"], check=False)
        except Exception:
            pass

    # Módulo de animación y banners dinámicos (Opción A2)
    banner_helper = None
    banner_frame_idx = 0
    try:
        from importlib.machinery import SourceFileLoader
        cand = shutil.which("code-stack-ascii") or os.path.join(os.path.dirname(os.path.abspath(__file__)), "code-stack-ascii")
        if cand and os.path.isfile(cand):
            banner_helper = SourceFileLoader("code_stack_ascii", cand).load_module()
    except Exception:
        pass

    raw_args = [a for a in sys.argv[1:] if not a.startswith('-')]
    if raw_args:
        target = raw_args[0]
        if os.path.exists(target):
            launch_workspace_with_desc(os.path.abspath(target))
            return
        else:
            print(f"{RED}[!] La ruta no existe: {target}{NC}")
            sys.exit(1)

    # 2. Comprobar permisos de almacenamiento
    has_perm = check_storage_permission()
    raw_cwd = os.getcwd()
    current_dir = normalize_path(raw_cwd)

    # Si se ejecuta desde el HOME de Termux (~$) sin argumentos
    if current_dir == TERMUX_HOME or raw_cwd == TERMUX_HOME:
        if not has_perm:
            if request_storage_permission():
                current_dir = STORAGE_ROOT
            else:
                current_dir = TERMUX_HOME
        else:
            current_dir = STORAGE_ROOT

    active_tab = 0  # 0: Explorador, 1: Historial
    page_size = 10
    current_page = 0
    status_msg = ""
    search_filter = ""

    # Determinar posición inicial del cursor (en la primera carpeta si existen)
    initial_subdirs = get_subdirs(current_dir)
    cursor_idx = 2 if initial_subdirs else 0

    while True:
        cols = min(get_term_cols(), 72)
        div_line = f"{GRAY}" + "─" * cols + f"{NC}"
        data = load_data()
        descriptions = data.get("descriptions", {})
        history = data.get("history", [])

        # Preparar datos según pestaña activa
        if active_tab == 0:
            current_dir = normalize_path(current_dir)
            all_subdirs = get_subdirs(current_dir)
            
            # Aplicar filtro de búsqueda si está activo
            if search_filter:
                subdirs = [d for d in all_subdirs if search_filter.lower() in d.lower()]
            else:
                subdirs = all_subdirs

            total_dirs = len(subdirs)
            total_pages = max(1, ((total_dirs - 1) // page_size) + 1)
            if current_page >= total_pages:
                current_page = total_pages - 1
            if current_page < 0:
                current_page = 0

            start_idx = current_page * page_size
            end_idx = min(start_idx + page_size, total_dirs)
            visible_subdirs = subdirs[start_idx:end_idx]
            items_on_screen = 2 + len(visible_subdirs)

            if cursor_idx >= items_on_screen:
                cursor_idx = items_on_screen - 1
            if cursor_idx < 0:
                cursor_idx = 0
        else:
            total_hist = len(history)
            total_pages = max(1, ((total_hist - 1) // page_size) + 1)
            if current_page >= total_pages:
                current_page = total_pages - 1
            if current_page < 0:
                current_page = 0

            start_idx = current_page * page_size
            end_idx = min(start_idx + page_size, total_hist)
            visible_hist = history[start_idx:end_idx]
            items_on_screen = len(visible_hist)

            if cursor_idx >= items_on_screen:
                cursor_idx = max(0, items_on_screen - 1)
            if cursor_idx < 0:
                cursor_idx = 0

        # Dibujar pantalla limpia
        sys.stdout.write("\033[H\033[J")
        term_size = shutil.get_terminal_size((80, 24))
        # Banner animado dinámico (Opción A2) si hay espacio vertical suficiente (al menos 20 líneas)
        if banner_helper and term_size.lines >= 20 and cols >= 44:
            b_lines = banner_helper.get_formatted_banner_lines(banner_frame_idx, max_cols=cols, max_rows=term_size.lines)
            banner_frame_idx = (banner_frame_idx + 4) % 120
            for bl in b_lines:
                sys.stdout.write(bl + "\n")

        print(f"{BLUE}╔" + "═" * (cols - 2) + f"╗{NC}")
        active_file = os.path.expanduser("~/.config/termux-vscode/active_identity")
        active_user = "Miguel (Líder)"
        if os.path.exists(active_file):
            try:
                active_user = open(active_file).read().strip().split('_')[0]
            except Exception:
                pass
        title_text = f"CODE STACK SH  •  👑 {active_user.upper()}"
        print(f"{BLUE}║{WHITE}{BOLD} {title_text.center(cols - 4)} {BLUE}║{NC}")
        slogan_l1 = "«La libertad de programar sin necesidad de una PC: ingeniería portátil"
        slogan_l2 = "en una estación de trabajo completa, autónoma y lista para crear.»"
        print(f"{BLUE}║{YELLOW} {slogan_l1.center(cols - 4)} {BLUE}║{NC}")
        print(f"{BLUE}║{YELLOW} {slogan_l2.center(cols - 4)} {BLUE}║{NC}")
        print(f"{BLUE}╚" + "═" * (cols - 2) + f"╝{NC}")

        # Pestañas de navegación interactiva
        hist_badge = f" ({len(history)})" if history else ""
        if active_tab == 0:
            tab_exp = f"{HL_TAB} [ 📁 Explorador ] {NC}"
            tab_his = f"{GRAY}   [ 🕒 Historial{hist_badge} ]   {NC}"
        else:
            tab_exp = f"{GRAY}   [ 📁 Explorador ]   {NC}"
            tab_his = f"{HL_TAB} [ 🕒 Historial{hist_badge} ] {NC}"

        print(f" {tab_exp}  {tab_his}")
        print(div_line)

        # ------------------ CONTENIDO PESTAÑA 0: EXPLORADOR ------------------
        if active_tab == 0:
            is_storage_root = (current_dir == STORAGE_ROOT)
            print(f"{YELLOW}Ruta actual:{NC} {CYAN}{BOLD}{current_dir}{NC}")
            if search_filter:
                print(f" {YELLOW}🔍 Filtro activo:{NC} {BOLD}\"{search_filter}\"{NC} {GRAY}(coincidencias: {len(subdirs)}) • Pulsa [ / ] para limpiar{NC}")
            print(div_line)

            # Opción 0: Iniciar entorno
            if cursor_idx == 0:
                line_0 = " > [ 0] 🚀 [ INICIAR ENTORNO DE ESCRITORIO EN ESTA CARPETA ]".ljust(cols - 2)
                print(f"{HL_GREEN} {line_0}{NC}")
            else:
                print(f"{GREEN}   [ 0] 🚀 [ INICIAR ENTORNO DE ESCRITORIO EN ESTA CARPETA ]{NC}")
            print(f"        {GRAY}└─ Inicia la estación de trabajo Code Stack Sh en este directorio{NC}")

            # Opción 1: Subir de nivel
            if is_storage_root:
                up_text = "⬆️  [..] Raíz del teléfono (Límite del almacenamiento)"
                sub_text = "└─ Límite de carpetas alcanzado en Android"
            else:
                up_text = "⬆️  Subir un nivel (Volver atrás)"
                sub_text = "└─ Regresa a la carpeta superior"

            if cursor_idx == 1:
                line_1 = f" > [..] {up_text}".ljust(cols - 2)
                print(f"{HL_YELLOW} {line_1}{NC}")
            else:
                print(f"{YELLOW}   [..] {up_text}{NC}")
            print(f"        {GRAY}{sub_text}{NC}")
            print(div_line)

            # Listado de subcarpetas (1 a 10)
            if not visible_subdirs:
                if search_filter:
                    print(f"   {GRAY}(No se encontraron carpetas con: '{search_filter}'){NC}")
                    print(f"   {CYAN}👉 Pulsa [/] o ESC para limpiar la búsqueda.{NC}")
                else:
                    print(f"   {GRAY}(No hay subcarpetas en este directorio){NC}")
                    print(f"   {CYAN}👉 Pulsa [0] para iniciar el entorno en esta carpeta o [..] para volver.{NC}")
            else:
                name_w = 20
                for idx, dname in enumerate(visible_subdirs):
                    item_cursor = idx + 2
                    is_sel = (cursor_idx == item_cursor)
                    num = idx + 1
                    
                    full_p = os.path.join(current_dir, dname)
                    desc = descriptions.get(full_p, "")
                    is_git = os.path.isdir(os.path.join(full_p, '.git'))
                    git_tag = "[git] " if is_git else ""
                    
                    display_name = dname if len(dname) <= name_w else (dname[:name_w - 3] + "...")
                    padded_name = display_name.ljust(name_w)
                    rem = cols - 12 - name_w - len(git_tag) - 3

                    if is_sel:
                        desc_text = f"│ {desc}" if desc else "│"
                        raw_line = f" > [{num:2d}] 📁 {padded_name} {git_tag}{desc_text}".ljust(cols - 2)
                        print(f"{HL_CYAN} {raw_line}{NC}")
                    else:
                        git_color_tag = f"{GREEN}[git]{NC} " if is_git else ""
                        if desc:
                            display_desc = desc if len(desc) <= rem else (desc[:rem - 3] + "...")
                            desc_part = f"{GRAY}│{NC} {YELLOW}\"{display_desc}\"{NC}"
                        else:
                            desc_part = f"{GRAY}│ —{NC}"
                        print(f"   [{num:2d}] 📁 {padded_name} {git_color_tag}{desc_part}")

            print(div_line)

            # Paginación con flechas explícitas
            prev_s = "« [← / P] Anterior" if current_page > 0 else "                  "
            next_s = "[→ / N] Siguiente »" if current_page < (total_pages - 1) else "                  "
            rango_s = f"Carpetas {start_idx + 1}-{end_idx} de {total_dirs}" if total_dirs > 0 else "0 carpetas"
            print(f" {CYAN}{prev_s}{NC}    {BOLD}Pág {current_page + 1}/{total_pages} ({rango_s}){NC}    {CYAN}{next_s}{NC}")
            print(div_line)

            # Guía explicativa sin conflictos
            print(f"💡 {BOLD}Guía de navegación:{NC}")
            print(f" • {YELLOW}Flechas ↑/↓ o W/S{NC}   : Mover cursor       • {YELLOW}ENTER{NC}          : Entrar o Abrir")
            print(f" • {YELLOW}Flechas ←/→ o P/N{NC}   : Cambiar de página  • {YELLOW}ESC o Backspace{NC}: Subir un nivel")
            print(f" • {YELLOW}[1-9]{NC}               : Salto numérico     • {YELLOW}[ / ]{NC}          : Buscar / Filtrar")
            print(f" • {YELLOW}[E]{NC}                 : Poner descripción  • {YELLOW}TAB{NC}            : Ver Historial")
            c_hint = f"{BOLD}{WHITE}c{NC}{GRAY} Identidad  " if is_current_device_leader() else ""
            print(f"{GRAY}Teclado: {BOLD}{WHITE}enter{NC}{GRAY} Abrir  {BOLD}{WHITE}tab{NC}{GRAY} Historial  {c_hint}{BOLD}{WHITE}←/→{NC}{GRAY} Páginas  {BOLD}{WHITE}esc{NC}{GRAY} Volver  {BOLD}{WHITE}↑/↓{NC}{GRAY} Mover  {BOLD}{WHITE}/{NC}{GRAY} Buscar  {BOLD}{WHITE}q{NC}{GRAY} Salir{NC}")

        # ------------------ CONTENIDO PESTAÑA 1: HISTORIAL ------------------
        else:
            print(f"{BOLD}Proyectos abiertos anteriormente en este dispositivo:{NC}")
            print(div_line)

            if not history:
                print(f"   {GRAY}(No hay proyectos en el historial aún){NC}")
                print(f"   {CYAN}👉 Se guardarán automáticamente cuando abras carpetas en Code Stack Sh.{NC}")
                print(f"   {GRAY}Pulsa {BOLD}TAB{NC}{GRAY} para volver al Explorador de carpetas.{NC}")
            else:
                name_w = 20
                for idx, item in enumerate(visible_hist):
                    is_sel = (cursor_idx == idx)
                    num = idx + 1
                    p = item.get("path", "")
                    name = item.get("name", os.path.basename(p))
                    last_t = item.get("last_opened", "")
                    desc = descriptions.get(p, "")
                    
                    display_name = name if len(name) <= name_w else (name[:name_w - 3] + "...")
                    padded_name = display_name.ljust(name_w)
                    rem = cols - 10 - name_w - 3

                    if is_sel:
                        desc_text = f"│ {desc}" if desc else "│"
                        raw_line = f" > [{num:2d}] 📁 {padded_name} {desc_text}".ljust(cols - 2)
                        print(f"{HL_CYAN} {raw_line}{NC}")
                        short_p = p if len(p) <= cols - 12 else ("..." + p[-(cols - 15):])
                        time_str = f" • Última vez: {last_t}" if last_t else ""
                        print(f"        {GRAY}└─ {short_p}{time_str}{NC}")
                    else:
                        if desc:
                            display_desc = desc if len(desc) <= rem else (desc[:rem - 3] + "...")
                            desc_part = f"{GRAY}│{NC} {YELLOW}\"{display_desc}\"{NC}"
                        else:
                            desc_part = f"{GRAY}│ —{NC}"
                        print(f"   [{num:2d}] 📁 {padded_name} {desc_part}")

            print(div_line)

            # Paginación Historial
            prev_s = "« [← / P] Anterior" if current_page > 0 else "                  "
            next_s = "[→ / N] Siguiente »" if current_page < (total_pages - 1) else "                  "
            rango_s = f"Proyectos {start_idx + 1}-{end_idx} de {total_hist}" if total_hist > 0 else "0 proyectos"
            print(f" {CYAN}{prev_s}{NC}    {BOLD}Pág {current_page + 1}/{total_pages} ({rango_s}){NC}    {CYAN}{next_s}{NC}")
            print(div_line)

            # Guía Historial
            print(f"💡 {BOLD}Guía de Historial:{NC}")
            print(f" • {YELLOW}Flechas ↑/↓ o W/S + ENTER{NC}: Inicia la estación de trabajo en el proyecto seleccionado")
            print(f" • {YELLOW}Flechas ←/→ o P/N{NC}        : Cambiar página de proyectos")
            print(f" • {YELLOW}[1-{min(len(visible_hist), 10)}]{NC}              : Abre directo ese número")
            print(f" • {YELLOW}[E]{NC}                       : Editar la descripción de este proyecto")
            print(f" • {YELLOW}[D]{NC}                       : Eliminar este proyecto del historial")
            print(f" • {YELLOW}TAB o ESC o [0]{NC}          : Volver al Explorador de carpetas")
            print(f" • {YELLOW}[Q]{NC}                       : Salir sin abrir nada")
            c_hint = f"{BOLD}{WHITE}c{NC}{GRAY} Identidad  " if is_current_device_leader() else ""
            print(f"{GRAY}Teclado: {BOLD}{WHITE}enter{NC}{GRAY} Abrir  {BOLD}{WHITE}tab{NC}{GRAY} Explorador  {c_hint}{BOLD}{WHITE}←/→{NC}{GRAY} Páginas  {BOLD}{WHITE}e{NC}{GRAY} Editar  {BOLD}{WHITE}d{NC}{GRAY} Borrar  {BOLD}{WHITE}esc{NC}{GRAY} Volver  {BOLD}{WHITE}q{NC}{GRAY} Salir{NC}")

        if status_msg:
            print(f"\n{YELLOW}⚠️  {status_msg}{NC}")
            status_msg = ""

        sys.stdout.flush()

        # Captura de teclado robusta
        raw_key = get_key()
        action = classify_key(raw_key)

        # Acciones Globales
        if action == 'TAB':
            active_tab = 1 - active_tab
            current_page = 0
            if active_tab == 0:
                subdirs = get_subdirs(current_dir)
                cursor_idx = 2 if subdirs else 0
            else:
                cursor_idx = 0
            status_msg = ""
            continue

        if action == 'QUIT':
            print(f"\n{YELLOW}[*] Cancelado. Saliendo sin iniciar el entorno.{NC}\n")
            sys.exit(0)

        if action == 'SWITCH_IDENTITY':
            if is_current_device_leader():
                subprocess.run(["switch-identity"])
                status_msg = "Identidad actualizada."
            continue

        # ------------------ EVENTOS: EXPLORADOR ------------------
        if active_tab == 0:
            if action == 'UP':
                cursor_idx -= 1
                if cursor_idx < 0:
                    if current_page > 0:
                        current_page -= 1
                        cursor_idx = items_on_screen - 1
                    else:
                        cursor_idx = 0

            elif action == 'DOWN':
                cursor_idx += 1
                if cursor_idx >= items_on_screen:
                    if current_page < total_pages - 1:
                        current_page += 1
                        cursor_idx = 2
                    else:
                        cursor_idx = items_on_screen - 1

            elif action == 'BACK':
                # Si hay un filtro de búsqueda activo, ESC lo limpia primero
                if search_filter:
                    search_filter = ""
                    current_page = 0
                    subdirs_now = get_subdirs(current_dir)
                    cursor_idx = 2 if subdirs_now else 0
                    status_msg = "Filtro de búsqueda limpiado."
                elif is_storage_root:
                    status_msg = "Límite alcanzado: Raíz del teléfono (/storage/emulated/0)."
                else:
                    parent = os.path.dirname(os.path.abspath(current_dir))
                    current_dir = normalize_path(parent)
                    search_filter = ""
                    subdirs_now = get_subdirs(current_dir)
                    cursor_idx = 2 if subdirs_now else 0
                    current_page = 0

            elif action == 'ENTER':
                if cursor_idx == 0:
                    if launch_workspace_with_desc(current_dir):
                        return
                    else:
                        status_msg = "Apertura cancelada."
                elif cursor_idx == 1:
                    if is_storage_root:
                        status_msg = "Límite alcanzado: No se puede subir más en Android."
                    else:
                        parent = os.path.dirname(os.path.abspath(current_dir))
                        current_dir = normalize_path(parent)
                        search_filter = ""
                        subdirs_now = get_subdirs(current_dir)
                        cursor_idx = 2 if subdirs_now else 0
                        current_page = 0
                else:
                    folder_selected = visible_subdirs[cursor_idx - 2]
                    current_dir = normalize_path(os.path.join(current_dir, folder_selected))
                    search_filter = ""
                    subdirs_now = get_subdirs(current_dir)
                    cursor_idx = 2 if subdirs_now else 0
                    current_page = 0

            # Flecha Derecha o N: Siguiente página de carpetas
            elif action == 'NEXT':
                if current_page < total_pages - 1:
                    current_page += 1
                    cursor_idx = 2
                    status_msg = f"Página {current_page + 1} de {total_pages}"
                else:
                    status_msg = "Ya estás en la última página."

            # Flecha Izquierda o P: Página anterior de carpetas
            elif action == 'PREV':
                if current_page > 0:
                    current_page -= 1
                    cursor_idx = 2
                    status_msg = f"Página {current_page + 1} de {total_pages}"
                else:
                    status_msg = "Ya estás en la primera página."

            elif action == 'SEARCH':
                sys.stdout.write("\033[H\033[J")
                cols = min(get_term_cols(), 72)
                print(f"{BLUE}" + "═" * cols + f"{NC}")
                print(f"{GREEN}  🔍 BUSCAR / FILTRAR CARPETAS{NC}")
                print(f"{BLUE}" + "═" * cols + f"{NC}")
                print(f"Ruta actual: {CYAN}{current_dir}{NC}\n")
                if search_filter:
                    print(f"Filtro actual: {YELLOW}\"{search_filter}\"{NC}")
                print("Escribe el nombre de la carpeta a buscar:")
                print(f" • {YELLOW}ENTER{NC} : Aplicar filtro (o ENTER vacío para quitarlo).")
                print(f" • {YELLOW}ESC{NC}   : Cancelar y volver.\n")
                q = prompt_text_with_esc(f"{BOLD}🔍 Buscar:{NC} ")
                if q is not None:
                    search_filter = q.strip()
                    current_page = 0
                    all_sub = get_subdirs(current_dir)
                    matching = [d for d in all_sub if search_filter.lower() in d.lower()] if search_filter else all_sub
                    cursor_idx = 2 if matching else 0
                    if search_filter:
                        status_msg = f"Filtro aplicado: '{search_filter}' ({len(matching)} carpetas)."
                    else:
                        status_msg = "Filtro eliminado (mostrando todas las carpetas)."

            elif action == 'EDIT':
                if cursor_idx >= 2:
                    folder_selected = visible_subdirs[cursor_idx - 2]
                    target_edit = os.path.join(current_dir, folder_selected)
                    edit_description_dialog(target_edit, folder_selected)
                elif cursor_idx == 0:
                    edit_description_dialog(current_dir, os.path.basename(current_dir) or current_dir)

            elif action.startswith('DIGIT_'):
                val = int(action.split('_')[1])
                if val == 0:
                    if launch_workspace_with_desc(current_dir):
                        return
                    else:
                        status_msg = "Apertura cancelada."
                elif 1 <= val <= len(visible_subdirs):
                    folder_selected = visible_subdirs[val - 1]
                    current_dir = normalize_path(os.path.join(current_dir, folder_selected))
                    search_filter = ""
                    subdirs_now = get_subdirs(current_dir)
                    cursor_idx = 2 if subdirs_now else 0
                    current_page = 0

        # ------------------ EVENTOS: HISTORIAL ------------------
        else:
            if action == 'UP':
                cursor_idx = max(0, cursor_idx - 1)

            elif action == 'DOWN':
                cursor_idx = min(len(visible_hist) - 1, cursor_idx + 1)

            elif action == 'BACK':
                active_tab = 0
                subdirs_now = get_subdirs(current_dir)
                cursor_idx = 2 if subdirs_now else 0
                current_page = 0

            elif action == 'ENTER':
                if visible_hist:
                    target = visible_hist[cursor_idx].get("path")
                    if os.path.exists(target):
                        if launch_workspace_with_desc(target):
                            return
                        else:
                            status_msg = "Apertura cancelada."
                    else:
                        status_msg = f"La carpeta ya no existe: {target}"

            elif action == 'NEXT':
                if current_page < total_pages - 1:
                    current_page += 1
                    cursor_idx = 0
                    status_msg = f"Página {current_page + 1} de {total_pages}"
                else:
                    status_msg = "Ya estás en la última página del historial."

            elif action == 'PREV':
                if current_page > 0:
                    current_page -= 1
                    cursor_idx = 0
                    status_msg = f"Página {current_page + 1} de {total_pages}"
                else:
                    status_msg = "Ya estás en la primera página del historial."

            elif action == 'EDIT':
                if visible_hist:
                    item = visible_hist[cursor_idx]
                    edit_description_dialog(item.get("path"), item.get("name"))

            elif action == 'DELETE':
                if visible_hist:
                    item = visible_hist[cursor_idx]
                    p_del = item.get("path")
                    name_del = item.get("name")
                    sys.stdout.write("\033[H\033[J")
                    print(f"{YELLOW}¿Eliminar '{name_del}' del historial? [s/N]: {NC}", end="")
                    try:
                        resp = input().strip().lower()
                    except Exception:
                        resp = "n"
                    if resp in ('s', 'si', 'y', 'yes'):
                        data = load_data()
                        data["history"] = [h for h in data.get("history", []) if h.get("path") != p_del]
                        save_data(data)
                        status_msg = f"Proyecto '{name_del}' eliminado del historial."
                        cursor_idx = max(0, cursor_idx - 1)

            elif action.startswith('DIGIT_'):
                val = int(action.split('_')[1])
                if val == 0:
                    active_tab = 0
                    subdirs_now = get_subdirs(current_dir)
                    cursor_idx = 2 if subdirs_now else 0
                    current_page = 0
                elif 1 <= val <= len(visible_hist):
                    target = visible_hist[val - 1].get("path")
                    if os.path.exists(target):
                        if launch_workspace_with_desc(target):
                            return
                        else:
                            status_msg = "Apertura cancelada."
                    else:
                        status_msg = f"La carpeta ya no existe: {target}"

if __name__ == "__main__":
    try:
        # Disparo oportunista Serverless: vaciar búfer offline cifrado y sincronizar (<30ms)
        try:
            subprocess.Popen(["watcher-sync", "--once"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass
        main()
    except KeyboardInterrupt:
        print("\nSaliendo...")
        sys.exit(0)
```

### Archivo: `Programas/menu-instalador.sh`

```bash
#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# menu-instalador.sh: Centro de Instalación y Desinstalación de Software
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
GRAY='\033[0;90m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALLED_REGISTRY="$HOME/.config/termux-software-center/installed.list"
mkdir -p "$(dirname "$INSTALLED_REGISTRY")" "$HOME/Desktop"

# ------------------------------------------------------------------------------
# Ejecutor de instaladores con Split-Screen y animación ASCII Matrix en tiempo real
# ------------------------------------------------------------------------------
run_installer_script() {
    local target_script="$1"
    local target_name="$2"
    local ascii_runner=""
    if command -v code-stack-ascii >/dev/null 2>&1; then
        ascii_runner="$(command -v code-stack-ascii)"
    elif [ -f "$REPO_DIR/bin/code-stack-ascii" ]; then
        ascii_runner="$REPO_DIR/bin/code-stack-ascii"
    fi

    if [ -n "$ascii_runner" ]; then
        python3 "$ascii_runner" run --title "$target_name" -- bash "$target_script"
    else
        bash "$target_script"
    fi
}

# ------------------------------------------------------------------------------
# Lector de entrada con soporte nativo para la tecla BORRAR (Backspace) como ATRÁS
# Envía los mensajes visuales a stderr para que command substitution $(...) capture
# únicamente la opción seleccionada.
# ------------------------------------------------------------------------------
read_menu_input() {
    local prompt="$1"
    local input=""
    local char=""

    echo -ne "$prompt" >&2

    # Si la entrada no es una terminal interactiva (ej. scripts o pipes)
    if [ ! -t 0 ]; then
        read -r input || return 0
        echo "$input"
        return 0
    fi

    local old_stty
    old_stty=$(stty -g 2>/dev/null || true)
    # Desactivar modo canónico y eco para capturar la tecla borrar en tiempo real
    stty -icanon -echo min 1 time 0 2>/dev/null || true

    trap 'stty "$old_stty" 2>/dev/null; exit 130' INT TERM

    while IFS= read -r -s -n 1 char; do
        # Tecla ENTER (\r = 13, \n = 10, o vacío)
        if [ -z "$char" ] || [ "$char" = $'\r' ] || [ "$char" = $'\n' ]; then
            stty "$old_stty" 2>/dev/null || true
            trap - INT TERM
            echo "" >&2
            echo "$input"
            return 0
        fi

        # Tecla BORRAR del teclado (Backspace: ASCII 127 o ASCII 8)
        if [ "$char" = $'\x7f' ] || [ "$char" = $'\b' ]; then
            if [ -z "$input" ]; then
                # Si el campo está vacío y presiona borrar -> ECHARSE PARA ATRÁS
                stty "$old_stty" 2>/dev/null || true
                trap - INT TERM
                echo "" >&2
                echo "__BACK__"
                return 0
            else
                # Borrar el último carácter en pantalla y memoria
                input="${input%?}"
                echo -ne "\b \b" >&2
            fi
            continue
        fi

        # Tecla ESC (\x1b)
        if [ "$char" = $'\x1b' ]; then
            local extra=""
            read -r -s -n 2 -t 0.05 extra 2>/dev/null || true
            if [ -z "$extra" ]; then
                # Tecla ESC solitaria -> ATRÁS
                stty "$old_stty" 2>/dev/null || true
                trap - INT TERM
                echo "" >&2
                echo "__BACK__"
                return 0
            fi
            # Ignorar secuencias de escape de flechas
            continue
        fi

        # Ctrl+C (\x03) o Ctrl+D (\x04) -> ATRÁS
        if [ "$char" = $'\x03' ] || [ "$char" = $'\x04' ]; then
            stty "$old_stty" 2>/dev/null || true
            trap - INT TERM
            echo "" >&2
            echo "__BACK__"
            return 0
        fi

        # Caracteres normales imprimibles
        if [[ "$char" =~ [[:print:]] ]]; then
            input+="$char"
            echo -n "$char" >&2
        fi
    done

    stty "$old_stty" 2>/dev/null || true
    trap - INT TERM
    echo "" >&2
    echo "$input"
    return 0
}

pause_menu() {
    local prompt="${1:-Presiona ENTER o borrar para continuar...}"
    read_menu_input "${YELLOW}$prompt${NC}" >/dev/null
}

# ------------------------------------------------------------------------------
# Lector ultrarrápido de metadatos (# Nombre y # Tagline) sin procesos hijos
# ------------------------------------------------------------------------------
get_program_meta() {
    local file="$1"
    _META_NAME=""
    _META_TAGLINE=""
    local count=0
    while IFS= read -r line || [ -n "$line" ]; do
        ((count++))
        case "$line" in
            "# Nombre:"*)
                _META_NAME="${line#\# Nombre:}"
                _META_NAME="${_META_NAME#"${_META_NAME%%[![:space:]]*}"}"
                ;;
            "# Tagline:"*)
                _META_TAGLINE="${line#\# Tagline:}"
                _META_TAGLINE="${_META_TAGLINE#"${_META_TAGLINE%%[![:space:]]*}"}"
                ;;
        esac
        if [ -n "$_META_NAME" ] && [ -n "$_META_TAGLINE" ]; then
            break
        fi
        [ "$count" -ge 25 ] && break
    done < "$file"
    # Limpiar posibles paréntesis sobrantes en los extremos
    _META_TAGLINE="${_META_TAGLINE#\(}"
    _META_TAGLINE="${_META_TAGLINE%\)}"
}

# ------------------------------------------------------------------------------
# Caché de búsqueda ultra-rápida de programas instalados
# ------------------------------------------------------------------------------
declare -A INSTALLED_BIN_MAP
declare -A INSTALLED_DESKTOP_MAP

refresh_installed_cache() {
    INSTALLED_BIN_MAP=()
    INSTALLED_DESKTOP_MAP=()

    local b d
    for b in "$PREFIX/bin"/*; do
        [ -e "$b" ] && INSTALLED_BIN_MAP["${b##*/}"]=1
    done

    for d in "$PREFIX/share/applications"/*.desktop \
             "$HOME/.local/share/applications"/*.desktop \
             "$HOME/Desktop"/*.desktop; do
        [ -f "$d" ] && INSTALLED_DESKTOP_MAP["${d##*/}"]=1
    done
}

is_program_installed() {
    local pscript="$1"
    local fname="${pscript##*/}"
    local slug="${fname#instalar-}"
    slug="${slug%.sh}"

    # Casos especiales
    if [ "$slug" = "vscode" ]; then
        if [ -n "${INSTALLED_BIN_MAP["code-oss"]}" ] || \
           [ -n "${INSTALLED_DESKTOP_MAP["code-oss.desktop"]}" ] || \
           [ -n "${INSTALLED_DESKTOP_MAP["vscode.desktop"]}" ]; then
            return 0
        fi
    fi

    if [ "$slug" = "zen-browser" ]; then
        if [ -n "${INSTALLED_BIN_MAP["zen-browser"]}" ] || \
           [ -n "${INSTALLED_DESKTOP_MAP["zen-browser.desktop"]}" ]; then
            return 0
        fi
    fi

    if [ "$slug" = "openbox" ]; then
        if [ -n "${INSTALLED_BIN_MAP["openbox"]}" ] || \
           [ -n "${INSTALLED_DESKTOP_MAP["openbox.desktop"]}" ] || \
           command -v openbox >/dev/null 2>&1; then
            return 0
        fi
    fi

    # Comprobación por binario
    if [ -n "${INSTALLED_BIN_MAP["$slug"]}" ]; then
        return 0
    fi
    local slug_clean="${slug//-/}"
    if [ -n "${INSTALLED_BIN_MAP["$slug_clean"]}" ]; then
        return 0
    fi

    # Comprobación por archivo .desktop
    if [ -n "${INSTALLED_DESKTOP_MAP["${slug}.desktop"]}" ] || \
       [ -n "${INSTALLED_DESKTOP_MAP["${slug//-/_}.desktop"]}" ]; then
        return 0
    fi

    # Registro persistente
    if [ -f "$INSTALLED_REGISTRY" ] && grep -Fxq "$slug" "$INSTALLED_REGISTRY" 2>/dev/null; then
        return 0
    fi

    return 1
}

# ------------------------------------------------------------------------------
# Sincronizar lanzador en el Escritorio interactivo (~/Desktop) estilo PC
# ------------------------------------------------------------------------------
sync_desktop_launcher() {
    local slug="$1"
    mkdir -p "$HOME/Desktop" "$HOME/.local/share/applications"

    # Descargar / asegurar icono oficial bajo demanda si aún no existe
    command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "$slug" >/dev/null 2>&1 || true

    local desktop_found=""
    for d in "$PREFIX/share/applications/${slug}.desktop" \
             "$HOME/.local/share/applications/${slug}.desktop" \
             "$PREFIX/share/applications/${slug//-/_}.desktop"; do
        if [ -f "$d" ]; then
            desktop_found="$d"
            break
        fi
    done

    if [ "$slug" = "vscode" ] && [ -f "$PREFIX/share/applications/code-oss.desktop" ]; then
        desktop_found="$PREFIX/share/applications/code-oss.desktop"
    fi

    if [ -n "$desktop_found" ]; then
        cp -f "$desktop_found" "$HOME/Desktop/" 2>/dev/null || true
        chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true
    fi

    command -v openbox >/dev/null 2>&1 && openbox --reconfigure >/dev/null 2>&1 || true
    command -v pcmanfm >/dev/null 2>&1 && pcmanfm --reconfigure >/dev/null 2>&1 || true
}

remove_desktop_launcher() {
    local slug="$1"
    rm -f "$HOME/Desktop/${slug}.desktop" \
          "$HOME/Desktop/${slug//-/_}.desktop" \
          "$HOME/.local/share/applications/${slug}.desktop" \
          "$PREFIX/share/applications/${slug}.desktop" 2>/dev/null || true

    if [ "$slug" = "vscode" ]; then
        rm -f "$HOME/Desktop/code-oss.desktop" "$HOME/Desktop/vscode.desktop" \
              "$HOME/.local/share/applications/code-oss.desktop" \
              "$HOME/.local/share/applications/vscode.desktop" 2>/dev/null || true
    fi
    if [ "$slug" = "zen-browser" ]; then
        rm -f "$HOME/Desktop/zen-browser.desktop" "$HOME/Desktop/userapp-Zen-"*.desktop \
              "$HOME/.local/share/applications/zen-browser.desktop" 2>/dev/null || true
    fi

    # Eliminar el icono oficial de disco para no ocupar espacio
    if [ "$slug" != "vscode" ] && [ "$slug" != "zen-browser" ]; then
        command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon --clean "$slug" >/dev/null 2>&1 || true
        rm -f "/data/data/com.termux/files/usr/share/pixmaps/${slug}.png" \
              "/data/data/com.termux/files/usr/share/pixmaps/${slug}.svg" 2>/dev/null || true
    fi

    command -v openbox >/dev/null 2>&1 && openbox --reconfigure >/dev/null 2>&1 || true
    command -v pcmanfm >/dev/null 2>&1 && pcmanfm --reconfigure >/dev/null 2>&1 || true
}

# ------------------------------------------------------------------------------
# Respaldo Criptográfico Silencioso (Cero mención de subidas o GitHub)
# ------------------------------------------------------------------------------
do_silent_backup() {
    # Respaldo seguro a través de vault-manager (cifrado AES-256 PBKDF2, sin exponer perfiles en texto plano en Git)
    if command -v vault-manager >/dev/null 2>&1; then
        vault-manager pack >/dev/null 2>&1 || true
    elif [ -f "$REPO_DIR/bin/vault-manager" ]; then
        bash "$REPO_DIR/bin/vault-manager" pack >/dev/null 2>&1 || true
    fi
}

# ------------------------------------------------------------------------------
# Diálogo unificado de Desinstalación (Borrar o Conservar credenciales)
# ------------------------------------------------------------------------------
prompt_and_uninstall() {
    local target_script="$1"
    local fname="${target_script##*/}"
    local slug="${fname#instalar-}"
    slug="${slug%.sh}"

    get_program_meta "$target_script"
    local pname="$_META_NAME"
    [ -z "$pname" ] && pname="$slug"

    # Protección de componentes del entorno de ventanas
    if [ "$slug" = "openbox" ] || [ "$slug" = "tint2" ]; then
        echo ""
        echo -e "${RED}[!] AVISO: ${BOLD}${pname}${NC}${RED} es el gestor gráfico principal.${NC}"
        echo -e "${YELLOW}Desinstalarlo desactivará la interfaz visual de escritorio.${NC}"
        echo ""
        echo -e "  [${YELLOW}1${NC}] Cancelar y volver atrás ${GRAY}(Recomendado)${NC}"
        echo -e "  [${YELLOW}2${NC}] Continuar de todos modos"
        echo ""
        local confirm_crit
        confirm_crit=$(read_menu_input "${BOLD}👉 Opción [1/2]: ${NC}")
        if [ "$confirm_crit" != "2" ]; then
            return 0
        fi
    fi

    while true; do
        clear
        echo -e "${BLUE}======================================================${NC}"
        echo -e "${YELLOW}  ⚠️ OPCIONES DE DESINSTALACIÓN: ${BOLD}${pname}${NC}"
        echo -e "${BLUE}======================================================${NC}"
        echo ""
        echo -e "¿Cómo deseas proceder con la desinstalación?"
        echo ""
        echo -e "  [${YELLOW}1${NC}] 🗑️ ${BOLD}Desinstalar aplicación CONSERVANDO credenciales y datos${NC}"
        echo -e "      ${GRAY}└─ Tus cuentas, preferencias y tokens quedarán guardados.${NC}"
        echo -e "      ${GRAY}   Si lo vuelves a instalar en el futuro, iniciará con todo listo.${NC}"
        echo ""
        echo -e "  [${YELLOW}2${NC}] 💥 ${RED}${BOLD}Desinstalar aplicación y BORRAR TODOS los datos${NC}"
        echo -e "      ${GRAY}└─ Se asegura un respaldo previo y luego se purgan por${NC}"
        echo -e "      ${GRAY}   completo carpetas de usuario, configuraciones y tokens.${NC}"
        echo ""
        echo -e "  [${YELLOW}0${NC}] ↩️ Cancelar y volver atrás ${GRAY}(o pulsa borrar)${NC}"
        echo ""
        local opt_mode
        opt_mode=$(read_menu_input "${BOLD}👉 Selecciona una opción [1/2/0]: ${NC}")

        if [ "$opt_mode" = "0" ] || [ "$opt_mode" = "__BACK__" ] || [ "$opt_mode" = "b" ] || [ "$opt_mode" = "q" ]; then
            return 0
        fi

        if [ -z "$opt_mode" ]; then
            continue
        fi

        if [ "$opt_mode" = "1" ] || [ "$opt_mode" = "2" ]; then
            local delete_data=0
            [ "$opt_mode" = "2" ] && delete_data=1

            echo ""
            echo -e "${BLUE}======================================================${NC}"
            echo -e "${YELLOW}  🗑️ Desinstalando: ${BOLD}${pname}${NC}"
            echo -e "${BLUE}======================================================${NC}"
            echo ""

            if [ "$delete_data" = "1" ]; then
                # Respaldo silencioso de seguridad antes de borrar
                do_silent_backup

                echo -e "${CYAN}[*] Purgando configuraciones, cachés y datos locales...${NC}"
                if [ "$slug" = "vscode" ]; then
                    rm -rf "$HOME/.config/Code - OSS" "$HOME/.vscode-oss" "$HOME/.config/Code" 2>/dev/null || true
                elif [ "$slug" = "zen-browser" ]; then
                    rm -rf "$HOME/.config/zen" "$HOME/.zen" "$HOME/.cache/zen" 2>/dev/null || true
                else
                    rm -rf "$HOME/.config/$slug" "$HOME/.$slug" "$HOME/.local/share/$slug" "$HOME/.cache/$slug" 2>/dev/null || true
                fi
            else
                echo -e "${GREEN}[*] Conservando credenciales, configuraciones y datos de usuario intactos.${NC}"
            fi

            # Detener procesos
            echo -e "${CYAN}[*] Deteniendo procesos de $pname...${NC}"
            pkill -9 -f "$slug" 2>/dev/null || true
            if [ "$slug" = "vscode" ]; then
                pkill -9 -f "code-oss" 2>/dev/null || true
            fi

            # Eliminar binarios
            echo -e "${CYAN}[*] Eliminando ejecutables de $PREFIX/bin...${NC}"
            rm -f "$PREFIX/bin/$slug" "$PREFIX/bin/${slug//-/}" 2>/dev/null || true
            if [ "$slug" = "vscode" ]; then
                rm -f "$PREFIX/bin/code-oss" "$PREFIX/bin/vscode" 2>/dev/null || true
            fi

            # Retirar lanzador del escritorio
            echo -e "${CYAN}[*] Retirando iconos del escritorio y menús...${NC}"
            remove_desktop_launcher "$slug"

            # Desinstalar paquetes si aplica
            echo -e "${CYAN}[*] Verificando paquetes del sistema...${NC}"
            if [ "$slug" = "vscode" ]; then
                pkg uninstall -y code-oss >/dev/null 2>&1 || true
            elif [ "$slug" = "zen-browser" ]; then
                pkg uninstall -y zen-browser >/dev/null 2>&1 || true
            else
                pkg uninstall -y "$slug" >/dev/null 2>&1 || true
            fi

            # Limpiar registro persistente
            if [ -f "$INSTALLED_REGISTRY" ]; then
                grep -Fvx "$slug" "$INSTALLED_REGISTRY" > "$INSTALLED_REGISTRY.tmp" 2>/dev/null || true
                mv "$INSTALLED_REGISTRY.tmp" "$INSTALLED_REGISTRY" 2>/dev/null || true
            fi

            echo ""
            echo -e "${GREEN}======================================================${NC}"
            if [ "$delete_data" = "1" ]; then
                echo -e "${GREEN}  ✔ ${pname} y todos sus datos han sido eliminados.${NC}"
            else
                echo -e "${GREEN}  ✔ ${pname} desinstalado (datos y credenciales conservados).${NC}"
            fi
            echo -e "${GREEN}======================================================${NC}"
            echo ""

            pause_menu "Presiona ENTER o borrar para continuar..."
            return 0
        fi
    done
}

# ------------------------------------------------------------------------------
# MENÚ DE DESINSTALACIÓN (Solo muestra lo que está instalado)
# ------------------------------------------------------------------------------
menu_desinstalar() {
    while true; do
        refresh_installed_cache

        local INSTALLED_LIST=()
        for p in "$SCRIPT_DIR"/*/instalar-*.sh; do
            [ -f "$p" ] || continue
            if is_program_installed "$p"; then
                INSTALLED_LIST+=("$p")
            fi
        done

        clear
        echo -e "${BLUE}======================================================${NC}"
        echo -e "${RED}  🗑️ DESINSTALADOR DE PROGRAMAS (SISTEMA LOCAL)${NC}"
        echo -e "${BLUE}======================================================${NC}"
        echo ""

        if [ "${#INSTALLED_LIST[@]}" -eq 0 ]; then
            echo -e "${YELLOW}  ℹ️ No se detectaron programas instalados actualmente.${NC}"
            echo ""
            echo -e "  [${YELLOW}0${NC}] ↩️ Volver al menú principal ${GRAY}(o pulsa borrar)${NC}"
            echo ""
            pause_menu "Pulsa ENTER o borrar para volver..."
            return 0
        fi

        echo -e "Programas detectados en el sistema (${GREEN}${#INSTALLED_LIST[@]} instalados${NC}):"
        echo ""
        local k=1
        for p in "${INSTALLED_LIST[@]}"; do
            get_program_meta "$p"
            local pname="$_META_NAME"
            local ptagline="$_META_TAGLINE"
            if [ -z "$pname" ]; then
                local fname="${p##*/}"
                local slug="${fname#instalar-}"
                pname="${slug%.sh}"
            fi

            if [ -n "$ptagline" ]; then
                echo -e "  [${YELLOW}$k${NC}] 📦 ${BOLD}${pname}${NC} ${CYAN}(${ptagline})${NC}"
            else
                echo -e "  [${YELLOW}$k${NC}] 📦 ${BOLD}${pname}${NC}"
            fi
            ((k++))
        done

        echo ""
        echo -e "  [${YELLOW}0${NC}] ↩️ Volver al menú principal ${GRAY}(o pulsa borrar)${NC}"
        echo ""
        local opt_sel
        opt_sel=$(read_menu_input "${BOLD}👉 Selecciona un programa para desinstalar: ${NC}")

        if [ "$opt_sel" = "0" ] || [ "$opt_sel" = "__BACK__" ] || [ "$opt_sel" = "b" ] || [ "$opt_sel" = "q" ]; then
            return 0
        fi

        if [ -z "$opt_sel" ]; then
            continue
        fi

        if [[ "$opt_sel" =~ ^[0-9]+$ ]] && [ "$opt_sel" -ge 1 ] && [ "$opt_sel" -le "${#INSTALLED_LIST[@]}" ]; then
            local target_p="${INSTALLED_LIST[$((opt_sel-1))]}"
            prompt_and_uninstall "$target_p"
        fi
    done
}

# ------------------------------------------------------------------------------
# MENÚ DE BÚSQUEDA RÁPIDA (Bucle interactivo con soporte de atrás)
# ------------------------------------------------------------------------------
menu_buscar() {
    while true; do
        clear
        echo -e "${BLUE}======================================================${NC}"
        echo -e "${GREEN}  🔍 BÚSQUEDA GLOBAL DE PROGRAMAS (+110 DISPONIBLES)${NC}"
        echo -e "${BLUE}======================================================${NC}"
        echo ""
        echo -e "Escribe el nombre o tema a buscar ${GRAY}(o '0' / borrar para volver al menú)${NC}:"
        echo ""
        local query
        query=$(read_menu_input "${BOLD}👉 Buscar: ${NC}")

        if [ -z "$query" ] || [ "$query" = "__BACK__" ] || [ "$query" = "0" ] || [ "$query" = "q" ] || [ "$query" = "Q" ]; then
            return 0
        fi

        echo ""
        echo -e "${CYAN}[*] Buscando resultados para: '$query'...${NC}"
        echo ""

        refresh_installed_cache

        local MATCHES=()
        declare -A MATCH_MAP=()
        while IFS= read -r f; do
            [ -n "$f" ] && MATCH_MAP["$f"]=1
        done < <(grep -l -i "$query" "$SCRIPT_DIR"/*/instalar-*.sh 2>/dev/null || true)

        for p in "$SCRIPT_DIR"/*/instalar-*.sh; do
            [ -f "$p" ] || continue
            if [ -n "${MATCH_MAP["$p"]}" ] || [[ "${p##*/}" =~ $query ]]; then
                MATCHES+=("$p")
            fi
        done

        if [ "${#MATCHES[@]}" -eq 0 ]; then
            echo -e "${YELLOW}  ℹ️ No se encontraron coincidencias para: '$query'.${NC}"
            echo ""
            pause_menu "Presiona ENTER o borrar para buscar de nuevo..."
            continue
        fi

        while true; do
            clear
            echo -e "${BLUE}======================================================${NC}"
            echo -e "${GREEN}  🔍 RESULTADOS PARA: '$query' (${#MATCHES[@]} coincidencias)${NC}"
            echo -e "${BLUE}======================================================${NC}"
            echo ""

            local m=1
            for p in "${MATCHES[@]}"; do
                get_program_meta "$p"
                local pname="$_META_NAME"
                local ptagline="$_META_TAGLINE"
                local inst_tag=""
                if [ -z "$pname" ]; then
                    local fname="${p##*/}"
                    local s="${fname#instalar-}"
                    pname="${s%.sh}"
                fi

                if is_program_installed "$p"; then
                    inst_tag=" ${GREEN}[✓ INSTALADO]${NC}"
                fi

                if [ -n "$ptagline" ]; then
                    echo -e "  [${YELLOW}$m${NC}] 📦 ${BOLD}${pname}${NC} ${CYAN}(${ptagline})${NC}${inst_tag}"
                else
                    echo -e "  [${YELLOW}$m${NC}] 📦 ${BOLD}${pname}${NC}${inst_tag}"
                fi
                ((m++))
            done

            echo ""
            echo -e "  [${YELLOW}0${NC}] ↩️ Volver a buscar ${GRAY}(o pulsa borrar)${NC}"
            echo ""
            local opt_b
            opt_b=$(read_menu_input "${BOLD}👉 Selecciona un número para gestionar/instalar: ${NC}")

            if [ "$opt_b" = "0" ] || [ "$opt_b" = "__BACK__" ] || [ "$opt_b" = "b" ] || [ "$opt_b" = "q" ] || [ -z "$opt_b" ]; then
                break
            fi

            if [[ "$opt_b" =~ ^[0-9]+$ ]] && [ "$opt_b" -ge 1 ] && [ "$opt_b" -le "${#MATCHES[@]}" ]; then
                local target_script="${MATCHES[$((opt_b-1))]}"
                local fname="${target_script##*/}"
                local slug="${fname#instalar-}"
                slug="${slug%.sh}"

                get_program_meta "$target_script"
                local target_name="$_META_NAME"
                [ -z "$target_name" ] && target_name="$slug"

                if is_program_installed "$target_script"; then
                    echo ""
                    echo -e "${YELLOW}[!] ${target_name} ya está instalado en este sistema.${NC}"
                    echo -e "  [${YELLOW}1${NC}] ⚡ Reinstalar / Actualizar"
                    echo -e "  [${YELLOW}2${NC}] 🗑️ Desinstalar programa"
                    echo -e "  [${YELLOW}0${NC}] ↩️ Volver atrás ${GRAY}(o pulsa borrar)${NC}"
                    echo ""
                    local sub_opt
                    sub_opt=$(read_menu_input "${BOLD}👉 Opción [1/2/0]: ${NC}")
                    if [ "$sub_opt" = "1" ]; then
                        echo ""
                        echo -e "${CYAN}⚡ Reinstalando: ${target_name}...${NC}"
                        echo ""
                        run_installer_script "$target_script" "$target_name"
                        sync_desktop_launcher "$slug"
                        echo "$slug" >> "$INSTALLED_REGISTRY" 2>/dev/null || true
                        pause_menu "Presiona ENTER o borrar para continuar..."
                    elif [ "$sub_opt" = "2" ]; then
                        prompt_and_uninstall "$target_script"
                    fi
                else
                    echo ""
                    echo -e "${CYAN}⚡ Instalando: ${target_name}...${NC}"
                    echo ""
                    run_installer_script "$target_script" "$target_name"
                    sync_desktop_launcher "$slug"
                    echo "$slug" >> "$INSTALLED_REGISTRY" 2>/dev/null || true
                    echo ""
                    pause_menu "Presiona ENTER o borrar para continuar..."
                fi
                refresh_installed_cache
            fi
        done
    done
}

# ------------------------------------------------------------------------------
# MENÚ DE CATEGORÍA
# ------------------------------------------------------------------------------
menu_categoria() {
    local sel_cat="$1"
    local sel_path="$SCRIPT_DIR/$sel_cat"

    while true; do
        refresh_installed_cache

        clear
        local cat_title="${sel_cat#[0-9]*-}"
        cat_title="${cat_title//_/ }"

        echo -e "${BLUE}======================================================${NC}"
        echo -e "${GREEN}  📁 CATEGORÍA: $cat_title${NC}"
        echo -e "${BLUE}======================================================${NC}"
        echo ""

        local PROGRAMS=()
        local j=1
        for p in "$sel_path"/instalar-*.sh; do
            [ -f "$p" ] || continue
            PROGRAMS+=("$p")

            get_program_meta "$p"
            local pname="$_META_NAME"
            local ptagline="$_META_TAGLINE"
            local inst_tag=""
            if [ -z "$pname" ]; then
                local fname="${p##*/}"
                local s="${fname#instalar-}"
                pname="${s%.sh}"
            fi

            if is_program_installed "$p"; then
                inst_tag=" ${GREEN}[✓ INSTALADO]${NC}"
            fi

            if [ -n "$ptagline" ]; then
                echo -e "  [${YELLOW}$j${NC}] 📦 ${BOLD}${pname}${NC} ${CYAN}(${ptagline})${NC}${inst_tag}"
            else
                echo -e "  [${YELLOW}$j${NC}] 📦 ${BOLD}${pname}${NC}${inst_tag}"
            fi
            ((j++))
        done

        echo ""
        echo -e "  [${YELLOW}0${NC}] ↩️ Volver a categorías ${GRAY}(o pulsa borrar)${NC}"
        echo ""
        local opt_prog
        opt_prog=$(read_menu_input "${BOLD}👉 Selecciona un programa para instalar o gestionar: ${NC}")

        if [ "$opt_prog" = "0" ] || [ "$opt_prog" = "__BACK__" ] || [ "$opt_prog" = "b" ] || [ "$opt_prog" = "q" ]; then
            break
        fi

        if [ -z "$opt_prog" ]; then
            continue
        fi

        if [[ "$opt_prog" =~ ^[0-9]+$ ]] && [ "$opt_prog" -ge 1 ] && [ "$opt_prog" -le "${#PROGRAMS[@]}" ]; then
            local target_script="${PROGRAMS[$((opt_prog-1))]}"
            local fname="${target_script##*/}"
            local slug="${fname#instalar-}"
            slug="${slug%.sh}"

            get_program_meta "$target_script"
            local target_name="$_META_NAME"
            [ -z "$target_name" ] && target_name="$slug"

            if is_program_installed "$target_script"; then
                echo ""
                echo -e "${YELLOW}[!] ${target_name} ya está instalado en este sistema.${NC}"
                echo -e "  [${YELLOW}1${NC}] ⚡ Reinstalar / Actualizar"
                echo -e "  [${YELLOW}2${NC}] 🗑️ Desinstalar programa"
                echo -e "  [${YELLOW}0${NC}] ↩️ Volver atrás ${GRAY}(o pulsa borrar)${NC}"
                echo ""
                local sub_action
                sub_action=$(read_menu_input "${BOLD}👉 Opción [1/2/0]: ${NC}")
                if [ "$sub_action" = "1" ]; then
                    echo ""
                    echo -e "${CYAN}⚡ Reinstalando: ${target_name}...${NC}"
                    echo ""
                    run_installer_script "$target_script" "$target_name"
                    sync_desktop_launcher "$slug"
                    echo "$slug" >> "$INSTALLED_REGISTRY" 2>/dev/null || true
                    pause_menu "Presiona ENTER o borrar para continuar..."
                elif [ "$sub_action" = "2" ]; then
                    prompt_and_uninstall "$target_script"
                fi
            else
                echo ""
                echo -e "${CYAN}⚡ Instalando: ${target_name}...${NC}"
                echo ""
                run_installer_script "$target_script" "$target_name"
                sync_desktop_launcher "$slug"
                echo "$slug" >> "$INSTALLED_REGISTRY" 2>/dev/null || true
                echo ""
                pause_menu "Presiona ENTER o borrar para continuar..."
            fi
        fi
    done
}

# ------------------------------------------------------------------------------
# BUCLE PRINCIPAL DEL CENTRO DE SOFTWARE
# ------------------------------------------------------------------------------
run_main_menu() {
    local banner_frame=0
    while true; do
        refresh_installed_cache

        # Contar programas instalados con caché en memoria ultra-rápida (cero subshells)
        local inst_count=0
        for p in "$SCRIPT_DIR"/*/instalar-*.sh; do
            [ -f "$p" ] || continue
            if is_program_installed "$p"; then
                ((inst_count++))
            fi
        done

        clear
        # Mostrar banner Code Stack Sh si la terminal tiene al menos 20 líneas de alto
        local t_lines=$(tput lines 2>/dev/null || echo 24)
        if [ "$t_lines" -ge 20 ]; then
            if command -v code-stack-ascii >/dev/null 2>&1; then
                python3 "$(command -v code-stack-ascii)" banner "$banner_frame" 2>/dev/null || true
            elif [ -f "$REPO_DIR/bin/code-stack-ascii" ]; then
                python3 "$REPO_DIR/bin/code-stack-ascii" banner "$banner_frame" 2>/dev/null || true
            fi
            ((banner_frame=(banner_frame+4)%120))
        fi
        echo -e "${BLUE}======================================================${NC}"
        echo -e "${GREEN}  📦 CODE STACK SH • CENTRO DE SOFTWARE OFICIAL${NC}"
        echo -e "${CYAN}     «La libertad de programar sin necesidad de una PC»${NC}"
        echo -e "${BLUE}======================================================${NC}"
        echo ""
        echo -e "Explorar categorías para instalar:"
        echo ""

        CATEGORIES=()
        local i=1
        for d in "$SCRIPT_DIR"/*/; do
            [ -d "$d" ] || continue
            local cname="${d%/}"
            cname="${cname##*/}"
            CATEGORIES+=("$cname")
            local cname_clean="${cname#[0-9]*-}"
            cname_clean="${cname_clean//_/ }"

            local cat_files=("$d"instalar-*.sh)
            local count=0
            [ -e "${cat_files[0]}" ] && count="${#cat_files[@]}"

            echo -e "  [${YELLOW}$i${NC}] 📁 $cname_clean (${CYAN}$count programas${NC})"
            ((i++))
        done

        echo ""
        echo -e "${GRAY}------------------------------------------------------${NC}"
        echo -e "  [${YELLOW}D${NC}] 🗑️ ${BOLD}Desinstalar programas${NC} (${GREEN}$inst_count instalados${NC})"
        echo -e "  [${YELLOW}B${NC}] 🔍 ${BOLD}Buscar programa${NC} (+110 apps)"
        echo -e "  [${YELLOW}G${NC}] ⚡ ${BOLD}Calibrar GPU y Aceleración Hardware${NC}"
        echo -e "  [${YELLOW}0${NC}] 🚪 Salir ${GRAY}(o pulsa borrar)${NC}"
        echo -e "${GRAY}------------------------------------------------------${NC}"
        echo ""

        local opt_cat
        opt_cat=$(read_menu_input "${BOLD}👉 Selecciona una opción: ${NC}")

        if [ "$opt_cat" = "0" ] || [ "$opt_cat" = "__BACK__" ] || [ "$opt_cat" = "q" ] || [ "$opt_cat" = "Q" ]; then
            echo -e "\n${YELLOW}[*] Saliendo del Centro de Software...${NC}\n" >&2
            exit 0
        fi

        if [ -z "$opt_cat" ]; then
            continue
        fi

        if [ "$opt_cat" = "d" ] || [ "$opt_cat" = "D" ]; then
            menu_desinstalar
            continue
        fi

        if [ "$opt_cat" = "b" ] || [ "$opt_cat" = "B" ]; then
            menu_buscar
            continue
        fi

        if [ "$opt_cat" = "g" ] || [ "$opt_cat" = "G" ]; then
            if command -v gpu-optimizer >/dev/null 2>&1; then
                gpu-optimizer --reprobe
            elif [ -f "$REPO_DIR/bin/gpu-optimizer" ]; then
                "$REPO_DIR/bin/gpu-optimizer" --reprobe
            fi
            echo -ne "${BOLD}Presiona ENTER para continuar...${NC}" >&2
            read_menu_input "" >/dev/null
            continue
        fi

        if [[ "$opt_cat" =~ ^[0-9]+$ ]] && [ "$opt_cat" -ge 1 ] && [ "$opt_cat" -le "${#CATEGORIES[@]}" ]; then
            local sel_cat="${CATEGORIES[$((opt_cat-1))]}"
            menu_categoria "$sel_cat"
        fi
    done
}

# Ejecutar bucle principal solo cuando se ejecuta directamente el script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main_menu
fi
```

### Archivo: `bin/switch-identity`

```bash
#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# switch-identity: Conmutador Multi-Dispositivo Exclusivo del Líder
# Alterna instantáneamente entre los celulares de la flota, sincroniza deltas y
# bóvedas cifradas con Cloudflare R2, y valida la paridad de programas instalados.
# ==============================================================================

BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
NC='\033[0m'

LEADER_SEAL="ums9230-sp_6300-3724801c"
LOCAL_SEAL=""
if command -v cloud-sentinel >/dev/null 2>&1; then
    LOCAL_SEAL=$(cloud-sentinel seal 2>/dev/null || true)
fi
if [ -z "$LOCAL_SEAL" ] && [ -f "$HOME/.config/termux-vscode/.device_hw_seal" ]; then
    LOCAL_SEAL=$(cat "$HOME/.config/termux-vscode/.device_hw_seal" 2>/dev/null || true)
fi

# 1. Verificación de Hardware Líder
if [ "$LOCAL_SEAL" != "$LEADER_SEAL" ]; then
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ⛔ ACCESO DENEGADO: FUNCIÓN EXCLUSIVA DEL LÍDER                  ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}[!] Este dispositivo no posee privilegios de conmutación.${NC}"
    exit 1
fi

REPO_DIR=""
CONFIG_FILE="$HOME/.config/termux-vscode/repo_path"
[ -f "$CONFIG_FILE" ] && REPO_DIR=$(cat "$CONFIG_FILE" 2>/dev/null || true)
if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR/.git" ]; then
    REPO_DIR="/storage/emulated/0/Antigravity/IdeasMillonarias/termux-vscode-x11"
fi
if [ ! -d "$REPO_DIR/.git" ] && [ -d "$HOME/termux-vscode-x11/.git" ]; then
    REPO_DIR="$HOME/termux-vscode-x11"
fi

CREDS_DIR="$REPO_DIR/credenciales"
mkdir -p "$CREDS_DIR"

GATEWAY_URL=""
[ -f "$HOME/.config/termux-vscode/gateway_url" ] && GATEWAY_URL=$(cat "$HOME/.config/termux-vscode/gateway_url" 2>/dev/null | tr -d '[:space:]')
[ -z "$GATEWAY_URL" ] && GATEWAY_URL="https://code-stack-gateway.cdn-sys-runtime.workers.dev"

ACTIVE_FILE="$HOME/.config/termux-vscode/active_identity"
CURRENT_ACTIVE="ums9230-sp_6300-3724801c"
[ -f "$ACTIVE_FILE" ] && CURRENT_ACTIVE=$(cat "$ACTIVE_FILE" 2>/dev/null | tr -d '[:space:]' || echo "$CURRENT_ACTIVE")

clear 2>/dev/null || true
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   👑 CONMUTADOR DE IDENTIDADES MULTI-DISPOSITIVO (LÍDER)          ║${NC}"
echo -e "${CYAN}║      Alterna entre los celulares de la flota y sus cuentas         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}[*] Consultando flota registrada en Cloudflare Edge y almacenamiento local...${NC}"

FLEET_JSON=$(curl -s --connect-timeout 4 --max-time 6 "$GATEWAY_URL/api/v1/fleet/devices" 2>/dev/null || echo '{"ok":false}')

DISP_LIST=$(python3 -c '
import json, glob, os, sys

fleet_raw = sys.argv[1]
creds_dir = sys.argv[2]
leader_seal = sys.argv[3]

remote_devices = {}
try:
    data = json.loads(fleet_raw)
    if data.get("ok"):
        for d in data.get("devices", []):
            remote_devices[d["seal"]] = {
                "seal": d["seal"],
                "username": d.get("username") or d["seal"],
                "model": d.get("device_model") or "Android",
                "role": d.get("role") or "Worker",
                "status": d.get("status") or "active",
                "source": "cloud"
            }
except Exception:
    pass

for p in glob.glob(os.path.join(creds_dir, "*")):
    if not os.path.isdir(p): continue
    s = os.path.basename(p)
    if s.startswith("."): continue
    if s not in remote_devices:
        remote_devices[s] = {
            "seal": s,
            "username": s,
            "model": "Android",
            "role": "Líder" if s == leader_seal else "Worker",
            "status": "local",
            "source": "local"
        }

if leader_seal not in remote_devices:
    remote_devices[leader_seal] = {
        "seal": leader_seal,
        "username": "Líder Maestro",
        "model": "Siragon SP_6300",
        "role": "Líder",
        "status": "active",
        "source": "master"
    }

ordered = sorted(remote_devices.values(), key=lambda x: (0 if x["role"] == "Líder" else 1, x["username"]))
print(json.dumps(ordered))
' "$FLEET_JSON" "$CREDS_DIR" "$LEADER_SEAL")

SEAL_MAP=()
USER_MAP=()
MODEL_MAP=()
ROLE_MAP=()
INDEX=1

echo ""
echo -e "${BOLD}Dispositivos y cuentas disponibles en la flota:${NC}"
echo -e "${BLUE}───────────────────────────────────────────────────────────────────${NC}"

DEVICE_COUNT=$(python3 -c "import json, sys; print(len(json.loads(sys.argv[1])))" "$DISP_LIST")

for (( i=0; i<DEVICE_COUNT; i++ )); do
    SEAL=$(python3 -c "import json, sys; print(json.loads(sys.argv[1])[$i]['seal'])" "$DISP_LIST")
    UNAME=$(python3 -c "import json, sys; print(json.loads(sys.argv[1])[$i]['username'])" "$DISP_LIST")
    MODEL=$(python3 -c "import json, sys; print(json.loads(sys.argv[1])[$i]['model'])" "$DISP_LIST")
    ROLE=$(python3 -c "import json, sys; print(json.loads(sys.argv[1])[$i]['role'])" "$DISP_LIST")
    STATUS=$(python3 -c "import json, sys; print(json.loads(sys.argv[1])[$i]['status'])" "$DISP_LIST")

    SEAL_MAP+=("$SEAL")
    USER_MAP+=("$UNAME")
    MODEL_MAP+=("$MODEL")
    ROLE_MAP+=("$ROLE")

    TAG=""
    if [ "$SEAL" = "$CURRENT_ACTIVE" ]; then
        TAG=" ${GREEN}(ACTIVO EN ESTE MOMENTO)${NC}"
    fi

    STATUS_TAG=""
    if [ "$STATUS" = "rejected" ] || [ "$STATUS" = "revoked" ]; then
        STATUS_TAG=" ${RED}[BLOQUEADO]${NC}"
    fi

    if [ "$ROLE" = "Líder" ]; then
        echo -e " [${INDEX}] ${YELLOW}⭐ ${UNAME}${NC} [${MODEL}] (${ROLE}) [${SEAL}]${STATUS_TAG}${TAG}"
    else
        echo -e " [${INDEX}] 📱 ${CYAN}${UNAME}${NC} [${MODEL}] (${ROLE}) [${SEAL}]${STATUS_TAG}${TAG}"
    fi
    INDEX=$((INDEX + 1))
done

echo -e " [0] Cancelar y volver"
echo -e "${BLUE}───────────────────────────────────────────────────────────────────${NC}"
echo ""

TOTAL_ITEMS=${#SEAL_MAP[@]}
if [ "$TOTAL_ITEMS" -eq 0 ]; then
    echo -e "${YELLOW}[*] No hay dispositivos disponibles.${NC}"
    read -p "Presiona ENTER para salir..." dummy
    exit 0
fi

echo -ne "${BOLD}Selecciona el número de identidad a cargar (0-${TOTAL_ITEMS}): ${NC}"
read -r CHOICE

if [ -z "$CHOICE" ] || [ "$CHOICE" -eq 0 ] 2>/dev/null; then
    echo "Operación cancelada."
    exit 0
fi

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "$TOTAL_ITEMS" ]; then
    echo -e "${RED}[!] Selección no válida.${NC}"
    exit 1
fi

TARGET_SEAL="${SEAL_MAP[$((CHOICE - 1))]}"
TARGET_UNAME="${USER_MAP[$((CHOICE - 1))]}"
TARGET_MODEL="${MODEL_MAP[$((CHOICE - 1))]}"

if [ "$TARGET_SEAL" = "$CURRENT_ACTIVE" ]; then
    echo -e "${GREEN}[✓] La identidad '${TARGET_UNAME}' (${TARGET_SEAL}) ya está activa en este dispositivo.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}===================================================================${NC}"
echo -e "${YELLOW}  ETAPA 1/3: RESPALDANDO IDENTIDAD ACTUAL '${CURRENT_ACTIVE}'...${NC}"
echo -e "${YELLOW}===================================================================${NC}"

CURRENT_VAULT_DIR="$CREDS_DIR/$CURRENT_ACTIVE"
mkdir -p "$CURRENT_VAULT_DIR"

if [ -d "$HOME/.config" ]; then
    echo -e "${CYAN}[*] Empaquetando perfiles y credenciales de '${CURRENT_ACTIVE}' (110+ programas)...${NC}"
    if command -v vault-manager >/dev/null 2>&1; then
        vault-manager pack "$CURRENT_ACTIVE" "$CURRENT_VAULT_DIR/vault.enc"
    elif [ -f "$REPO_DIR/bin/vault-manager" ]; then
        bash "$REPO_DIR/bin/vault-manager" pack "$CURRENT_ACTIVE" "$CURRENT_VAULT_DIR/vault.enc"
    fi

    if [ -f "$CURRENT_VAULT_DIR/vault.enc" ]; then
        echo -e "${CYAN}[*] Subiendo 'vault.enc' a Cloudflare R2...${NC}"
        curl -s -X POST --data-binary @"$CURRENT_VAULT_DIR/vault.enc" "$GATEWAY_URL/api/v1/vault/upload?seal=$CURRENT_ACTIVE" >/dev/null 2>&1 || true
        echo -e "${GREEN}[✓] Bóveda cifrada de '${CURRENT_ACTIVE}' respaldada en Cloudflare R2.${NC}"
    fi
fi

echo -e "${CYAN}[*] Recolectando inventario local de paquetes y extensiones...${NC}"
LOCAL_INV=$(python3 -c '
import subprocess, shutil, json, sys

seal = sys.argv[1]
model = sys.argv[2]

core_pkgs = ["code-oss", "zen-browser", "termux-x11-nightly", "termux-x11", "openbox", "virglrenderer-android", "python", "git", "openssl", "pulseaudio", "tar", "curl", "jq", "neofetch", "htop"]
installed_pkgs = []
for p in core_pkgs:
    cmd_name = p.split("-")[0]
    if shutil.which(p) or shutil.which(cmd_name):
        installed_pkgs.append(p)
    else:
        res = subprocess.run(["dpkg", "-s", p], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if res.returncode == 0:
            installed_pkgs.append(p)

exts = []
if shutil.which("code-oss"):
    try:
        out = subprocess.check_output(["code-oss", "--list-extensions"], stderr=subprocess.DEVNULL).decode().strip()
        if out: exts = [e.strip() for e in out.splitlines() if e.strip()]
    except Exception:
        pass

payload = {
    "seal": seal,
    "system_packages": installed_pkgs,
    "vscode_extensions": exts,
    "device_model": model
}
print(json.dumps(payload))
' "$CURRENT_ACTIVE" "$TARGET_MODEL")

echo "$LOCAL_INV" > "$CURRENT_VAULT_DIR/inventory.json"
curl -s -X POST -H "Content-Type: application/json" -d "$LOCAL_INV" "$GATEWAY_URL/api/v1/vault/inventory?seal=$CURRENT_ACTIVE" >/dev/null 2>&1 || true

if command -v watcher-sync >/dev/null 2>&1; then
    echo -e "${CYAN}[*] Transmitiendo deltas pendientes a Cloudflare Edge...${NC}"
    watcher-sync --once >/dev/null 2>&1 || true
fi

echo ""
echo -e "${YELLOW}===================================================================${NC}"
echo -e "${YELLOW}  ETAPA 2/3: DESCARGANDO Y ACTIVANDO IDENTIDAD '${TARGET_UNAME}'...${NC}"
echo -e "${YELLOW}===================================================================${NC}"

TARGET_DIR="$CREDS_DIR/$TARGET_SEAL"
mkdir -p "$TARGET_DIR"

echo -e "${CYAN}[*] Descargando bóveda de '${TARGET_SEAL}' desde Cloudflare R2...${NC}"
HTTP_CODE=$(curl -s -w "%{http_code}" -o "$TARGET_DIR/vault.enc.download" "$GATEWAY_URL/api/v1/vault/download?seal=$TARGET_SEAL" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ] && [ -s "$TARGET_DIR/vault.enc.download" ]; then
    mv -f "$TARGET_DIR/vault.enc.download" "$TARGET_DIR/vault.enc"
    echo -e "${GREEN}[✓] Bóveda cifrada descargada exitosamente desde Cloudflare R2.${NC}"
else
    rm -f "$TARGET_DIR/vault.enc.download" 2>/dev/null || true
    if [ -f "$TARGET_DIR/vault.enc" ]; then
        echo -e "${YELLOW}[!] Usando copia local en disco de 'vault.enc'.${NC}"
    else
        echo -e "${YELLOW}[!] El dispositivo '${TARGET_UNAME}' aún no ha subido su 'vault.enc' a Cloudflare R2.${NC}"
        echo -e "${YELLOW}[*] Se iniciará un perfil base para '${TARGET_UNAME}'.${NC}"
    fi
fi

SWITCH_SUCCESS=0
if [ -f "$TARGET_DIR/vault.enc" ]; then
    echo -e "${CYAN}[*] Descifrando bóveda de forma atómica para: ${TARGET_SEAL}...${NC}"
    if command -v vault-manager >/dev/null 2>&1; then
        if vault-manager unpack "$TARGET_SEAL" "$TARGET_DIR/vault.enc"; then
            SWITCH_SUCCESS=1
        fi
    elif [ -f "$REPO_DIR/bin/vault-manager" ]; then
        if bash "$REPO_DIR/bin/vault-manager" unpack "$TARGET_SEAL" "$TARGET_DIR/vault.enc"; then
            SWITCH_SUCCESS=1
        fi
    fi
else
    # Inicializar perfil limpio para nuevo dispositivo sin sobreescribir con datos ajenos
    mkdir -p "$TARGET_DIR"
    SWITCH_SUCCESS=1
fi

if [ "$SWITCH_SUCCESS" -eq 1 ]; then
    echo "$TARGET_SEAL" > "$ACTIVE_FILE"
    echo -e "${GREEN}[✓] ¡Conmutación exitosa! Ahora estás operando como: ${BOLD}${TARGET_UNAME}${NC} (${TARGET_SEAL})"
    if command -v cloud-sentinel >/dev/null 2>&1; then
        cloud-sentinel notify "🔄 *CONMUTACIÓN DE IDENTIDAD EN DISPOSITIVO LÍDER*" "📱 Perfil activo cambiado a: \`${TARGET_UNAME}\` (\`${TARGET_SEAL}\`)" >/dev/null 2>&1 || true
    fi
else
    echo -e "${RED}[!] Error crítico: La restauración de la bóveda falló. Se mantiene la identidad previa para proteger tus perfiles.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}===================================================================${NC}"
echo -e "${YELLOW}  ETAPA 3/3: AUDITORÍA Y CHECKLIST DE PARIDAD DE SOFTWARE          ${NC}"
echo -e "${YELLOW}===================================================================${NC}"

TARGET_INV_RAW=$(curl -s --connect-timeout 4 --max-time 6 "$GATEWAY_URL/api/v1/vault/inventory?seal=$TARGET_SEAL" 2>/dev/null || echo '{"ok":false}')

python3 -c '
import json, subprocess, shutil, sys

BLUE = "\033[1;34m"
GREEN = "\033[1;32m"
CYAN = "\033[1;36m"
YELLOW = "\033[1;33m"
RED = "\033[1;31m"
BOLD = "\033[1m"
NC = "\033[0m"

raw = sys.argv[1]
target_uname = sys.argv[2]
target_seal = sys.argv[3]

inv_data = {}
try:
    p = json.loads(raw)
    if p.get("ok") and "inventory" in p:
        inv_data = p["inventory"]
except Exception:
    pass

sys_pkgs = inv_data.get("system_packages", [])
vscode_exts = inv_data.get("vscode_extensions", [])

if not sys_pkgs and not vscode_exts:
    print(f"{YELLOW}[*] No se encontró manifiesto de software remoto para \x27{target_uname}\x27.{NC}")
    print(f"{CYAN}[✓] Puedes instalar tus programas habituales o sincronizarlos al encender el otro dispositivo.{NC}")
    sys.exit(0)

print(f"{BOLD}Inventario de programas y extensiones de: {CYAN}{target_uname}{NC}")
print(f"{BLUE}───────────────────────────────────────────────────────────────────{NC}")

missing_pkgs = []
for pkg in sys_pkgs:
    cmd_name = pkg.split("-")[0]
    is_installed = False
    if shutil.which(pkg) or shutil.which(cmd_name):
        is_installed = True
    else:
        res = subprocess.run(["dpkg", "-s", pkg], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if res.returncode == 0:
            is_installed = True

    if is_installed:
        print(f"  {GREEN}[✓] {pkg}{NC} (Instalado)")
    else:
        print(f"  {RED}[✗] {pkg}{NC} {YELLOW}(FALTANTE EN ESTE TELÉFONO){NC}")
        missing_pkgs.append(pkg)

installed_exts = []
if shutil.which("code-oss"):
    try:
        out = subprocess.check_output(["code-oss", "--list-extensions"], stderr=subprocess.DEVNULL).decode().strip()
        if out: installed_exts = [e.strip().lower() for e in out.splitlines() if e.strip()]
    except Exception:
        pass

missing_exts = []
for ext in vscode_exts:
    if ext.lower() in installed_exts:
        print(f"  {GREEN}[✓] [Ext] {ext}{NC} (Instalada)")
    else:
        print(f"  {RED}[✗] [Ext] {ext}{NC} {YELLOW}(FALTANTE EN ESTE TELÉFONO){NC}")
        missing_exts.append(ext)

print(f"{BLUE}───────────────────────────────────────────────────────────────────{NC}")

if not missing_pkgs and not missing_exts:
    print(f"{GREEN}🎉 ¡Paridad al 100%! Tienes exactamente los mismos programas y extensiones.{NC}")
else:
    print(f"{YELLOW}⚡ Para alcanzar el 100% de paridad con {target_uname}, ejecuta:{NC}")
    if missing_pkgs:
        pkgs_cmd = " ".join(missing_pkgs)
        print(f"  {BOLD}pkg in -y {pkgs_cmd}{NC}")
    if missing_exts:
        for me in missing_exts:
            print(f"  {BOLD}code-oss --install-extension {me}{NC}")
    print("")
    sys.stdout.flush()

    with open("/data/data/com.termux/files/home/.config/termux-vscode/missing_packages.txt", "w") as mf:
        mf.write(" ".join(missing_pkgs) + "\n")
        mf.write(" ".join(missing_exts) + "\n")
' "$TARGET_INV_RAW" "$TARGET_UNAME" "$TARGET_SEAL"

MISSING_FILE="$HOME/.config/termux-vscode/missing_packages.txt"
if [ -f "$MISSING_FILE" ]; then
    MISSING_PKGS=$(head -n 1 "$MISSING_FILE" 2>/dev/null || true)
    MISSING_EXTS=$(tail -n 1 "$MISSING_FILE" 2>/dev/null || true)
    rm -f "$MISSING_FILE" 2>/dev/null || true

    if [ -n "$MISSING_PKGS" ] || [ -n "$MISSING_EXTS" ]; then
        echo -ne "${BOLD}¿Deseas descargar e instalar automáticamente los programas/extensiones faltantes ahora? (s/N): ${NC}"
        read -r INSTALL_CHOICE
        if [ "$INSTALL_CHOICE" = "s" ] || [ "$INSTALL_CHOICE" = "S" ] || [ "$INSTALL_CHOICE" = "y" ] || [ "$INSTALL_CHOICE" = "Y" ]; then
            if [ -n "$MISSING_PKGS" ]; then
                echo -e "${YELLOW}[*] Instalando paquetes del sistema: $MISSING_PKGS...${NC}"
                pkg in -y $MISSING_PKGS || true
            fi
            if [ -n "$MISSING_EXTS" ] && command -v code-oss >/dev/null 2>&1; then
                for ext in $MISSING_EXTS; do
                    echo -e "${YELLOW}[*] Instalando extensión: $ext...${NC}"
                    code-oss --install-extension "$ext" || true
                done
            fi
            echo -e "${GREEN}[✓] ¡Instalación de paridad completada!${NC}"
        fi
    fi
fi

echo ""
echo -e "${GREEN}===================================================================${NC}"
echo -e "${GREEN}  ✓ Conmutación completada. Ya puedes iniciar con 'encender'.      ${NC}"
echo -e "${GREEN}===================================================================${NC}"
```

### Archivo: `bin/flota`

```bash
#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# flota: Centro de Comando y Control de la Flota (Exclusivo del Líder)
# Control Total sobre la Flota de Celulares y sus Cuentas de Google
# ==============================================================================

BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BOLD='\033[1m'
MAGENTA='\033[1;35m'
GRAY='\033[0;90m'
NC='\033[0m'

LEADER_SEAL="ums9230-sp_6300-3724801c"
LOCAL_SEAL=""
if command -v cloud-sentinel >/dev/null 2>&1; then
    LOCAL_SEAL=$(cloud-sentinel seal 2>/dev/null || true)
fi
if [ -z "$LOCAL_SEAL" ] && [ -f "$HOME/.config/termux-vscode/.device_hw_seal" ]; then
    LOCAL_SEAL=$(cat "$HOME/.config/termux-vscode/.device_hw_seal" 2>/dev/null || true)
fi

# 1. Verificación Estricta de Hardware Líder
if [ "$LOCAL_SEAL" != "$LEADER_SEAL" ]; then
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ⛔ ACCESO DENEGADO: CENTRO DE COMANDO EXCLUSIVO DEL LÍDER        ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}[!] Este dispositivo no posee privilegios de mando sobre la flota.${NC}"
    exit 1
fi

REPO_DIR=""
CONFIG_FILE="$HOME/.config/termux-vscode/repo_path"
[ -f "$CONFIG_FILE" ] && REPO_DIR=$(cat "$CONFIG_FILE" 2>/dev/null || true)
if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR/.git" ]; then
    REPO_DIR="$HOME/termux-vscode-x11"
fi

CREDS_DIR="$REPO_DIR/credenciales"
mkdir -p "$CREDS_DIR"
ACTIVE_FILE="$HOME/.config/termux-vscode/active_identity"
CURRENT_ACTIVE="ums9230-sp_6300-3724801c"
[ -f "$ACTIVE_FILE" ] && CURRENT_ACTIVE=$(cat "$ACTIVE_FILE" 2>/dev/null || echo "$CURRENT_ACTIVE")

# Función para descifrar metadatos en RAM
get_decrypted_meta() {
    local folder="$1"
    local seal="$(basename "$folder")"
    local enc_file="$CREDS_DIR/$seal/metadata.enc"

    if [ -f "$enc_file" ]; then
        PASS_KEY="$(github-auth-broker session-key "$seal" 2>/dev/null)" openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass env:PASS_KEY -in "$enc_file" 2>/dev/null || echo "{}"
    else
        echo "{}"
    fi
}

# Subcomando: Listar / Dashboard
cmd_listar() {
    clear 2>/dev/null || true
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   👑 CENTRO DE COMANDO Y CONTROL DE FLOTA (LÍDER MAESTRO)         ║${NC}"
    echo -e "${CYAN}║      Inspección Descifrada en RAM • Cero Rastros en Disco         ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    INDEX=1
    FOLDERS=()
    echo -e "${BOLD}DISPOSITIVOS REGISTRADOS Y ESTADO DE CUENTAS:${NC}"
    echo -e "${BLUE}───────────────────────────────────────────────────────────────────${NC}"

    for d in "$CREDS_DIR"/*; do
        [ -d "$d" ] || continue
        SEAL=$(basename "$d")
        [[ "$SEAL" == .* ]] && continue
        FOLDERS+=("$SEAL")
        
        META=$(get_decrypted_meta "$SEAL")
        
        USER_NAME=$(python3 -c "import json; print(json.loads('''$META''').get('username', '$SEAL'))" 2>/dev/null || echo "$SEAL")
        MODEL=$(python3 -c "import json; print(json.loads('''$META''').get('device_model', 'Android'))" 2>/dev/null || echo "Android")
        ROLE=$(python3 -c "import json; print(json.loads('''$META''').get('role', 'Worker'))" 2>/dev/null || echo "Worker")
        ACCOUNTS=$(python3 -c "import json; print(json.loads('''$META''').get('accounts_limit', 'Ilimitadas'))" 2>/dev/null || echo "Ilimitadas")
        STATUS=$(python3 -c "import json; print(json.loads('''$META''').get('status', 'Activo'))" 2>/dev/null || echo "Activo")
        LAST_SYNC=$(python3 -c "import json; print(json.loads('''$META''').get('last_sync', 'Reciente'))" 2>/dev/null || echo "Reciente")

        TAG=""
        if [ "$SEAL" = "$CURRENT_ACTIVE" ] || [ "$SEAL" = "$LOCAL_SEAL" ]; then
            TAG=" ${GREEN}(ACTIVO EN ESTE MOMENTO)${NC}"
        fi

        if [ "$ROLE" = "Líder" ]; then
            echo -e " [${INDEX}] ${YELLOW}⭐ ${USER_NAME}${NC} [${MODEL}]${TAG}"
            echo -e "     ${GRAY}├─ Sello Hardware : ${CYAN}${SEAL}${NC}"
            echo -e "     ${GRAY}├─ Cuentas Google : ${GREEN}${ACCOUNTS}${NC} (Sin límites)"
            echo -e "     ${GRAY}└─ Último guardado : ${GRAY}${LAST_SYNC}${NC}"
        else
            echo -e " [${INDEX}] 📱 ${USER_NAME} [${MODEL}]${TAG}"
            echo -e "     ${GRAY}├─ Sello Hardware : ${CYAN}${SEAL}${NC}"
            echo -e "     ${GRAY}├─ Cuentas Google : ${GREEN}${ACCOUNTS}${NC}"
            echo -e "     ${GRAY}└─ Estado Flota   : ${GREEN}${STATUS}${NC}"
        fi
        echo ""
        INDEX=$((INDEX + 1))
    done

    echo -e "${BLUE}───────────────────────────────────────────────────────────────────${NC}"
    echo -e "${BOLD}Comandos de Acción Rápida:${NC}"
    echo -e "  ${YELLOW}flota inspeccionar [N]${NC}  : Ver ficha técnica y telemetría completa"
    echo -e "  ${YELLOW}flota switch [N]${NC}        : Cargar y conmutar a ese celular"
    echo -e "  ${YELLOW}flota bloquear [N]${NC}      : Revocar acceso y ordenar auto-destrucción"
    echo -e "  ${YELLOW}flota broadcast${NC}         : Difundir ajustes del Líder a toda la flota"
    echo -e "  ${YELLOW}flota backup${NC}            : Exportar respaldo unificado de la flota"
    echo ""
}

# Subcomando: Inspeccionar en detalle
cmd_inspeccionar() {
    local target="$1"
    FOLDERS=()
    for d in "$CREDS_DIR"/*; do
        [ -d "$d" ] && [[ "$(basename "$d")" != .* ]] && FOLDERS+=("$(basename "$d")")
    done

    SELECTED=""
    if [[ "$target" =~ ^[0-9]+$ ]] && [ "$target" -ge 1 ] && [ "$target" -le "${#FOLDERS[@]}" ]; then
        SELECTED="${FOLDERS[$((target - 1))]}"
    else
        for f in "${FOLDERS[@]}"; do
            if [[ "$f" == *"$target"* ]]; then
                SELECTED="$f"
                break
            fi
        done
    fi

    if [ -z "$SELECTED" ]; then
        echo -e "${RED}[!] Dispositivo no encontrado: ${target}${NC}"
        exit 1
    fi

    META=$(get_decrypted_meta "$SELECTED")

    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  🔍 FICHA TÉCNICA Y TELEMETRÍA DESCIFRADA EN RAM${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    python3 -c "
import json
try:
    data = json.loads('''$META''')
    for k, v in data.items():
        print(f' • \033[1;33m{k.replace(\"_\", \" \").title():20s}\033[0m : \033[1;36m{v}\033[0m')
except Exception as e:
    print('Error parseando metadatos:', e)
"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
}

# Subcomando: Bloqueo Remoto (Kill-Switch)
cmd_bloquear() {
    local target="$1"
    FOLDERS=()
    for d in "$CREDS_DIR"/*; do
        [ -d "$d" ] && [[ "$(basename "$d")" != .* ]] && FOLDERS+=("$(basename "$d")")
    done

    SELECTED=""
    if [[ "$target" =~ ^[0-9]+$ ]] && [ "$target" -ge 1 ] && [ "$target" -le "${#FOLDERS[@]}" ]; then
        SELECTED="${FOLDERS[$((target - 1))]}"
    else
        SELECTED="$target"
    fi

    if [ "$SELECTED" = "$LEADER_SEAL" ]; then
        echo -e "${RED}[!] Error: No es posible bloquear el dispositivo Líder Maestro.${NC}"
        exit 1
    fi

    BLACKLIST_FILE="$CREDS_DIR/.blacklist.enc"
    github-auth-broker revoke "$SELECTED" >/dev/null 2>&1 || true
    PASS_KEY="$(github-auth-broker session-key "$LEADER_SEAL" 2>/dev/null)" openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass env:PASS_KEY -out "$BLACKLIST_FILE" <<< "$SELECTED"

    echo -e "${RED}[🚨] DISPOSITIVO BLOQUEADO Y HASH QUEMADO:${NC} ${SELECTED}"
    echo -e "${YELLOW}[*] Orden de auto-destrucción y borrado de cookies registrada en la flota.${NC}"

    if command -v cloud-sentinel >/dev/null 2>&1; then
        cloud-sentinel notify "🚨 *ORDEN DE BLOQUEO Y BORRADO REMOTO (LÍDER)*" "📱 Dispositivo bloqueado: \`${SELECTED}\`\nSello: \`${SELECTED}\`" >/dev/null 2>&1 || true
    fi

    sync-vscode --quiet >/dev/null 2>&1 || true
}

# Subcomando: Broadcast de Configuraciones
cmd_broadcast() {
    echo -e "${CYAN}[*] Difundiendo configuraciones del Líder a toda la flota...${NC}"
    SETT_SRC="$HOME/.config/Code - OSS/User/settings.json"
    [ -f "$SETT_SRC" ] && cp "$SETT_SRC" "$REPO_DIR/config/settings.json" 2>/dev/null || true
    sync-vscode
    echo -e "${GREEN}[✓] Configuraciones y ajustes propagados a todos los celulares de la flota.${NC}"
}

# Subcomando: Respaldo Maestro Offline
cmd_backup() {
    BACKUP_FILE="$HOME/backup_flota_$(date +%Y%m%d_%H%M%S).bin"
    echo -e "${YELLOW}[*] Generando respaldo maestro ultra-cifrado de la flota completa...${NC}"
    tar -czf - -C "$REPO_DIR" credenciales config bin 2>/dev/null | \
        PASS_KEY="$(github-auth-broker session-key "$LEADER_SEAL" 2>/dev/null)" openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass env:PASS_KEY -out "$BACKUP_FILE"
    echo -e "${GREEN}[✓] Respaldo maestro guardado en:${NC} ${BACKUP_FILE}"
    echo -e "${GRAY}    Puedes guardarlo en un pendrive USB o almacenamiento externo seguro.${NC}"
}

# Subcomando: Contabilidad y Suscripciones
cmd_contabilidad() {
    github-auth-broker accounting
}

# Subcomando: Renovar Suscripción
cmd_renovar() {
    local target="${1:-}"
    if [ -z "$target" ]; then
        echo -e "${YELLOW}Uso: flota renovar <N | Sello>${NC}"
        return 1
    fi
    local seal="$target"
    if [[ "$target" =~ ^[0-9]+$ ]]; then
        local idx=1
        for d in "$CREDS_DIR"/*; do
            [ -d "$d" ] || continue
            local s=$(basename "$d")
            [[ "$s" == .* ]] && continue
            if [ "$idx" -eq "$target" ]; then
                seal="$s"
                break
            fi
            idx=$((idx + 1))
        done
    fi
    echo -e "${CYAN}[*] Renovando suscripción para: ${seal}...${NC}"
    github-auth-broker renew-license "$seal" "Líder Maestro (flota renovar)"
}

ACTION="${1:-listar}"
shift || true

case "$ACTION" in
    listar|status|ls)
        cmd_listar
        ;;
    inspeccionar|info|view)
        cmd_inspeccionar "${1:-1}"
        ;;
    switch|conmutar)
        if command -v switch-identity >/dev/null 2>&1; then
            switch-identity "$@"
        fi
        ;;
    bloquear|wipe|kill)
        cmd_bloquear "${1:-}"
        ;;
    broadcast|difundir)
        cmd_broadcast
        ;;
    backup|respaldo)
        cmd_backup
        ;;
    contabilidad|accounting|suscripciones)
        cmd_contabilidad
        ;;
    renovar|renew)
        cmd_renovar "${1:-}"
        ;;
    ayuda|help|-h|--help)
        echo "Uso de flota (Centro de Control del Líder):"
        echo "  flota                : Ver panel de control con todos los celulares y cuentas"
        echo "  flota inspeccionar N : Ver ficha técnica y telemetría descifrada en RAM"
        echo "  flota switch N       : Conmutar perfil a otro celular de la flota"
        echo "  flota bloquear N     : Bloquear y revocar acceso de un celular"
        echo "  flota broadcast      : Difundir configuraciones del Líder a toda la flota"
        echo "  flota backup         : Generar respaldo unificado maestro de la flota"
        echo "  flota contabilidad   : Ver libro mayor contable y fechas de suscripción"
        echo "  flota renovar N      : Renovar suscripción por 30 días a un dispositivo"
        ;;
    *)
        cmd_listar
        ;;
esac
```
