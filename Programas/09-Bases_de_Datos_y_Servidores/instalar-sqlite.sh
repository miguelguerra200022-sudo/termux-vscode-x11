#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: SQLite
# Tagline: Small, fast, self-contained, high-reliability, full-featured SQL database engine
# Instalador: SQLite (Small, fast, self-contained, high-reliability, full-featured SQL database engine)
# Descripción: Motor de base de datos relacional ligera embebida sin servidor.
# URL Oficial: https://www.sqlite.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando SQLite${NC}"
echo -e "${CYAN}  (Small, fast, self-contained, high-reliability, full-featured SQL database engine)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y sqlite

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/sqlite.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=SQLite Engine
Comment=Motor de base de datos relacional ligera embebida sin servidor.
Exec=sqlite
Icon=sqlite
Terminal=false
Type=Application
Categories=Development;Database;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ SQLite Engine instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
