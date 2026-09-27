#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Void Editor (Open Source Cursor)
# Descripción: Alternativa open-source a Cursor construida sobre VS Code.
# URL Oficial: https://github.com/voideditor/void
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Void Editor (Open Source Cursor)${NC}"
echo -e "${CYAN}  Alternativa open-source a Cursor construida sobre VS Code.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
pkg install -y void-editor || true

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/void-editor.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Void Editor (Open Source Cursor)
Comment=Alternativa open-source a Cursor construida sobre VS Code.
Exec=void-editor
Icon=void-editor
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Void Editor (Open Source Cursor) instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
