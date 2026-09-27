#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Fastfetch
# Tagline: Herramienta rápida y personalizable para mostrar información del sistema al instante
# Instalador: Fastfetch (Herramienta rápida y personalizable para mostrar información del sistema al instante)
# Descripción: Herramienta de información de hardware y sistema ultra-rápida en C.
# URL Oficial: https://github.com/fastfetch-cli/fastfetch
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Fastfetch${NC}"
echo -e "${CYAN}  (Herramienta rápida y personalizable para mostrar información del sistema al instante)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y fastfetch

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/fastfetch.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Fastfetch System Info
Comment=Herramienta de información de hardware y sistema ultra-rápida en C.
Exec=fastfetch
Icon=fastfetch
Terminal=false
Type=Application
Categories=System;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Fastfetch System Info instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
