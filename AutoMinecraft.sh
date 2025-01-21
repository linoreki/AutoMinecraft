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
    echo "  --install [version]     Instala y configura una versión específica de Minecraft"
    echo "  --start [Xms] [Xmx]     Inicia el servidor con memoria asignada (por defecto 1G, 2G)"
    echo "  --stop                  Detiene el servidor"
    echo "  --restart               Reinicia el servidor"
    echo "  --status                Muestra el estado del servidor"
    echo "  --help                  Muestra esta ayuda"
}

# Función para instalar dependencias
function install_dependencies {
    echo "Instalando dependencias necesarias..."
    sudo apt update
    sudo apt install -y openjdk-17-jre-headless wget screen ufw
    sudo ufw allow 25565
    echo "Dependencias instaladas y puerto 25565 habilitado en el firewall."
}

# Función para instalar una versión específica de Minecraft
function install_minecraft {
    VERSION=$1
    if [[ -z "$VERSION" ]]; then
        echo "Por favor, especifica una versión. Ejemplo: $0 --install 1.20.1"
        exit 1
    fi

    echo "Instalando Minecraft versión $VERSION..."
    install_dependencies

    mkdir -p "$MINECRAFT_DIR"
    cd "$MINECRAFT_DIR" || exit

    # Descargar el servidor desde el enlace proporcionado
    JAR_URL="https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar"
    wget -O "$JAR_FILE" "$JAR_URL"

    # Aceptar el EULA
    echo "eula=true" > eula.txt
    echo "Minecraft $VERSION instalado en $MINECRAFT_DIR"
}


# Función para iniciar el servidor
function start_server {
    XMS=${1:-1G}
    XMX=${2:-2G}

    echo "Iniciando el servidor de Minecraft con $XMS de memoria inicial y $XMX de máxima..."
    if screen -list | grep -q "$SCREEN_NAME"; then
        echo "El servidor ya está en ejecución."
    else
        cd "$MINECRAFT_DIR" || exit
        screen -dmS "$SCREEN_NAME" $JAVA_CMD -Xms$XMS -Xmx$XMX -jar "$JAR_FILE" nogui
        echo "Servidor iniciado."
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
        echo "El servidor no está en ejecución."
    fi
}

# Parseo de argumentos
case "$1" in
    --install)
        install_minecraft "$2"
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
    --help)
        show_help
        ;;
    *)
        echo "Opcion no valida. Usa --help para mas informacion."
        exit 1
        ;;
esac
