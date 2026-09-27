#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: LÖVE (Love2D)
# Descripción: Framework para desarrollo rápido de videojuegos 2D con lenguaje Lua.
# URL Oficial: https://love2d.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando LÖVE (Love2D)${NC}"
echo -e "${CYAN}  Framework para desarrollo rápido de videojuegos 2D con lenguaje Lua.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete love2d...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y love2d

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/love2d.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=LÖVE (Love2D)
Comment=Framework para desarrollo rápido de videojuegos 2D con lenguaje Lua.
Exec=love2d
Icon=love2d
Terminal=false
Type=Application
Categories=Development;GameDevelopment;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ LÖVE (Love2D) instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
