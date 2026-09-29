#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# deploy.sh: Despliegue Automatizado a Cloudflare Serverless Edge
# ==============================================================================

echo "======================================================"
echo "  🚀 Desplegando Code Stack Sh Gateway a Cloudflare"
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

# 1. Comprobar Node.js y Wrangler
if ! command -v npx >/dev/null 2>&1; then
    echo "[!] Node.js / npx no encontrado. Instalando..."
    pkg install -y nodejs
fi

# 2. Inicializar base de datos D1 si no existe
echo "[*] Verificando base de datos D1 fleet-d1..."
npx wrangler d1 create fleet-d1 --yes 2>/dev/null || true

# 3. Aplicar esquema D1
echo "[*] Aplicando esquema SQL a Cloudflare D1..."
npx wrangler d1 execute fleet-d1 --file=schema.sql --yes 2>/dev/null || true

# 4. Crear bucket R2 para Bóvedas Cifradas
echo "[*] Verificando bucket R2 code-stack-vaults..."
npx wrangler r2 bucket create code-stack-vaults 2>/dev/null || true

# 5. Desplegar Worker
echo "[*] Desplegando Cloudflare Edge Worker..."
npx wrangler deploy

echo ""
echo "[✓] ¡Despliegue completado exitosamente!"
echo "[*] Configura el Webhook en Telegram ejecutando:"
echo "    curl -s https://api.telegram.org/bot<TOKEN>/setWebhook?url=https://<TU-WORKER>.workers.dev/telegram/webhook"
