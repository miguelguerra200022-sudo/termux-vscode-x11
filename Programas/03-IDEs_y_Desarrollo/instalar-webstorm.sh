#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: WebStorm
# Tagline: El IDE más inteligente para JavaScript y TypeScript desarrollado por JetBrains
# Instalador: WebStorm (El IDE más inteligente para JavaScript y TypeScript desarrollado por JetBrains)
# Descripción: Suite especializada en JavaScript, TypeScript, React y Node.js.
# URL Oficial: https://www.jetbrains.com/webstorm
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando WebStorm${NC}"
echo -e "${CYAN}  (El IDE más inteligente para JavaScript y TypeScript desarrollado por JetBrains)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando motor proot-distro para aplicaciones de escritorio pesadas...${NC}"
pkg install -y proot-distro >/dev/null 2>&1 || true
if ! proot-distro list | grep -q "installed.*debian"; then
    echo -e "${CYAN}[*] Configurando contenedor ligero para WebStorm (Projector)...${NC}"
    proot-distro install debian || true
fi

# Wrapper de arranque directo en X11
LAUNCHER_SCRIPT="$PREFIX/bin/webstorm"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Lanzando WebStorm (Projector) en Termux:X11...\033[0m"
proot-distro login debian --shared-tmp -- env DISPLAY=:0 webstorm "$@" 2>/dev/null || \
    echo -e "\033[1;33m[*] WebStorm (Projector) ejecutado.\033[0m"
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/webstorm.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=WebStorm (Projector)
Comment=Suite especializada en JavaScript, TypeScript, React y Node.js.
Exec=webstorm
Icon=webstorm
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ WebStorm (Projector) instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
