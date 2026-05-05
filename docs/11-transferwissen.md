# Nota – Transferwissen

Diese Datei konserviert das Warum hinter dem Code. Der Code zeigt was gebaut wurde – diese Datei zeigt warum.

**Pflege-Regel:** Nach jedem Implementation-Chat ergänzt der Hub neue Entscheidungen, Edge-Cases und Konventionen hier.

## Architektur-Entscheidungen

**Provider statt Riverpod/Bloc**
- Einfachere Lernkurve für Flutter-Anfänger, ausreichend für App-Größe
- Pattern: ein zentraler `BandProvider` mit allen Daten

**SharedPreferences statt SQLite/Hive**
- Alle Daten als ein einziges JSON-Blob
- Kein komplexes Querying nötig, App-Daten klein genug
- Trade-off: bei sehr großen Datenmengen (viele PDFs) wird Laden langsam – akzeptiert

**Pixel-Koordinaten für Striche (statt relative)**
- Einfacher zu implementieren
- Bewusst akzeptierter Nachteil: Sidebar-Modus zeigt Canvas-Ausschnitt
- Refactoring zu relativen Koordinaten im Backlog (Prio niedrig, evtl. nicht nötig)

**Chord Chart als Base64 im JSON (statt separate Dateien)**
- Vereinfacht Backup (alles in einer Datei), keine Pfad-Verwaltung
- Trade-off: Backup wird größer

**Nur erste PDF-Seite**
- Chord Charts typischerweise einseitig
- Mehrseiten-Logik wäre Overhead ohne Nutzen

**Edit-Dialog statt Vollbild-Edit-Page (Songs UND Gigs)**
- Kompakte Felder, Dialog reicht
- Konsistenz zwischen Songs und Gigs

## UX-/Design-Entscheidungen

**Live-Modus Standard = WithSidebar**
- Erste Annahme war Fullscreen, geändert nach Diskussion
- Mehr Kontext durch sichtbare Setliste, häufiger Songwechsel

**Tab-Stop für Key/S/B im Live-Modus**
- Feste Pixelbreite (400px Titel, 80px Key) statt `Expanded`
- Auge muss nicht suchen, Key immer an gleicher Stelle bei Songwechsel
- Nutzerwunsch explizit "wie Tab in Windows"

**Solo=rot, Backing=blau**
- Rot = Achtung (Solo spielen), Blau = ruhig (Backing-Track läuft)
- Konsistent in allen Views

**Auto-Hide Overlays nach 3s**
- Auf der Bühne soll nichts ablenken
- 3s = Kompromiss zwischen "schnell weg" und "lang genug zum Klicken"

**Swipe-Schwelle 120px**
- "Deutlich swipen müssen" – verhindert versehentliches Wechseln auf der Bühne

**Vektor-Eraser statt Pixel-Eraser**
- Wie GoodNotes – ganzer Strich verschwindet
- Funktioniert mit allen Hintergründen einheitlich, kein Hintergrundfarben-Trick

**S Pen Doppelklick = Stift ↔ Marker**
- Pen wird nur außerhalb Live genutzt → Konflikte im Live-Modus irrelevant
- Im Live ist Canvas readonly

**Standard-Modus wird nicht persistent gespeichert**
- Bewusst nicht: erst Erfahrung sammeln vor Pref-Speicherung
- *[unsicher]* ob das später geändert werden soll

**Setting als Freitext statt Enum**
- Ursprünglich `isOutdoor` Boolean → flexibler String "Setting"
- "Indoor/Outdoor reicht nicht" (auch: Zelt, etc.)

**Intro/Outro mit Pfeilen ↑ →**
- ↑ = Anfang (Pfeil hoch zeigt auf Song-Beginn)
- → = Ende (Pfeil rechts zeigt nach vorne/Outro)
- *[unsicher]* ob auf Dauer intuitiv

## Verworfene Ansätze

**`BoxFit.contain` mit voller MediaQuery**
- Schwarze Ränder im Live-Modus
- → ersetzt durch LayoutBuilder mit constraints

**`BoxFit.fill` + LayoutBuilder zur Sidebar-Fix**
- Striche wurden gestreckt
- → "Akzeptanz" dass Sidebar Ausschnitt zeigt (siehe Pixel-Koordinaten oben)

**Transform.scale für Sidebar-Canvas**
- Inkonsistent über Modi hinweg
- → Original-Verhalten akzeptiert

**S Pen Doppelklick = Farbwechsel Weiß↔Rot**
- Erster Vorschlag basierend auf "rot für Solo"
- Verworfen, weil Pen nur außerhalb Live → Solo-Markierung weniger relevant
- → ersetzt durch Stift↔Marker

**Rotation für Chord Chart**
- Diskutiert, dann verworfen
- Charts immer Querformat, Rotation kompliziert Touch-Handling
- Bewusst als nachrüstbar markiert

**Mehrere PDF-Seiten als Hintergrund**
- Use-Case "All of Me" braucht nur eine Seite
- "Macht wenig Sinn"

**Bottom-Sheet bei Setlist-Long-Press im Gig**
- Nur eine Aktion (umbenennen) → Bottom-Sheet wäre Overhead
- → direkter Rename-Dialog

## Edge-Cases / Sonderfälle

**Backwards-Compatibility `isOutdoor` → `setting`**
```dart
g['setting'] ?? (g['isOutdoor'] == true ? 'Outdoor' : '')
```
- Klammern wegen Operator-Precedence von `??` und `==` (war ein Bug, der zu Datenverlust führte)
- Lehre: defensive Klammerung bei `??` immer

**Gig-Setlists ohne Slots**
- Setlists wurden in Gigs ohne Slots gespeichert → Live-Modus-Songs leer
- Fix: Slots auch im Gig-Block speichern und laden

**Canvas-Strich abbrechen bei Mehr-Finger-Touch**
- Zweiter Finger für Zoom → sonst Linie zwischen Fingern
- Fix in `didUpdateWidget`: wenn `editable` false wird (Pointer >= 2), `_currentStroke = null`

**Eraser malt nicht bei `onPointerDown`**
- War Bug: Eraser erstellte initialen Strich-Punkt mit Hintergrundfarbe
- Fix: bei Eraser direkt `return` in `onPointerDown`

**Daten-Reset durch Parsing-Fehler**
- Bei Format-Änderung gingen Daten verloren (`_load()` fiel in catch zu `_loadDefaults()`)
- Lehre: Restore from Nextcloud rettete den Tag → Backups vor Modell-Änderungen!

**Live-Modus aus Gig vs. Setlist**
- `widget.songs` waren alle Band-Songs, nicht Setlist-Songs
- Fix: `getSongsForSetlist()` verwenden
- Auch wichtig für "first setlist Live"-Button im Gig

## Implizites Wissen / Konventionen

**Modell-Updates – 4 Stellen prüfen**
Neue Felder im Modell brauchen Updates an genau **vier** Stellen:
1. Modell-Klasse + Konstruktor
2. `BandProvider._load()`
3. `BandProvider._save()`
4. Alle UI-Stellen, wo neues Song-/Gig-/Setlist-Objekt gebaut wird

Häufige Fehlerquelle: eine der vier Stellen vergessen.

**Code-Konventionen**
- Files mit `_` prefix für private Widgets im selben File
- Konstruktoren: `required` für notwendige Parameter, Defaults wo möglich
- `setState` immer mit context-mounted Check bei async Operationen
- Beim Erstellen neuer Songs/Gigs: alle Felder explizit setzen, nicht copy-with

**Git-Workflow**
- Nach jedem größeren Feature: `git add . && git commit -m "..." && git push`
- Test immer auf echtem Tablet, nicht nur Emulator (Lag-Probleme)

**UI-Patterns**
- Long Press → Bottom Sheet (mehrere Aktionen) ODER direkter Dialog (eine Aktion)
- Buttons mit "Live"-Endung = rot, sonst primary (lila)

## Persönliche Präferenzen / Stil

**Code-Lieferung**
- Exakte Stellen nennen ("such X, ersetze mit Y")
- Bei längeren Files: schrittweise statt komplette Datei
- Bei sehr komplexen Refactorings: ganzen Block ersetzen
- User sendet komplette Dateien zurück zur Verifikation

**Sprache**
- Deutsch, technische Begriffe Englisch
- Voice-to-Text: gelegentliche Transkriptions-Fehler filtern
- Knappe Antworten, kein Smalltalk
- "Lets go" / "weiter" = Signal zum Fortfahren

**Testing-Stil**
- Fokussiert, nicht alle Modi durchtesten
- Bei Bugs: oft Screenshots statt Beschreibung
- Kleinere Bugs werden für später akzeptiert, wenn Hauptfeature funktioniert

**Was der User explizit NICHT will**
- Strecken/Stauchen von Inhalten
- Versehentliches Swipen auf der Bühne
- Daten-Verlust ohne Backup
- Overhead für selten genutzte Features
- S Pen Features, die auf der Bühne stören könnten

**Entscheidungsstil**
- Empfehlung mit Begründung erwartet, nicht offene Frage
- Bei mehreren Optionen: ranked Vorschläge
- Akzeptiert Empfehlungen schnell, wenn gut begründet
- Bei kritischen Entscheidungen (Daten-Format): doppelt nachfragen

## Kontext / Bands

- Eigene Bands: PRIMEBEATS, Jukebox22, Solo (Rockabilly / 50s Rock'n'Roll)
- App primär für eigene Bands, evtl. später für andere Musiker
- Bühne: nur Finger-Bedienung, S Pen für Probe/Pausen
- Sekundäre Doku: Obsidian Vault
- Pi/Nextcloud: Eigenleistung, hohe emotionale Investition
