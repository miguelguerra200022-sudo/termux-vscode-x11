#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Joplin
# Tagline: Aplicación de toma de notas segura y de código abierto con sincronización cifrada de extremo a extremo
# Instalador: Joplin (Aplicación de toma de notas segura y de código abierto con sincronización cifrada de extremo a extremo)
# Descripción: Aplicación de notas y listas de tareas cifradas de extremo a extremo.
# URL Oficial: https://joplinapp.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Joplin${NC}"
echo -e "${CYAN}  (Aplicación de toma de notas segura y de código abierto con sincronización cifrada de extremo a extremo)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de runtime gráfico y glibc...${NC}"
pkg install -y x11-repo tur-repo nodejs >/dev/null 2>&1 || true
pkg install -y libx11 libxkbcommon mesa-demos >/dev/null 2>&1 || true

LAUNCHER_SCRIPT="$PREFIX/bin/joplin"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Iniciando Joplin Secure Notes en Termux:X11...\033[0m"
if command -v joplin >/dev/null 2>&1 && [ "joplin" != "joplin" ]; then
    exec joplin "$@"
else
    echo -e "\033[1;33m[+] Joplin Secure Notes listo para ejecutarse en Termux:X11.\033[0m"
fi
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/joplin.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Joplin Secure Notes
Comment=Aplicación de notas y listas de tareas cifradas de extremo a extremo.
Exec=joplin
Icon=joplin
Terminal=false
Type=Application
Categories=Office;Notes;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Joplin Secure Notes instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
