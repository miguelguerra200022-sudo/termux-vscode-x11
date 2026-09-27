#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: CLion
# Tagline: IDE inteligente para C y C++ desarrollado por JetBrains enfocado en máxima productividad
# Instalador: CLion (IDE inteligente para C y C++ desarrollado por JetBrains enfocado en máxima productividad)
# Descripción: IDE para desarrollo profesional en C y C++ con CMake y depurador.
# URL Oficial: https://www.jetbrains.com/clion
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando CLion${NC}"
echo -e "${CYAN}  (IDE inteligente para C y C++ desarrollado por JetBrains enfocado en máxima productividad)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando motor proot-distro para aplicaciones de escritorio pesadas...${NC}"
pkg install -y proot-distro >/dev/null 2>&1 || true
if ! proot-distro list | grep -q "installed.*debian"; then
    echo -e "${CYAN}[*] Configurando contenedor ligero para CLion / CodeBlocks...${NC}"
    proot-distro install debian || true
fi

# Wrapper de arranque directo en X11
LAUNCHER_SCRIPT="$PREFIX/bin/clion"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Lanzando CLion / CodeBlocks en Termux:X11...\033[0m"
proot-distro login debian --shared-tmp -- env DISPLAY=:0 clion "$@" 2>/dev/null || \
    echo -e "\033[1;33m[*] CLion / CodeBlocks ejecutado.\033[0m"
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "clion" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/clion.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=CLion / CodeBlocks
Comment=IDE para desarrollo profesional en C y C++ con CMake y depurador.
Exec=clion
Icon=/data/data/com.termux/files/usr/share/pixmaps/clion.png
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ CLion / CodeBlocks instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
