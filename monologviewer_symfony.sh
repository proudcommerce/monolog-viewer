#!/bin/bash

# ANSI-Farbcodes
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
# ANSI-Farbcode zum Zurücksetzen
RESET="\033[0m"

# Überprüfen, ob ein Dateiname als Argument übergeben wurde
if [ -z "$1" ]; then
  echo "Bitte geben Sie den Namen der Log-Datei an. Beispiel: ./monologviewer_symfony.sh logfile.log"
  exit 1
fi

# Log-Datei vom Argument setzen
LOGFILE="$1"

# Überprüfen, ob die Datei existiert
if [ ! -f "$LOGFILE" ]; then
  echo "Die Datei '$LOGFILE' wurde nicht gefunden."
  exit 1
fi

# Einträge durchlaufen und formatieren
while IFS= read -r line
do
  # Zeile nach dem Datum und Uhrzeit durchsuchen (angepasst für eckige Klammern)
  if [[ "$line" =~ ^\[[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\] ]]; then
    # Datum und Zeit extrahieren (inkl. eckiger Klammern)
    TIMESTAMP="${BASH_REMATCH[0]}"
    # Log-Typ und Nachricht trennen, indem der Zeitstempel entfernt wird
    TYPE_MESSAGE="${line#"$TIMESTAMP "}"
    
    # Ausgabe formatieren
    echo -e "\n${YELLOW}$TIMESTAMP${RESET}"
    
    # Prüfen, ob ein JSON-Objekt in der Nachricht enthalten ist
    if [[ "$TYPE_MESSAGE" =~ (\{.*\}) ]]; then
      # JSON extrahieren
      JSON_CONTENT="${BASH_REMATCH[1]}"
      # JSON formatieren und Nachricht ohne JSON ausgeben
      MESSAGE_WITHOUT_JSON="${TYPE_MESSAGE//$JSON_CONTENT/}"
      echo "$MESSAGE_WITHOUT_JSON"
      echo "$JSON_CONTENT" | jq .
    else
      # Falls kein JSON vorhanden, Nachricht direkt ausgeben
      echo "$TYPE_MESSAGE"
    fi
  fi
done < "$LOGFILE"
