#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Links2
# Tagline: Navegador web ultraligero con soporte para modo gráfico y texto
# Instalador: Links2 (Navegador web ultraligero con soporte para modo gráfico y texto)
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
echo -e "${CYAN}  (Navegador web ultraligero con soporte para modo gráfico y texto)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete links2...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y links2

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "links2" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/links2.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Links2 (Modo Gráfico)
Comment=Navegador web ligero con soporte gráfico directo en pantalla X11.
Exec=links2 -g
Icon=/data/data/com.termux/files/usr/share/pixmaps/links2.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Links2 (Modo Gráfico) instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
