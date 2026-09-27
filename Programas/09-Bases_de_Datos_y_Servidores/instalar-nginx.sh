#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Nginx Web Server
# Descripción: Servidor web ligero y proxy inverso de alto rendimiento para proyectos.
# URL Oficial: https://nginx.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Nginx Web Server${NC}"
echo -e "${CYAN}  Servidor web ligero y proxy inverso de alto rendimiento para proyectos.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y nginx

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/nginx.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Nginx Web Server
Comment=Servidor web ligero y proxy inverso de alto rendimiento para proyectos.
Exec=nginx
Icon=nginx
Terminal=false
Type=Application
Categories=Network;Webserver;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Nginx Web Server instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
