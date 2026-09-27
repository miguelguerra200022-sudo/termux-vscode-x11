#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Bluefish
# Tagline: Potente editor para programadores y diseñadores web con múltiples herramientas avanzadas
# Instalador: Bluefish (Potente editor para programadores y diseñadores web con múltiples herramientas avanzadas)
# Descripción: Editor y entorno de desarrollo orientado a programadores y diseñadores web.
# URL Oficial: http://bluefish.openoffice.nl
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Bluefish${NC}"
echo -e "${CYAN}  (Potente editor para programadores y diseñadores web con múltiples herramientas avanzadas)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete bluefish...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y bluefish

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "bluefish" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/bluefish.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Bluefish Editor
Comment=Editor y entorno de desarrollo orientado a programadores y diseñadores web.
Exec=bluefish
Icon=/data/data/com.termux/files/usr/share/pixmaps/bluefish.png
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Bluefish Editor instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
