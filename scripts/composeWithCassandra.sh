#!/bin/bash

start_compose() {
    echo "Starte Container..."
    export $(grep -v '^#' .env | xargs)
    docker compose -f docker-compose-with-cassandra.yml up -d
    if [ $? -eq 0 ]; then
        echo "Container wurden erfolgreich gestartet."
    else
        echo "Fehler beim Starten."
        exit 1
    fi
}

stop_compose() {
    echo "Stoppe Container..."
    docker compose -f docker-compose-with-cassandra.yml down
    if [ $? -eq 0 ]; then
        echo "Container wurden erfolgreich gestoppt."
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

# Starten oder Stoppen des Container basierend auf dem Argument
case "$1" in
    start)
        start_compose
        ;;
    stop)
        stop_compose
        ;;
    *)
        echo "Ungültige Option: $1"
        echo "Verwendung: $0 {start|stop}"
        exit 1
        ;;
esac