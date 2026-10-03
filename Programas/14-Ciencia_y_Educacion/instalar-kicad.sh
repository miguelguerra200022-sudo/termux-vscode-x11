#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: KiCad
# Tagline: Suite profesional para diseño de esquemas electrónicos y placas PCB
# Instalador: KiCad (Suite profesional para diseño de esquemas electrónicos y placas PCB)
# Descripción: Captura de esquemáticos, trazado de circuitos impresos y visor 3D de placas.
# URL Oficial: https://www.kicad.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando KiCad${NC}"
echo -e "${CYAN}  (Suite profesional para diseño de esquemas electrónicos y placas PCB)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete kicad...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v kicad >/dev/null 2>&1; then
    pkg install -y kicad >/dev/null 2>&1 || apt-get install -y kicad >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "14-Ciencia_y_Educacion" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/kicad"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/kicad" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "kicad" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/kicad.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=KiCad (Electronic Design Automation Suite)
Comment=Captura de esquemáticos, trazado de circuitos impresos y visor 3D de placas.
Exec=kicad
Icon=/data/data/com.termux/files/usr/share/pixmaps/kicad.png
Terminal=false
Type=Application
Categories=Development;Electronics;Engineering;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ KiCad instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
