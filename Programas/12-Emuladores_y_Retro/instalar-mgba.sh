#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: mGBA
# Tagline: Emulador de Game Boy Advance de alta fidelidad, rápido y ligero
# Instalador: mGBA (Emulador de Game Boy Advance de alta fidelidad, rápido y ligero)
# Descripción: Emulador preciso y optimizado para Game Boy, Game Boy Color y Game Boy Advance.
# URL Oficial: https://mgba.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando mGBA${NC}"
echo -e "${CYAN}  (Emulador de Game Boy Advance de alta fidelidad, rápido y ligero)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete mgba-qt...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v mgba-qt >/dev/null 2>&1; then
    pkg install -y mgba-qt >/dev/null 2>&1 || apt-get install -y mgba-qt >/dev/null 2>&1 || true
fi
    if ! command -v mgba-qt >/dev/null 2>&1; then
        echo -e "${YELLOW}[*] Probando paquete alternativo mgba...${NC}"
        pkg install -y mgba >/dev/null 2>&1 || apt-get install -y mgba >/dev/null 2>&1 || true
    fi

# Asegurar directorios de soporte para juegos y emuladores
if [ "12-Emuladores_y_Retro" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/mgba"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/mgba" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "mgba" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/mgba.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=mGBA (Game Boy Advance Emulator)
Comment=Emulador preciso y optimizado para Game Boy, Game Boy Color y Game Boy Advance.
Exec=mgba-qt
Icon=/data/data/com.termux/files/usr/share/pixmaps/mgba.png
Terminal=false
Type=Application
Categories=Game;Emulator;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ mGBA instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
