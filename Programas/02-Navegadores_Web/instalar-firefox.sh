#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Mozilla Firefox
# Tagline: El navegador independiente que prioriza a las personas, la privacidad y los estándares abiertos
# Instalador: Mozilla Firefox (El navegador independiente que prioriza a las personas, la privacidad y los estándares abiertos)
# Descripción: Navegador web de soporte extendido con renderizado gráfico para X11.
# URL Oficial: https://www.mozilla.org/firefox
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Mozilla Firefox${NC}"
echo -e "${CYAN}  (El navegador independiente que prioriza a las personas, la privacidad y los estándares abiertos)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete firefox...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y firefox

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/firefox.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Mozilla Firefox ESR
Comment=Navegador web de soporte extendido con renderizado gráfico para X11.
Exec=firefox
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Mozilla Firefox ESR instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
