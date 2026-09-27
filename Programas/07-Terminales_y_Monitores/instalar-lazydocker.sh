#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Lazydocker
# Tagline: La interfaz de usuario en terminal más sencilla para gestionar contenedores Docker
# Instalador: LazyDocker (La interfaz de usuario en terminal más sencilla para gestionar contenedores Docker)
# Descripción: Interfaz de consola interactiva para administrar contenedores y volúmenes.
# URL Oficial: https://github.com/jesseduffield/lazydocker
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Lazydocker${NC}"
echo -e "${CYAN}  (La interfaz de usuario en terminal más sencilla para gestionar contenedores Docker)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y lazydocker

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "lazydocker" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/lazydocker.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Lazydocker Container TUI
Comment=Interfaz de consola interactiva para administrar contenedores y volúmenes.
Exec=lazydocker
Icon=/data/data/com.termux/files/usr/share/pixmaps/lazydocker.png
Terminal=false
Type=Application
Categories=System;Monitor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Lazydocker Container TUI instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
