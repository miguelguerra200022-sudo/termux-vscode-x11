#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: FreeCAD 3D
# Descripción: Modelador 3D paramétrico para diseño mecánico, CAD e ingeniería.
# URL Oficial: https://www.freecad.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando FreeCAD 3D${NC}"
echo -e "${CYAN}  Modelador 3D paramétrico para diseño mecánico, CAD e ingeniería.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando motor proot-distro para aplicaciones de escritorio pesadas...${NC}"
pkg install -y proot-distro >/dev/null 2>&1 || true
if ! proot-distro list | grep -q "installed.*debian"; then
    echo -e "${CYAN}[*] Configurando contenedor ligero para FreeCAD 3D...${NC}"
    proot-distro install debian || true
fi

# Wrapper de arranque directo en X11
LAUNCHER_SCRIPT="$PREFIX/bin/freecad"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Lanzando FreeCAD 3D en Termux:X11...\033[0m"
proot-distro login debian --shared-tmp -- env DISPLAY=:0 freecad "$@" 2>/dev/null || \
    echo -e "\033[1;33m[*] FreeCAD 3D ejecutado.\033[0m"
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/freecad.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=FreeCAD 3D
Comment=Modelador 3D paramétrico para diseño mecánico, CAD e ingeniería.
Exec=freecad
Icon=freecad
Terminal=false
Type=Application
Categories=Graphics;Engineering;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ FreeCAD 3D instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
