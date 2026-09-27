#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Lazarus
# Tagline: The professional Free Pascal RAD IDE with visual drag-and-drop designer
# Instalador: Lazarus (The professional Free Pascal RAD IDE with visual drag-and-drop designer)
# Descripción: Entorno de desarrollo visual con diseñador de interfaces gráficas.
# URL Oficial: https://www.lazarus-ide.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Lazarus${NC}"
echo -e "${CYAN}  (The professional Free Pascal RAD IDE with visual drag-and-drop designer)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete lazarus...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y lazarus

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/lazarus.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Lazarus IDE (Free Pascal)
Comment=Entorno de desarrollo visual con diseñador de interfaces gráficas.
Exec=lazarus
Icon=lazarus
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Lazarus IDE (Free Pascal) instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
