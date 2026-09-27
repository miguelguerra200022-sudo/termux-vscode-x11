#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: MariaDB
# Tagline: Uno de los servidores de bases de datos relacionales SQL más populares de código abierto
# Instalador: MariaDB (Uno de los servidores de bases de datos relacionales SQL más populares de código abierto)
# Descripción: Servidor de base de datos relacional optimizado para entornos móviles.
# URL Oficial: https://mariadb.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando MariaDB${NC}"
echo -e "${CYAN}  (Uno de los servidores de bases de datos relacionales SQL más populares de código abierto)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y mariadb

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "mariadb" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/mariadb.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=MariaDB (MySQL) Server
Comment=Servidor de base de datos relacional optimizado para entornos móviles.
Exec=mariadb
Icon=/data/data/com.termux/files/usr/share/pixmaps/mariadb.png
Terminal=false
Type=Application
Categories=Development;Database;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ MariaDB (MySQL) Server instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
