#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: GIMP
# Tagline: The Free & Open Source Image Editor for photo retouching and graphic artwork
# Instalador: GIMP (The Free & Open Source Image Editor for photo retouching and graphic artwork)
# Descripción: Editor avanzado de imágenes, retoque fotográfico y pintura digital.
# URL Oficial: https://www.gimp.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando GIMP${NC}"
echo -e "${CYAN}  (The Free & Open Source Image Editor for photo retouching and graphic artwork)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete gimp...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y gimp

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/gimp.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=GIMP (GNU Image Manipulation Program)
Comment=Editor avanzado de imágenes, retoque fotográfico y pintura digital.
Exec=gimp
Icon=gimp
Terminal=false
Type=Application
Categories=Graphics;RasterEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ GIMP (GNU Image Manipulation Program) instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
