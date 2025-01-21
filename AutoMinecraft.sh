#!/bin/bash

# Script de gestión para servidores de Minecraft
# Compatible con Ubuntu Server 24.04.1
# Autor: Linoreki

# Variables globales
MINECRAFT_DIR="/opt/minecraft_server"
JAR_FILE="server.jar"
CRON_FILE="/etc/cron.d/minecraft"
SCREEN_NAME="minecraft"
DEFAULT_MIN_RAM="1G"
DEFAULT_MAX_RAM="2G"

# Función para mostrar ayuda
function show_help {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo "  --install [version] [url]     Instala una versión específica de Minecraft o URL personalizada"
    echo "  --start [minRAM maxRAM]       Inicia el servidor con RAM mínima y máxima opcional"
    echo "  --stop                        Detiene el servidor"
    echo "  --restart [minRAM maxRAM]     Reinicia el servidor con RAM opcional"
    echo "  --status                      Muestra el estado del servidor"
    echo "  --schedule [hh:mm]            Programa un reinicio diario del servidor"
    echo "  --help                        Muestra esta ayuda"
}

# Función para verificar e instalar dependencias
function install_dependencies {
    echo "Instalando dependencias necesarias..."
    deps=(openjdk-17-jre wget curl jq screen)
    for dep in "${deps[@]}"; do
        if ! dpkg -l | grep -q "$dep"; then
            echo "Instalando $dep..."
            sudo apt install -y "$dep"
        else
            echo "$dep ya está instalado."
        fi
    done
}

# Función para instalar una versión específica de Minecraft
function install_minecraft {
    VERSION=$1
    CUSTOM_URL=$2

    if [[ -z "$VERSION" ]]; then
        echo "Por favor, especifica una versión. Ejemplo: $0 --install 1.20.1"
        exit 1
    fi

    echo "Instalando Minecraft versión $VERSION..."
    mkdir -p "$MINECRAFT_DIR"
    cd "$MINECRAFT_DIR" || exit

    if [[ -n "$CUSTOM_URL" ]]; then
        echo "Descargando archivo del servidor desde URL personalizada: $CUSTOM_URL"
        wget -O "$JAR_FILE" "$CUSTOM_URL" || { echo "Error al descargar el servidor"; exit 1; }
    else
        DOWNLOAD_URL=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json | \
            jq -r --arg VERSION "$VERSION" '.versions[] | select(.id == $VERSION) | .url' | \
            xargs curl -s | jq -r '.downloads.server.url')

        if [[ -z "$DOWNLOAD_URL" ]]; then
            echo "No se encontró la URL de descarga para la versión $VERSION. Revisa la versión especificada."
            exit 1
        fi

        wget -O "$JAR_FILE" "$DOWNLOAD_URL" || { echo "Error al descargar el servidor"; exit 1; }
    fi

    echo "Aceptando EULA..."
    echo "eula=true" > eula.txt

    echo "Minecraft $VERSION instalado en $MINECRAFT_DIR"
}

# Función para iniciar el servidor
function start_server {
    MIN_RAM=${1:-$DEFAULT_MIN_RAM}
    MAX_RAM=${2:-$DEFAULT_MAX_RAM}

    echo "Iniciando el servidor de Minecraft con MIN_RAM=$MIN_RAM y MAX_RAM=$MAX_RAM..."
    if screen -list | grep -q "$SCREEN_NAME"; then
        echo "El servidor ya está en ejecución."
    else
        cd "$MINECRAFT_DIR" || exit
        screen -dmS "$SCREEN_NAME" java -Xms"$MIN_RAM" -Xmx"$MAX_RAM" -jar "$JAR_FILE" nogui
        echo "Servidor iniciado con MIN_RAM=$MIN_RAM y MAX_RAM=$MAX_RAM."
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
    MIN_RAM=${1:-$DEFAULT_MIN_RAM}
    MAX_RAM=${2:-$DEFAULT_MAX_RAM}

    echo "Reiniciando el servidor..."
    stop_server
    sleep 5
    start_server "$MIN_RAM" "$MAX_RAM"
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
        install_minecraft "$2" "$3"
        ;;
    --start)
        start_server "$2" "$3"
        ;;
    --stop)
        stop_server
        ;;
    --restart)
        restart_server "$2" "$3"
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
