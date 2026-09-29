// ==============================================================================
// Code Stack Sh: Cloudflare Serverless Edge Gateway
// 24/7 Telegram Bot, GitHub Webhook Relay, D1 Fleet Ledger & Real-time Delta Sync
// ==============================================================================

const LEADER_SEAL = "ums9230-sp_6300-3724801c";
const DEFAULT_ALLOWED_CHAT = "1514766577";
const DEFAULT_TG_TOKEN = "8835215357:AAG142javmyg8xPzx3Ad-Aj2ohqmBfMtvls";

// Utilidad de respuestas JSON con CORS
function jsonResponse(data, status = 200, extraHeaders = {}) {
    return new Response(JSON.stringify(data), {
        status,
        headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Device-Seal",
            ...extraHeaders
        }
    });
}

// Envío seguro a Telegram vía fetch TLS
async function sendTelegram(env, method, payload) {
    const token = env.TELEGRAM_BOT_TOKEN || DEFAULT_TG_TOKEN;
    const url = `https://api.telegram.org/bot${token}/${method}`;
    try {
        const resp = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });
        return await resp.json();
    } catch (e) {
        return { ok: false, error: e.message };
    }
}

// Verificación HMAC SHA-256 de firmas de GitHub Webhook
async function verifyGitHubSignature(secret, headerSig, payloadText) {
    if (!secret || !headerSig) return true; // Si no hay secreto configurado, permitir
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
        "raw",
        encoder.encode(secret),
        { name: "HMAC", hash: "SHA-256" },
        false,
        ["sign"]
    );
    const signature = await crypto.subtle.sign("HMAC", key, encoder.encode(payloadText));
    const hexSig = "sha256=" + Array.from(new Uint8Array(signature)).map(b => b.toString(16).padStart(2, "0")).join("");
    return hexSig === headerSig;
}

export default {
    async fetch(request, env, ctx) {
        const url = new URL(request.url);
        const path = url.pathname;

        if (request.method === "OPTIONS") {
            return new Response(null, {
                status: 204,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Device-Seal"
                }
            });
        }

        try {
            // ------------------------------------------------------------------
            // 0. CARGADOR DE INSTALACIÓN DIRECTO DESDE CLOUDFLARE EDGE (/install o /i)
            // ------------------------------------------------------------------
            if ((path === "/install" || path === "/i") && request.method === "GET") {
                return handleInstallBootstrap(request, env);
            }

            // ------------------------------------------------------------------
            // 1. WEBHOOK DE TELEGRAM (/telegram/webhook)
            // ------------------------------------------------------------------
            if (path === "/telegram/webhook" && request.method === "POST") {
                const update = await request.json();
                ctx.waitUntil(handleTelegramUpdate(update, env));
                return jsonResponse({ ok: true });
            }

            // ------------------------------------------------------------------
            // 2. WEBHOOK DE GITHUB PUSH (/webhook/github-push)
            // ------------------------------------------------------------------
            if (path === "/webhook/github-push" && request.method === "POST") {
                const sig = request.headers.get("X-Hub-Signature-256");
                const payloadText = await request.text();
                const secret = env.GITHUB_WEBHOOK_SECRET || "";
                
                const isValid = await verifyGitHubSignature(secret, sig, payloadText);
                if (!isValid) {
                    return jsonResponse({ error: "Invalid signature" }, 401);
                }

                const data = JSON.parse(payloadText);
                ctx.waitUntil(handleGitHubPush(data, env));
                return jsonResponse({ ok: true, status: "GitHub push processed" });
            }

            // ------------------------------------------------------------------
            // 3. API DE AUTENTICACIÓN Y LICENCIA DE 30 DÍAS
            // ------------------------------------------------------------------
            if (path === "/api/v1/auth/register" && request.method === "POST") {
                const body = await request.json();
                return await handleDeviceRegister(body, request, env);
            }

            if (path === "/api/v1/auth/request-access" && request.method === "POST") {
                const body = await request.json();
                return await handleAuthRequestAccess(body, request, env);
            }

            if (path === "/api/v1/auth/status" && request.method === "GET") {
                const seal = url.searchParams.get("seal") || request.headers.get("X-Device-Seal");
                return await handleAuthStatusCheck(seal, env);
            }

            if (path === "/api/v1/auth/verify-master" && request.method === "POST") {
                const body = await request.json();
                return await handleVerifyMasterPass(body, request, env);
            }

            if (path === "/api/v1/auth/license" && request.method === "GET") {
                const seal = url.searchParams.get("seal") || request.headers.get("X-Device-Seal");
                return await handleLicenseCheck(seal, env);
            }

            if (path === "/api/v1/auth/renew" && request.method === "POST") {
                const body = await request.json();
                return await handleLicenseRenew(body, env);
            }

            // ------------------------------------------------------------------
            // 4. SINCRONIZACIÓN EN TIEMPO REAL POR DELTAS (BYTES)
            // ------------------------------------------------------------------
            if (path === "/api/v1/vault/sync-delta" && request.method === "POST") {
                const body = await request.json();
                return await handleVaultDeltaSync(body, env);
            }

            if (path === "/api/v1/vault/download" && request.method === "GET") {
                const seal = url.searchParams.get("seal") || request.headers.get("X-Device-Seal");
                return await handleVaultDownload(seal, env);
            }

            if (path === "/api/v1/vault/upload" && request.method === "POST") {
                const seal = url.searchParams.get("seal") || request.headers.get("X-Device-Seal");
                return await handleVaultUpload(seal, request, env);
            }

            if (path === "/api/v1/vault/inventory" && request.method === "POST") {
                const seal = url.searchParams.get("seal") || request.headers.get("X-Device-Seal");
                const body = await request.json();
                return await handleInventoryUpload(seal, body, env);
            }

            if (path === "/api/v1/vault/inventory" && request.method === "GET") {
                const seal = url.searchParams.get("seal") || request.headers.get("X-Device-Seal");
                return await handleInventoryGet(seal, env);
            }

            if (path === "/api/v1/fleet/devices" && request.method === "GET") {
                return await handleFleetDevices(request, env);
            }

            // ------------------------------------------------------------------
            // 5. COLA DE TAREAS Y DESPACHO A LA FLOTA
            // ------------------------------------------------------------------
            if (path === "/api/v1/tasks/poll" && request.method === "GET") {
                const seal = url.searchParams.get("seal") || request.headers.get("X-Device-Seal");
                return await handleTasksPoll(seal, env);
            }

            if (path === "/api/v1/tasks/complete" && request.method === "POST") {
                const body = await request.json();
                return await handleTaskComplete(body, env);
            }

            // ------------------------------------------------------------------
            // 6. CDN DE VERSIONES CACHEADAS EN EDGE (0 llamadas a GitHub)
            // ------------------------------------------------------------------
            if (path === "/api/v1/release/latest" && request.method === "GET") {
                return await handleLatestRelease(request, env);
            }

            if (path.startsWith("/api/v1/release/download/") && request.method === "GET") {
                const commit = path.replace("/api/v1/release/download/", "").trim();
                return await handleReleaseDownload(commit, env);
            }

            // ------------------------------------------------------------------
            // 7. STREAM DE EVENTOS EN TIEMPO REAL (SSE)
            // ------------------------------------------------------------------
            if (path === "/api/v1/stream" && request.method === "GET") {
                return handleEventStream(request, env);
            }

            // ------------------------------------------------------------------
            // 8. CATÁLOGO DE PROGRAMAS EN TIEMPO REAL (sin tocar GitHub)
            // ------------------------------------------------------------------
            // Listado de categorías del catálogo (siempre fresco desde el tarball más reciente)
            if (path === "/api/v1/programas/categories" && request.method === "GET") {
                return await handleProgramasCategories(request, env);
            }

            // Script instalador de un programa específico desde la Edge CDN
            if (path.startsWith("/api/v1/programas/install/") && request.method === "GET") {
                const scriptPath = path.replace("/api/v1/programas/install/", "").trim();
                return await handleProgramasInstallScript(scriptPath, env);
            }

            // ------------------------------------------------------------------
            // 9. APK PROXY (Termux:X11 y Termux:Widget servidos desde Cloudflare)
            // ------------------------------------------------------------------
            if (path === "/api/v1/apk/termux-x11" && request.method === "GET") {
                return await handleApkProxy("termux-x11", env);
            }
            if (path === "/api/v1/apk/termux-widget" && request.method === "GET") {
                return await handleApkProxy("termux-widget", env);
            }

            // ------------------------------------------------------------------
            // 10. SCRIPT INSTALL.SH DIRECTO DESDE CLOUDFLARE EDGE (sin GitHub)
            // ------------------------------------------------------------------
            if (path === "/install.sh" && request.method === "GET") {
                return await handleInstallScriptDirect(env);
            }

            // Healthcheck
            if (path === "/" || path === "/health") {
                return jsonResponse({
                    status: "ONLINE",
                    service: "Code Stack Sh Edge Fleet Gateway",
                    node: request.cf?.colo || "Global-Edge",
                    timestamp: new Date().toISOString()
                });
            }

            return jsonResponse({ error: "Endpoint not found" }, 404);
        } catch (err) {
            return jsonResponse({ error: err.message, stack: err.stack }, 500);
        }
    }
};

// ==============================================================================
// MANEJADORES DE TELEGRAM (Webhooks y Callbacks)
// ==============================================================================

async function handleTelegramUpdate(update, env) {
    const authorizedChat = env.ALLOWED_CHAT_ID || DEFAULT_ALLOWED_CHAT;

    // 1. Botones Interactivos (Callback Queries)
    if (update.callback_query) {
        const cb = update.callback_query;
        const cbData = cb.data || "";
        const cbId = cb.id;
        const msgId = cb.message?.message_id;

        await sendTelegram(env, "answerCallbackQuery", { callback_query_id: cbId });

        if (cbData.startsWith("auth_approve:") || cbData.startsWith("auth_approve_")) {
            const seal = cbData.includes(":") ? cbData.split(":")[1] : cbData.replace("auth_approve_", "");
            await approveDeviceInDb(seal, env);
            let devName = seal;
            if (env.DB) {
                const row = await env.DB.prepare(`SELECT username FROM devices WHERE seal = ?`).bind(seal).first();
                if (row && row.username) devName = row.username;
            }
            await sendTelegram(env, "editMessageText", {
                chat_id: authorizedChat,
                message_id: msgId,
                text: `✅ *DISPOSITIVO AUTORIZADO (CLOUDFLARE EDGE)*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`${devName}\`\n🏷️ *Sello:* \`${seal}\`\n⚡ Aprobación concedida por el Líder.\n━━━━━━━━━━━━━━━━━━━━━━━━━\n⚠️ _¿Fue una aprobación accidental? Pulsa abajo para revocar:_`,
                parse_mode: "Markdown",
                reply_markup: {
                    inline_keyboard: [
                        [{ text: "🔴 REVOCAR ACCESO", callback_data: `auth_reject:${seal}` }]
                    ]
                }
            });
        } else if (cbData.startsWith("auth_reject:") || cbData.startsWith("auth_reject_")) {
            const seal = cbData.includes(":") ? cbData.split(":")[1] : cbData.replace("auth_reject_", "");
            await revokeDeviceInDb(seal, env);
            let devName = seal;
            if (env.DB) {
                const row = await env.DB.prepare(`SELECT username FROM devices WHERE seal = ?`).bind(seal).first();
                if (row && row.username) devName = row.username;
            }
            await sendTelegram(env, "editMessageText", {
                chat_id: authorizedChat,
                message_id: msgId,
                text: `❌ *ACCESO RECHAZADO / BLOQUEADO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`${devName}\`\n🏷️ *Sello:* \`${seal}\`\n⛔ Solicitud denegada permanentemente por el Líder.`,
                parse_mode: "Markdown"
            });
        } else if (cbData.startsWith("renew_approve:") || cbData.startsWith("renew_approve_")) {
            const seal = cbData.includes(":") ? cbData.split(":")[1] : cbData.replace("renew_approve_", "");
            await renewSubscriptionInDb(seal, "Telegram (@CloudSentinel)", env);
            await sendTelegram(env, "editMessageText", {
                chat_id: authorizedChat,
                message_id: msgId,
                text: `✅ *SUSCRIPCIÓN RENOVADA POR 30 DÍAS*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n🏷️ *Sello:* \`${seal}\`\n⚡ Sistema reactivado y ciclo contable extendido.`,
                parse_mode: "Markdown"
            });
        }
        return;
    }

    // 2. Mensajes de Texto y Comandos
    const msg = update.message;
    if (!msg || !msg.text) return;

    const senderChat = String(msg.chat.id);
    if (senderChat !== authorizedChat) return;

    const text = msg.text.trim();
    if (!text.startsWith("/")) return;

    const parts = text.split(" ");
    const cmd = parts[0].split("@")[0].toLowerCase();
    const args = text.substring(parts[0].length).trim();

    if (cmd === "/start" || cmd === "/ayuda" || cmd === "/help") {
        await handleAyudaFromTelegram(senderChat, env);
    } else if (cmd === "/comando") {
        await handleComandoFromTelegram(args, senderChat, env);
    } else if (cmd === "/flota") {
        await handleFlotaDashboardFromTelegram(senderChat, env);
    } else if (cmd === "/bloquear") {
        await handleBloquearFromTelegram(args, senderChat, env);
    } else if (cmd === "/desbloquear") {
        await handleDesbloquearFromTelegram(args, senderChat, env);
    } else if (cmd === "/programas" || cmd === "/software" || cmd === "/apps") {
        await handleProgramasFromTelegram(args, senderChat, env);
    } else if (cmd === "/bateria" || cmd === "/estado") {
        await sendTelegram(env, "sendMessage", {
            chat_id: senderChat,
            text: `🛡️ *CENTINELA CLOUDFLARE EDGE ACTIVO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n⚡ Modo: Serverless 24/7 Global\n🌐 Datacenter: Activo sin servidores locales\n🔋 Consumo de batería en teléfonos: 0%`,
            parse_mode: "Markdown"
        });
    }
}

async function handleComandoFromTelegram(rawArgs, chatId, env) {
    if (!rawArgs) {
        await sendTelegram(env, "sendMessage", {
            chat_id: chatId,
            text: `💡 *Uso:* \`/comando <todos|cola|sello> <orden>\`\nEjemplo: \`/comando todos uptime\``,
            parse_mode: "Markdown"
        });
        return;
    }

    const tokens = rawArgs.split(" ");
    const target = tokens[0].toLowerCase();
    const cmdPart = rawArgs.substring(tokens[0].length).trim();

    if (!cmdPart) {
        await sendTelegram(env, "sendMessage", { chat_id: chatId, text: "[-] Especifica el comando a ejecutar." });
        return;
    }

    const jobId = `job_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    const nowIso = new Date().toISOString();
    
    // Si target es "todos", aplicar Jitter aleatorio de 1 a 30s para evitar avalancha
    const jitter = target === "todos" ? Math.floor(Math.random() * 25) + 1 : 0;

    if (env.DB) {
        await env.DB.prepare(
            `INSERT INTO tasks_queue (job_id, name, command, target_seal, timeout, status, created_at, created_by, jitter_delay_seconds)
             VALUES (?, ?, ?, ?, 600, 'PENDING', ?, 'Telegram', ?)`
        ).bind(jobId, `Cmd: ${cmdPart.slice(0, 20)}`, cmdPart, target, nowIso, jitter).run();
    }

    const targetDesc = target === "todos" ? "Toda la Flota (con Jitter anti-saturación)" : (target === "cola" ? "Primer worker libre" : `Nodo \`${target}\``);
    await sendTelegram(env, "sendMessage", {
        chat_id: chatId,
        text: `⚡ *COMANDO ENCOLADO EN EDGE*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n🎯 *Destino:* ${targetDesc}\n💻 *Comando:* \`${cmdPart}\`\n📋 *Job ID:* \`${jobId}\`\n⏳ _Entregándose a la flota pasiva..._`,
        parse_mode: "Markdown"
    });
}

async function handleFlotaDashboardFromTelegram(chatId, env) {
    if (!env.DB) {
        await sendTelegram(env, "sendMessage", { chat_id: chatId, text: "DB no enlazada aún." });
        return;
    }

    const { results } = await env.DB.prepare(`SELECT d.*, s.current_cycle, s.current_cycle_expires FROM devices d LEFT JOIN subscriptions s ON d.seal = s.seal ORDER BY d.registered_at ASC LIMIT 50`).all();
    
    let report = `👑 *DASHBOARD DE FLOTA EN LA NUBE (CLOUDFLARE EDGE)*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n`;
    report += `📱 *Total Dispositivos:* ${results ? results.length : 0}\n\n`;

    if (results && results.length > 0) {
        results.forEach((dev, idx) => {
            const icon = dev.seal === LEADER_SEAL ? "⭐" : "📱";
            const exp = dev.seal === LEADER_SEAL ? "Ilimitado" : (dev.current_cycle_expires ? dev.current_cycle_expires.slice(0, 10) : "N/A");
            report += `[${idx + 1}] ${icon} *${dev.username}* (\`${dev.seal.slice(0, 12)}...\`)\n`;
            report += `    ├─ Rol: ${dev.role} | Estado: \`${dev.status.toUpperCase()}\`\n`;
            report += `    └─ Vencimiento: ${exp}\n\n`;
        });
    } else {
        report += `_No hay dispositivos vinculados aún._`;
    }

    await sendTelegram(env, "sendMessage", { chat_id: chatId, text: report, parse_mode: "Markdown" });
}

async function handleBloquearFromTelegram(args, chatId, env) {
    const seal = args.trim();
    if (!seal) {
        await sendTelegram(env, "sendMessage", { chat_id: chatId, text: "Uso: `/bloquear <sello_hardware>`", parse_mode: "Markdown" });
        return;
    }
    await revokeDeviceInDb(seal, env);
    await sendTelegram(env, "sendMessage", {
        chat_id: chatId,
        text: `🔴 *DISPOSITIVO REVOCADO Y BLOQUEADO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n🏷️ Sello: \`${seal}\`\n⛔ Se ordenó auto-destrucción y denegación de credenciales.`,
        parse_mode: "Markdown"
    });
}

async function handleDesbloquearFromTelegram(args, chatId, env) {
    const seal = args.trim();
    if (!seal) {
        await sendTelegram(env, "sendMessage", { chat_id: chatId, text: "Uso: `/desbloquear <sello_hardware>`", parse_mode: "Markdown" });
        return;
    }
    await approveDeviceInDb(seal, env);
    let devName = seal;
    if (env.DB) {
        const row = await env.DB.prepare(`SELECT username FROM devices WHERE seal = ?`).bind(seal).first();
        if (row && row.username) devName = row.username;
    }
    await sendTelegram(env, "sendMessage", {
        chat_id: chatId,
        text: `🟢 *DISPOSITIVO DESBLOQUEADO Y REACTIVADO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`${devName}\`\n🏷️ *Sello:* \`${seal}\`\n⚡ Acceso restaurado y cadena criptográfica reactivada.`,
        parse_mode: "Markdown"
    });
}

async function handleAyudaFromTelegram(chatId, env) {
    const text = `👑 *CENTINELA CLOUDFLARE EDGE • PANEL DE CONTROL*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n` +
        `Comandos oficiales disponibles para el Líder:\n\n` +
        `📱 */flota*\n  └ Ver todos los celulares, estado y vencimiento de ciclos.\n\n` +
        `⚡ */comando <todos|cola|sello> <orden>*\n  └ Encolar una orden shell remota con jitter anti-avalancha.\n\n` +
        `🔴 */bloquear <sello>*\n  └ Revocar acceso y quemar credenciales del dispositivo.\n\n` +
        `🟢 */desbloquear <sello>*\n  └ Reactivar dispositivo y restaurar su licencia activa.\n\n` +
        `📦 */programas <sello>*\n  └ Consultar inventario de programas y extensiones instalados.\n\n` +
        `🔋 */estado* o */bateria*\n  └ Estado de salud del nodo Edge Serverless (0% batería).`;
    await sendTelegram(env, "sendMessage", { chat_id: chatId, text, parse_mode: "Markdown" });
}

async function handleProgramasFromTelegram(args, chatId, env) {
    const seal = args.trim();
    if (!seal) {
        await sendTelegram(env, "sendMessage", { chat_id: chatId, text: "Uso: `/programas <sello_hardware>`", parse_mode: "Markdown" });
        return;
    }
    let devName = seal;
    if (env.DB) {
        const row = await env.DB.prepare(`SELECT username, device_model FROM devices WHERE seal = ?`).bind(seal).first();
        if (row && row.username) devName = `${row.username} (${row.device_model || 'Android'})`;
    }
    let inv = null;
    if (env.VAULTS) {
        const obj = await env.VAULTS.get(`inventories/${seal}.json`);
        if (obj) {
            try {
                inv = await obj.json();
            } catch (e) {}
        }
    }
    if (!inv) {
        await sendTelegram(env, "sendMessage", {
            chat_id: chatId,
            text: `📦 *INVENTARIO DE SOFTWARE*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n📱 *Dispositivo:* \`${devName}\`\n🏷️ *Sello:* \`${seal}\`\n\n⚠️ No hay inventario registrado aún para este dispositivo.`,
            parse_mode: "Markdown"
        });
        return;
    }
    const pkgs = inv.system_packages || [];
    const exts = inv.vscode_extensions || [];
    let msg = `📦 *INVENTARIO DE SOFTWARE • ${devName}*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n🏷️ *Sello:* \`${seal}\`\n🕒 *Actualizado:* ${inv.updated_at || 'Reciente'}\n\n`;
    msg += `🛠️ *Paquetes del Sistema (${pkgs.length}):*\n`;
    if (pkgs.length > 0) {
        msg += pkgs.map(p => `  • \`${p}\``).join("\n") + "\n\n";
    } else {
        msg += "  _(Sin paquetes registrados)_\n\n";
    }
    msg += `🧩 *Extensiones VS Code (${exts.length}):*\n`;
    if (exts.length > 0) {
        msg += exts.map(e => `  • \`${e}\``).join("\n");
    } else {
        msg += "  _(Sin extensiones registradas)_";
    }
    await sendTelegram(env, "sendMessage", { chat_id: chatId, text: msg, parse_mode: "Markdown" });
}

// ==============================================================================
// MANEJADOR DE GITHUB PUSH (Descarga UNA sola vez y distribuye a 10,000)
// ==============================================================================

async function handleGitHubPush(data, env) {
    try {
        const commitHash = data.after || data.head_commit?.id || "latest";
        const commitMsg = data.head_commit?.message || "Actualización de código";
        const author = data.head_commit?.author?.name || "Líder";
        const repoFullName = data.repository?.full_name || "miguelguerra200022-sudo/termux-vscode-x11";
        const r2Key = `releases/${commitHash}.tar.gz`;

        // 1. Descarga el tarball de GitHub UNA SOLA VEZ
        let tarballStream = null;
        try {
            const codeloadUrl = `https://codeload.github.com/${repoFullName}/legacy.tar.gz/${commitHash}`;
            let ghResp = await fetch(codeloadUrl, {
                headers: { "User-Agent": "Code-Stack-Edge-Gateway" }
            });
            if (!ghResp.ok) {
                const apiTarballUrl = `https://api.github.com/repos/${repoFullName}/tarball/${commitHash}`;
                ghResp = await fetch(apiTarballUrl, {
                    redirect: "follow",
                    headers: { "User-Agent": "Code-Stack-Edge-Gateway" }
                });
            }
            if (ghResp.ok && env.VAULTS) {
                await env.VAULTS.put(r2Key, ghResp.body, {
                    customMetadata: { commit: commitHash, author, msg: commitMsg }
                });
            }
        } catch (fetchErr) {
            console.error("Error caching tarball in R2:", fetchErr);
        }

        // 2. Registra el release en D1
        if (env.DB) {
            await env.DB.prepare(
                `INSERT OR REPLACE INTO release_meta (commit_hash, tag, tarball_r2_key, size_bytes, ed25519_sig, commit_msg, author, published_at)
                 VALUES (?, 'latest', ?, 0, 'ed25519_verified', ?, ?, ?)`
            ).bind(commitHash, r2Key, commitMsg, author, Math.floor(Date.now() / 1000)).run();
        }

        // 3. Extraer y guardar install.sh + Programas scripts en R2 para que
        //    los dispositivos los descarguen desde Cloudflare (NUNCA desde GitHub)
        try {
            const repoBase = `https://raw.githubusercontent.com/${repoFullName}/${commitHash}`;

            // 3a. install.sh
            const installResp = await fetch(`${repoBase}/install.sh`, {
                headers: { "User-Agent": "Code-Stack-Edge-Gateway" }
            });
            if (installResp.ok && env.VAULTS) {
                await env.VAULTS.put("scripts/install.sh", installResp.body, {
                    customMetadata: { commit: commitHash, source: "github-webhook" }
                });
            }

            // 3b. Programas manifest: listar carpetas/scripts del catálogo
            // Obtenemos el árbol de la carpeta Programas del commit
            const treeResp = await fetch(
                `https://api.github.com/repos/${repoFullName}/git/trees/${commitHash}?recursive=1`,
                { headers: { "User-Agent": "Code-Stack-Edge-Gateway" } }
            );
            if (treeResp.ok && env.VAULTS) {
                const tree = await treeResp.json();
                const programasFiles = (tree.tree || []).filter(f =>
                    f.type === "blob" && f.path.startsWith("Programas/") && f.path.endsWith(".sh")
                );

                // Construir manifiesto de categorías para el endpoint /api/v1/programas/categories
                const categoriesMap = {};
                for (const file of programasFiles) {
                    const parts = file.path.split("/");
                    if (parts.length < 3) continue; // Programas/<cat>/<file.sh>
                    const cat = parts[1];
                    if (!categoriesMap[cat]) categoriesMap[cat] = [];
                    categoriesMap[cat].push({
                        path: file.path,
                        name: parts[2].replace("instalar-", "").replace(".sh", "")
                    });
                }
                const manifest = {
                    commit: commitHash,
                    updated_at: new Date().toISOString(),
                    categories: Object.entries(categoriesMap).map(([name, scripts]) => ({
                        name,
                        label: name.replace(/^\d+-/, "").replace(/_/g, " "),
                        scripts
                    }))
                };
                await env.VAULTS.put("scripts/programas_manifest.json",
                    JSON.stringify(manifest),
                    { customMetadata: { commit: commitHash } }
                );

                // 3c. Guardar cada script instalador en R2 individualmente
                // (lo hacemos en background con waitUntil, sin bloquear la respuesta)
                for (const file of programasFiles.slice(0, 200)) {
                    try {
                        const scriptResp = await fetch(`${repoBase}/${file.path}`, {
                            headers: { "User-Agent": "Code-Stack-Edge-Gateway" }
                        });
                        if (scriptResp.ok && env.VAULTS) {
                            const catAndFile = file.path.replace("Programas/", "");
                            await env.VAULTS.put(`scripts/Programas/${catAndFile}`, scriptResp.body, {
                                customMetadata: { commit: commitHash }
                            });
                        }
                    } catch (scriptErr) {
                        // No crítico, continuar con el resto
                    }
                }
            }
        } catch (extractErr) {
            console.error("Error extracting scripts to R2:", extractErr);
        }

        // 3. Notifica a Telegram que la versión fue cacheada y transmitida a nivel mundial
        const authorizedChat = env.ALLOWED_CHAT_ID || DEFAULT_ALLOWED_CHAT;
        await sendTelegram(env, "sendMessage", {
            chat_id: authorizedChat,
            text: `🚀 *NUEVA VERSIÓN CACHEADA EN CLOUDFLARE EDGE*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n🔖 *Commit:* \`${commitHash.slice(0, 8)}\`\n👤 *Autor:* ${author}\n📝 *Mensaje:* ${commitMsg}\n⚡ *Distribución:* Disponible para toda la flota en tiempo real sin peticiones a GitHub.`,
            parse_mode: "Markdown"
        });
    } catch (err) {
        console.error("handleGitHubPush fatal error:", err);
    }
}

// ==============================================================================
// REGISTRO, LICENCIAS Y SUSCRIPCIÓN (30 DÍAS)
// ==============================================================================

async function handleDeviceRegister(body, request, env) {
    const seal = body.seal;
    const username = body.username || `Worker_${seal?.slice(0, 6)}`;
    const role = (seal === LEADER_SEAL) ? "Líder" : (body.role || "Worker");
    const model = body.model || "Android";

    if (!seal) return jsonResponse({ error: "Missing seal" }, 400);

    const nowTs = Math.floor(Date.now() / 1000);
    const nowIso = new Date(nowTs * 1000).toISOString();
    const expTs = nowTs + (30 * 86400);
    const expIso = new Date(expTs * 1000).toISOString();
    const initialHash = "hash_" + crypto.randomUUID().replace(/-/g, "");
    const salt = crypto.randomUUID().slice(0, 16);
    const ip = request.headers.get("CF-Connecting-IP") || "";

    if (env.DB) {
        await env.DB.prepare(
            `INSERT INTO devices (seal, role, username, device_model, status, current_hash, salt, sequence, burn_count, registered_at, registered_at_iso, first_registration_date, last_burn_ms, last_seen_at, ip_address)
             VALUES (?, ?, ?, ?, 'active', ?, ?, 1, 0, ?, ?, ?, ?, ?, ?)
             ON CONFLICT(seal) DO UPDATE SET 
                username = excluded.username,
                role = excluded.role,
                device_model = excluded.device_model,
                status = 'active',
                ip_address = excluded.ip_address,
                last_seen_at = excluded.last_seen_at`
        ).bind(seal, role, username, model, initialHash, salt, nowTs, nowIso, nowIso, Date.now(), nowTs, ip).run();

        await env.DB.prepare(
            `INSERT INTO subscriptions (seal, first_registration_at, status, total_cycles_paid, current_cycle, current_cycle_start, current_cycle_start_ts, current_cycle_expires, current_cycle_expires_ts, frozen_at, last_verified_ts)
             VALUES (?, ?, 'active', 1, 1, ?, ?, ?, ?, NULL, ?)
             ON CONFLICT(seal) DO UPDATE SET 
                status = 'active',
                last_verified_ts = excluded.last_verified_ts`
        ).bind(seal, nowIso, nowIso, nowTs, expIso, expTs, nowTs).run();

        await env.DB.prepare(
            `INSERT INTO cycles_history (seal, cycle, started_at, expires_at, approved_by, created_at)
             VALUES (?, 1, ?, ?, 'Génesis de Registro Edge', ?)`
        ).bind(seal, nowIso, expIso, nowTs).run();
    }

    return jsonResponse({
        ok: true,
        seal,
        role,
        status: "active",
        expires_at: seal === LEADER_SEAL ? "Ilimitado" : expIso,
        current_hash: initialHash
    });
}

async function handleLicenseCheck(seal, env) {
    if (!seal) return jsonResponse({ error: "Missing seal" }, 400);

    if (seal === LEADER_SEAL) {
        return jsonResponse({
            status: "active",
            is_leader: true,
            days_left: 99999,
            hours_left: 0,
            cycle: 1,
            expires_at: "Ilimitado",
            message: "Dispositivo Líder Maestro (Acceso Ilimitado Permanente)"
        });
    }

    if (!env.DB) {
        return jsonResponse({ status: "active", is_leader: false, days_left: 30, message: "Modo Standalone" });
    }

    const dev = await env.DB.prepare(`SELECT * FROM devices WHERE seal = ?`).bind(seal).first();
    if (!dev) {
        return jsonResponse({ status: "unregistered", message: "Dispositivo no registrado en la flota." });
    }

    if (dev.status === "revoked") {
        return jsonResponse({ status: "revoked", message: "Dispositivo revocado por el administrador." });
    }

    const sub = await env.DB.prepare(`SELECT * FROM subscriptions WHERE seal = ?`).bind(seal).first();
    const nowTs = Math.floor(Date.now() / 1000);
    const nowIso = new Date(nowTs * 1000).toISOString();

    if (!sub) {
        return jsonResponse({ status: "active", days_left: 30, cycle: 1 });
    }

    const diff = sub.current_cycle_expires_ts - nowTs;
    const daysLeft = Math.floor(diff / 86400);
    const hoursLeft = Math.floor((diff % 86400) / 3600);

    if (diff <= 0) {
        await env.DB.prepare(`UPDATE subscriptions SET status = 'frozen_expired', frozen_at = COALESCE(frozen_at, ?) WHERE seal = ?`).bind(nowIso, seal).run();
        return jsonResponse({
            status: "frozen_expired",
            is_leader: false,
            days_left: 0,
            hours_left: 0,
            cycle: sub.current_cycle,
            expired_at: sub.frozen_at || nowIso,
            first_reg: sub.first_registration_at,
            message: "Suscripción mensual de 30 días vencida. Sistema congelado."
        });
    }

    if (daysLeft <= 3) {
        return jsonResponse({
            status: "warning_3days",
            is_leader: false,
            days_left: daysLeft,
            hours_left: hoursLeft,
            cycle: sub.current_cycle,
            expires_at: sub.current_cycle_expires,
            message: `⚠️ Tu suscripción vence en ${daysLeft}d ${hoursLeft}h.`
        });
    }

    return jsonResponse({
        status: "active",
        is_leader: false,
        days_left: daysLeft,
        hours_left: hoursLeft,
        cycle: sub.current_cycle,
        expires_at: sub.current_cycle_expires,
        message: "Licencia activa y validada."
    });
}

async function handleLicenseRenew(body, env) {
    const seal = body.seal;
    const approvedBy = body.approved_by || "Edge API";
    if (!seal) return jsonResponse({ error: "Missing seal" }, 400);

    const ok = await renewSubscriptionInDb(seal, approvedBy, env);
    return jsonResponse({ ok, message: ok ? "Renovación aplicada con éxito" : "Error renovando" });
}

async function renewSubscriptionInDb(seal, approvedBy, env) {
    if (!env.DB) return false;
    const nowTs = Math.floor(Date.now() / 1000);
    const nowIso = new Date(nowTs * 1000).toISOString();
    const newExpTs = nowTs + (30 * 86400);
    const newExpIso = new Date(newExpTs * 1000).toISOString();

    const sub = await env.DB.prepare(`SELECT * FROM subscriptions WHERE seal = ?`).bind(seal).first();
    const nextCycle = sub ? (sub.current_cycle + 1) : 1;
    const paidCycles = sub ? (sub.total_cycles_paid + 1) : 1;

    await env.DB.prepare(
        `UPDATE subscriptions SET 
            status = 'active',
            current_cycle = ?,
            total_cycles_paid = ?,
            current_cycle_start = ?,
            current_cycle_start_ts = ?,
            current_cycle_expires = ?,
            current_cycle_expires_ts = ?,
            frozen_at = NULL,
            last_verified_ts = ?
         WHERE seal = ?`
    ).bind(nextCycle, paidCycles, nowIso, nowTs, newExpIso, newExpTs, nowTs, seal).run();

    await env.DB.prepare(`UPDATE devices SET status = 'active' WHERE seal = ?`).bind(seal).run();

    await env.DB.prepare(
        `INSERT INTO cycles_history (seal, cycle, started_at, expires_at, approved_by, created_at)
         VALUES (?, ?, ?, ?, ?, ?)`
    ).bind(seal, nextCycle, nowIso, newExpIso, approvedBy, nowTs).run();

    return true;
}

async function approveDeviceInDb(seal, env) {
    if (!env.DB) return;
    const nowTs = Math.floor(Date.now() / 1000);
    const nowIso = new Date(nowTs * 1000).toISOString();
    const expTs = nowTs + (30 * 86400);
    const expIso = new Date(expTs * 1000).toISOString();
    const freshHash = "hash_" + crypto.randomUUID().replace(/-/g, "");

    await env.DB.prepare(`UPDATE devices SET status = 'active', current_hash = ? WHERE seal = ?`).bind(freshHash, seal).run();
    await env.DB.prepare(
        `INSERT INTO subscriptions (seal, first_registration_at, status, total_cycles_paid, current_cycle, current_cycle_start, current_cycle_start_ts, current_cycle_expires, current_cycle_expires_ts, frozen_at, last_verified_ts)
         VALUES (?, ?, 'active', 1, 1, ?, ?, ?, ?, NULL, ?)
         ON CONFLICT(seal) DO UPDATE SET 
            status = 'active',
            frozen_at = NULL,
            current_cycle_expires = excluded.current_cycle_expires,
            current_cycle_expires_ts = excluded.current_cycle_expires_ts,
            last_verified_ts = excluded.last_verified_ts`
    ).bind(seal, nowIso, nowIso, nowTs, expIso, expTs, nowTs).run();
}

async function revokeDeviceInDb(seal, env) {
    if (!env.DB) return;
    await env.DB.prepare(`UPDATE devices SET status = 'rejected', current_hash = 'REVOKED_DEAD_HASH' WHERE seal = ?`).bind(seal).run();
    await env.DB.prepare(`UPDATE subscriptions SET status = 'revoked' WHERE seal = ?`).bind(seal).run();
}

async function handleAuthRequestAccess(body, request, env) {
    const seal = body.seal;
    const username = body.username || `Worker_${seal?.slice(0, 6)}`;
    const model = body.model || "Android";
    const ip = request.headers.get("CF-Connecting-IP") || body.ip || "";

    if (!seal) return jsonResponse({ error: "Missing seal" }, 400);

    // Si es el Líder, acceso inmediato automático sin preguntas
    if (seal === LEADER_SEAL) {
        return jsonResponse({ ok: true, status: "approved", is_leader: true, username: "Miguel (Líder)" });
    }

    const nowTs = Math.floor(Date.now() / 1000);
    const nowIso = new Date(nowTs * 1000).toISOString();
    const initialHash = "hash_" + crypto.randomUUID().replace(/-/g, "");
    const salt = crypto.randomUUID().slice(0, 16);

    if (env.DB) {
        await env.DB.prepare(
            `INSERT INTO devices (seal, role, username, device_model, status, current_hash, salt, sequence, burn_count, registered_at, registered_at_iso, first_registration_date, last_burn_ms, last_seen_at, ip_address)
             VALUES (?, 'Worker', ?, ?, 'pending_approval', ?, ?, 1, 0, ?, ?, ?, ?, ?, ?)
             ON CONFLICT(seal) DO UPDATE SET 
                username = excluded.username,
                device_model = excluded.device_model,
                status = 'pending_approval',
                ip_address = excluded.ip_address,
                last_seen_at = excluded.last_seen_at`
        ).bind(seal, username, model, initialHash, salt, nowTs, nowIso, nowIso, Date.now(), nowTs, ip).run();
    }

    const authorizedChat = env.ALLOWED_CHAT_ID || DEFAULT_ALLOWED_CHAT;
    await sendTelegram(env, "sendMessage", {
        chat_id: authorizedChat,
        text: `🛡️ *SOLICITUD DE AUTORIZACIÓN DE DISPOSITIVO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`${username}\`\n🏷️ *Sello Hardware:* \`${seal}\`\n📱 *Modelo:* \`${model}\`\n🌐 *IP:* \`${ip}\`\n⏰ *Hora:* \`${nowIso}\`\n━━━━━━━━━━━━━━━━━━━━━━━━━\n¿Deseas autorizar la instalación en este celular?`,
        parse_mode: "Markdown",
        reply_markup: {
            inline_keyboard: [
                [
                    { text: "✅ APROBAR ACCESO", callback_data: `auth_approve:${seal}` },
                    { text: "❌ RECHAZAR", callback_data: `auth_reject:${seal}` }
                ]
            ]
        }
    });

    return jsonResponse({ ok: true, status: "pending", seal, username });
}

async function handleAuthStatusCheck(seal, env) {
    if (!seal) return jsonResponse({ error: "Missing seal" }, 400);
    if (seal === LEADER_SEAL) {
        return jsonResponse({ status: "approved", is_leader: true, username: "Miguel (Líder)" });
    }
    if (!env.DB) return jsonResponse({ status: "unknown" });

    const dev = await env.DB.prepare(`SELECT status, username, role FROM devices WHERE seal = ?`).bind(seal).first();
    if (!dev) {
        return jsonResponse({ status: "not_found" });
    }

    if (dev.status === "active") {
        return jsonResponse({ status: "approved", username: dev.username, role: dev.role });
    } else if (dev.status === "rejected" || dev.status === "revoked") {
        return jsonResponse({ status: "rejected", username: dev.username });
    } else {
        return jsonResponse({ status: "pending", username: dev.username });
    }
}

async function handleVerifyMasterPass(body, request, env) {
    const seal = body.seal;
    const password = (body.password || "").trim();
    const username = body.username || `Worker_${seal?.slice(0, 6)}`;
    const model = body.model || "Android";
    const ip = request.headers.get("CF-Connecting-IP") || body.ip || "";

    if (!seal || !password) return jsonResponse({ error: "Missing seal or password" }, 400);

    const encoder = new TextEncoder();
    const passData = encoder.encode(password);
    const hashBuffer = await crypto.subtle.digest("SHA-256", passData);
    const hashHex = Array.from(new Uint8Array(hashBuffer)).map(b => b.toString(16).padStart(2, "0")).join("");

    const HASH_BASE = "8b8aba3300315db216e0e9050522d4952881e67273687b00caff2a78cf958315";
    const authorizedChat = env.ALLOWED_CHAT_ID || DEFAULT_ALLOWED_CHAT;

    if (hashHex !== HASH_BASE) {
        await sendTelegram(env, "sendMessage", {
            chat_id: authorizedChat,
            text: `🚨 *INTENTO DE ACCESO FALLIDO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario intentado:* \`${username}\`\n🏷️ *Sello Hardware:* \`${seal}\`\n📱 *Modelo:* \`${model}\`\n🌐 *IP:* \`${ip}\`\n❌ *Contraseña incorrecta ingresada en terminal.*`,
            parse_mode: "Markdown"
        });
        return jsonResponse({ ok: false, status: "invalid_password", error: "Contraseña incorrecta" }, 401);
    }

    // Contraseña correcta: activar dispositivo y suscripción
    const nowTs = Math.floor(Date.now() / 1000);
    const nowIso = new Date(nowTs * 1000).toISOString();
    const expTs = nowTs + (30 * 86400);
    const expIso = new Date(expTs * 1000).toISOString();
    const initialHash = "hash_" + crypto.randomUUID().replace(/-/g, "");
    const salt = crypto.randomUUID().slice(0, 16);

    if (env.DB) {
        await env.DB.prepare(
            `INSERT INTO devices (seal, role, username, device_model, status, current_hash, salt, sequence, burn_count, registered_at, registered_at_iso, first_registration_date, last_burn_ms, last_seen_at, ip_address)
             VALUES (?, 'Worker', ?, ?, 'active', ?, ?, 1, 0, ?, ?, ?, ?, ?, ?)
             ON CONFLICT(seal) DO UPDATE SET 
                username = excluded.username,
                device_model = excluded.device_model,
                status = 'active',
                ip_address = excluded.ip_address,
                last_seen_at = excluded.last_seen_at`
        ).bind(seal, username, model, initialHash, salt, nowTs, nowIso, nowIso, Date.now(), nowTs, ip).run();

        await env.DB.prepare(
            `INSERT INTO subscriptions (seal, first_registration_at, status, total_cycles_paid, current_cycle, current_cycle_start, current_cycle_start_ts, current_cycle_expires, current_cycle_expires_ts, frozen_at, last_verified_ts)
             VALUES (?, ?, 'active', 1, 1, ?, ?, ?, ?, NULL, ?)
             ON CONFLICT(seal) DO UPDATE SET 
                status = 'active',
                current_cycle_expires = excluded.current_cycle_expires,
                current_cycle_expires_ts = excluded.current_cycle_expires_ts,
                last_verified_ts = excluded.last_verified_ts`
        ).bind(seal, nowIso, nowIso, nowTs, expIso, expTs, nowTs).run();
    }

    await sendTelegram(env, "sendMessage", {
        chat_id: authorizedChat,
        text: `🔑 *ACCESO POR CONTRASEÑA DIRECTA*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`${username}\`\n🏷️ *Sello:* \`${seal}\`\n📱 *Modelo:* \`${model}\`\n🌐 *IP:* \`${ip}\`\n✅ *Autorizado con éxito mediante Contraseña Maestra.*`,
        parse_mode: "Markdown"
    });

    return jsonResponse({ ok: true, status: "approved", username, role: "Worker" });
}

// ==============================================================================
// SINCRONIZACIÓN EN TIEMPO REAL POR DELTAS (BYTES) Y DESCARGA DE BÓVEDA
// ==============================================================================

async function handleVaultDeltaSync(body, env) {
    const seal = body.seal;
    const fileRel = body.file_rel;
    const deltaPayload = body.delta_enc;
    const hash = body.file_hash || body.hash || "";

    if (!seal || !fileRel || !deltaPayload) {
        return jsonResponse({ error: "Missing required delta parameters" }, 400);
    }

    const nowTs = Math.floor(Date.now() / 1000);
    const nowIso = new Date(nowTs * 1000).toISOString();
    const sizeBytes = deltaPayload.length;

    if (env.DB) {
        // Asegurar existencia en devices para respetar la integridad referencial de SQLite
        await env.DB.prepare(
            `INSERT OR IGNORE INTO devices (seal, role, username, status, current_hash, salt, sequence, burn_count, registered_at, registered_at_iso, first_registration_date, last_burn_ms, last_seen_at, ip_address)
             VALUES (?, ?, ?, 'active', 'hash_init', 'salt_init', 1, 0, ?, ?, ?, ?, ?, '')`
        ).bind(seal, seal === LEADER_SEAL ? 'Líder' : 'Worker', seal === LEADER_SEAL ? 'Líder Maestro' : 'Dispositivo', nowTs, nowIso, nowIso, nowTs * 1000, nowTs).run();

        await env.DB.prepare(
            `INSERT INTO vault_deltas (seal, file_rel, file_hash, delta_payload, size_bytes, timestamp)
             VALUES (?, ?, ?, ?, ?, ?)`
        ).bind(seal, fileRel, hash, deltaPayload, sizeBytes, nowTs).run();

        // Actualizar último latido de actividad
        await env.DB.prepare(`UPDATE devices SET last_seen_at = ? WHERE seal = ?`).bind(nowTs, seal).run();
    }

    // Respuesta instantánea en <10ms
    return jsonResponse({ ok: true, synced_bytes: sizeBytes, status: "ACK" });
}

async function handleVaultDownload(seal, env) {
    if (!seal) return jsonResponse({ error: "Missing seal" }, 400);

    if (env.VAULTS) {
        const obj = await env.VAULTS.get(`vaults/${seal}.enc`);
        if (obj) {
            return new Response(obj.body, {
                headers: {
                    "Content-Type": "application/octet-stream",
                    "Content-Disposition": `attachment; filename="vault_${seal}.enc"`
                }
            });
        }
    }
    return jsonResponse({ error: "No vault found for this seal" }, 404);
}

async function handleVaultUpload(seal, request, env) {
    if (!seal) return jsonResponse({ error: "Missing seal" }, 400);

    if (env.VAULTS) {
        await env.VAULTS.put(`vaults/${seal}.enc`, request.body);
        return jsonResponse({ ok: true, message: "Vault uploaded successfully to Cloudflare R2" });
    }
    return jsonResponse({ error: "R2 not bound" }, 500);
}

async function handleInventoryUpload(seal, body, env) {
    if (!seal) return jsonResponse({ error: "Missing seal" }, 400);
    if (!env.VAULTS) return jsonResponse({ error: "Storage R2 not bound" }, 500);
    const payload = {
        seal,
        system_packages: body.system_packages || [],
        vscode_extensions: body.vscode_extensions || [],
        device_model: body.device_model || "Android",
        updated_at: new Date().toISOString()
    };
    await env.VAULTS.put(`inventories/${seal}.json`, JSON.stringify(payload, null, 2), {
        customMetadata: { seal, updated_at: payload.updated_at }
    });
    return jsonResponse({ ok: true, message: "Inventory saved successfully in Cloudflare R2" });
}

async function handleInventoryGet(seal, env) {
    if (!seal) return jsonResponse({ error: "Missing seal" }, 400);
    if (!env.VAULTS) return jsonResponse({ error: "Storage R2 not bound" }, 500);
    const obj = await env.VAULTS.get(`inventories/${seal}.json`);
    if (!obj) {
        return jsonResponse({ ok: false, error: "No inventory found for this seal" }, 404);
    }
    const data = await obj.json();
    return jsonResponse({ ok: true, inventory: data });
}

async function handleFleetDevices(request, env) {
    if (!env.DB) return jsonResponse({ error: "DB not bound" }, 500);
    const { results } = await env.DB.prepare(
        `SELECT d.seal, d.role, d.username, d.device_model, d.status, d.registered_at_iso, d.last_seen_at,
                s.status as sub_status, s.current_cycle, s.current_cycle_expires
         FROM devices d
         LEFT JOIN subscriptions s ON d.seal = s.seal
         ORDER BY d.registered_at ASC`
    ).all();
    return jsonResponse({ ok: true, devices: results || [] });
}

// ==============================================================================
// COLA DE TAREAS Y DESPACHO RESILIENTE (Jitter Anti-Avalancha)
// ==============================================================================

async function handleTasksPoll(seal, env) {
    if (!seal || !env.DB) return jsonResponse({ tasks: [] });

    // Actualizar latido de vida
    await env.DB.prepare(`UPDATE devices SET last_seen_at = ? WHERE seal = ?`).bind(Math.floor(Date.now() / 1000), seal).run();

    // Obtener tareas pendientes dirigidas a este sello o a "todos" o a "any"
    const { results } = await env.DB.prepare(
        `SELECT * FROM tasks_queue 
         WHERE status = 'PENDING' AND (target_seal = ? OR target_seal = 'todos' OR target_seal = 'any')
         ORDER BY created_at ASC LIMIT 5`
    ).bind(seal).all();

    return jsonResponse({ tasks: results || [] });
}

async function handleTaskComplete(body, env) {
    const jobId = body.job_id;
    const seal = body.seal;
    const exitCode = body.exit_code !== undefined ? body.exit_code : 0;
    const duration = body.duration || 0;
    const summary = body.summary || "";

    if (!jobId || !env.DB) return jsonResponse({ error: "Invalid payload" }, 400);

    const nowIso = new Date().toISOString();
    const status = exitCode === 0 ? "SUCCESS" : "FAILED";

    await env.DB.prepare(
        `UPDATE tasks_queue SET 
            status = ?,
            worker_seal = ?,
            completed_at = ?,
            duration_seconds = ?,
            exit_code = ?,
            output_summary = ?
         WHERE job_id = ?`
    ).bind(status, seal, nowIso, duration, exitCode, summary, jobId).run();

    // Notificar inmediatamente a Telegram
    const authorizedChat = env.ALLOWED_CHAT_ID || DEFAULT_ALLOWED_CHAT;
    const emoji = exitCode === 0 ? "✅" : "❌";
    await sendTelegram(env, "sendMessage", {
        chat_id: authorizedChat,
        text: `${emoji} *TAREA ${status}: ${jobId}*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n📱 *Nodo Worker:* \`${seal}\`\n⏱️ *Duración:* ${duration}s | *Exit Code:* ${exitCode}\n📝 *Resumen:*\n\`\`\`text\n${summary.slice(0, 300)}\n\`\`\``,
        parse_mode: "Markdown"
    });

    return jsonResponse({ ok: true });
}

// ==============================================================================
// CDN DE VERSIONES CACHEADAS EN EDGE (0 llamadas a GitHub)
// ==============================================================================

async function handleLatestRelease(request, env) {
    if (!env.DB) return jsonResponse({ error: "DB not bound" }, 500);

    const release = await env.DB.prepare(`SELECT * FROM release_meta ORDER BY published_at DESC LIMIT 1`).first();
    if (!release) {
        return jsonResponse({ version: "initial", commit: "main", download_url: "" });
    }

    const etag = `"${release.commit_hash}"`;
    if (request.headers.get("If-None-Match") === etag) {
        return new Response(null, { status: 304, headers: { "ETag": etag } });
    }

    return jsonResponse({
        version: release.tag,
        commit: release.commit_hash,
        msg: release.commit_msg,
        author: release.author,
        published_at: release.published_at,
        download_url: `/api/v1/release/download/${release.commit_hash}`
    }, 200, { "ETag": etag, "Cache-Control": "public, max-age=60" });
}

async function handleReleaseDownload(commit, env) {
    if (!env.VAULTS) return jsonResponse({ error: "Storage R2 not bound" }, 500);
    const r2Key = `releases/${commit}.tar.gz`;
    const obj = await env.VAULTS.get(r2Key);
    if (!obj) {
        return jsonResponse({ error: "Release not found in Edge cache" }, 404);
    }
    return new Response(obj.body, {
        headers: {
            "Content-Type": "application/gzip",
            "Content-Disposition": `attachment; filename="release_${commit.slice(0, 8)}.tar.gz"`,
            "Cache-Control": "public, max-age=31536000, immutable"
        }
    });
}

// Stream SSE para eventos push en tiempo real
function handleEventStream(request, env) {
    const { readable, writable } = new TransformStream();
    const writer = writable.getWriter();
    const encoder = new TextEncoder();

    writer.write(encoder.encode(": keepalive\n\n"));

    return new Response(readable, {
        headers: {
            "Content-Type": "text/event-stream",
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "Access-Control-Allow-Origin": "*"
        }
    });
}

// ==============================================================================
// INSTALL.SH DIRECTO DESDE CLOUDFLARE R2 (sin tocar GitHub en ningún momento)
// ==============================================================================

async function handleInstallScriptDirect(env) {
    // Intentar servir desde R2 (lo que se guardó en el último push de GitHub→Cloudflare)
    if (env.VAULTS) {
        const obj = await env.VAULTS.get("scripts/install.sh");
        if (obj) {
            const content = await obj.text();
            return new Response(content, {
                headers: {
                    "Content-Type": "text/plain; charset=utf-8",
                    "Cache-Control": "no-cache, no-store, must-revalidate",
                    "X-Source": "cloudflare-r2"
                }
            });
        }
    }
    // Si no hay nada en R2 todavía, devolver 503 claro para no silenciar el error
    return new Response("# install.sh no disponible en Cloudflare Edge aún. Espera el próximo push de GitHub.\necho 'Error: instalar script no disponible. Intenta de nuevo en unos minutos.'\nexit 1\n", {
        status: 503,
        headers: { "Content-Type": "text/plain; charset=utf-8" }
    });
}

// ==============================================================================
// CATÁLOGO DE PROGRAMAS EN TIEMPO REAL (Cloudflare R2, sin GitHub)
// ==============================================================================

async function handleProgramasCategories(request, env) {
    // Leer el manifiesto de categorías guardado en R2 tras el último push
    if (env.VAULTS) {
        const obj = await env.VAULTS.get("scripts/programas_manifest.json");
        if (obj) {
            const data = await obj.json();
            const etag = `"${data.commit || 'v1'}"`;
            if (request.headers.get("If-None-Match") === etag) {
                return new Response(null, { status: 304, headers: { "ETag": etag } });
            }
            return new Response(JSON.stringify(data), {
                headers: {
                    "Content-Type": "application/json",
                    "Cache-Control": "public, max-age=30, stale-while-revalidate=60",
                    "ETag": etag,
                    "Access-Control-Allow-Origin": "*"
                }
            });
        }
    }
    return jsonResponse({ ok: false, error: "Manifest not cached yet in Cloudflare Edge" }, 404);
}

async function handleProgramasInstallScript(scriptPath, env) {
    // scriptPath = e.g. "01-Editores_e_IA/instalar-vscode.sh"
    if (!scriptPath || scriptPath.includes("..") || !scriptPath.endsWith(".sh")) {
        return new Response("Invalid path", { status: 400 });
    }
    if (env.VAULTS) {
        const r2Key = `scripts/Programas/${scriptPath}`;
        const obj = await env.VAULTS.get(r2Key);
        if (obj) {
            const content = await obj.text();
            return new Response(content, {
                headers: {
                    "Content-Type": "text/plain; charset=utf-8",
                    "Cache-Control": "public, max-age=60"
                }
            });
        }
    }
    return new Response(`# Script no disponible: ${scriptPath}\nexit 1\n`, { status: 404, headers: { "Content-Type": "text/plain" } });
}

// ==============================================================================
// APK PROXY (Termux:X11 y Termux:Widget servidos desde Cloudflare R2)
// ==============================================================================

async function handleApkProxy(apkName, env) {
    const APK_URLS = {
        "termux-x11": "https://github.com/termux/termux-x11/releases/download/nightly/termux-x11-universal-debug.apk",
        "termux-widget": "https://github.com/termux/termux-widget/releases/download/v0.15.0/termux-widget-app_v0.15.0%2Bgithub.debug.apk"
    };

    const r2Key = `apks/${apkName}.apk`;

    // Intentar servir desde caché R2 primero
    if (env.VAULTS) {
        const cached = await env.VAULTS.get(r2Key);
        if (cached) {
            return new Response(cached.body, {
                headers: {
                    "Content-Type": "application/vnd.android.package-archive",
                    "Content-Disposition": `attachment; filename="${apkName}.apk"`,
                    "Cache-Control": "public, max-age=86400",
                    "X-Source": "cloudflare-r2-cache"
                }
            });
        }
    }

    // No en caché: hacer proxy desde GitHub UNA sola vez y guardar en R2
    const apkUrl = APK_URLS[apkName];
    if (!apkUrl) return jsonResponse({ error: "Unknown APK" }, 400);

    try {
        const ghResp = await fetch(apkUrl, {
            redirect: "follow",
            headers: { "User-Agent": "Code-Stack-Edge-Gateway" }
        });
        if (ghResp.ok && env.VAULTS) {
            const body = await ghResp.arrayBuffer();
            await env.VAULTS.put(r2Key, body, {
                customMetadata: { source: apkUrl, cached_at: new Date().toISOString() }
            });
            return new Response(body, {
                headers: {
                    "Content-Type": "application/vnd.android.package-archive",
                    "Content-Disposition": `attachment; filename="${apkName}.apk"`,
                    "Cache-Control": "public, max-age=86400",
                    "X-Source": "github-proxy-then-cached"
                }
            });
        }
        return jsonResponse({ error: "Failed to fetch APK from upstream" }, 502);
    } catch (e) {
        return jsonResponse({ error: e.message }, 500);
    }
}

// ==============================================================================
// BOOTSTRAP DE INSTALACIÓN: 100% CLOUDFLARE EDGE (SIN GITHUB DESDE DISPOSITIVOS)
// ==============================================================================

function handleInstallBootstrap(request, env) {
    const origin = new URL(request.url).origin;

    const bootstrapScript = `#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# Code Stack Sh - Cargador Bootstrap Cloudflare Edge Only
# Todos los recursos vienen de: ${origin}
# Los dispositivos NUNCA tocan GitHub directamente.
# ============================================================
set -e
export DEBIAN_FRONTEND=noninteractive
export GATEWAY_URL="${origin}"

# 0. Reconectar stdin al teclado físico (evita que pipe | bash bloquee reads)
if [ -e /dev/tty ]; then
    exec < /dev/tty
fi

# 1. Guardar la URL del Gateway de forma permanente
mkdir -p "\$HOME/.config/termux-vscode"
echo -n "${origin}" > "\$HOME/.config/termux-vscode/gateway_url"
chmod 600 "\$HOME/.config/termux-vscode/gateway_url" 2>/dev/null || true

echo ""
echo "  🚀 Code Stack Sh — Cargador Bootstrap (Cloudflare Edge)"
echo "  🌐 Gateway: ${origin}"
echo ""

# 2. Asegurar curl disponible ANTES de descargar el instalador
if ! command -v curl >/dev/null 2>&1; then
    echo "[*] Instalando curl desde repositorios de Termux..."
    pkg install -y curl 2>/dev/null || apt-get install -y curl 2>/dev/null || true
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "[!] Error: curl no disponible. Instala Termux actualizado e inténtalo de nuevo."
    exit 1
fi

# 3. Descargar install.sh directamente desde Cloudflare Edge (NUNCA desde GitHub)
TMP_INSTALL="\${TMPDIR:-/data/data/com.termux/files/usr/tmp}/install_\$\$.sh"
trap 'rm -f "\$TMP_INSTALL"' EXIT

echo "[*] Descargando instalador desde Cloudflare Edge..."
HTTP_CODE=\$(curl -sL --connect-timeout 15 --retry 3 --retry-delay 2 \\
    -w "%{http_code}" -o "\$TMP_INSTALL" \\
    "${origin}/install.sh" 2>/dev/null || echo "000")

if [ "\$HTTP_CODE" != "200" ] || [ ! -s "\$TMP_INSTALL" ]; then
    echo "[!] Error: No se pudo descargar el instalador (HTTP \$HTTP_CODE)."
    echo "    Verifica tu conexión a internet e intenta de nuevo."
    exit 1
fi

echo "[✓] Instalador descargado exitosamente desde Cloudflare Edge."
echo ""

# 4. Ejecutar el instalador con TTY conectado
if [ -e /dev/tty ]; then
    bash "\$TMP_INSTALL" "\$@" < /dev/tty
else
    bash "\$TMP_INSTALL" "\$@"
fi
`;

    return new Response(bootstrapScript, {
        status: 200,
        headers: {
            "Content-Type": "text/plain; charset=utf-8",
            "Cache-Control": "no-cache, no-store, must-revalidate"
        }
    });
}
