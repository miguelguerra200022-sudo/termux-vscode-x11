#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: LibreCAD
# Tagline: Aplicación de diseño asistido por computadora (CAD) 2D madura y de código abierto
# Instalador: LibreCAD (Aplicación de diseño asistido por computadora (CAD) 2D madura y de código abierto)
# Descripción: Sistema CAD 2D ligero para diseño técnico y planos arquitectónicos.
# URL Oficial: https://librecad.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando LibreCAD${NC}"
echo -e "${CYAN}  (Aplicación de diseño asistido por computadora (CAD) 2D madura y de código abierto)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete librecad...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y librecad

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/librecad.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=LibreCAD 2D
Comment=Sistema CAD 2D ligero para diseño técnico y planos arquitectónicos.
Exec=librecad
Icon=librecad
Terminal=false
Type=Application
Categories=Graphics;Engineering;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ LibreCAD 2D instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
