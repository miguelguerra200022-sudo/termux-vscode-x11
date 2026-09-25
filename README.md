# 🚀 Termux VS Code + Termux:X11 Mobile IDE

Entorno de desarrollo nativo de **Visual Studio Code (Code - OSS)** para **Android** ejecutándose sobre **Termux** y **Termux:X11**.

A diferencia de las instalaciones pesadas basadas en PRoot / Ubuntu / Debian, este entorno corre de forma **100% nativa** en Termux con máximo rendimiento, aceleración y acceso directo a todos tus paquetes y herramientas de Android.

---

## ✨ Características y Mejoras Principales

* ⚡ **100% Nativo y Ultraligero**: Sin PRoot, sin chroot, sin emulación lenta. Comparte exactamente el mismo entorno de paquetes y compiladores de tu Termux.
* 🌐 **Acceso al Navegador del Celular**: Cualquier enlace abierto desde VS Code o su terminal abre automáticamente tu navegador predeterminado de Android (Chrome, Brave, Firefox, etc.) mediante intents nativos.
* 💻 **Desarrollo Web en Localhost**: Cualquier servidor local iniciado en VS Code (`npm run dev`, `vite`, `python -m http.server`, `flask`) es accesible de inmediato desde el navegador de tu móvil en `http://localhost:<puerto>`.
* 📋 **Portapapeles Unificado**: Sincronización bidireccional entre el portapapeles de Android y VS Code. Copia en Android y pega en VS Code (o viceversa) sin pasos intermedios.
* 💾 **Persistencia Completa de Sesiones y Credenciales**: Incluye `password-store=basic` y `VSCODE_CLI_USE_FILE_KEYCHAIN=1` para mantener tus inicios de sesión, tokens de IA, pestañas abiertas y ventanas guardadas entre reinicios.
* 📱 **Optimización Táctil en Openbox**: Reglas de ventana configuradas para eliminar barras de título innecesarias y maximizar el editor al 100% de la pantalla táctil de tu teléfono.
* 🔊 **Soporte de Sonido (PulseAudio)**: Servidor de audio enrutado a los altavoces de tu móvil para escuchar sonidos, alertas o pruebas multimedia.
* 🧹 **Instalación Limpia (Sin Extensiones Pesadas)**: El instalador configura todo el entorno base optimizado sin precargar extensiones lentas, permitiéndote instalar únicamente las extensiones que desees.

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

## 🎮 Modo de Uso

### 1. Iniciar VS Code
En cualquier momento, escribe en la terminal de Termux:
```bash
start-vscode
```
*Se levantará automáticamente el entorno X11, Openbox, PulseAudio y se traerá al frente la app de Termux:X11 con tu VS Code listo para programar.*

### 2. Guardar y Salir
Para apagar el entorno gráfico y asegurarte de que **todas tus sesiones, pestañas y credenciales queden guardadas en disco**:
```bash
stop-vscode
```

---

## 🌐 Cómo usar el Navegador y Servidores de tu Móvil

1. **Abrir enlaces**:
   Haz `Ctrl + Clic` en cualquier enlace web dentro de un archivo o en la terminal integrada de VS Code. Se abrirá de inmediato en Chrome / Firefox en tu teléfono.

2. **Probar páginas web y APIs locales**:
   Si estás creando una web (por ejemplo con Vite, Next.js, Node o Python):
   - En la terminal de VS Code corre tu servidor, por ejemplo:
     ```bash
     python -m http.server 8080
     ```
   - Abre tu navegador de Android (Chrome, Brave, etc.) e ingresa a:
     ```
     http://localhost:8080
     ```
   ¡Funciona al instante porque Termux comparte la red nativa del teléfono!

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
│   ├── start-vscode     # Script optimizado de arranque
│   └── stop-vscode      # Script de cierre limpio y guardado de sesión
├── config/
│   ├── settings.json    # Configuración de VS Code (persistencia y navegador)
│   ├── argv.json        # Flags de Electron y password-store
│   └── rc.xml           # Reglas táctiles de Openbox (pantalla completa)
├── install.sh           # Instalador automatizado en un solo comando
├── uninstall.sh         # Script de desinstalación limpia
├── .gitignore           # Excluye cachés y extensiones temporales
└── README.md            # Documentación completa
```

---

## 👤 Autor
* **Miguel Guerra** - [@miguelguerra200022-sudo](https://github.com/miguelguerra200022-sudo)
