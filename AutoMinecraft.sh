#!/bin/bash

# Script de gestión para servidores de Minecraft
# Compatible con Ubuntu Server 24.04.1
# Autor: [Tu nombre]

# Variables globales
MINECRAFT_DIR="/opt/minecraft_server"
JAR_FILE="server.jar"
JAVA_CMD="java"
SCREEN_NAME="minecraft"

# Función para mostrar ayuda
function show_help {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo "  --install                Instala y configura una versión específica de Minecraft"
    echo "  --startGUI [Xms] [Xmx]      Inicia el servidor con memoria asignada (por defecto 1G, 2G) [!]puede que esta funcion no funcione en interfaces no graficas"
    echo "  --start [Xms] [Xmx]      Inicia el servidor con memoria asignada con interface (por defecto 1G, 2G)"
    echo "  --stop                   Detiene el servidor"
    echo "  --restart                Reinicia el servidor"
    echo "  --status                 Muestra el estado del servidor"
    echo "  --interface              Ingresa a la consola interactiva del servidor"
    echo "  --help                   Muestra esta ayuda"
}

# Función para instalar dependencias
function install_dependencies {
    echo "Instalando dependencias necesarias..."
    sudo apt update
    sudo apt install -y openjdk-21-jre-headless wget screen ufw
    sudo ufw allow 25565
    echo "Dependencias instaladas y puerto 25565 habilitado en el firewall."
}

# Función para instalar una versión específica de Minecraft
function install_minecraft {
    echo "Instalando Minecraft versión 1.21.4..."
    install_dependencies

    mkdir -p "$MINECRAFT_DIR"
    cd "$MINECRAFT_DIR" || exit

    JAR_URL="https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar"
    wget -O "$JAR_FILE" "$JAR_URL"

    echo "eula=true" > eula.txt
    echo "Minecraft instalado en $MINECRAFT_DIR"
}

# Función para iniciar el servidor
function start_server_gui {
    XMS=${1:-1G}
    XMX=${2:-2G}

    echo "Iniciando el servidor de Minecraft con $XMS de memoria inicial y $XMX de máxima..."
    if screen -list | grep -q "$SCREEN_NAME"; then
        echo "El servidor ya está en ejecución."
    else
        if [[ -d "$MINECRAFT_DIR" ]]; then
            cd "$MINECRAFT_DIR" || exit
            screen -dmS "$SCREEN_NAME" bash -c "$JAVA_CMD -Xms$XMS -Xmx$XMX -jar $JAR_FILE nogui >> server.log 2>&1"
            sleep 2
            if screen -list | grep -q "$SCREEN_NAME"; then
                echo "Servidor iniciado correctamente."
            else
                echo "Error al iniciar el servidor. Revisa server.log para más detalles."
            fi
        else
            echo "El directorio $MINECRAFT_DIR no existe. Por favor, instala el servidor primero usando --install."
            exit 1
        fi
    fi
}
function start_server {
    XMS=${1:-1G}
    XMX=${2:-2G}

    echo "Iniciando el servidor de Minecraft con $XMS de memoria inicial y $XMX de máxima..."
    if screen -list | grep -q "$SCREEN_NAME"; then
        echo "El servidor ya está en ejecución."
    else
        if [[ -d "$MINECRAFT_DIR" ]]; then
            cd "$MINECRAFT_DIR" || exit
            $JAVA_CMD -Xms$XMS -Xmx$XMX -jar $JAR_FILE nogui
        else
            echo "El directorio $MINECRAFT_DIR no existe. Por favor, instala el servidor primero usando --install."
            exit 1
        fi
    fi
}
# Función para detener el servidor
function stop_server {
    echo "Deteniendo el servidor de Minecraft..."
    if screen -list | grep -q "$SCREEN_NAME"; then
        screen -S "$SCREEN_NAME" -X quit
        echo "Servidor detenido."
    else
        echo "El servidor no está en ejecución."
    fi
}

# Función para reiniciar el servidor
function restart_server {
    stop_server
    sleep 5
    start_server
}

# Función para mostrar el estado del servidor
function server_status {
    if screen -list | grep -q "$SCREEN_NAME"; then
        echo "El servidor está en ejecución."
    else
        echo "El servidor no está en ejecución. Revisa server.log para más detalles."
    fi
}

# Función para ingresar a la consola interactiva
function server_interface {
    echo "Ingresando a la consola interactiva del servidor de Minecraft..."
    if screen -list | grep -q "$SCREEN_NAME"; then
        screen -r "$SCREEN_NAME"
    else
        echo "El servidor no está en ejecución. Por favor, inícialo primero con --start."
        exit 1
    fi
}

# Parseo de argumentos
case "$1" in
    --install)
        install_minecraft "$2"
        ;;
    --startGUI)
        start_server_gui "$2" "$3"
        ;;
    --start)
        start_server "$2" "$3"
        ;;    
    --stop)
        stop_server
        ;;
    --restart)
        restart_server
        ;;
    --status)
        server_status
        ;;
    --interface)
        server_interface
        ;;
    --help)
        show_help
        ;;
    *)
        echo "Opción no válida. Usa --help para más información."
        exit 1
        ;;
esac
