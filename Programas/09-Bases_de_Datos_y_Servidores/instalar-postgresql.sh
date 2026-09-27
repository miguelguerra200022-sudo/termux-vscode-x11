#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: PostgreSQL
# Tagline: The World's Most Advanced Open Source Relational Database
# Instalador: PostgreSQL (The World's Most Advanced Open Source Relational Database)
# Descripción: Sistema de base de datos relacional avanzada de nivel empresarial.
# URL Oficial: https://www.postgresql.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando PostgreSQL${NC}"
echo -e "${CYAN}  (The World's Most Advanced Open Source Relational Database)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y postgresql

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/postgresql.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=PostgreSQL Database Server
Comment=Sistema de base de datos relacional avanzada de nivel empresarial.
Exec=postgresql
Icon=postgresql
Terminal=false
Type=Application
Categories=Development;Database;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ PostgreSQL Database Server instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
