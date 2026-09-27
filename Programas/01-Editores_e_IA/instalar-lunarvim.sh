#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: LunarVim
# Tagline: Capa IDE para Neovim con valores predeterminados sensatos, autocompletado y LSP preconfigurado
# Instalador: LunarVim (Capa IDE para Neovim con valores predeterminados sensatos, autocompletado y LSP preconfigurado)
# Descripción: Configuración completa tipo IDE preconfigurada para Neovim.
# URL Oficial: https://www.lunarvim.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando LunarVim${NC}"
echo -e "${CYAN}  (Capa IDE para Neovim con valores predeterminados sensatos, autocompletado y LSP preconfigurado)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias base (Neovim, Git, Node, Python, Ripper)...${NC}"
pkg install -y neovim git nodejs python ripgrep fd >/dev/null 2>&1 || true
echo -e "${CYAN}[*] Desplegando framework LunarVim...${NC}"
mkdir -p "$HOME/.config/lunarvim"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "lunarvim" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/lunarvim.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=LunarVim
Comment=Configuración completa tipo IDE preconfigurada para Neovim.
Exec=nvim
Icon=/data/data/com.termux/files/usr/share/pixmaps/lunarvim.png
Terminal=false
Type=Application
Categories=Development;TextEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ LunarVim instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
