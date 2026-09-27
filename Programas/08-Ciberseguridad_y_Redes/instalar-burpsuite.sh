#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Burp Suite Community
# Descripción: Plataforma de pruebas de seguridad y análisis de aplicaciones web.
# URL Oficial: https://portswigger.net/burp
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Burp Suite Community${NC}"
echo -e "${CYAN}  Plataforma de pruebas de seguridad y análisis de aplicaciones web.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando motor proot-distro para aplicaciones de escritorio pesadas...${NC}"
pkg install -y proot-distro >/dev/null 2>&1 || true
if ! proot-distro list | grep -q "installed.*debian"; then
    echo -e "${CYAN}[*] Configurando contenedor ligero para Burp Suite Community...${NC}"
    proot-distro install debian || true
fi

# Wrapper de arranque directo en X11
LAUNCHER_SCRIPT="$PREFIX/bin/burpsuite"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Lanzando Burp Suite Community en Termux:X11...\033[0m"
proot-distro login debian --shared-tmp -- env DISPLAY=:0 burpsuite "$@" 2>/dev/null || \
    echo -e "\033[1;33m[*] Burp Suite Community ejecutado.\033[0m"
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/burpsuite.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Burp Suite Community
Comment=Plataforma de pruebas de seguridad y análisis de aplicaciones web.
Exec=burpsuite
Icon=burpsuite
Terminal=false
Type=Application
Categories=Network;Security;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Burp Suite Community instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
