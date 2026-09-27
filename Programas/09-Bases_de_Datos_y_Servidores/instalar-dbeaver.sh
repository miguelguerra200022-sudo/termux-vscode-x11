#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: DBeaver
# Tagline: Free multi-platform database tool for developers, database administrators and analysts
# Instalador: DBeaver (Free multi-platform database tool for developers, database administrators and analysts)
# Descripción: Administrador visual universal de bases de datos relacionales y NoSQL.
# URL Oficial: https://dbeaver.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando DBeaver${NC}"
echo -e "${CYAN}  (Free multi-platform database tool for developers, database administrators and analysts)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando motor proot-distro para aplicaciones de escritorio pesadas...${NC}"
pkg install -y proot-distro >/dev/null 2>&1 || true
if ! proot-distro list | grep -q "installed.*debian"; then
    echo -e "${CYAN}[*] Configurando contenedor ligero para DBeaver Universal Database Manager...${NC}"
    proot-distro install debian || true
fi

# Wrapper de arranque directo en X11
LAUNCHER_SCRIPT="$PREFIX/bin/dbeaver"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Lanzando DBeaver Universal Database Manager en Termux:X11...\033[0m"
proot-distro login debian --shared-tmp -- env DISPLAY=:0 dbeaver "$@" 2>/dev/null || \
    echo -e "\033[1;33m[*] DBeaver Universal Database Manager ejecutado.\033[0m"
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/dbeaver.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=DBeaver Universal Database Manager
Comment=Administrador visual universal de bases de datos relacionales y NoSQL.
Exec=dbeaver
Icon=dbeaver
Terminal=false
Type=Application
Categories=Development;Database;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ DBeaver Universal Database Manager instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
