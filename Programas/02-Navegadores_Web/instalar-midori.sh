#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Midori
# Tagline: Navegador web ligero, rápido y seguro basado en el motor WebKitGTK
# Instalador: Midori (Navegador web ligero, rápido y seguro basado en el motor WebKitGTK)
# Descripción: Navegador ultra-ligero basado en WebKitGTK con mínimo consumo de RAM.
# URL Oficial: https://astian.org/midori-browser
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Midori${NC}"
echo -e "${CYAN}  (Navegador web ligero, rápido y seguro basado en el motor WebKitGTK)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete midori...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y midori

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "midori" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/midori.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Midori Web Browser
Comment=Navegador ultra-ligero basado en WebKitGTK con mínimo consumo de RAM.
Exec=midori
Icon=/data/data/com.termux/files/usr/share/pixmaps/midori.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Midori Web Browser instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
