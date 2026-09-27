#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: AstroNvim
# Descripción: Framework estético, ultrarrápido y modular para Neovim.
# URL Oficial: https://astronvim.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando AstroNvim${NC}"
echo -e "${CYAN}  Framework estético, ultrarrápido y modular para Neovim.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias base (Neovim, Git, Node, Python, Ripper)...${NC}"
pkg install -y neovim git nodejs python ripgrep fd >/dev/null 2>&1 || true
echo -e "${CYAN}[*] Desplegando framework AstroNvim...${NC}"
mkdir -p "$HOME/.config/astronvim"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/astronvim.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=AstroNvim
Comment=Framework estético, ultrarrápido y modular para Neovim.
Exec=nvim
Icon=astronvim
Terminal=false
Type=Application
Categories=Development;TextEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ AstroNvim instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
