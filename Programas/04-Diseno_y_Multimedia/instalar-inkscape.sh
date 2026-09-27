#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Inkscape
# Tagline: A powerful, free design tool for professional vector graphics SVG
# Instalador: Inkscape (A powerful, free design tool for professional vector graphics SVG)
# Descripción: Editor profesional de gráficos vectoriales SVG y diseño ilustrativo.
# URL Oficial: https://inkscape.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Inkscape${NC}"
echo -e "${CYAN}  (A powerful, free design tool for professional vector graphics SVG)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete inkscape...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y inkscape

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/inkscape.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Inkscape Vector Graphics
Comment=Editor profesional de gráficos vectoriales SVG y diseño ilustrativo.
Exec=inkscape
Icon=inkscape
Terminal=false
Type=Application
Categories=Graphics;VectorEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Inkscape Vector Graphics instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
