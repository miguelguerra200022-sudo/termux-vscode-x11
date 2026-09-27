#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Alacritty
# Tagline: A fast, cross-platform, OpenGL-accelerated terminal emulator
# Instalador: Alacritty (A fast, cross-platform, OpenGL-accelerated terminal emulator)
# Descripción: Emulador de terminal ultra-rápido acelerado por GPU escrito en Rust.
# URL Oficial: https://alacritty.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Alacritty${NC}"
echo -e "${CYAN}  (A fast, cross-platform, OpenGL-accelerated terminal emulator)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete alacritty...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y alacritty

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/alacritty.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Alacritty GPU Terminal
Comment=Emulador de terminal ultra-rápido acelerado por GPU escrito en Rust.
Exec=alacritty
Icon=alacritty
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Alacritty GPU Terminal instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
