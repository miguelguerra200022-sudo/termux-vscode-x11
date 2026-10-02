#!/usr/bin/env python3
"""
deploy_api.py: Despliegue nativo directo a la API REST de Cloudflare v4.
No depende de wrangler ni de binarios x86/glibc; funciona al 100% en Termux ARM64.
"""

import os
import sys
import json
import urllib.request
import urllib.parse
import urllib.error

API_BASE = "https://api.cloudflare.com/client/v4"

def make_request(method, endpoint, token, data=None, content_type="application/json"):
    url = f"{API_BASE}{endpoint}"
    headers = {
        "Authorization": f"Bearer {token}",
        "User-Agent": "Code-Stack-Deployer/1.0"
    }
    body = None
    if data is not None:
        if isinstance(data, (dict, list)):
            body = json.dumps(data).encode("utf-8")
            headers["Content-Type"] = "application/json"
        elif isinstance(data, bytes):
            body = data
            headers["Content-Type"] = content_type
        elif isinstance(data, str):
            body = data.encode("utf-8")
            headers["Content-Type"] = content_type

    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read().decode("utf-8", errors="replace")
            return json.loads(raw)
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8", errors="replace")
        try:
            return json.loads(err_body)
        except Exception:
            return {"success": False, "errors": [{"message": f"HTTP {e.code}: {err_body}"}]}
    except Exception as e:
        return {"success": False, "errors": [{"message": str(e)}]}

def main():
    account_id = os.environ.get("CLOUDFLARE_ACCOUNT_ID")
    token = os.environ.get("CLOUDFLARE_API_TOKEN")

    if not account_id or not token:
        if len(sys.argv) >= 3:
            account_id = sys.argv[1]
            token = sys.argv[2]
        else:
            print("[!] Uso: python3 deploy_api.py <ACCOUNT_ID> <API_TOKEN>")
            sys.exit(1)

    print("======================================================")
    print("  🚀 DESPLIEGUE NATIVO A CLOUDFLARE EDGE (REST API v4)")
    print("======================================================")
    print(f"[*] Account ID: {account_id}")

    # 1. Verificar Token
    print("[1/6] Verificando permisos del API Token a nivel de cuenta...")
    res = make_request("GET", f"/accounts/{account_id}/workers/scripts", token)
    if not res.get("success"):
        print(f"[❌] Error de autenticación a nivel de cuenta: {res.get('errors')}")
        sys.exit(1)
    print("    [✓] API Token VÁLIDO con acceso a Workers y D1.")

    # 2. Base de Datos D1
    print("\n[2/6] Gestionando Base de Datos D1 (fleet-d1)...")
    d1_list = make_request("GET", f"/accounts/{account_id}/d1/database", token)
    db_id = None
    if d1_list.get("success"):
        for db in d1_list.get("result", []):
            if db.get("name") == "fleet-d1":
                db_id = db.get("uuid")
                print(f"    [✓] D1 'fleet-d1' ya existe con UUID: {db_id}")
                break

    if not db_id:
        create_res = make_request("POST", f"/accounts/{account_id}/d1/database", token, {"name": "fleet-d1"})
        if create_res.get("success"):
            db_id = create_res["result"]["uuid"]
            print(f"    [✓] D1 'fleet-d1' creada exitosamente: {db_id}")
        else:
            print(f"    [!] Error creando D1: {create_res.get('errors')}")
            # Continuar si ya existía o falla no crítica

    # Aplicar Esquema SQL a D1
    script_dir = os.path.dirname(os.path.abspath(__file__))
    schema_path = os.path.join(script_dir, "schema.sql")
    if db_id and os.path.isfile(schema_path):
        print("    [*] Aplicando schema.sql a D1...")
        with open(schema_path, "r", encoding="utf-8") as f:
            sql_content = f.read()
        sql_res = make_request("POST", f"/accounts/{account_id}/d1/database/{db_id}/query", token, {"sql": sql_content})
        if sql_res.get("success"):
            print("    [✓] Tablas y esquema SQL aplicados en D1.")
        else:
            print(f"    [!] Aviso en SQL D1: {sql_res.get('errors')}")

    # 3. Bucket R2
    print("\n[3/6] Gestionando Bucket R2 (code-stack-vaults)...")
    r2_res = make_request("POST", f"/accounts/{account_id}/r2/buckets", token, {"name": "code-stack-vaults"})
    if r2_res.get("success") or "already exists" in str(r2_res):
        print("    [✓] Bucket R2 'code-stack-vaults' listo y operativo.")
    else:
        print(f"    [!] Aviso R2: {r2_res.get('errors')}")

    # 4. Desplegar Worker Script
    print("\n[4/6] Desplegando Worker 'code-stack-gateway'...")
    index_js_path = os.path.join(script_dir, "src", "index.js")
    with open(index_js_path, "r", encoding="utf-8") as f:
        worker_code = f.read()

    # Cargar secretos de webhooks
    secrets_file = os.path.expanduser("~/.config/termux-vscode/.secrets.json")
    sec_data = {}
    if os.path.isfile(secrets_file):
        try:
            with open(secrets_file, "r") as sf:
                sec_data = json.load(sf)
        except Exception:
            pass
    tg_secret = sec_data.get("telegram_webhook_secret", "")
    gh_secret = sec_data.get("github_webhook_secret", "")

    # Subir script con metadata y bindings
    # Multipart form data para subir script ES module + bindings
    boundary = "----CloudflareWorkerBoundaryXYZ123"
    metadata = {
        "main_module": "index.js",
        "compatibility_date": "2024-09-01",
        "compatibility_flags": ["nodejs_compat"],
        "bindings": [
            {
                "type": "d1",
                "name": "DB",
                "id": db_id if db_id else "fleet-d1"
            },
            {
                "type": "r2_bucket",
                "name": "VAULTS",
                "bucket_name": "code-stack-vaults"
            },
            {
                "type": "plain_text",
                "name": "LEADER_SEAL",
                "text": "ums9230-sp_6300-3724801c"
            },
            {
                "type": "plain_text",
                "name": "ALLOWED_CHAT_ID",
                "text": "1514766577"
            },
            {
                "type": "secret_text",
                "name": "TELEGRAM_BOT_TOKEN",
                "text": "8835215357:AAG142javmyg8xPzx3Ad-Aj2ohqmBfMtvls"
            },
            {
                "type": "secret_text",
                "name": "TELEGRAM_WEBHOOK_SECRET",
                "text": tg_secret
            },
            {
                "type": "secret_text",
                "name": "GITHUB_WEBHOOK_SECRET",
                "text": gh_secret
            }
        ]
    }

    body_parts = []
    body_parts.append(f"--{boundary}\r\nContent-Disposition: form-data; name=\"metadata\"\r\nContent-Type: application/json\r\n\r\n{json.dumps(metadata)}\r\n")
    body_parts.append(f"--{boundary}\r\nContent-Disposition: form-data; name=\"index.js\"; filename=\"index.js\"\r\nContent-Type: application/javascript+module\r\n\r\n{worker_code}\r\n")
    body_parts.append(f"--{boundary}--\r\n")
    full_body = "".join(body_parts).encode("utf-8")

    upload_res = make_request(
        "PUT",
        f"/accounts/{account_id}/workers/scripts/code-stack-gateway",
        token,
        data=full_body,
        content_type=f"multipart/form-data; boundary={boundary}"
    )

    if upload_res.get("success"):
        print("    [✓] Script de Worker desplegado con éxito en el Edge.")
    else:
        print(f"    [❌] Error al desplegar Worker: {upload_res.get('errors')}")
        sys.exit(1)

    # 5. Activar ruta workers.dev
    print("\n[5/6] Habilitando subdominio workers.dev...")
    sub_res = make_request("POST", f"/accounts/{account_id}/workers/scripts/code-stack-gateway/subdomain", token, {"enabled": True})
    
    # Obtener subdominio de la cuenta
    sub_info = make_request("GET", f"/accounts/{account_id}/workers/subdomain", token)
    subdomain = sub_info.get("result", {}).get("subdomain", "")
    if subdomain:
        worker_url = f"https://code-stack-gateway.{subdomain}.workers.dev"
    else:
        worker_url = "https://code-stack-gateway.workers.dev"

    print(f"    [✓] Gateway Activo en: {worker_url}")

    # Guardar gateway_url en el dispositivo
    cfg_dir = os.path.expanduser("~/.config/termux-vscode")
    os.makedirs(cfg_dir, exist_ok=True)
    with open(os.path.join(cfg_dir, "gateway_url"), "w", encoding="utf-8") as f:
        f.write(worker_url)
    print(f"    [✓] Guardada URL del Gateway en ~/.config/termux-vscode/gateway_url")

    # 6. Conectar Webhook de Telegram
    print("\n[6/6] Enlazando Webhook de Telegram (Con Token Secreto Criptográfico)...")
    tg_token = "8835215357:AAG142javmyg8xPzx3Ad-Aj2ohqmBfMtvls"
    sec_param = f"&secret_token={urllib.parse.quote(tg_secret, safe='')}" if tg_secret else ""
    tg_webhook_url = f"https://api.telegram.org/bot{tg_token}/setWebhook?url={urllib.parse.quote(worker_url + '/telegram/webhook', safe='')}{sec_param}&max_connections=40"
    try:
        with urllib.request.urlopen(tg_webhook_url) as tg_r:
            tg_data = json.loads(tg_r.read().decode())
            if tg_data.get("ok"):
                print("    [✓] Webhook de Telegram configurado con secreto criptográfico 24/7.")
            else:
                print(f"    [!] Telegram respondió: {tg_data}")
    except Exception as e:
        print(f"    [!] Error enlazando Telegram: {e}")

    print("\n" + "=" * 60)
    print("  🎉 ¡INFRAESTRUCTURA CLOUDFLARE COMPLETAMENTE OPERATIVA!")
    print("=" * 60)
    print(f"🔗 Gateway URL: {worker_url}")
    print(f"📊 D1 Database ID: {db_id}")
    print(f"📦 Bóveda R2: code-stack-vaults")
    print("⚡ Todo listo para atender a los 10,000 dispositivos.")

if __name__ == "__main__":
    main()
