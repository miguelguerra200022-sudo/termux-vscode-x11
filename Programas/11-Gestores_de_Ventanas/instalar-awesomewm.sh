#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: AwesomeWM
# Tagline: Gestor de ventanas dinámico altamente configurable para X11 mediante scripts en Lua
# Instalador: AwesomeWM (Gestor de ventanas dinámico altamente configurable para X11 mediante scripts en Lua)
# Descripción: Gestor de ventanas altamente extensible y programable en lenguaje Lua.
# URL Oficial: https://awesomewm.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando AwesomeWM${NC}"
echo -e "${CYAN}  (Gestor de ventanas dinámico altamente configurable para X11 mediante scripts en Lua)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete awesomewm...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y awesomewm

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "awesomewm" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/awesomewm.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=AwesomeWM Window Manager
Comment=Gestor de ventanas altamente extensible y programable en lenguaje Lua.
Exec=awesomewm
Icon=/data/data/com.termux/files/usr/share/pixmaps/awesomewm.png
Terminal=false
Type=Application
Categories=System;WindowManager;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ AwesomeWM Window Manager instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
