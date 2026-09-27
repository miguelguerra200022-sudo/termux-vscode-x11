#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: PICO-8
# Tagline: A fantasy console for making, sharing and playing tiny games and chiptune music
# Instalador: PICO-8 (A fantasy console for making, sharing and playing tiny games and chiptune music)
# Descripción: Fantasía de consola para diseño, música y programación de juegos pixel-art.
# URL Oficial: https://www.lexaloffle.com/pico-8.php
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando PICO-8${NC}"
echo -e "${CYAN}  (A fantasy console for making, sharing and playing tiny games and chiptune music)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
pkg install -y pico8 || true

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/pico8.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=PICO-8 Fantasy Console
Comment=Fantasía de consola para diseño, música y programación de juegos pixel-art.
Exec=pico8
Icon=pico8
Terminal=false
Type=Application
Categories=Development;GameDevelopment;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ PICO-8 Fantasy Console instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
