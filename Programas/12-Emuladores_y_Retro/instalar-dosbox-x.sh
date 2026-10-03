#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: DOSBox-X
# Tagline: Emulador completo de arquitectura de PC y juegos MS-DOS clásicos
# Instalador: DOSBox-X (Emulador completo de arquitectura de PC y juegos MS-DOS clásicos)
# Descripción: Emulación completa de hardware de PC, sonido SoundBlaster y juegos de los años 80 y 90.
# URL Oficial: https://dosbox-x.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando DOSBox-X${NC}"
echo -e "${CYAN}  (Emulador completo de arquitectura de PC y juegos MS-DOS clásicos)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete dosbox-x...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v dosbox-x >/dev/null 2>&1; then
    pkg install -y dosbox-x >/dev/null 2>&1 || apt-get install -y dosbox-x >/dev/null 2>&1 || true
fi
    if ! command -v dosbox-x >/dev/null 2>&1; then
        echo -e "${YELLOW}[*] Probando paquete alternativo dosbox...${NC}"
        pkg install -y dosbox >/dev/null 2>&1 || apt-get install -y dosbox >/dev/null 2>&1 || true
    fi

# Asegurar directorios de soporte para juegos y emuladores
if [ "12-Emuladores_y_Retro" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/dosbox-x"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/dosbox-x" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "dosbox-x" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/dosbox-x.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=DOSBox-X (MS-DOS PC Emulator)
Comment=Emulación completa de hardware de PC, sonido SoundBlaster y juegos de los años 80 y 90.
Exec=dosbox-x
Icon=/data/data/com.termux/files/usr/share/pixmaps/dosbox-x.png
Terminal=false
Type=Application
Categories=Game;Emulator;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ DOSBox-X instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
