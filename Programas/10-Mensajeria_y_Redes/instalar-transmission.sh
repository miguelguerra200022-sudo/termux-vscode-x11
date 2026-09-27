#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Transmission
# Tagline: Cliente BitTorrent rápido, ligero y fácil de usar con bajo consumo de recursos
# Instalador: Transmission (Cliente BitTorrent rápido, ligero y fácil de usar con bajo consumo de recursos)
# Descripción: Cliente BitTorrent ligero y rápido para descargas eficientes en segundo plano.
# URL Oficial: https://transmissionbt.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Transmission${NC}"
echo -e "${CYAN}  (Cliente BitTorrent rápido, ligero y fácil de usar con bajo consumo de recursos)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete transmission...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y transmission

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "transmission" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/transmission.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Transmission GTK Torrent
Comment=Cliente BitTorrent ligero y rápido para descargas eficientes en segundo plano.
Exec=transmission
Icon=/data/data/com.termux/files/usr/share/pixmaps/transmission.png
Terminal=false
Type=Application
Categories=Network;FileTransfer;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Transmission GTK Torrent instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
