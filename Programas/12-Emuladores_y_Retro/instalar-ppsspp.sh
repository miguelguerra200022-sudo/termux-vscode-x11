#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: PPSSPP
# Tagline: El mejor emulador de PlayStation Portable (PSP) a 60 FPS con OpenGL
# Instalador: PPSSPP (El mejor emulador de PlayStation Portable (PSP) a 60 FPS con OpenGL)
# Descripción: Emulador de Sony PSP con soporte de texturas HD, filtros y mandos.
# URL Oficial: https://www.ppsspp.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando PPSSPP${NC}"
echo -e "${CYAN}  (El mejor emulador de PlayStation Portable (PSP) a 60 FPS con OpenGL)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Desplegando lanzador y soporte oficial de PPSSPP...${NC}"
REPO_DIR="$HOME/termux-vscode-x11"
[ -d "/sdcard/Antigravity/IdeasMillonarias/termux-vscode-x11" ] && REPO_DIR="/sdcard/Antigravity/IdeasMillonarias/termux-vscode-x11"
if [ -f "$REPO_DIR/bin/ppsspp" ]; then
    cp -f "$REPO_DIR/bin/ppsspp" "$PREFIX/bin/"
    chmod +x "$PREFIX/bin/ppsspp"
fi

# Asegurar directorios de soporte para juegos y emuladores
if [ "12-Emuladores_y_Retro" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/ppsspp"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/ppsspp" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "ppsspp" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/ppsspp.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=PPSSPP (PlayStation Portable Emulator)
Comment=Emulador de Sony PSP con soporte de texturas HD, filtros y mandos.
Exec=ppsspp
Icon=/data/data/com.termux/files/usr/share/pixmaps/ppsspp.png
Terminal=false
Type=Application
Categories=Game;Emulator;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ PPSSPP instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
