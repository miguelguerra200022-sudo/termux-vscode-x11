#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: AwesomeWM
# Tagline: A highly configurable, next generation framework window manager for X
# Instalador: AwesomeWM (A highly configurable, next generation framework window manager for X)
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
echo -e "${CYAN}  (A highly configurable, next generation framework window manager for X)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete awesomewm...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y awesomewm

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/awesomewm.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=AwesomeWM Window Manager
Comment=Gestor de ventanas altamente extensible y programable en lenguaje Lua.
Exec=awesomewm
Icon=awesomewm
Terminal=false
Type=Application
Categories=System;WindowManager;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ AwesomeWM Window Manager instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
