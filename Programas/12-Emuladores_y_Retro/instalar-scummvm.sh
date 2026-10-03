#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: ScummVM
# Tagline: Motor para revivir las mejores aventuras gráficas clásicas de LucasArts
# Instalador: ScummVM (Motor para revivir las mejores aventuras gráficas clásicas de LucasArts)
# Descripción: Intérprete para jugar Monkey Island, Day of the Tentacle, Broken Sword y más.
# URL Oficial: https://www.scummvm.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando ScummVM${NC}"
echo -e "${CYAN}  (Motor para revivir las mejores aventuras gráficas clásicas de LucasArts)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Desplegando lanzador y soporte oficial de ScummVM...${NC}"
REPO_DIR="$HOME/termux-vscode-x11"
[ -d "/sdcard/Antigravity/IdeasMillonarias/termux-vscode-x11" ] && REPO_DIR="/sdcard/Antigravity/IdeasMillonarias/termux-vscode-x11"
if [ -f "$REPO_DIR/bin/scummvm" ]; then
    cp -f "$REPO_DIR/bin/scummvm" "$PREFIX/bin/"
    chmod +x "$PREFIX/bin/scummvm"
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "12-Emuladores_y_Retro" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/scummvm"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/scummvm" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "scummvm" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/scummvm.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=ScummVM (Classic Adventure Game Engine)
Comment=Intérprete para jugar Monkey Island, Day of the Tentacle, Broken Sword y más.
Exec=scummvm
Icon=/data/data/com.termux/files/usr/share/pixmaps/scummvm.png
Terminal=false
Type=Application
Categories=Game;AdventureGame;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ ScummVM instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
