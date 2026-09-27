#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Dillo
# Tagline: Navegador web gráfico multiplataforma conocido por su velocidad y diminuto consumo de memoria
# Instalador: Dillo (Navegador web gráfico multiplataforma conocido por su velocidad y diminuto consumo de memoria)
# Descripción: Navegador gráfico ultra-rápido que consume menos de 20 MB de memoria RAM.
# URL Oficial: https://dillo-browser.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Dillo${NC}"
echo -e "${CYAN}  (Navegador web gráfico multiplataforma conocido por su velocidad y diminuto consumo de memoria)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete dillo...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y dillo

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "dillo" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/dillo.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Dillo Browser
Comment=Navegador gráfico ultra-rápido que consume menos de 20 MB de memoria RAM.
Exec=dillo
Icon=/data/data/com.termux/files/usr/share/pixmaps/dillo.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Dillo Browser instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
