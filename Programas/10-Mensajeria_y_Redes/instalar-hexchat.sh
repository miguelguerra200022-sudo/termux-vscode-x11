#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: HexChat
# Tagline: Cliente IRC fácil de usar, personalizable y de código abierto para entornos gráficos
# Instalador: HexChat (Cliente IRC fácil de usar, personalizable y de código abierto para entornos gráficos)
# Descripción: Cliente IRC gráfico clásico, altamente personalizable y ligero.
# URL Oficial: https://hexchat.github.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando HexChat${NC}"
echo -e "${CYAN}  (Cliente IRC fácil de usar, personalizable y de código abierto para entornos gráficos)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete hexchat...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y hexchat

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "hexchat" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/hexchat.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=HexChat IRC Client
Comment=Cliente IRC gráfico clásico, altamente personalizable y ligero.
Exec=hexchat
Icon=/data/data/com.termux/files/usr/share/pixmaps/hexchat.png
Terminal=false
Type=Application
Categories=Network;IRCClient;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ HexChat IRC Client instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
