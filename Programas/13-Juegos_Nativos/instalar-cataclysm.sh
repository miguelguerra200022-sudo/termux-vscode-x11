#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Cataclysm: DDA
# Tagline: El simulador de supervivencia postapocalíptica y crafteo más profundo
# Instalador: Cataclysm: DDA (El simulador de supervivencia postapocalíptica y crafteo más profundo)
# Descripción: Sobrevive en un mundo implacable con zombis, mutaciones, vehículos blindados y búnkeres.
# URL Oficial: https://cataclysmdda.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Cataclysm: DDA${NC}"
echo -e "${CYAN}  (El simulador de supervivencia postapocalíptica y crafteo más profundo)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete cataclysm-dda-tiles...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v cataclysm-tiles >/dev/null 2>&1; then
    pkg install -y cataclysm-dda-tiles >/dev/null 2>&1 || apt-get install -y cataclysm-dda-tiles >/dev/null 2>&1 || true
fi
    if ! command -v cataclysm-tiles >/dev/null 2>&1; then
        echo -e "${YELLOW}[*] Probando paquete alternativo cataclysm-dda...${NC}"
        pkg install -y cataclysm-dda >/dev/null 2>&1 || apt-get install -y cataclysm-dda >/dev/null 2>&1 || true
    fi

# Asegurar directorios de soporte para juegos y emuladores
if [ "13-Juegos_Nativos" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/cataclysm"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/cataclysm" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "cataclysm" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/cataclysm.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Cataclysm: Dark Days Ahead (Roguelike)
Comment=Sobrevive en un mundo implacable con zombis, mutaciones, vehículos blindados y búnkeres.
Exec=cataclysm-tiles
Icon=/data/data/com.termux/files/usr/share/pixmaps/cataclysm.png
Terminal=false
Type=Application
Categories=Game;RolePlaying;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Cataclysm: DDA instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
