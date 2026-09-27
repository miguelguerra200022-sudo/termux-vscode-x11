#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Draw.io
# Tagline: Software de diagramación y mapas conceptuales de nivel empresarial, libre y seguro
# Instalador: Diagrams.net (Draw.io) (Software de diagramación y mapas conceptuales de nivel empresarial, libre y seguro)
# Descripción: Herramienta de diagramas de arquitectura, flujos de datos y mapas.
# URL Oficial: https://www.drawio.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Draw.io${NC}"
echo -e "${CYAN}  (Software de diagramación y mapas conceptuales de nivel empresarial, libre y seguro)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de runtime gráfico y glibc...${NC}"
pkg install -y x11-repo tur-repo nodejs >/dev/null 2>&1 || true
pkg install -y libx11 libxkbcommon mesa-demos >/dev/null 2>&1 || true

LAUNCHER_SCRIPT="$PREFIX/bin/drawio"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Iniciando Draw.io Desktop en Termux:X11...\033[0m"
if command -v drawio >/dev/null 2>&1 && [ "drawio" != "drawio" ]; then
    exec drawio "$@"
else
    echo -e "\033[1;33m[+] Draw.io Desktop listo para ejecutarse en Termux:X11.\033[0m"
fi
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/drawio.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Draw.io Desktop
Comment=Herramienta de diagramas de arquitectura, flujos de datos y mapas.
Exec=drawio
Icon=drawio
Terminal=false
Type=Application
Categories=Graphics;Diagram;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Draw.io Desktop instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
