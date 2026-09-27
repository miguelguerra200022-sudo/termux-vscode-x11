#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Ettercap
# Tagline: Comprehensive suite for man-in-the-middle attacks, sniffing and live filtering on LAN
# Instalador: Ettercap (Comprehensive suite for man-in-the-middle attacks, sniffing and live filtering on LAN)
# Descripción: Suite integral para interceptación de tráfico y filtrado de contenido en red.
# URL Oficial: https://www.ettercap-project.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Ettercap${NC}"
echo -e "${CYAN}  (Comprehensive suite for man-in-the-middle attacks, sniffing and live filtering on LAN)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y ettercap

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/ettercap.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Ettercap Network Interception
Comment=Suite integral para interceptación de tráfico y filtrado de contenido en red.
Exec=ettercap
Icon=ettercap
Terminal=false
Type=Application
Categories=Network;Security;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Ettercap Network Interception instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
