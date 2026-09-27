#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Kakoune
# Tagline: Editor de texto modal con selecciones múltiples y retroalimentación visual interactiva
# Instalador: Kakoune (Editor de texto modal con selecciones múltiples y retroalimentación visual interactiva)
# Descripción: Editor modal interactivo con selección primero y acción después.
# URL Oficial: https://kakoune.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Kakoune${NC}"
echo -e "${CYAN}  (Editor de texto modal con selecciones múltiples y retroalimentación visual interactiva)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y kakoune

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "kakoune" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/kakoune.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Kakoune
Comment=Editor modal interactivo con selección primero y acción después.
Exec=kakoune
Icon=/data/data/com.termux/files/usr/share/pixmaps/kakoune.png
Terminal=false
Type=Application
Categories=Development;TextEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Kakoune instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
