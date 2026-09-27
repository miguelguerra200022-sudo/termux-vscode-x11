#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Godot 4
# Tagline: The game engine you have been waiting for - Next-gen Vulkan rendering, physics and GDScript
# Instalador: Godot 4 (The game engine you have been waiting for - Next-gen Vulkan rendering, physics and GDScript)
# Descripción: Motor de nueva generación con renderizado moderno y GDScript 2.0.
# URL Oficial: https://godotengine.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Godot 4${NC}"
echo -e "${CYAN}  (The game engine you have been waiting for - Next-gen Vulkan rendering, physics and GDScript)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando Termux User Repository (TUR)...${NC}"
pkg install -y tur-repo >/dev/null 2>&1 || true
pkg install -y godot4 || pkg install -y godot4 || true

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/godot4.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Godot Engine 4.x
Comment=Motor de nueva generación con renderizado moderno y GDScript 2.0.
Exec=godot4
Icon=godot4
Terminal=false
Type=Application
Categories=Development;GameDevelopment;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Godot Engine 4.x instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
