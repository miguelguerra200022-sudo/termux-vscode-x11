#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: i3wm
# Tagline: Tiling window manager, primarily targeted at advanced users and developers
# Instalador: i3wm (Tiling window manager, primarily targeted at advanced users and developers)
# Descripción: Gestor de ventanas en mosaico automático ideal para programadores por teclado.
# URL Oficial: https://i3wm.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando i3wm${NC}"
echo -e "${CYAN}  (Tiling window manager, primarily targeted at advanced users and developers)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete i3-wm...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y i3-wm

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/i3-wm.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=i3 Tiling Window Manager
Comment=Gestor de ventanas en mosaico automático ideal para programadores por teclado.
Exec=i3-wm
Icon=i3-wm
Terminal=false
Type=Application
Categories=System;WindowManager;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ i3 Tiling Window Manager instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
