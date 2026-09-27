#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Nmap
# Tagline: Free and open source utility for network discovery, port scanning and security auditing
# Instalador: Nmap (Free and open source utility for network discovery, port scanning and security auditing)
# Descripción: Escáner de seguridad para exploración de redes y auditoría de puertos.
# URL Oficial: https://nmap.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Nmap${NC}"
echo -e "${CYAN}  (Free and open source utility for network discovery, port scanning and security auditing)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y nmap

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/nmap.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Nmap Network Scanner
Comment=Escáner de seguridad para exploración de redes y auditoría de puertos.
Exec=nmap
Icon=nmap
Terminal=false
Type=Application
Categories=Network;Security;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Nmap Network Scanner instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
