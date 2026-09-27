#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Chromium
# Tagline: The open-source browser project building a safer, faster way to experience the web
# Instalador: Chromium (The open-source browser project building a safer, faster way to experience the web)
# Descripción: Navegador web de código abierto con aceleración y motor Blink.
# URL Oficial: https://www.chromium.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Chromium${NC}"
echo -e "${CYAN}  (The open-source browser project building a safer, faster way to experience the web)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete chromium...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y chromium

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/chromium.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Chromium (Termux:X11)
Comment=Navegador web de código abierto con aceleración y motor Blink.
Exec=chromium
Icon=chromium
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Chromium (Termux:X11) instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
