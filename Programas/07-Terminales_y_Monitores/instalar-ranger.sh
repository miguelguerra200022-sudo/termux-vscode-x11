#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Ranger
# Tagline: Administrador de archivos para consola con atajos de teclado tipo VI y vista previa integrada
# Instalador: Ranger (Administrador de archivos para consola con atajos de teclado tipo VI y vista previa integrada)
# Descripción: Administrador de archivos de consola con atajos Vim y previsualización.
# URL Oficial: https://ranger.github.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Ranger${NC}"
echo -e "${CYAN}  (Administrador de archivos para consola con atajos de teclado tipo VI y vista previa integrada)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y ranger

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/ranger.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Ranger File Manager
Comment=Administrador de archivos de consola con atajos Vim y previsualización.
Exec=ranger
Icon=ranger
Terminal=false
Type=Application
Categories=System;FileManager;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Ranger File Manager instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
