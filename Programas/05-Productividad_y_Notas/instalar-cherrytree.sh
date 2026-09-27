#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: CherryTree
# Tagline: Aplicación jerárquica para toma de notas con resaltado de sintaxis y almacenamiento seguro
# Instalador: CherryTree (Aplicación jerárquica para toma de notas con resaltado de sintaxis y almacenamiento seguro)
# Descripción: Organizador jerárquico de notas con resaltado de código y cifrado.
# URL Oficial: https://www.giuspen.net/cherrytree/
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando CherryTree${NC}"
echo -e "${CYAN}  (Aplicación jerárquica para toma de notas con resaltado de sintaxis y almacenamiento seguro)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete cherrytree...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y cherrytree

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "cherrytree" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/cherrytree.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=CherryTree Hierarchical Notes
Comment=Organizador jerárquico de notas con resaltado de código y cifrado.
Exec=cherrytree
Icon=/data/data/com.termux/files/usr/share/pixmaps/cherrytree.png
Terminal=false
Type=Application
Categories=Office;Notes;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ CherryTree Hierarchical Notes instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
