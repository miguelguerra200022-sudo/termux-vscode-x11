#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: THC-Hydra
# Tagline: Very fast network logon cracker supporting numerous remote authentication protocols
# Instalador: THC-Hydra (Very fast network logon cracker supporting numerous remote authentication protocols)
# Descripción: Herramienta rápida de prueba de fuerza bruta para protocolos de red.
# URL Oficial: https://github.com/vanhauser-thc/thc-hydra
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando THC-Hydra${NC}"
echo -e "${CYAN}  (Very fast network logon cracker supporting numerous remote authentication protocols)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y hydra

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/hydra.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=THC-Hydra Network Logon Cracker
Comment=Herramienta rápida de prueba de fuerza bruta para protocolos de red.
Exec=hydra
Icon=hydra
Terminal=false
Type=Application
Categories=Network;Security;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ THC-Hydra Network Logon Cracker instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
