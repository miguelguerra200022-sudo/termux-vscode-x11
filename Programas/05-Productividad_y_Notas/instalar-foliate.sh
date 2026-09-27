#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Foliate E-Book Reader
# Descripción: Lector moderno de libros digitales (EPUB, PDF, MOBI, CBR) para X11.
# URL Oficial: https://johnfactotum.github.io/foliate/
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Foliate E-Book Reader${NC}"
echo -e "${CYAN}  Lector moderno de libros digitales (EPUB, PDF, MOBI, CBR) para X11.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete foliate...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y foliate

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/foliate.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Foliate E-Book Reader
Comment=Lector moderno de libros digitales (EPUB, PDF, MOBI, CBR) para X11.
Exec=foliate
Icon=foliate
Terminal=false
Type=Application
Categories=Office;Viewer;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Foliate E-Book Reader instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
