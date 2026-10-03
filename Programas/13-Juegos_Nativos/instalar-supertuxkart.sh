#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: SuperTuxKart
# Tagline: Juego de carreras 3D arcade con aceleración gráfica por hardware
# Instalador: SuperTuxKart (Juego de carreras 3D arcade con aceleración gráfica por hardware)
# Descripción: Compite con Tux y sus amigos en circuitos 3D con armas, poderes y copas de carreras.
# URL Oficial: https://supertuxkart.net
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando SuperTuxKart${NC}"
echo -e "${CYAN}  (Juego de carreras 3D arcade con aceleración gráfica por hardware)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete supertuxkart...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v supertuxkart >/dev/null 2>&1; then
    pkg install -y supertuxkart >/dev/null 2>&1 || apt-get install -y supertuxkart >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "13-Juegos_Nativos" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/supertuxkart"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/supertuxkart" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "supertuxkart" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/supertuxkart.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=SuperTuxKart (3D Kart Racing)
Comment=Compite con Tux y sus amigos en circuitos 3D con armas, poderes y copas de carreras.
Exec=supertuxkart
Icon=/data/data/com.termux/files/usr/share/pixmaps/supertuxkart.png
Terminal=false
Type=Application
Categories=Game;ArcadeGame;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ SuperTuxKart instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
