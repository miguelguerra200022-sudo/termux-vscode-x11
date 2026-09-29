# 🌐 Code Stack Sh: Cloudflare Serverless Edge Gateway

Centro de control, mensajería y sincronización en la nube para flotas de hasta **10,000+ dispositivos Termux** concurrentes con **cero demonios en los teléfonos**, **latencia <15ms** y **cero llamadas de fondo a GitHub**.

---

## 🚀 Características Principales

1. **Bot de Telegram 24/7 Serverless:**
   - Responde inmediatamente a `/comando`, `/flota`, `/bloquear`, etc. vía Webhook HTTPS nativo.
   - Cero procesos corriendo en los celulares.
2. **GitHub Webhook Relay (1 sola descarga de GitHub):**
   - Cuando haces `git push origin main`, GitHub notifica a Cloudflare por Webhook.
   - Cloudflare descarga la versión UNA SOLA VEZ, la almacena en caché en 330 ciudades y la distribuye a los 10,000 usuarios sin saturar la cuota de GitHub.
3. **Contabilidad y Licencias D1 (30 Días):**
   - Base de datos ACID distribuida globalmente (SQLite Edge).
   - Aviso preventivo al día 27, congelamiento estricto al día 30 y renovación en 1 clic.
4. **Sincronización Incremental por Deltas (Bytes en tiempo real):**
   - Los celulares envían deltas de 500 bytes cuando editan archivos en lugar de comprimir zips de 50 MB.
5. **Bóvedas Cifradas R2 (Zero Egress Fees):**
   - Los respaldos pesados de perfiles y credenciales viajan directo a Cloudflare R2 sin límites de tamaño.

---

## 📦 Despliegue Rápido en 3 Pasos

### Paso 1: Instalar dependencias
```bash
cd cloud-gateway
pkg install -y nodejs
npm install -g wrangler
```

### Paso 2: Autenticarse en Cloudflare
```bash
wrangler login
```

### Paso 3: Ejecutar despliegue automatizado
```bash
./deploy.sh
```

---

## 🔗 Configuración de Webhooks

### 1. Activar Webhook de Telegram
```bash
curl -s "https://api.telegram.org/bot<TU_BOT_TOKEN>/setWebhook?url=https://<TU_WORKER>.workers.dev/telegram/webhook"
```

### 2. Activar Webhook de GitHub
En tu repositorio de GitHub:
1. Ve a **Settings -> Webhooks -> Add Webhook**.
2. **Payload URL:** `https://<TU_WORKER>.workers.dev/webhook/github-push`
3. **Content type:** `application/json`
4. **Events:** Just the `push` event.
5. Guardar.
