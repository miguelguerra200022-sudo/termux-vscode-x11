#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Caddy Web Server
# Descripción: Servidor web moderno en Go con configuración automática de puertos y rutas.
# URL Oficial: https://caddyserver.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Caddy Web Server${NC}"
echo -e "${CYAN}  Servidor web moderno en Go con configuración automática de puertos y rutas.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y caddy

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/caddy.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Caddy Web Server
Comment=Servidor web moderno en Go con configuración automática de puertos y rutas.
Exec=caddy
Icon=caddy
Terminal=false
Type=Application
Categories=Network;Webserver;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Caddy Web Server instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
