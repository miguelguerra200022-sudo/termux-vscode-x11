-- ==============================================================================
-- Cloudflare D1 Distributed Database Schema: Code Stack Sh Edge Fleet
-- ==============================================================================

-- 1. Tabla de Dispositivos Registrados (Hardware Seals)
CREATE TABLE IF NOT EXISTS devices (
    seal TEXT PRIMARY KEY,
    role TEXT NOT NULL DEFAULT 'Worker',
    username TEXT NOT NULL,
    device_model TEXT DEFAULT 'Android',
    status TEXT NOT NULL DEFAULT 'active',
    current_hash TEXT NOT NULL,
    salt TEXT NOT NULL,
    sequence INTEGER NOT NULL DEFAULT 1,
    burn_count INTEGER NOT NULL DEFAULT 0,
    registered_at INTEGER NOT NULL,
    registered_at_iso TEXT NOT NULL,
    first_registration_date TEXT NOT NULL,
    last_burn_ms INTEGER NOT NULL DEFAULT 0,
    last_seen_at INTEGER NOT NULL DEFAULT 0,
    ip_address TEXT DEFAULT ''
);

-- 2. Tabla de Suscripciones y Ciclos Contables (30 Días)
CREATE TABLE IF NOT EXISTS subscriptions (
    seal TEXT PRIMARY KEY,
    first_registration_at TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    total_cycles_paid INTEGER NOT NULL DEFAULT 1,
    current_cycle INTEGER NOT NULL DEFAULT 1,
    current_cycle_start TEXT NOT NULL,
    current_cycle_start_ts INTEGER NOT NULL,
    current_cycle_expires TEXT NOT NULL,
    current_cycle_expires_ts INTEGER NOT NULL,
    frozen_at TEXT DEFAULT NULL,
    last_verified_ts INTEGER NOT NULL,
    FOREIGN KEY(seal) REFERENCES devices(seal) ON DELETE CASCADE
);

-- 3. Historial Inmutable de Ciclos de Pago y Renovaciones
CREATE TABLE IF NOT EXISTS cycles_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    seal TEXT NOT NULL,
    cycle INTEGER NOT NULL,
    started_at TEXT NOT NULL,
    expires_at TEXT NOT NULL,
    approved_by TEXT NOT NULL,
    expired_at TEXT DEFAULT NULL,
    renewed_at TEXT DEFAULT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY(seal) REFERENCES devices(seal) ON DELETE CASCADE
);

-- 4. Cola de Comandos y Trabajos de la Flota (Thundering Herd Resilient)
CREATE TABLE IF NOT EXISTS tasks_queue (
    job_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    command TEXT NOT NULL,
    target_seal TEXT NOT NULL DEFAULT 'any',
    timeout INTEGER NOT NULL DEFAULT 600,
    status TEXT NOT NULL DEFAULT 'PENDING',
    created_at TEXT NOT NULL,
    created_by TEXT NOT NULL,
    jitter_delay_seconds INTEGER NOT NULL DEFAULT 0,
    worker_seal TEXT DEFAULT NULL,
    started_at TEXT DEFAULT NULL,
    completed_at TEXT DEFAULT NULL,
    duration_seconds REAL DEFAULT 0.0,
    exit_code INTEGER DEFAULT NULL,
    output_summary TEXT DEFAULT '',
    output_encrypted TEXT DEFAULT ''
);

-- 5. Registro de Sincronización Incremental por Deltas (Bytes en tiempo real)
CREATE TABLE IF NOT EXISTS vault_deltas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    seal TEXT NOT NULL,
    file_rel TEXT NOT NULL,
    file_hash TEXT NOT NULL,
    delta_payload TEXT NOT NULL,
    size_bytes INTEGER NOT NULL,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY(seal) REFERENCES devices(seal) ON DELETE CASCADE
);

-- 6. Metadatos de Versiones y Releases (Disparadas por GitHub Webhook)
CREATE TABLE IF NOT EXISTS release_meta (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    commit_hash TEXT NOT NULL UNIQUE,
    tag TEXT DEFAULT 'latest',
    tarball_r2_key TEXT NOT NULL,
    size_bytes INTEGER NOT NULL,
    ed25519_sig TEXT NOT NULL,
    commit_msg TEXT DEFAULT '',
    author TEXT DEFAULT '',
    published_at INTEGER NOT NULL
);

-- Índices de Alto Rendimiento para Latencia <5ms
CREATE INDEX IF NOT EXISTS idx_devices_status ON devices(status);
CREATE INDEX IF NOT EXISTS idx_tasks_status_target ON tasks_queue(status, target_seal);
CREATE INDEX IF NOT EXISTS idx_deltas_seal ON vault_deltas(seal, timestamp);
CREATE INDEX IF NOT EXISTS idx_sub_expires ON subscriptions(current_cycle_expires_ts);
