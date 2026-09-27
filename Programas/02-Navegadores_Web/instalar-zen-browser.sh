#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Zen Browser
# Tagline: Experience tranquility while browsing the web - Fast, private and beautiful
# Instalador: Zen Browser (Experience tranquility while browsing the web - Fast, private and beautiful)
# Descripción: Navegador web moderno centrado en privacidad, diseño y pestañas verticales.
# URL Oficial: https://zen-browser.app
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Zen Browser${NC}"
echo -e "${CYAN}  (Experience tranquility while browsing the web - Fast, private and beautiful)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Verificando e instalando Zen Browser para Termux:X11...${NC}"
pkg install -y tur-repo >/dev/null 2>&1 || true
pkg install -y zen-browser || true
exec_cmd="zen-browser"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/zen-browser.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Zen Browser
Comment=Navegador web moderno centrado en privacidad, diseño y pestañas verticales.
Exec=zen-browser
Icon=zen-browser
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Zen Browser instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
