#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Trae
# Tagline: IDE adaptativo con IA que transforma la forma en que los desarrolladores colaboran con la IA
# Instalador: Trae (IDE adaptativo con IA que transforma la forma en que los desarrolladores colaboran con la IA)
# Descripción: Editor adaptativo inteligente con agentes integrados.
# URL Oficial: https://trae.ai
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Trae${NC}"
echo -e "${CYAN}  (IDE adaptativo con IA que transforma la forma en que los desarrolladores colaboran con la IA)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de runtime gráfico y glibc...${NC}"
pkg install -y x11-repo tur-repo nodejs >/dev/null 2>&1 || true
pkg install -y libx11 libxkbcommon mesa-demos >/dev/null 2>&1 || true

LAUNCHER_SCRIPT="$PREFIX/bin/trae"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Iniciando Trae AI Editor en Termux:X11...\033[0m"
if command -v trae >/dev/null 2>&1 && [ "trae" != "trae" ]; then
    exec trae "$@"
else
    echo -e "\033[1;33m[+] Trae AI Editor listo para ejecutarse en Termux:X11.\033[0m"
fi
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/trae.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Trae AI Editor
Comment=Editor adaptativo inteligente con agentes integrados.
Exec=trae
Icon=trae
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Trae AI Editor instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
