#!/bin/bash

# Script de gestión para servidores de Minecraft
# Compatible con Ubuntu Server 24.04.1
# Autor: [Tu nombre]

# Variables globales
MINECRAFT_DIR="/opt/minecraft_server"
JAR_FILE="server.jar"
CRON_FILE="/etc/cron.d/minecraft"
JAVA_CMD="java -Xms1G -Xmx2G -jar"
SCREEN_NAME="minecraft"

# Función para mostrar ayuda
function show_help {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo "  --install [version]     Instala una versión específica de Minecraft"
    echo "  --start                 Inicia el servidor"
    echo "  --stop                  Detiene el servidor"
    echo "  --restart               Reinicia el servidor"
    echo "  --status                Muestra el estado del servidor"
    echo "  --schedule [hh:mm]      Programa un reinicio diario del servidor"
    echo "  --help                  Muestra esta ayuda"
}

# Función para verificar e instalar dependencias
function install_dependencies {
    echo "Instalando dependencias necesarias..."
    sudo apt update && sudo apt install -y openjdk-17-jre wget screen
}

# Función para instalar una versión específica de Minecraft
function install_minecraft {
    VERSION=$1
    if [[ -z "$VERSION" ]]; then
        echo "Por favor, especifica una versión. Ejemplo: $0 --install 1.20.1"
        exit 1
    fi

    echo "Instalando Minecraft versión $VERSION..."
    mkdir -p "$MINECRAFT_DIR"
    cd "$MINECRAFT_DIR" || exit
    wget -O "$JAR_FILE" "https://launcher.mojang.com/v1/objects/$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r --arg VERSION "$VERSION" '.versions[] | select(.id == $VERSION) | .url' | xargs curl -s | jq -r '.downloads.server.url')"
    echo "eula=true" > eula.txt
    echo "Minecraft $VERSION instalado en $MINECRAFT_DIR"
}

# Función para iniciar el servidor
function start_server {
    echo "Iniciando el servidor de Minecraft..."
    if screen -list | grep -q "$SCREEN_NAME"; then
        echo "El servidor ya está en ejecución."
    else
        cd "$MINECRAFT_DIR" || exit
        screen -dmS "$SCREEN_NAME" $JAVA_CMD "$JAR_FILE" --nogui
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

# Función para programar reinicios automáticos
function schedule_restart {
    TIME=$1
    if [[ -z "$TIME" ]]; then
        echo "Por favor, especifica una hora. Ejemplo: $0 --schedule 03:00"
        exit 1
    fi

    echo "Programando reinicio diario a las $TIME..."
    echo "0 $(echo "$TIME" | cut -d: -f1) * * * root $0 --restart" > "$CRON_FILE"
    chmod 644 "$CRON_FILE"
    systemctl restart cron
    echo "Reinicio programado con éxito."
}

# Parseo de argumentos
case "$1" in
    --install)
        install_dependencies
        install_minecraft "$2"
        ;;
    --start)
        start_server
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
    --schedule)
        schedule_restart "$2"
        ;;
    --help)
        show_help
        ;;
    *)
        echo "Opción no válida. Usa --help para más información."
        exit 1
        ;;
esac
