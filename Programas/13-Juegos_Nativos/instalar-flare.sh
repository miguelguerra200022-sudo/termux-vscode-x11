#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Flare RPG
# Tagline: Juego de rol de acción isométrica hack-and-slash estilo Diablo
# Instalador: Flare RPG (Juego de rol de acción isométrica hack-and-slash estilo Diablo)
# Descripción: Explora mazmorras, derrota hordas de monstruos y equipa armaduras legendarias.
# URL Oficial: https://flarerpg.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Flare RPG${NC}"
echo -e "${CYAN}  (Juego de rol de acción isométrica hack-and-slash estilo Diablo)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete flare-game...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v flare >/dev/null 2>&1; then
    pkg install -y flare-game >/dev/null 2>&1 || apt-get install -y flare-game >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "13-Juegos_Nativos" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/flare"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/flare" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "flare" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/flare.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Flare (Action RPG Hack & Slash)
Comment=Explora mazmorras, derrota hordas de monstruos y equipa armaduras legendarias.
Exec=flare
Icon=/data/data/com.termux/files/usr/share/pixmaps/flare.png
Terminal=false
Type=Application
Categories=Game;RolePlaying;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Flare RPG instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
