#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Aircrack-ng Suite
# Descripción: Herramientas de evaluación y auditoría de seguridad para redes inalámbricas.
# URL Oficial: https://www.aircrack-ng.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Aircrack-ng Suite${NC}"
echo -e "${CYAN}  Herramientas de evaluación y auditoría de seguridad para redes inalámbricas.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y aircrack-ng

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/aircrack-ng.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Aircrack-ng Suite
Comment=Herramientas de evaluación y auditoría de seguridad para redes inalámbricas.
Exec=aircrack-ng
Icon=aircrack-ng
Terminal=false
Type=Application
Categories=Network;Security;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Aircrack-ng Suite instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
