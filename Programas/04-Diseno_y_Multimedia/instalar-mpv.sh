#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: MPV Media Player
# Descripción: Reproductor ultra-ligero de audio y video con scripts Lua y bajo consumo.
# URL Oficial: https://mpv.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando MPV Media Player${NC}"
echo -e "${CYAN}  Reproductor ultra-ligero de audio y video con scripts Lua y bajo consumo.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete mpv...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y mpv

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/mpv.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=MPV Media Player
Comment=Reproductor ultra-ligero de audio y video con scripts Lua y bajo consumo.
Exec=mpv
Icon=mpv
Terminal=false
Type=Application
Categories=AudioVideo;Player;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ MPV Media Player instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
