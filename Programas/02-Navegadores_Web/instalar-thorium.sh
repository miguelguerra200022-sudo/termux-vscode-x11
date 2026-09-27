#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Thorium
# Tagline: El navegador más rápido de la Tierra optimizado por compilador con base Chromium
# Instalador: Thorium (El navegador más rápido de la Tierra optimizado por compilador con base Chromium)
# Descripción: Navegador hiper-optimizado para máxima velocidad de compilación y carga.
# URL Oficial: https://thorium.rocks
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Thorium${NC}"
echo -e "${CYAN}  (El navegador más rápido de la Tierra optimizado por compilador con base Chromium)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando Termux User Repository (TUR)...${NC}"
pkg install -y tur-repo >/dev/null 2>&1 || true
pkg install -y thorium-browser || pkg install -y thorium || true

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "thorium" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/thorium.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Thorium Browser
Comment=Navegador hiper-optimizado para máxima velocidad de compilación y carga.
Exec=thorium-browser
Icon=/data/data/com.termux/files/usr/share/pixmaps/thorium.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Thorium Browser instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
