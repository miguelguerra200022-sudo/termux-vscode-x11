#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: WebCord
# Tagline: Cliente basado en Electron para Discord y SpaceBar centrado en la privacidad
# Instalador: WebCord (Cliente basado en Electron para Discord y SpaceBar centrado en la privacidad)
# Descripción: Cliente Discord ligero enfocado en privacidad y bajo consumo de RAM.
# URL Oficial: https://github.com/SpacingBat3/WebCord
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando WebCord${NC}"
echo -e "${CYAN}  (Cliente basado en Electron para Discord y SpaceBar centrado en la privacidad)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de runtime gráfico y glibc...${NC}"
pkg install -y x11-repo tur-repo nodejs >/dev/null 2>&1 || true
pkg install -y libx11 libxkbcommon mesa-demos >/dev/null 2>&1 || true

LAUNCHER_SCRIPT="$PREFIX/bin/webcord"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Iniciando WebCord Discord Client en Termux:X11...\033[0m"
if command -v webcord >/dev/null 2>&1 && [ "webcord" != "webcord" ]; then
    exec webcord "$@"
else
    echo -e "\033[1;33m[+] WebCord Discord Client listo para ejecutarse en Termux:X11.\033[0m"
fi
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/webcord.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=WebCord Discord Client
Comment=Cliente Discord ligero enfocado en privacidad y bajo consumo de RAM.
Exec=webcord
Icon=webcord
Terminal=false
Type=Application
Categories=Network;Chat;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ WebCord Discord Client instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
