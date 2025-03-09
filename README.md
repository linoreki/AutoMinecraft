# AutoMinecraft

**AutoMinecraft** es un script de gestión automatizada para servidores de Minecraft, diseñado para ser compatible con **Ubuntu Server 24.04.1**. Facilita tareas como instalación, inicio, detención y monitoreo del servidor, utilizando herramientas como `screen` y `java`.

## Autor
Creado por: **Linoreki**

---

## Requisitos previos

Antes de usar este script, asegúrate de cumplir con los siguientes requisitos:

- **Sistema operativo:** Ubuntu Server 24.04.1 o superior.
- **Java:** OpenJDK 21 instalado.
- **Permisos:** Usuario con privilegios de `sudo`.

---

## Instalación

1. Clona este repositorio o descarga el script directamente:

   ```bash
   git clone https://github.com/linoreki/AutoMinecraft
   cd AutoMinecraft
   chmod +x AutoMinecraft.sh
   ```

2. Ejecuta el script con la opción de instalación:

   ```bash
   ./AutoMinecraft.sh --install
   ```

Esto instalará las dependencias necesarias y configurará la versión **1.21.4** del servidor Minecraft en el directorio `/opt/minecraft_server`.

---

## Opciones disponibles

El script soporta las siguientes opciones:

| Opción              | Descripción                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `--install`         | Instala y configura una versión específica de Minecraft.                                     |
| `--startGUI [Xms] [Xmx]` | Inicia el servidor con una cantidad específica de memoria asignada (con GUI). **Nota:** Puede no funcionar en sistemas sin entorno gráfico. |
| `--start [Xms] [Xmx]` | Inicia el servidor con una cantidad específica de memoria asignada (sin GUI).               |
| `--stop`            | Detiene el servidor Minecraft.                                                              |
| `--restart`         | Reinicia el servidor.                                                                        |
| `--status`          | Muestra el estado actual del servidor.                                                      |
| `--interface`       | Ingresa a la consola interactiva del servidor utilizando `screen`.                           |
| `--help`            | Muestra la ayuda del script.                                                                |

---

## Ejemplos de uso

### Instalar el servidor
```bash
./AutoMinecraft.sh --install
```

### Iniciar el servidor sin interfaz gráfica
```bash
./AutoMinecraft.sh --start 2G 4G
```
En este ejemplo, se asigna 2 GB de memoria inicial y 4 GB de memoria máxima.

### Detener el servidor
```bash
./AutoMinecraft.sh --stop
```

### Verificar el estado del servidor
```bash
./AutoMinecraft.sh --status
```

### Acceder a la consola interactiva
```bash
./AutoMinecraft.sh --interface
```

---

## Notas importantes

- **Archivos de configuración:** El archivo `eula.txt` se configura automáticamente con `eula=true`. Puedes modificarlo manualmente si necesitas realizar otros cambios.
- **Logs:** Los registros del servidor se almacenan en el archivo `server.log` dentro del directorio del servidor (`/opt/minecraft_server`).

---

## Contribuciones

Si deseas contribuir a este proyecto, siéntete libre de abrir un **pull request** o crear un **issue** en este repositorio.

---

## Licencia
Este proyecto está bajo la licencia [MIT](LICENSE).
