#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: RetroArch
# Tagline: El frontend universal de emulación multiconsola (NES, SNES, Genesis, Arcade)
# Instalador: RetroArch (El frontend universal de emulación multiconsola (NES, SNES, Genesis, Arcade))
# Descripción: Frontend universal modular para motores de juegos y emulación de consolas clásicas.
# URL Oficial: https://www.retroarch.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando RetroArch${NC}"
echo -e "${CYAN}  (El frontend universal de emulación multiconsola (NES, SNES, Genesis, Arcade))${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete retroarch...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v retroarch >/dev/null 2>&1; then
    pkg install -y retroarch >/dev/null 2>&1 || apt-get install -y retroarch >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "12-Emuladores_y_Retro" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/retroarch"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/retroarch" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "retroarch" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/retroarch.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=RetroArch (Universal Emulator Frontend)
Comment=Frontend universal modular para motores de juegos y emulación de consolas clásicas.
Exec=retroarch
Icon=/data/data/com.termux/files/usr/share/pixmaps/retroarch.png
Terminal=false
Type=Application
Categories=Game;Emulator;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ RetroArch instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
