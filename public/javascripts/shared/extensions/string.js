// Methode ltrim (left trim) zum String-Objekt hinzufügen
// Diese Methode löscht, ausgehend vom Anfang der Zeichenkette,
// alle Zeichen, die bei deren Vorkommen entfernt werden sollen.
// Der Parameter clist ist optional und gibt eine Liste von Zeichen vor,
// die von der Methode herausgelöscht werden sollen.
// Wird dieser Parameter nicht übergeben, so werden alle Whitespaces
// gelöscht, die am Anfang des Strings stehen.
String.prototype.ltrim = function (clist) {
    // Wurde eine Zeichenkette mit den zu entfernenden
    // Zeichen übergeben?
    if (clist)
        // In diesem Fall sollen nicht Whitespaces, sondern
        // alle Zeichen aus dieser Liste gelöscht werden,
        // die am Anfang des Strings stehen.
        return this.replace (new RegExp ('^[' + clist + ']+'), '');
    // Führende Whitespaces aus dem String entfernen
    // und das resultierende String zurückgeben.
    return this.replace (/^\s+/, '');
}

// Die Methode rtrim (right trim) erweitert ebenfalls das String-Objekt.
// Im Gegensatz zu ltrim wird hier aber vom Ende des Strings ausgegangen.
// Es werden also alle Whitespaces bzw. die Zeichen aus der übergebenen
// Zeichenliste gelöscht, die am Ende des Strings stehen.
String.prototype.rtrim = function (clist) {
    // Zeichenkette mit den zu entfernenden Zeichen angegeben?
    if (clist)
        // Zeichen aus der Liste, die am Ende des String stehen
        // löschen.
        return this.replace (new RegExp ('[' + clist + ']+$'), '');
    // Whitespaces am Ende des Strings ertfernen und dann das Ergebnis
    // dieser Operation zurückgeben.
    return this.replace (/\s+$/, '');
}

// Implementierung einer JavaScript trim Function als Erweiterung
// des vordefinierten JavaScript String-Objekts.
// Die Methode bedient sich den zuvor definierten Methoden ltrim
// und rtrim und kombiniert diese miteinander.
// Mit dem Parameter clist kann man auch hier eine Liste von Zeichen
// angeben, die vom Anfang, wie auch vom Ende der Zeichenkette entfernt
// werden soll.
String.prototype.trim = function (clist) {
    // Wird der Parameter clist angegeben, so werden statt der Whitespaces
    // die in dieser Variablen angegebenen Zeichen "getrimmt".
    if (clist)
        // Führende und abschließende Zeichen aus der Liste entfernen.
        return this.ltrim (clist).rtrim (clist);
    // Whitespaces vom Anfang und am Ende entfernen
    return this.ltrim ().rtrim ();
};