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
| **`vscode`** | Explorador interactivo con pestañas (`Explorador` e `Historial`), navegación con flechas `↑/↓`, cambio de páginas con `←/→`, buscador rápido (`/`), indicador `[git]`, descripciones y permisos automáticos de Android. |
| **`start-vscode`** | Arranca directo en la carpeta actual con el entorno gráfico, barra Ubuntu, escudo anti-cierres (Wakelock), aceleración multi-hilo y tema OLED. |
| **`stop-vscode`** | Cierra de forma limpia VS Code y Zen Browser, guarda tus pestañas y sesiones, y **respalda automáticamente todos los datos a GitHub y al celular**. |
| **`sync-vscode`** | Sincroniza al instante historial, cookies de terceros, credenciales, extensiones y configuraciones sin comprimir a tu repositorio privado. |
| **`restore-vscode`** | Restaura todo idéntico en un clic en cualquier celular recién instalado desde tu respaldo. |
| **`guia`** | Abre inmediatamente la copia maestra de esta guía en VS Code. |

---

## 🌐 2. Zen Browser Integrado (Navegación Desktop Nativa)

* **Navegador dentro de la pantalla gráfica (Termux-X11)**:
  Cualquier enlace en el que hagas `Ctrl + Clic` dentro de VS Code, o cualquier servidor local que abras (`http://localhost:3000`, `8080`, etc.), se abre directamente en **Zen Browser** dentro de tu misma pantalla gráfica. ¡No te saca al navegador de Android!
* **Historial, Cookies y Credenciales Persistentes**:
  Todo lo que navegues, tus inicios de sesión en webs y tus extensiones de Zen se guardan de forma permanente y se respaldan automáticamente al cerrar.

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

## 🖥️ 5. Barra de Tareas Estilo Ubuntu (Multitarea y Lanzadores Fijos)

En la parte inferior de la pantalla gráfica (Termux-X11) cuentas con una barra de tareas inspirada en Ubuntu:
* **Iconos Fijos (Lanzadores):** A la izquierda de la barra tienes siempre visibles los iconos de 🟦 **VS Code** y 🌐 **Zen Browser**. Si accidentalmente cierras alguna ventana con la "X", solo toca el icono en la barra y se abrirá de nuevo al instante.
* **Menú al tocar la pantalla negra:** Si cierras todo y tocas cualquier parte del fondo de pantalla, se abre un menú contextual para abrir VS Code, Zen Browser o recargar la interfaz.
* **Clic o Toque en el botón de la ventana:** Minimiza la ventana activa o la restaura inmediatamente si estaba minimizada o detrás.
* **Múltiples ventanas:** Si abres varios proyectos en VS Code o múltiples ventanas de Zen, cada una tendrá su propio botón con icono y nombre.
* **Clic derecho / Presión prolongada:** Alterna entre maximizar y restaurar tamaño de ventana.
* **Reloj integrado:** Muestra la hora local en la esquina inferior derecha.

---

## 💻 6. Modo Dual: Usar VS Code en tu PC o Tablet Remota

* **`start-vscode-web`**:
  Ejecuta este comando para compartir la pantalla de tu VS Code en tu red Wi-Fi. Te mostrará un enlace como:
  ```
  http://192.168.x.x:5900
  ```
  Para que lo abras desde tu computadora o tablet y programes en pantalla grande usando el procesador de tu móvil.

---

## 🛡️ 7. Protección y Estabilidad

* **`fix-phantom-killer`**:
  Desactiva el límite de 32 subprocesos de Android 12, 13, 14 y 15 para evitar que el sistema cierre tus terminales.
* **`setup-swap`**:
  Diagnostica la memoria RAM y el archivo Swap para prevenir cierres por falta de memoria al compilar paquetes pesados.

---

## 📱 8. Accesos Directos en Pantalla de Inicio

Si instalas la app **Termux:Widget** desde F-Droid, tendrás botones directos en la pantalla de inicio de tu celular para abrir VS Code (`VS-Code`) o cerrarlo y respaldarlo (`Cerrar-VS-Code`) con un solo toque.

---
*(Recuerda: puedes eliminar este archivo de tu carpeta cuando termines de leerlo pulsando `clic derecho > Eliminar`).*
