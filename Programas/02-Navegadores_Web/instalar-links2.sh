#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Links2
# Tagline: Fast lightweight web browser with native graphical and text mode support
# Instalador: Links2 (Fast lightweight web browser with native graphical and text mode support)
# Descripción: Navegador web ligero con soporte gráfico directo en pantalla X11.
# URL Oficial: http://links.twibright.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Links2${NC}"
echo -e "${CYAN}  (Fast lightweight web browser with native graphical and text mode support)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete links2...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y links2

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/links2.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Links2 (Modo Gráfico)
Comment=Navegador web ligero con soporte gráfico directo en pantalla X11.
Exec=links2 -g
Icon=links2
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Links2 (Modo Gráfico) instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
