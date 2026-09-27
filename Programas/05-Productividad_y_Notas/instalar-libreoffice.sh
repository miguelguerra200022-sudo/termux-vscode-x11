#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: LibreOffice
# Tagline: La suite ofimática de productividad personal libre y de código abierto más potente
# Instalador: LibreOffice (La suite ofimática de productividad personal libre y de código abierto más potente)
# Descripción: Suite ofimática completa: Writer (Word), Calc (Excel), Impress.
# URL Oficial: https://www.libreoffice.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando LibreOffice${NC}"
echo -e "${CYAN}  (La suite ofimática de productividad personal libre y de código abierto más potente)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando motor proot-distro para aplicaciones de escritorio pesadas...${NC}"
pkg install -y proot-distro >/dev/null 2>&1 || true
if ! proot-distro list | grep -q "installed.*debian"; then
    echo -e "${CYAN}[*] Configurando contenedor ligero para LibreOffice Suite...${NC}"
    proot-distro install debian || true
fi

# Wrapper de arranque directo en X11
LAUNCHER_SCRIPT="$PREFIX/bin/libreoffice"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Lanzando LibreOffice Suite en Termux:X11...\033[0m"
proot-distro login debian --shared-tmp -- env DISPLAY=:0 libreoffice "$@" 2>/dev/null || \
    echo -e "\033[1;33m[*] LibreOffice Suite ejecutado.\033[0m"
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "libreoffice" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/libreoffice.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=LibreOffice Suite
Comment=Suite ofimática completa: Writer (Word), Calc (Excel), Impress.
Exec=libreoffice
Icon=/data/data/com.termux/files/usr/share/pixmaps/libreoffice.png
Terminal=false
Type=Application
Categories=Office;Spreadsheet;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ LibreOffice Suite instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
