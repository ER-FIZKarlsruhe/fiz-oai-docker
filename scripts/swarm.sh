#!/bin/bash

start_swarm() {
    echo "Starte Services..."
    export $(grep -v '^#' .env | xargs)
    docker stack deploy -c docker-compose4swarm.yml oai
    if [ $? -eq 0 ]; then
        echo "Services wurden erfolgreich gestartet."
    else
        echo "Fehler beim Starten."
        exit 1
    fi
}

stop_swarm() {
    echo "Stoppe Services..."
    docker stack rm oai
    if [ $? -eq 0 ]; then
        echo "Services wurden erfolgreich gestoppt."
    else
        echo "Fehler beim Stoppen."
        exit 1
    fi
}

# Prüfen, ob ein Argument übergeben wurde
if [ "$#" -ne 1 ]; then
    echo "Verwendung: $0 {start|stop}"
    exit 1
fi

# Starten oder Stoppen des Swarms basierend auf dem Argument
case "$1" in
    start)
        start_swarm
        ;;
    stop)
        stop_swarm
        ;;
    *)
        echo "Ungültige Option: $1"
        echo "Verwendung: $0 {start|stop}"
        exit 1
        ;;
esac