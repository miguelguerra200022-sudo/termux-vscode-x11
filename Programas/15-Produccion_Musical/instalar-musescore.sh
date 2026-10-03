#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: MuseScore
# Tagline: Editor y reproductor profesional de partituras orquestales
# Instalador: MuseScore (Editor y reproductor profesional de partituras orquestales)
# Descripción: Creación, edición y reproducción de notación musical para todos los instrumentos.
# URL Oficial: https://musescore.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando MuseScore${NC}"
echo -e "${CYAN}  (Editor y reproductor profesional de partituras orquestales)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete musescore...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v musescore >/dev/null 2>&1; then
    pkg install -y musescore >/dev/null 2>&1 || apt-get install -y musescore >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "15-Produccion_Musical" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/musescore"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/musescore" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "musescore" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/musescore.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=MuseScore (Music Notation & Scoring)
Comment=Creación, edición y reproducción de notación musical para todos los instrumentos.
Exec=musescore
Icon=/data/data/com.termux/files/usr/share/pixmaps/musescore.png
Terminal=false
Type=Application
Categories=AudioVideo;Audio;Education;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ MuseScore instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
