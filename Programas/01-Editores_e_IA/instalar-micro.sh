#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Micro
# Tagline: Editor de texto moderno e intuitivo para terminal con soporte completo para ratón
# Instalador: Micro (Editor de texto moderno e intuitivo para terminal con soporte completo para ratón)
# Descripción: Editor de terminal intuitivo con soporte táctil de ratón y atajos estándar.
# URL Oficial: https://micro-editor.github.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Micro${NC}"
echo -e "${CYAN}  (Editor de texto moderno e intuitivo para terminal con soporte completo para ratón)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y micro

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/micro.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Micro Text Editor
Comment=Editor de terminal intuitivo con soporte táctil de ratón y atajos estándar.
Exec=micro
Icon=micro
Terminal=false
Type=Application
Categories=Development;TextEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Micro Text Editor instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
