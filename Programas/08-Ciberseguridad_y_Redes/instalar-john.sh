#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: John the Ripper
# Tagline: Herramienta de auditoría de seguridad de contraseñas y descifrado de hashes ultrarrápida
# Instalador: John the Ripper (Herramienta de auditoría de seguridad de contraseñas y descifrado de hashes ultrarrápida)
# Descripción: Auditor de seguridad y descifrado de contraseñas mediante hashes.
# URL Oficial: https://www.openwall.com/john/
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando John the Ripper${NC}"
echo -e "${CYAN}  (Herramienta de auditoría de seguridad de contraseñas y descifrado de hashes ultrarrápida)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y john

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/john.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=John the Ripper
Comment=Auditor de seguridad y descifrado de contraseñas mediante hashes.
Exec=john
Icon=john
Terminal=false
Type=Application
Categories=Security;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ John the Ripper instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
