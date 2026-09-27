#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Helix
# Tagline: Editor modal posmoderno escrito en Rust con configuración cero
# Instalador: Helix (Editor modal posmoderno escrito en Rust con configuración cero)
# Descripción: Editor modal moderno en Rust con selección múltiple y configuración zero.
# URL Oficial: https://helix-editor.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Helix${NC}"
echo -e "${CYAN}  (Editor modal posmoderno escrito en Rust con configuración cero)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y helix

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "helix" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/helix.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Helix Editor
Comment=Editor modal moderno en Rust con selección múltiple y configuración zero.
Exec=helix
Icon=/data/data/com.termux/files/usr/share/pixmaps/helix.png
Terminal=false
Type=Application
Categories=Development;TextEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Helix Editor instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
