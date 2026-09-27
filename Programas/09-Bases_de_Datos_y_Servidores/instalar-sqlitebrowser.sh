#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: DB Browser for SQLite
# Tagline: High quality, visual open source tool to create, design, and edit SQLite databases
# Instalador: DB Browser for SQLite (High quality, visual open source tool to create, design, and edit SQLite databases)
# Descripción: Interfaz gráfica para crear, diseñar y editar bases de datos SQLite en X11.
# URL Oficial: https://sqlitebrowser.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando DB Browser for SQLite${NC}"
echo -e "${CYAN}  (High quality, visual open source tool to create, design, and edit SQLite databases)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete sqlitebrowser...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y sqlitebrowser

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/sqlitebrowser.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=DB Browser for SQLite
Comment=Interfaz gráfica para crear, diseñar y editar bases de datos SQLite en X11.
Exec=sqlitebrowser
Icon=sqlitebrowser
Terminal=false
Type=Application
Categories=Development;Database;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ DB Browser for SQLite instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
