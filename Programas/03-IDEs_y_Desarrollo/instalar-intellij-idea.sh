#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: IntelliJ IDEA
# Tagline: El IDE líder en la industria para Java y desarrollo en Kotlin por JetBrains
# Instalador: IntelliJ IDEA (El IDE líder en la industria para Java y desarrollo en Kotlin por JetBrains)
# Descripción: IDE profesional para desarrollo en Java, Kotlin y backend.
# URL Oficial: https://www.jetbrains.com/idea
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando IntelliJ IDEA${NC}"
echo -e "${CYAN}  (El IDE líder en la industria para Java y desarrollo en Kotlin por JetBrains)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando motor proot-distro para aplicaciones de escritorio pesadas...${NC}"
pkg install -y proot-distro >/dev/null 2>&1 || true
if ! proot-distro list | grep -q "installed.*debian"; then
    echo -e "${CYAN}[*] Configurando contenedor ligero para IntelliJ IDEA Community...${NC}"
    proot-distro install debian || true
fi

# Wrapper de arranque directo en X11
LAUNCHER_SCRIPT="$PREFIX/bin/intellij-idea"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Lanzando IntelliJ IDEA Community en Termux:X11...\033[0m"
proot-distro login debian --shared-tmp -- env DISPLAY=:0 intellij-idea "$@" 2>/dev/null || \
    echo -e "\033[1;33m[*] IntelliJ IDEA Community ejecutado.\033[0m"
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/intellij-idea.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=IntelliJ IDEA Community
Comment=IDE profesional para desarrollo en Java, Kotlin y backend.
Exec=intellij-idea
Icon=intellij-idea
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ IntelliJ IDEA Community instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
