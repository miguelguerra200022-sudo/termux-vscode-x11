# 🚀 Termux VS Code + Termux:X11 Mobile IDE Pro

Entorno de desarrollo nativo de **Visual Studio Code (Code - OSS)** para **Android** ejecutándose sobre **Termux** y **Termux:X11**.

A diferencia de las instalaciones lentas basadas en PRoot / Ubuntu / Debian, este entorno corre de forma **100% nativa** en Termux con máximo rendimiento, aceleración multi-hilo, acceso directo al hardware de Android y un conjunto de herramientas profesionales diseñadas específicamente para programar desde el móvil.

---

## ✨ Características y Superpoderes Pro

* ⚡ **100% Nativo y Ultraligero**: Sin PRoot, sin chroot, sin emulación. Comparte los mismos paquetes y compiladores de tu Termux.
* 🛡️ **Anti-Cierres de Android (Wakelock Activo)**: `start-vscode` activa `termux-wake-lock` para evitar que Android mate VS Code o pause compilaciones cuando la pantalla se apague.
* 🏪 **Tienda Oficial Completa de Extensiones**: Incluye `set-marketplace official` para desbloquear el catálogo oficial de Microsoft Marketplace (+60.000 extensiones como Pylance, Python, Prettier, etc.).
* 📱 **Acceso Rápido desde Pantalla de Inicio (Widgets)**: Integración con `~/.shortcuts/` para abrir o cerrar VS Code con un solo toque desde tu launcher de Android con **Termux:Widget**.
* 🔤 **Tipografía Fira Code con Ligaduras**: Soporte nativo para símbolos estilizados de código (`=>`, `===`, `!=`, `->`) y glifos de terminal.
* 🎨 **Tema OLED Pure Black**: Fondo negro puro (`#000000`) para reducir drásticamente el consumo de batería en pantallas AMOLED de celulares.
* 💻 **Modo Dual (Móvil vs. PC / Laptop Remota)**: Con `start-vscode-web` puedes abrir la interfaz completa de tu VS Code en el navegador de tu computadora o tablet conectada a la misma red.
* ⚡ **Generador Rápido de Plantillas (`new-project`)**: Crea proyectos de Python (con virtualenv), Frontend Web (HTML/JS), Bots de Telegram o APIs Node.js en 3 segundos listos con Git.
* 🛡️ **Escudo Anti-Phantom Process Killer (`fix-phantom-killer`)**: Vacuna contra el limitador de 32 subprocesos en Android 12, 13, 14 y 15.
* 🌐 **Acceso al Navegador del Celular**: Cualquier enlace abierto desde VS Code o la terminal abre automáticamente tu navegador de Android (Chrome, Brave, Firefox, etc.) mediante intents nativos.
* 🌍 **Túneles HTTPS Públicos al Instante (`share-port`)**: Comparte tus proyectos locales por internet con un solo comando mediante túneles oficiales de Cloudflare (`https://*.trycloudflare.com`) sin abrir puertos en tu router.
* 📡 **Inspector de Red y Código QR (`dev-info`)**: Genera enlaces locales y códigos QR en la terminal para que cualquier persona en tu misma red Wi-Fi pueda escanear y probar tu web al instante.
* 🔔 **Notificaciones y Vibración Android (`notify-done`)**: Recibe una alerta háptica y notificación en la barra de Android cuando termine una tarea larga (ej: `npm run build && notify-done`).
* 🔄 **Sincronización y Respaldo 100% Automático**: Cada vez que ejecutas `stop-vscode`, tus configuraciones se respaldan y suben automáticamente a tu GitHub sin que tengas que acordarte.
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

---

## 🛠️ Caja de Herramientas y Comandos Disponibles

| Comando | Descripción |
| :--- | :--- |
| `start-vscode` | Arranca VS Code con Wakelock, audio, aceleración multi-hilo y entorno gráfico. |
| `stop-vscode` | Cierra limpiamente, guarda pestañas y credenciales, y respalda automáticamente tus configuraciones a GitHub. |
| `guia` | Abre inmediatamente la copia maestra permanente de la Guía Rápida (@GUIA_RAPIDA.md). |
| `start-vscode-web` | Modo Dual: comparte la pantalla de VS Code para usarlo desde tu PC o Tablet en la red local. |
| `new-project` | Generador interactivo de proyectos (Python, Web, Bots, Node) listos con Git en 3 segundos. |
| `set-marketplace` | Alterna entre la tienda oficial de Microsoft Marketplace (`official`) y Open-VSX (`openvsx`). |
| `fix-phantom-killer` | Diagnostica y desactiva el Phantom Process Killer de Android 12+. |
| `share-port <puerto>` | Genera un túnel público seguro HTTPS con Cloudflare (ej: `share-port 3000`). |
| `dev-info <puerto>` | Muestra URLs para móvil/PC en tu Wi-Fi y genera un código QR escaneable. |
| `notify-done "texto"` | Envía notificación y vibración a Android al terminar un comando. |
| `sync-vscode` | Respalda tus configuraciones actuales y hace `push` automático a GitHub. |
| `setup-swap` | Diagnostica el estado de la RAM y memoria Swap para prevenir cierres por memoria. |

---

## 📱 Accesos Directos en Pantalla de Inicio (Termux:Widget)

Si instalas la aplicación complementaria **Termux:Widget** desde F-Droid:
1. Mantén presionado un espacio vacío en la pantalla de inicio de tu celular y añade el widget de **Termux**.
2. Podrás colocar iconos directos para:
   * 🟢 **VS-Code**: Abre el entorno gráfico de inmediato.
   * 🔴 **Cerrar-VS-Code**: Cierra y respalda todo en GitHub.
   * 🌐 **Compartir-Web**: Muestra enlaces y código QR de tu servidor local.

---

## 👤 Autor
* **Miguel Guerra** - [@miguelguerra200022-sudo](https://github.com/miguelguerra200022-sudo)
