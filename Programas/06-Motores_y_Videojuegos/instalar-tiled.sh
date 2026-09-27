#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Tiled
# Tagline: A flexible and easy-to-use 2D level and tilemap editor
# Instalador: Tiled (A flexible and easy-to-use 2D level and tilemap editor)
# Descripción: Editor profesional de mapas y niveles basados en mosaicos/tiles.
# URL Oficial: https://www.mapeditor.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Tiled${NC}"
echo -e "${CYAN}  (A flexible and easy-to-use 2D level and tilemap editor)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete tiled...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y tiled

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/tiled.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Tiled Map Editor
Comment=Editor profesional de mapas y niveles basados en mosaicos/tiles.
Exec=tiled
Icon=tiled
Terminal=false
Type=Application
Categories=Development;GameDevelopment;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Tiled Map Editor instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
