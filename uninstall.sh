#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Desinstalando scripts y configuraciones de VS Code..."
rm -f "$PREFIX/bin/start-vscode" "$PREFIX/bin/stop-vscode"
rm -f "$HOME/start-vscode.sh" "$HOME/stop-vscode.sh"

read -p "¿Deseas desinstalar también los paquetes de Termux (code-oss, openbox, etc.)? (s/N): " resp
if [[ "$resp" =~ ^[sS]$ ]]; then
    pkg uninstall -y code-oss code-is-code-oss termux-x11-nightly openbox
fi

echo "[+] Limpieza terminada."
