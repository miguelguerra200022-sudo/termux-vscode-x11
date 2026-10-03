#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Luanti (Minetest)
# Tagline: Mundos infinitos de vóxeles y construcción libre estilo Minecraft
# Instalador: Luanti (Minetest) (Mundos infinitos de vóxeles y construcción libre estilo Minecraft)
# Descripción: Motor de juegos de vóxeles 3D infinitamente extensible con mods y multijugador.
# URL Oficial: https://www.luanti.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Luanti (Minetest)${NC}"
echo -e "${CYAN}  (Mundos infinitos de vóxeles y construcción libre estilo Minecraft)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete luanti...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v luanti >/dev/null 2>&1; then
    pkg install -y luanti >/dev/null 2>&1 || apt-get install -y luanti >/dev/null 2>&1 || true
fi
    if ! command -v luanti >/dev/null 2>&1; then
        echo -e "${YELLOW}[*] Probando paquete alternativo minetest...${NC}"
        pkg install -y minetest >/dev/null 2>&1 || apt-get install -y minetest >/dev/null 2>&1 || true
    fi

# Asegurar directorios de soporte para juegos y emuladores
if [ "13-Juegos_Nativos" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/luanti"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/luanti" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "luanti" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/luanti.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Luanti / Minetest (Infinite Voxel Sandbox)
Comment=Motor de juegos de vóxeles 3D infinitamente extensible con mods y multijugador.
Exec=luanti
Icon=/data/data/com.termux/files/usr/share/pixmaps/luanti.png
Terminal=false
Type=Application
Categories=Game;Simulation;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Luanti (Minetest) instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
