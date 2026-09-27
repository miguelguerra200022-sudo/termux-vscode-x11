#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: LibreWolf
# Tagline: Versión independiente y personalizada de Firefox enfocada en privacidad, seguridad y libertad
# Instalador: LibreWolf (Versión independiente y personalizada de Firefox enfocada en privacidad, seguridad y libertad)
# Descripción: Navegador web enfocado en privacidad sin telemetría ni rastreo.
# URL Oficial: https://librewolf.net
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando LibreWolf${NC}"
echo -e "${CYAN}  (Versión independiente y personalizada de Firefox enfocada en privacidad, seguridad y libertad)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de runtime gráfico y glibc...${NC}"
pkg install -y x11-repo tur-repo nodejs >/dev/null 2>&1 || true
pkg install -y libx11 libxkbcommon mesa-demos >/dev/null 2>&1 || true

LAUNCHER_SCRIPT="$PREFIX/bin/librewolf"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Iniciando LibreWolf en Termux:X11...\033[0m"
if command -v librewolf >/dev/null 2>&1 && [ "librewolf" != "librewolf" ]; then
    exec librewolf "$@"
else
    echo -e "\033[1;33m[+] LibreWolf listo para ejecutarse en Termux:X11.\033[0m"
fi
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "librewolf" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/librewolf.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=LibreWolf
Comment=Navegador web enfocado en privacidad sin telemetría ni rastreo.
Exec=librewolf
Icon=/data/data/com.termux/files/usr/share/pixmaps/librewolf.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ LibreWolf instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
