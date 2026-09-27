#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: SQLmap
# Tagline: Automatic SQL injection and database takeover penetration testing tool
# Instalador: SQLmap (Automatic SQL injection and database takeover penetration testing tool)
# Descripción: Herramienta de detección y explotación automática de inyecciones SQL.
# URL Oficial: https://sqlmap.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando SQLmap${NC}"
echo -e "${CYAN}  (Automatic SQL injection and database takeover penetration testing tool)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y sqlmap

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/sqlmap.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=SQLmap Injection Tool
Comment=Herramienta de detección y explotación automática de inyecciones SQL.
Exec=sqlmap
Icon=sqlmap
Terminal=false
Type=Application
Categories=Network;Security;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ SQLmap Injection Tool instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
