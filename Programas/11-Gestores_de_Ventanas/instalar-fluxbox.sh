#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Fluxbox
# Tagline: Lightweight and highly configurable window manager with built-in tabbed windows
# Instalador: Fluxbox (Lightweight and highly configurable window manager with built-in tabbed windows)
# Descripción: Gestor minimalista con agrupación de ventanas en pestañas integradas.
# URL Oficial: http://fluxbox.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Fluxbox${NC}"
echo -e "${CYAN}  (Lightweight and highly configurable window manager with built-in tabbed windows)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete fluxbox...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y fluxbox

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/fluxbox.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Fluxbox Window Manager
Comment=Gestor minimalista con agrupación de ventanas en pestañas integradas.
Exec=fluxbox
Icon=fluxbox
Terminal=false
Type=Application
Categories=System;WindowManager;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Fluxbox Window Manager instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
