# 🚀 Termux VS Code + Termux:X11 Mobile IDE Pro

Entorno de desarrollo nativo de **Visual Studio Code (Code - OSS)** para **Android** ejecutándose sobre **Termux** y **Termux:X11**.

A diferencia de las instalaciones lentas basadas en PRoot / Ubuntu / Debian, este entorno corre de forma **100% nativa** en Termux con máximo rendimiento, aceleración multi-hilo, acceso directo al hardware de Android y un conjunto de herramientas profesionales diseñadas específicamente para programar desde el móvil.

---

## ✨ Características y Superpoderes Pro

* ⚡ **100% Nativo y Ultraligero**: Sin PRoot, sin chroot, sin emulación. Comparte los mismos paquetes y compiladores de tu Termux.
* 🛡️ **Anti-Cierres de Android (Wakelock Activo)**: `start-vscode` activa `termux-wake-lock` para evitar que Android mate VS Code o pause compilaciones cuando la pantalla se apague.
* 🏎️ **Aceleración Multi-Hilo CPU y Memoria**: Configurado con `LP_NUM_THREADS=$(nproc)` para acelerar la renderización por software de la interfaz gráfica y límites de heap JS para evitar cierres OOM.
* 🌐 **Acceso al Navegador del Celular**: Cualquier enlace abierto desde VS Code o la terminal abre automáticamente tu navegador de Android (Chrome, Brave, Firefox, etc.) mediante intents nativos.
* 🌍 **Túneles HTTPS Públicos al Instante (`share-port`)**: Comparte tus proyectos locales por internet con un solo comando mediante túneles oficiales de Cloudflare (`https://*.trycloudflare.com`) sin abrir puertos en tu router.
* 📡 **Inspector de Red y Código QR (`dev-info`)**: Genera enlaces locales y códigos QR en la terminal para que cualquier persona en tu misma red Wi-Fi pueda escanear y probar tu web al instante.
* 🔔 **Notificaciones y Vibración Android (`notify-done`)**: Recibe una alerta háptica y notificación en la barra de Android cuando termine una tarea larga (ej: `npm run build && notify-done`).
* 🔄 **Sincronización con GitHub en 1 Clic (`sync-vscode`)**: Respalda y sube cualquier ajuste nuevo de VS Code directamente a tu repositorio de GitHub.
* 📋 **Portapapeles Unificado**: Sincronización bidireccional entre el portapapeles de Android y VS Code. Copia en Android y pega en VS Code (o viceversa) sin pasos intermedios.
* 💾 **Persistencia Completa de Sesiones y Credenciales**: Incluye `password-store=basic` y `VSCODE_CLI_USE_FILE_KEYCHAIN=1` para mantener tus inicios de sesión, tokens de IA, pestañas abiertas y ventanas guardadas entre reinicios.
* 📱 **Optimización Táctil en Openbox**: Reglas de ventana configuradas para eliminar barras de título y maximizar el editor al 100% de la pantalla táctil de tu teléfono.
* 🔊 **Soporte de Sonido (PulseAudio)**: Servidor de audio enrutado a los altavoces de tu móvil para escuchar sonidos, alertas o pruebas multimedia.
* 🧹 **Instalación Modular y Limpia**: El instalador configura todo el entorno base optimizado sin precargar extensiones lentas, permitiéndote instalar únicamente las que desees.

---

## 📥 Instalación

### Método 1: Un Solo Comando (Recomendado)
Abre Termux y ejecuta:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/miguelguerra200022-sudo/termux-vscode-x11/main/install.sh)"
```

### Método 2: Clonando el Repositorio
```bash
git clone https://github.com/miguelguerra200022-sudo/termux-vscode-x11.git
cd termux-vscode-x11
chmod +x install.sh
./install.sh
```

> [!NOTE]
> El instalador descargará automáticamente la aplicación complementaria **Termux:X11 APK** en tu carpeta de Descargas (`/storage/emulated/0/Download/termux-x11-universal-debug.apk`). Si aún no la tienes instalada en tu Android, simplemente abre tu gestor de archivos e instálala.

---

## 🛠️ Caja de Herramientas y Comandos Disponibles

| Comando | Descripción |
| :--- | :--- |
| `start-vscode` | Arranca VS Code con Wakelock, audio, aceleración multi-hilo y entorno gráfico. |
| `stop-vscode` | Cierra limpiamente, guarda pestañas y credenciales, y respalda automáticamente tus configuraciones a GitHub. |
| `share-port <puerto>` | Genera un túnel público seguro HTTPS con Cloudflare (ej: `share-port 3000`). |
| `dev-info <puerto>` | Muestra URLs para móvil/PC en tu Wi-Fi y genera un código QR escaneable. |
| `notify-done "texto"` | Envía notificación y vibración a Android al terminar un comando. |
| `sync-vscode` | Respalda tus configuraciones actuales y hace `push` automático a GitHub. |
| `setup-swap` | Diagnostica el estado de la RAM y memoria Swap para prevenir cierres por memoria. |

---

## 🌐 Cómo usar el Navegador y Servidores de tu Móvil

1. **Abrir enlaces en tu navegador**:
   Haz `Ctrl + Clic` en cualquier enlace web dentro de un archivo o en la terminal integrada de VS Code. Se abrirá de inmediato en Chrome / Firefox en tu teléfono.

2. **Probar páginas web y APIs locales**:
   Si estás creando una web (por ejemplo con Vite, Next.js, Node o Python):
   - En la terminal de VS Code corre tu servidor, por ejemplo:
     ```bash
     python -m http.server 8080
     ```
   - Abre tu navegador de Android (Chrome, Brave, etc.) e ingresa a `http://localhost:8080`.
   - Para compartirlo en tu red Wi-Fi o generar un QR, ejecuta:
     ```bash
     dev-info 8080
     ```
   - Para compartirlo con cualquier persona en internet mediante HTTPS seguro:
     ```bash
     share-port 8080
     ```

---

## 🧩 Instalación de Extensiones

Para mantener el sistema rápido y ordenado, el instalador no incluye extensiones por defecto. Puedes instalar las que necesites:

* **Desde la interfaz gráfica**: Abre el icono de Extensiones (`Ctrl + Shift + X`) dentro de VS Code y busca la extensión que necesites.
* **Desde la terminal de Termux**:
  ```bash
  code --install-extension <id-extension>
  ```
* **Para instalar extensiones VSIX locales (como Ahefi u otras)**:
  ```bash
  code --install-extension /ruta/a/extension.vsix
  ```

---

## 📂 Estructura del Repositorio

```text
termux-vscode-x11/
├── bin/
│   ├── start-vscode     # Arranque optimizado con Wakelock, multi-hilo y audio
│   ├── stop-vscode      # Cierre limpio y guardado de sesión
│   ├── share-port       # Túneles HTTPS públicos instantáneos (Cloudflare)
│   ├── dev-info         # Inspector de red local y generador de códigos QR
│   ├── notify-done      # Notificaciones y vibración en Android
│   ├── sync-vscode      # Respaldo automático a GitHub en 1 clic
│   └── setup-swap       # Monitor de memoria RAM / Swap
├── config/
│   ├── settings.json    # Configuración de VS Code (persistencia y navegador)
│   ├── argv.json        # Flags de Electron y password-store
│   └── rc.xml           # Reglas táctiles de Openbox (pantalla completa)
├── install.sh           # Instalador automatizado en un solo comando
├── uninstall.sh         # Script de desinstalación limpia
├── .gitignore           # Excluye cachés, llaves y extensiones temporales
└── README.md            # Documentación completa
```

---

## 👤 Autor
* **Miguel Guerra** - [@miguelguerra200022-sudo](https://github.com/miguelguerra200022-sudo)
