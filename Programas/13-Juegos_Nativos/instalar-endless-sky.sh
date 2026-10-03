#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Endless Sky
# Tagline: Exploración espacial, combate estelar y comercio galáctico 2D
# Instalador: Endless Sky (Exploración espacial, combate estelar y comercio galáctico 2D)
# Descripción: Comienza como capitán de una pequeña nave y expande tu flota por la galaxia.
# URL Oficial: https://endless-sky.github.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Endless Sky${NC}"
echo -e "${CYAN}  (Exploración espacial, combate estelar y comercio galáctico 2D)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete endless-sky...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v endless-sky >/dev/null 2>&1; then
    pkg install -y endless-sky >/dev/null 2>&1 || apt-get install -y endless-sky >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "13-Juegos_Nativos" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/endless-sky"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/endless-sky" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "endless-sky" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/endless-sky.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Endless Sky (Space Exploration & Trade)
Comment=Comienza como capitán de una pequeña nave y expande tu flota por la galaxia.
Exec=endless-sky
Icon=/data/data/com.termux/files/usr/share/pixmaps/endless-sky.png
Terminal=false
Type=Application
Categories=Game;Simulation;SpaceGame;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Endless Sky instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
