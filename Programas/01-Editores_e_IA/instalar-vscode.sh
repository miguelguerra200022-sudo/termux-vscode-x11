#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Visual Studio Code
# Tagline: Edición de código redefinida: gratuito, de código abierto y funciona en todas partes
# Instalador: Visual Studio Code (Edición de código redefinida: gratuito, de código abierto y funciona en todas partes)
# Descripción: Entorno de desarrollo nativo en Termux optimizado para Termux:X11.
# URL Oficial: https://github.com/microsoft/vscode
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Visual Studio Code${NC}"
echo -e "${CYAN}  (Edición de código redefinida: gratuito, de código abierto y funciona en todas partes)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Verificando e instalando Code - OSS nativo para Termux:X11...${NC}"
pkg install -y tur-repo x11-repo >/dev/null 2>&1 || true
pkg install -y code-oss || true
exec_cmd="code-oss --no-sandbox --disable-gpu --password-store=basic"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "vscode" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/vscode.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Visual Studio Code (Code - OSS)
Comment=Entorno de desarrollo nativo en Termux optimizado para Termux:X11.
Exec=code-oss --no-sandbox --disable-gpu --password-store=basic
Icon=/data/data/com.termux/files/usr/share/pixmaps/code-oss.png
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Visual Studio Code (Code - OSS) instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
