#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Evince Document Viewer
# Descripción: Visor de documentos PDF, PostScript y cómics rápido y ligero.
# URL Oficial: https://wiki.gnome.org/Apps/Evince
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Evince Document Viewer${NC}"
echo -e "${CYAN}  Visor de documentos PDF, PostScript y cómics rápido y ligero.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete evince...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y evince

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/evince.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Evince Document Viewer
Comment=Visor de documentos PDF, PostScript y cómics rápido y ligero.
Exec=evince
Icon=evince
Terminal=false
Type=Application
Categories=Office;Viewer;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Evince Document Viewer instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
