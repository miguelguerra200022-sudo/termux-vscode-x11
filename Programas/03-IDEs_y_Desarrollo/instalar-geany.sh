#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Geany
# Tagline: IDE ligero y rápido que utiliza GTK+ con dependencias mínimas
# Instalador: Geany (IDE ligero y rápido que utiliza GTK+ con dependencias mínimas)
# Descripción: IDE ultra-ligero en GTK con arranque instantáneo y mínimo consumo de RAM.
# URL Oficial: https://www.geany.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Geany${NC}"
echo -e "${CYAN}  (IDE ligero y rápido que utiliza GTK+ con dependencias mínimas)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete geany...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y geany

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "geany" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/geany.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Geany Fast IDE
Comment=IDE ultra-ligero en GTK con arranque instantáneo y mínimo consumo de RAM.
Exec=geany
Icon=/data/data/com.termux/files/usr/share/pixmaps/geany.png
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Geany Fast IDE instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
