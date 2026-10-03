#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: GeoGebra
# Tagline: Matemáticas visuales, geometría interactiva, álgebra y cálculo
# Instalador: GeoGebra (Matemáticas visuales, geometría interactiva, álgebra y cálculo)
# Descripción: Software dinámico de matemáticas para todas las etapas educativas con gráficos 2D y 3D.
# URL Oficial: https://www.geogebra.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando GeoGebra${NC}"
echo -e "${CYAN}  (Matemáticas visuales, geometría interactiva, álgebra y cálculo)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete geogebra...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v geogebra >/dev/null 2>&1; then
    pkg install -y geogebra >/dev/null 2>&1 || apt-get install -y geogebra >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "14-Ciencia_y_Educacion" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/geogebra"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/geogebra" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "geogebra" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/geogebra.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=GeoGebra (Dynamic Mathematics Suite)
Comment=Software dinámico de matemáticas para todas las etapas educativas con gráficos 2D y 3D.
Exec=geogebra
Icon=/data/data/com.termux/files/usr/share/pixmaps/geogebra.png
Terminal=false
Type=Application
Categories=Education;Science;Math;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ GeoGebra instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
