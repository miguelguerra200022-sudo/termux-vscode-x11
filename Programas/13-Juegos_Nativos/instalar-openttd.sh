#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: OpenTTD
# Tagline: El legendario simulador de transportes, trenes, barcos y ciudades
# Instalador: OpenTTD (El legendario simulador de transportes, trenes, barcos y ciudades)
# Descripción: Juego de simulación de negocios donde gestionas redes ferroviarias, carreteras y aeropuertos.
# URL Oficial: https://www.openttd.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando OpenTTD${NC}"
echo -e "${CYAN}  (El legendario simulador de transportes, trenes, barcos y ciudades)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete openttd...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v openttd >/dev/null 2>&1; then
    pkg install -y openttd >/dev/null 2>&1 || apt-get install -y openttd >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "13-Juegos_Nativos" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/openttd"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/openttd" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "openttd" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/openttd.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=OpenTTD (Transport Tycoon Deluxe)
Comment=Juego de simulación de negocios donde gestionas redes ferroviarias, carreteras y aeropuertos.
Exec=openttd
Icon=/data/data/com.termux/files/usr/share/pixmaps/openttd.png
Terminal=false
Type=Application
Categories=Game;Simulation;StrategyGame;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ OpenTTD instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
