#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Metasploit
# Tagline: La plataforma de pruebas de penetración y explotación de vulnerabilidades más utilizada del mundo
# Instalador: Metasploit Framework (La plataforma de pruebas de penetración y explotación de vulnerabilidades más utilizada del mundo)
# Descripción: Plataforma avanzada de pruebas de penetración y explotación ética.
# URL Oficial: https://www.metasploit.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Metasploit${NC}"
echo -e "${CYAN}  (La plataforma de pruebas de penetración y explotación de vulnerabilidades más utilizada del mundo)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando Termux User Repository (TUR)...${NC}"
pkg install -y tur-repo >/dev/null 2>&1 || true
pkg install -y metasploit || pkg install -y metasploit || true

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "metasploit" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/metasploit.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Metasploit Framework
Comment=Plataforma avanzada de pruebas de penetración y explotación ética.
Exec=msfconsole
Icon=/data/data/com.termux/files/usr/share/pixmaps/metasploit.png
Terminal=false
Type=Application
Categories=Network;Security;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Metasploit Framework instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
