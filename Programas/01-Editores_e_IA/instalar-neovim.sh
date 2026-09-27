#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Neovim
# Descripción: Editor de texto moderno basado en Vim con soporte Lua y LSP nativo.
# URL Oficial: https://neovim.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Neovim${NC}"
echo -e "${CYAN}  Editor de texto moderno basado en Vim con soporte Lua y LSP nativo.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y neovim

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/neovim.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Neovim
Comment=Editor de texto moderno basado en Vim con soporte Lua y LSP nativo.
Exec=neovim
Icon=neovim
Terminal=false
Type=Application
Categories=Development;TextEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Neovim instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
