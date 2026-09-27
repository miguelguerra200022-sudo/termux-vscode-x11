#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Bettercap
# Tagline: Framework suizo completo, modular y portátil para reconocimiento y ataques Man-in-the-Middle
# Instalador: Bettercap (Framework suizo completo, modular y portátil para reconocimiento y ataques Man-in-the-Middle)
# Descripción: Herramienta completa para ataques Man-in-the-Middle y redes inalámbricas.
# URL Oficial: https://www.bettercap.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Bettercap${NC}"
echo -e "${CYAN}  (Framework suizo completo, modular y portátil para reconocimiento y ataques Man-in-the-Middle)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y bettercap

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "bettercap" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/bettercap.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Bettercap Framework
Comment=Herramienta completa para ataques Man-in-the-Middle y redes inalámbricas.
Exec=bettercap
Icon=/data/data/com.termux/files/usr/share/pixmaps/bettercap.png
Terminal=false
Type=Application
Categories=Network;Security;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Bettercap Framework instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
