#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: FileZilla FTP/SFTP Client
# Descripción: Cliente gráfico de transferencia de archivos por FTP, FTPS y SFTP.
# URL Oficial: https://filezilla-project.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando FileZilla FTP/SFTP Client${NC}"
echo -e "${CYAN}  Cliente gráfico de transferencia de archivos por FTP, FTPS y SFTP.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete filezilla...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y filezilla

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/filezilla.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=FileZilla FTP/SFTP Client
Comment=Cliente gráfico de transferencia de archivos por FTP, FTPS y SFTP.
Exec=filezilla
Icon=filezilla
Terminal=false
Type=Application
Categories=Network;FileTransfer;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ FileZilla FTP/SFTP Client instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
