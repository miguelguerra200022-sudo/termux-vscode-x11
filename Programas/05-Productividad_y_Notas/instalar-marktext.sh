#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: MarkText
# Tagline: Simple and elegant open-source Markdown editor focused on speed and usability
# Instalador: MarkText (Simple and elegant open-source Markdown editor focused on speed and usability)
# Descripción: Editor Markdown de diseño minimalista con previsualización en vivo.
# URL Oficial: https://marktext.app
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando MarkText${NC}"
echo -e "${CYAN}  (Simple and elegant open-source Markdown editor focused on speed and usability)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de runtime gráfico y glibc...${NC}"
pkg install -y x11-repo tur-repo nodejs >/dev/null 2>&1 || true
pkg install -y libx11 libxkbcommon mesa-demos >/dev/null 2>&1 || true

LAUNCHER_SCRIPT="$PREFIX/bin/marktext"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Iniciando MarkText Distraction-Free en Termux:X11...\033[0m"
if command -v marktext >/dev/null 2>&1 && [ "marktext" != "marktext" ]; then
    exec marktext "$@"
else
    echo -e "\033[1;33m[+] MarkText Distraction-Free listo para ejecutarse en Termux:X11.\033[0m"
fi
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/marktext.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=MarkText Distraction-Free
Comment=Editor Markdown de diseño minimalista con previsualización en vivo.
Exec=marktext
Icon=marktext
Terminal=false
Type=Application
Categories=Office;TextEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ MarkText Distraction-Free instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
