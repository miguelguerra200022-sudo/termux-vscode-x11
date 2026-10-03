#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: GNU Octave
# Tagline: Software de computación matemática y cálculo matricial (Alternativa a MATLAB)
# Instalador: GNU Octave (Software de computación matemática y cálculo matricial (Alternativa a MATLAB))
# Descripción: Lenguaje de programación de alto nivel para computación numérica y gráficos científicos.
# URL Oficial: https://octave.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando GNU Octave${NC}"
echo -e "${CYAN}  (Software de computación matemática y cálculo matricial (Alternativa a MATLAB))${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete octave...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v octave >/dev/null 2>&1; then
    pkg install -y octave >/dev/null 2>&1 || apt-get install -y octave >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "14-Ciencia_y_Educacion" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/octave"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/octave" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "octave" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/octave.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=GNU Octave (Scientific Computing)
Comment=Lenguaje de programación de alto nivel para computación numérica y gráficos científicos.
Exec=octave --gui
Icon=/data/data/com.termux/files/usr/share/pixmaps/octave.png
Terminal=false
Type=Application
Categories=Education;Science;Math;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ GNU Octave instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
