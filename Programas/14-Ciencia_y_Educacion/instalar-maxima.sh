#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: wxMaxima
# Tagline: Sistema de álgebra computacional simbólica para resolver ecuaciones complejas
# Instalador: wxMaxima (Sistema de álgebra computacional simbólica para resolver ecuaciones complejas)
# Descripción: Cálculo simbólico y numérico: derivadas, integrales, matrices y expansión de series.
# URL Oficial: https://wxmaxima-developers.github.io/wxmaxima/
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando wxMaxima${NC}"
echo -e "${CYAN}  (Sistema de álgebra computacional simbólica para resolver ecuaciones complejas)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete wxmaxima...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v wxmaxima >/dev/null 2>&1; then
    pkg install -y wxmaxima >/dev/null 2>&1 || apt-get install -y wxmaxima >/dev/null 2>&1 || true
fi
    if ! command -v wxmaxima >/dev/null 2>&1; then
        echo -e "${YELLOW}[*] Probando paquete alternativo maxima...${NC}"
        pkg install -y maxima >/dev/null 2>&1 || apt-get install -y maxima >/dev/null 2>&1 || true
    fi

# Asegurar directorios de soporte para juegos y emuladores
if [ "14-Ciencia_y_Educacion" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/maxima"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/maxima" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "maxima" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/maxima.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=wxMaxima (Computer Algebra System)
Comment=Cálculo simbólico y numérico: derivadas, integrales, matrices y expansión de series.
Exec=wxmaxima
Icon=/data/data/com.termux/files/usr/share/pixmaps/maxima.png
Terminal=false
Type=Application
Categories=Education;Science;Math;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ wxMaxima instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
