#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Udocker Container Engine
# Descripción: Ejecución de contenedores tipo Docker en Android sin permisos de root.
# URL Oficial: https://indigo-dc.github.io/udocker/
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Udocker Container Engine${NC}"
echo -e "${CYAN}  Ejecución de contenedores tipo Docker en Android sin permisos de root.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y udocker

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/udocker.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Udocker Container Engine
Comment=Ejecución de contenedores tipo Docker en Android sin permisos de root.
Exec=udocker
Icon=udocker
Terminal=false
Type=Application
Categories=System;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Udocker Container Engine instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
