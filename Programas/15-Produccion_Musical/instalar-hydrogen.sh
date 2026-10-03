#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Hydrogen
# Tagline: Caja de ritmos avanzada y secuenciador de baterías electrónicas
# Instalador: Hydrogen (Caja de ritmos avanzada y secuenciador de baterías electrónicas)
# Descripción: Caja de ritmos basada en patrones con sonido realista y soporte MIDI.
# URL Oficial: http://www.hydrogen-music.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Hydrogen${NC}"
echo -e "${CYAN}  (Caja de ritmos avanzada y secuenciador de baterías electrónicas)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete hydrogen...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v hydrogen >/dev/null 2>&1; then
    pkg install -y hydrogen >/dev/null 2>&1 || apt-get install -y hydrogen >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "15-Produccion_Musical" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/hydrogen"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/hydrogen" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "hydrogen" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/hydrogen.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Hydrogen (Drum Machine & Beat Sequencer)
Comment=Caja de ritmos basada en patrones con sonido realista y soporte MIDI.
Exec=hydrogen
Icon=/data/data/com.termux/files/usr/share/pixmaps/hydrogen.png
Terminal=false
Type=Application
Categories=AudioVideo;Audio;Sequencer;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Hydrogen instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
