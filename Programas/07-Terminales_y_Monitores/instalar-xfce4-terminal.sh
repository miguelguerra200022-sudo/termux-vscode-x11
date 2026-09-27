#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: XFCE4 Terminal
# Tagline: Emulador de terminal ligero, altamente personalizable y eficiente para entornos X11
# Instalador: XFCE4 Terminal (Emulador de terminal ligero, altamente personalizable y eficiente para entornos X11)
# Descripción: Terminal gráfica con pestañas, colores personalizables y menú contextual.
# URL Oficial: https://docs.xfce.org/apps/terminal/start
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando XFCE4 Terminal${NC}"
echo -e "${CYAN}  (Emulador de terminal ligero, altamente personalizable y eficiente para entornos X11)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete xfce4-terminal...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y xfce4-terminal

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "xfce4-terminal" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/xfce4-terminal.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=XFCE4 Terminal
Comment=Terminal gráfica con pestañas, colores personalizables y menú contextual.
Exec=xfce4-terminal
Icon=/data/data/com.termux/files/usr/share/pixmaps/xfce4-terminal.png
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ XFCE4 Terminal instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
