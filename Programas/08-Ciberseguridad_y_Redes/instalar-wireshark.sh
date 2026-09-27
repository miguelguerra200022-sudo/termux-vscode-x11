#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Wireshark Packet Analyzer
# Descripción: Analizador de protocolos de red e inspección profunda de paquetes en X11.
# URL Oficial: https://www.wireshark.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Wireshark Packet Analyzer${NC}"
echo -e "${CYAN}  Analizador de protocolos de red e inspección profunda de paquetes en X11.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete wireshark...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y wireshark

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/wireshark.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Wireshark Packet Analyzer
Comment=Analizador de protocolos de red e inspección profunda de paquetes en X11.
Exec=wireshark
Icon=wireshark
Terminal=false
Type=Application
Categories=Network;Security;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Wireshark Packet Analyzer instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
