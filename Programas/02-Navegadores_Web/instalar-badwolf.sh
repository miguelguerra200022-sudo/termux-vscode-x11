#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: BadWolf Browser
# Descripción: Navegador minimalista enfocado en privacidad y aislamiento estricto.
# URL Oficial: https://hacktivis.me/projects/badwolf
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando BadWolf Browser${NC}"
echo -e "${CYAN}  Navegador minimalista enfocado en privacidad y aislamiento estricto.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete badwolf...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y badwolf

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/badwolf.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=BadWolf Browser
Comment=Navegador minimalista enfocado en privacidad y aislamiento estricto.
Exec=badwolf
Icon=badwolf
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ BadWolf Browser instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
