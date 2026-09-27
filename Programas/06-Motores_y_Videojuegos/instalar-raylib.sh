#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Raylib
# Tagline: Librería de programación de videojuegos simple, amigable y altamente optimizada en C
# Instalador: raylib (Librería de programación de videojuegos simple, amigable y altamente optimizada en C)
# Descripción: Biblioteca para programación de videojuegos en C/C++ y herramientas.
# URL Oficial: https://www.raylib.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Raylib${NC}"
echo -e "${CYAN}  (Librería de programación de videojuegos simple, amigable y altamente optimizada en C)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y raylib

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/raylib.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Raylib Game Library
Comment=Biblioteca para programación de videojuegos en C/C++ y herramientas.
Exec=raylib
Icon=raylib
Terminal=false
Type=Application
Categories=Development;Libraries;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Raylib Game Library instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
