#!/usr/bin/env python3
"""
backfill_r2.py: Sube install.sh, Programas scripts y manifiesto de categorías
directamente a Cloudflare R2 via Workers API. Ejecutar en el Líder después
de un push para poblar el Edge antes del primer dispositivo virgen.

Uso: python3 cloud-gateway/backfill_r2.py <ACCOUNT_ID> <API_TOKEN> <COMMIT_HASH>
"""
import sys
import os
import json
import urllib.request
import urllib.error
import glob

def upload_to_r2(account_id, api_token, bucket_name, key, content, content_type="text/plain"):
    """Sube un objeto a R2 via Cloudflare API."""
    url = f"https://api.cloudflare.com/client/v4/accounts/{account_id}/r2/buckets/{bucket_name}/objects/{key}"
    if isinstance(content, str):
        content = content.encode("utf-8")
    
    req = urllib.request.Request(url, data=content, method="PUT")
    req.add_header("Authorization", f"Bearer {api_token}")
    req.add_header("Content-Type", content_type)
    req.add_header("User-Agent", "Code-Stack-Backfill/1.0")
    
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return True, resp.status
    except urllib.error.HTTPError as e:
        return False, e.code
    except Exception as ex:
        return False, str(ex)

def main():
    if len(sys.argv) < 4:
        print("Uso: python3 backfill_r2.py <ACCOUNT_ID> <API_TOKEN> <COMMIT_HASH>")
        sys.exit(1)
    
    ACCOUNT_ID = sys.argv[1]
    API_TOKEN = sys.argv[2]
    COMMIT_HASH = sys.argv[3]
    BUCKET = "code-stack-vaults"
    
    # Directorio del repo (padre de cloud-gateway)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_dir = os.path.dirname(script_dir)
    
    print(f"[*] Backfill de R2 para commit {COMMIT_HASH[:8]}...")
    print(f"[*] Repositorio: {repo_dir}")
    print(f"[*] Bucket: {BUCKET}")
    print("")
    
    # 1. Subir install.sh
    install_sh_path = os.path.join(repo_dir, "install.sh")
    if os.path.isfile(install_sh_path):
        with open(install_sh_path, "r", encoding="utf-8") as f:
            content = f.read()
        ok, status = upload_to_r2(ACCOUNT_ID, API_TOKEN, BUCKET, "scripts/install.sh", content)
        if ok:
            print(f"[✓] install.sh subido a R2 (scripts/install.sh)")
        else:
            print(f"[!] Error subiendo install.sh: {status}")
    else:
        print(f"[!] No se encontró install.sh en {install_sh_path}")
    
    # 2. Subir todos los scripts de Programas e indexar categorías
    programas_dir = os.path.join(repo_dir, "Programas")
    categories = {}
    uploaded_scripts = 0
    
    if os.path.isdir(programas_dir):
        script_files = glob.glob(os.path.join(programas_dir, "*", "instalar-*.sh"))
        script_files.sort()
        
        for script_path in script_files:
            rel = os.path.relpath(script_path, programas_dir)  # e.g. "01-Editores_e_IA/instalar-vscode.sh"
            cat_name = os.path.dirname(rel)  # "01-Editores_e_IA"
            prog_name = os.path.basename(rel).replace("instalar-", "").replace(".sh", "")
            
            if cat_name not in categories:
                categories[cat_name] = []
            categories[cat_name].append({
                "path": f"Programas/{rel}",
                "name": prog_name
            })
            
            with open(script_path, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
            
            r2_key = f"scripts/Programas/{rel}"
            ok, status = upload_to_r2(ACCOUNT_ID, API_TOKEN, BUCKET, r2_key, content)
            if ok:
                uploaded_scripts += 1
                print(f"  [✓] {rel}")
            else:
                print(f"  [!] Error {rel}: {status}")
    
    print(f"\n[✓] {uploaded_scripts} scripts de Programas subidos a R2")
    
    # 3. Generar y subir el manifiesto de categorías
    from datetime import datetime, timezone
    manifest = {
        "commit": COMMIT_HASH,
        "updated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "categories": [
            {
                "name": name,
                "label": name.replace("-", " ").lstrip("0123456789 ").replace("_", " "),
                "scripts": scripts
            }
            for name, scripts in sorted(categories.items())
        ]
    }
    manifest_json = json.dumps(manifest, ensure_ascii=False, indent=2)
    ok, status = upload_to_r2(ACCOUNT_ID, API_TOKEN, BUCKET, "scripts/programas_manifest.json", 
                               manifest_json, "application/json")
    if ok:
        print(f"[✓] Manifiesto de categorías subido ({len(manifest['categories'])} categorías)")
    else:
        print(f"[!] Error subiendo manifiesto: {status}")
    
    # 4. Subir scripts de bin/ críticos
    bin_dir = os.path.join(repo_dir, "bin")
    bin_scripts = ["encender", "apagar", "start-vscode", "stop-vscode", "gpu-optimizer",
                   "programas", "gitops-sync", "watcher-sync", "cloud-sentinel",
                   "desinstalar", "desinstalar-vscode"]
    uploaded_bins = 0
    for b in bin_scripts:
        bp = os.path.join(bin_dir, b)
        if os.path.isfile(bp):
            with open(bp, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
            ok, status = upload_to_r2(ACCOUNT_ID, API_TOKEN, BUCKET, f"scripts/bin/{b}", content)
            if ok:
                uploaded_bins += 1
    print(f"[✓] {uploaded_bins} scripts de bin/ subidos a R2")
    
    print("\n" + "="*60)
    print("  ✅ Backfill de Cloudflare R2 completado.")
    print("  🌐 install.sh → /install.sh disponible desde Edge")
    print(f"  📦 Programas → /api/v1/programas/categories disponible")
    print("="*60)

if __name__ == "__main__":
    main()
