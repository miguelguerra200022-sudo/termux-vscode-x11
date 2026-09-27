#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: bspwm Tiling Window Manager
# Descripción: Gestor de ventanas en mosaico que representa ventanas como hojas de árbol binario.
# URL Oficial: https://github.com/baskerville/bspwm
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando bspwm Tiling Window Manager${NC}"
echo -e "${CYAN}  Gestor de ventanas en mosaico que representa ventanas como hojas de árbol binario.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete bspwm...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y bspwm

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/bspwm.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=bspwm Tiling Window Manager
Comment=Gestor de ventanas en mosaico que representa ventanas como hojas de árbol binario.
Exec=bspwm
Icon=bspwm
Terminal=false
Type=Application
Categories=System;WindowManager;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ bspwm Tiling Window Manager instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
