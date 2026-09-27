#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Htop
# Tagline: Visor y administrador interactivo de procesos para sistemas Unix en tiempo real
# Instalador: Htop (Visor y administrador interactivo de procesos para sistemas Unix en tiempo real)
# Descripción: Visor interactivo clásico de procesos y árbol de tareas del sistema.
# URL Oficial: https://htop.dev
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Htop${NC}"
echo -e "${CYAN}  (Visor y administrador interactivo de procesos para sistemas Unix en tiempo real)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y htop

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/htop.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Htop Process Viewer
Comment=Visor interactivo clásico de procesos y árbol de tareas del sistema.
Exec=htop
Icon=htop
Terminal=false
Type=Application
Categories=System;Monitor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Htop Process Viewer instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
