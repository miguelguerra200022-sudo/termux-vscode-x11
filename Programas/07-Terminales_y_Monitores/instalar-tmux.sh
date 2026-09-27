#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Tmux
# Tagline: Multiplexor de terminales para gestionar múltiples sesiones, ventanas y paneles simultáneos
# Instalador: Tmux (Multiplexor de terminales para gestionar múltiples sesiones, ventanas y paneles simultáneos)
# Descripción: Multiplexor de terminales para mantener sesiones persistentes en background.
# URL Oficial: https://github.com/tmux/tmux
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Tmux${NC}"
echo -e "${CYAN}  (Multiplexor de terminales para gestionar múltiples sesiones, ventanas y paneles simultáneos)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y tmux

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "tmux" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/tmux.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Tmux Multiplexer
Comment=Multiplexor de terminales para mantener sesiones persistentes en background.
Exec=tmux
Icon=/data/data/com.termux/files/usr/share/pixmaps/tmux.png
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Tmux Multiplexer instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
