#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Openbox
# Tagline: Gestor de ventanas altamente configurable, rápido y con soporte total de estándares para X11
# Instalador: Openbox (Gestor de ventanas altamente configurable, rápido y con soporte total de estándares para X11)
# Descripción: El gestor de ventanas ultra-ligero que usa el sistema por defecto (3MB RAM).
# URL Oficial: http://openbox.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Openbox${NC}"
echo -e "${CYAN}  (Gestor de ventanas altamente configurable, rápido y con soporte total de estándares para X11)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete openbox obconf...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y openbox obconf

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "openbox" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/openbox.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Openbox Window Manager
Comment=El gestor de ventanas ultra-ligero que usa el sistema por defecto (3MB RAM).
Exec=openbox
Icon=/data/data/com.termux/files/usr/share/pixmaps/openbox.png
Terminal=false
Type=Application
Categories=System;WindowManager;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Openbox Window Manager instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
