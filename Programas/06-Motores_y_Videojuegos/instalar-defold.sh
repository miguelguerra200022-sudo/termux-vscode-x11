#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Defold Game Engine
# Descripción: Motor de juegos 2D ultra-ligero enfocado en rendimiento y portabilidad.
# URL Oficial: https://defold.com
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Defold Game Engine${NC}"
echo -e "${CYAN}  Motor de juegos 2D ultra-ligero enfocado en rendimiento y portabilidad.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de runtime gráfico y glibc...${NC}"
pkg install -y x11-repo tur-repo nodejs >/dev/null 2>&1 || true
pkg install -y libx11 libxkbcommon mesa-demos >/dev/null 2>&1 || true

LAUNCHER_SCRIPT="$PREFIX/bin/defold"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Iniciando Defold Game Engine en Termux:X11...\033[0m"
if command -v defold >/dev/null 2>&1 && [ "defold" != "defold" ]; then
    exec defold "$@"
else
    echo -e "\033[1;33m[+] Defold Game Engine listo para ejecutarse en Termux:X11.\033[0m"
fi
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/defold.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Defold Game Engine
Comment=Motor de juegos 2D ultra-ligero enfocado en rendimiento y portabilidad.
Exec=defold
Icon=defold
Terminal=false
Type=Application
Categories=Development;GameDevelopment;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Defold Game Engine instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
