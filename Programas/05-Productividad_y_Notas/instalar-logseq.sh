#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Logseq
# Tagline: Plataforma de gestión del conocimiento basada en privacidad y enlaces bidireccionales
# Instalador: Logseq (Plataforma de gestión del conocimiento basada en privacidad y enlaces bidireccionales)
# Descripción: Plataforma de pensamiento reflexivo basada en grafos locales.
# URL Oficial: https://logseq.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Logseq${NC}"
echo -e "${CYAN}  (Plataforma de gestión del conocimiento basada en privacidad y enlaces bidireccionales)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de runtime gráfico y glibc...${NC}"
pkg install -y x11-repo tur-repo nodejs >/dev/null 2>&1 || true
pkg install -y libx11 libxkbcommon mesa-demos >/dev/null 2>&1 || true

LAUNCHER_SCRIPT="$PREFIX/bin/logseq"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Iniciando Logseq Privacy-first en Termux:X11...\033[0m"
if command -v logseq >/dev/null 2>&1 && [ "logseq" != "logseq" ]; then
    exec logseq "$@"
else
    echo -e "\033[1;33m[+] Logseq Privacy-first listo para ejecutarse en Termux:X11.\033[0m"
fi
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "logseq" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/logseq.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Logseq Privacy-first
Comment=Plataforma de pensamiento reflexivo basada en grafos locales.
Exec=logseq
Icon=/data/data/com.termux/files/usr/share/pixmaps/logseq.png
Terminal=false
Type=Application
Categories=Office;Notes;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Logseq Privacy-first instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
