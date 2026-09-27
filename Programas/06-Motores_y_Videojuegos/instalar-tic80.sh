#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: TIC-80 Tiny Computer
# Descripción: Computadora de fantasía open-source con JS, Lua, Python y Ruby.
# URL Oficial: https://tic80.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando TIC-80 Tiny Computer${NC}"
echo -e "${CYAN}  Computadora de fantasía open-source con JS, Lua, Python y Ruby.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete tic80...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y tic80

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/tic80.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=TIC-80 Tiny Computer
Comment=Computadora de fantasía open-source con JS, Lua, Python y Ruby.
Exec=tic80
Icon=tic80
Terminal=false
Type=Application
Categories=Development;GameDevelopment;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ TIC-80 Tiny Computer instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
