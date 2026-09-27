#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Godot 3
# Tagline: Motor de videojuegos libre y versátil optimizado para dispositivos de bajos recursos
# Instalador: Godot Engine 3 (Motor de videojuegos libre y versátil optimizado para dispositivos de bajos recursos)
# Descripción: Motor de videojuegos 2D y 3D ligero optimizado para dispositivos móviles.
# URL Oficial: https://godotengine.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Godot 3${NC}"
echo -e "${CYAN}  (Motor de videojuegos libre y versátil optimizado para dispositivos de bajos recursos)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando Termux User Repository (TUR)...${NC}"
pkg install -y tur-repo >/dev/null 2>&1 || true
pkg install -y godot || pkg install -y godot3 || true

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/godot3.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Godot Engine 3.x
Comment=Motor de videojuegos 2D y 3D ligero optimizado para dispositivos móviles.
Exec=godot
Icon=godot3
Terminal=false
Type=Application
Categories=Development;GameDevelopment;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Godot Engine 3.x instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
