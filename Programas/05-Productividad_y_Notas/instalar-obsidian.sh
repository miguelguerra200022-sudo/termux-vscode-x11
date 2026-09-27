#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Obsidian
# Tagline: Sharpen your thinking - The private and flexible writing app that adapts to how you think
# Instalador: Obsidian (Sharpen your thinking - The private and flexible writing app that adapts to how you think)
# Descripción: Base de conocimiento personal y red de notas Markdown enlazadas.
# URL Oficial: https://obsidian.md
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Obsidian${NC}"
echo -e "${CYAN}  (Sharpen your thinking - The private and flexible writing app that adapts to how you think)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de runtime gráfico y glibc...${NC}"
pkg install -y x11-repo tur-repo nodejs >/dev/null 2>&1 || true
pkg install -y libx11 libxkbcommon mesa-demos >/dev/null 2>&1 || true

LAUNCHER_SCRIPT="$PREFIX/bin/obsidian"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Iniciando Obsidian Markdown en Termux:X11...\033[0m"
if command -v obsidian >/dev/null 2>&1 && [ "obsidian" != "obsidian" ]; then
    exec obsidian "$@"
else
    echo -e "\033[1;33m[+] Obsidian Markdown listo para ejecutarse en Termux:X11.\033[0m"
fi
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/obsidian.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Obsidian Markdown
Comment=Base de conocimiento personal y red de notas Markdown enlazadas.
Exec=obsidian
Icon=obsidian
Terminal=false
Type=Application
Categories=Office;Notes;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Obsidian Markdown instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
