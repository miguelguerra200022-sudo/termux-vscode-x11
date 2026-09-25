# 🗑️ **BORRAR ESTE ARCHIVO CUANDO YA NO LO NECESITES**

> [!TIP]
> ### 💡 ¿Borraste este archivo y olvidaste cómo funciona algo?
> ¡No te preocupes! La copia maestra original y permanente siempre está protegida en tu sistema:
> 
> 👉 **`@GUIA_RAPIDA.md`** → [`/data/data/com.termux/files/usr/share/termux-vscode-x11/GUIA_RAPIDA.md`](file:///data/data/com.termux/files/usr/share/termux-vscode-x11/GUIA_RAPIDA.md)
> 
> * **Para abrir el original desde VS Code**: Presiona `Ctrl + P` y escribe `@GUIA_RAPIDA.md` (o haz clic en el enlace de arriba).
> * **Para abrirlo desde cualquier terminal**: Escribe simplemente `guia` y se abrirá de inmediato.

---

# 🚀 Guía Rápida: Herramientas y Superpoderes de tu VS Code en Android

Bienvenido a tu entorno de desarrollo nativo. Esta guía se genera automáticamente al iniciar VS Code en cualquier carpeta para que nunca te sientas perdido.

---

## ⚡ 1. Comandos Principales de Control

| Comando | Para qué sirve |
| :--- | :--- |
| **`start-vscode`** | Arranca el entorno gráfico, activa el escudo anti-cierres (Wakelock), acelera el procesador a multi-hilo y abre VS Code con tema negro OLED. |
| **`stop-vscode`** | Cierra de forma limpia, guarda tus pestañas y sesiones, y **respalda automáticamente tus configuraciones a GitHub**. |
| **`guia`** | Abre inmediatamente la copia maestra de esta guía en VS Code. |

---

## 🌐 2. Navegador del Celular y Servidores Locales

* **Abrir enlaces en tu navegador de Android**:
  Haz `Ctrl + Clic` en cualquier enlace web dentro de un archivo o en la terminal integrada. Se abrirá automáticamente en tu navegador predeterminado (Chrome, Brave, Firefox, etc.).
* **Probar webs y APIs en tu teléfono**:
  Cualquier servidor local que inicies en VS Code (ej: `python -m http.server 8080`, `npm run dev`, `vite`, `flask`) está disponible de inmediato en tu navegador ingresando a:
  ```
  http://localhost:8080
  ```
  *(Termux comparte la red nativa de tu teléfono, sin túneles ni configuraciones extra).*

---

## 🌍 3. Túneles Públicos por Internet y Código QR

* **Compartir tu web con cualquier persona en el mundo (`share-port`)**:
  ```bash
  share-port 8080
  ```
  Genera un túnel público seguro con Cloudflare (`https://tu-proyecto.trycloudflare.com`) sin abrir puertos en tu router.

* **Mostrar URLs locales y Código QR (`dev-info`)**:
  ```bash
  dev-info 8080
  ```
  Muestra los enlaces para tu móvil y para tu red Wi-Fi, y genera un **código QR en la terminal** para que otros dispositivos lo escaneen con la cámara.

---

## 🛠️ 4. Productividad y Nuevos Proyectos

* **Crear un nuevo proyecto en 3 segundos (`new-project`)**:
  ```bash
  new-project
  ```
  Crea proyectos listos con estructura y Git:
  1. 🐍 Python (con entorno virtual `.venv` y `main.py`).
  2. 🌐 Frontend Web (HTML5, CSS y JavaScript moderno).
  3. 🤖 Bot de Telegram / FastAPI.
  4. 🚀 Node.js Express API.

* **Desbloquear la Tienda Oficial de Microsoft (`set-marketplace`)**:
  ```bash
  set-marketplace official
  ```
  Te da acceso directo en el buscador a las más de **60.000 extensiones oficiales** de VS Code (Python oficial, Pylance, Prettier, Tailwind, etc.).

* **Notificaciones en Android al terminar tareas (`notify-done`)**:
  ```bash
  npm run build && notify-done "Compilación terminada"
  ```
  Hace vibrar el teléfono y manda una notificación a la barra de Android.

---

## 💻 5. Modo Dual: Usar VS Code en tu PC o Tablet Remota

* **`start-vscode-web`**:
  Ejecuta este comando para compartir la pantalla de tu VS Code en tu red Wi-Fi. Te mostrará un enlace como:
  ```
  http://192.168.x.x:5900
  ```
  Para que lo abras desde tu computadora o tablet y programes en pantalla grande usando el procesador de tu móvil.

---

## 🛡️ 6. Protección y Estabilidad

* **`fix-phantom-killer`**:
  Desactiva el límite de 32 subprocesos de Android 12, 13, 14 y 15 para evitar que el sistema cierre tus terminales.
* **`setup-swap`**:
  Diagnostica la memoria RAM y el archivo Swap para prevenir cierres por falta de memoria al compilar paquetes pesados.

---

## 📱 7. Accesos Directos en Pantalla de Inicio

Si instalas la app **Termux:Widget** desde F-Droid, tendrás botones directos en la pantalla de inicio de tu celular para abrir VS Code (`VS-Code`) o cerrarlo y respaldarlo (`Cerrar-VS-Code`) con un solo toque.

---
*(Recuerda: puedes eliminar este archivo de tu carpeta cuando termines de leerlo pulsando `clic derecho > Eliminar`).*
