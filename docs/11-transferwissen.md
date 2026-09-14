# Nota – Transferwissen

Diese Datei konserviert das Warum hinter dem Code. Der Code zeigt was gebaut wurde – diese Datei zeigt warum.

**Pflege-Regel:** Am Ende jeder inhaltlich wichtigen Session werden neue Entscheidungen, Edge-Cases und Konventionen hier ergänzt (siehe Session-Ende-Workflow in den Projekt-Anweisungen).

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

**Chord Charts als PNG-Files, nicht Base64 im Blob** *(geändert 07/2026)*
- Ursprünglich Base64 im JSON — vereinfachte das Backup, ließ aber den
  Prefs-Blob bei jedem Stroke-Save mit-serialisieren (Save-Spikes).
- Jetzt: `documents/charts/<songId>.png`, im Blob nur `chordChartFile`.
- Migration läuft in `_migrateChartsToFiles()` bei jedem `_load()` — alte
  Blobs und alte Backups bleiben ladbar. Bei Schreib-Fehler bleibt das
  Base64 erhalten (kein Datenverlust).
- **Backup-Format bewusst UNVERÄNDERT:** `exportBackupJson()` liest die
  Files und bettet sie wieder als Base64 ein, entfernt `chordChartFile`.
  Ein Backup bleibt eine Datei, Restore-Pfad und WebDAV-Konfig unberührt.
- Verworfen: ZIP-Backup (JSON + Files) — hätte Restore-Code, Doku und
  WebDAV-Pfad angefasst, ohne Mehrwert.
- Migration verifiziert 09/2026: 0 Base64-Reste im Blob, Referenzen = Dateien.

**Nur erste PDF-Seite**
- Chord Charts typischerweise einseitig
- Mehrseiten-Logik wäre Overhead ohne Nutzen

**Edit-Dialog statt Vollbild-Edit-Page (Songs UND Gigs)**
- Kompakte Felder, Dialog reicht
- Konsistenz zwischen Songs und Gigs

**Chat-Architektur: Phasen-Modell statt Hub-from-Day-One**
- Ursprünglich: Management-Hub + Implementation-Chats pro Feature + optionale Bug-Chats
- Geändert: aktuell ein Chat für alles, weil Solo-Code-Projekt keinen Dispatch-Bedarf hat
- Hub kommt zurück, sobald neue Disziplinen (Design, Marketing) dazukommen
- Trade-off: Single-Chat füllt sich schneller, dafür kein Overhead durch Chat-Wechsel

**LiveScreen API: flache Item-Liste mit Pause-Boundaries**
- Statt `Setlist + List<Song>` nimmt LiveScreen jetzt `List<Setlist> sets + bandId + initialSet/SongIndex`
- Intern wird eine flache Liste `_LiveItem` aufgebaut: Songs + Pause-Marker zwischen Sets
- Songs werden zur Laufzeit via Provider aufgelöst (nicht vorab als Liste übergeben)
- Vorteile: Multi-Set-Navigation einheitlich, Set-Grenzen explizit modelliert, Pause-Übergang Teil der normalen Swipe-Sequenz
- Standalone-Setlist und Single-Song laufen über denselben Mechanismus (`sets = [eineSetlist]`)

**PDF-Drag persistieren onEnd, nicht onUpdate**
- Erste Version rief bei jedem `onScaleUpdate` (60Hz) `updateSong` mit komplettem `_save()` auf
- `_save()` serialisierte damals den gesamten App-State inkl. Base64-PDFs nach SharedPreferences → 60×/s nicht haltbar *(Base64-PDFs seit 07/2026 aus dem Blob ausgelagert — das Pattern gilt weiter)*
- Fix: lokaler State während Drag, Persistierung erst auf `onScaleEnd`
- Pattern für künftige Drag/Skalier-Operationen: niemals jeden Frame persistieren

**Gig-Setlisten sind aktuell Referenzen (shared ID) — Entscheidung offen**
- Setlisten in Gigs teilen die ID mit der Standalone-Setliste
- `updateSetlist` aktualisiert daher beide (global + in allen Gigs per ID)
- Konsequenz: Song-Add/Reorder in Gig-Setliste wirkt auch auf Standalone-Version
- Noch nicht bewusst entschieden ob Referenz (shared) oder Snapshot (Kopie pro Gig) gewünscht ist → siehe Backlog-Blocker

**Stroke-Save debounced (statt sofort)**
- Problem: `_save()` serialisierte den ganzen JSON-Blob inkl. aller base64 Chord-Charts synchron bei jedem Pen-Up/Erase → Main-Isolate blockiert → Pointer-Events gedroppt (Striche erschienen als gerade Linie + 1-2s Lag). *(Chart-Anteil seit 07/2026 behoben — Charts liegen als Files außerhalb des Blobs; der Blob besteht seither fast nur aus Strichdaten.)*
- Verifikation: `_save()` in `updateSongStrokes` temporär auskommentiert → Lag komplett weg = Save als alleiniger Täter.
- Fix: nur `updateSongStrokes` debounced (`_scheduleStrokeSave`, 800ms, Timer resettet pro Aufruf). In-Memory-Update + `notifyListeners` bleiben sofortig. Alle anderen Mutationen sofort → strukturelle Daten immer durable, kleinste Verlust-Fläche.
- `flushPendingSave` via `WidgetsBindingObserver` in `app.dart` (`.value`-Provider) bei pause/inactive/detached → schließt Verlust-Fenster bis auf Hard-Kill <800ms.
- Rest-Lag bleibt (A≈B über leere/volle Songs): periodische Save-Spikes, voller Encode pro Fire → als Backlog geparkt. NICHT Rendering — *(Einschätzung 09/2026 revidiert: der A≈B-Test variierte die Seitenfülle, nicht die Strichlänge, und konnte den Render-Pfad nicht widerlegen. Siehe "Canvas-Performance: drei getrennte Ursachen".)*.

**Backwards-compatible Load bei neuem Blob-Key**
- Neuer Top-Level-Key (`practiceItems`) additiv in den JSON-Blob. Alte Backups ohne Key: `as Map? ?? {}` → kein Crash.
- Zusätzlich inneres try-catch NUR um den neuen Block: ein defektes Practice-Item leert schlimmstenfalls die Practice-Liste, reißt aber nie Songs/Setlists/Gigs in `_loadDefaults`. Muster für künftige additive Modell-Erweiterungen.

**To-Practice: Done-Verhalten zwei-achsig**
- Häkchen (erledigt, reversibel, eingeklappte Sektion) ≠ Prio-Cycle (geübt-aber-weiter-dran). Bewusst getrennt statt ein überladener „Practiced"-Button — jede Aktion tut genau eine Sache.

**Orphan-Handling Practice-Items: mit-löschen**
- `deleteSong` löscht die Practice-Items des Songs mit. Entscheidung gegen „zu Allgemein umhängen" (würde song-lose Karteileichen erzeugen).

**Gig-Datum: tages-genauer Vergleich + zentrale Getter**
- Bug: `showDatePicker` liefert Mitternacht; `date.isBefore(now)` schob den Gig am eigenen Tag nach PAST. Fix: Vergleich auf `DateTime(y,m,d)`-Ebene.
- „Heute" ist dritter Zustand (nicht upcoming/past-binär): bleibt oben, Highlight in Primary (NICHT Amber = Practice-reserviert).
- Datums-Logik zentral im Provider (`isToday`/`isPastDay`/`todayGig`/`nextUpcomingGig`), Screens rechnen nicht selbst. Offen: `nextUpcomingGig` normalisiert Datum tages-genau, falls Gigs je echte Uhrzeiten im `date` tragen (aktuell alle Mitternacht).

**Cross-Screen-Navigation via BandScaffold-Parameter**
- `initialIndex` (Ziel-Tab) + `initialGig` (pusht GigDetail via `addPostFrameCallback` nach erstem Frame, wenn interner Navigator gemountet ist). Ermöglicht band-übergreifende Startscreen-Widgets, die gezielt in eine Band/Tab springen.

**quickStrokes entfernt** *(07/2026)*
- Feld war nie von außen beschrieben (`isQuick: true` hatte null Aufrufer)
- Toter Code im Persistenz-Format ist Risiko → mit dem Chart-Sprint raus

**IDs: Timestamp, kein uuid-Package**
- Projektweit `DateTime.now().millisecondsSinceEpoch.toString()`
- Bewusst keine neue Dependency. Grenze: Bulk-Anlage in derselben
  Millisekunde kollidiert — relevant erst bei "mehrere gleichzeitig hinzufügen".

**Band-Metadaten: ein notes-Freitext statt strukturierter Felder**
- Strukturierte Felder lohnen erst, wenn ein Feature sie ausliest.
  Gründungsjahr, Adresse, Steuernummer werden nirgends angezeigt oder gefiltert.
- Besetzung ist bewusst KEIN Feld, sondern ein eigenes Modell (wie PracticeItem).
- ⚠ Prefs-Blob ist unverschlüsselt und landet im Nextcloud-Backup —
  vor IBAN/Steuernummer im notes-Feld bewusst entscheiden.

**Canvas-Performance: drei getrennte Ursachen** *(Recherche 09/2026)*
- Der alte A≈B-Test (leerer vs. voller Song) variierte die Seitenfülle,
  nicht die Strichlänge — konnte das O(n²)-Cloning strukturell nicht finden.
- Ursache 1 (Input): Listen-Kopie + setState pro Pointer-Event
- Ursache 2 (Render): `shouldRepaint => true`, volles Neuzeichnen pro Event
- Ursache 3 (Save): 7-MB-Blob synchron auf dem Main-Isolate
- Reihenfolge: Input → Render → Format → Isolate nur falls dann noch nötig.
- Referenz: Saber (Flutter-Handschrift-App, Nextcloud-Sync) trennt Input,
  Rendering und Persistenz in eigene Schichten und rendert mit
  Level-of-Detail. GPL-3.0 — als Muster lesen, Code nicht übernehmen.
- Impeller ist ab Flutter 3.41 Standard auf Android — die Engine ist nicht
  die Ursache.

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

**HitTestBehavior.opaque für GestureDetector mit nicht-vollflächigem Inhalt**
- Pause-Screen war ein zentriertes `Column` ohne vollflächigen Inhalt → leere Bereiche waren keine Hit-Targets, Swipe/Tap funktionierten nicht
- Fix: `behavior: HitTestBehavior.opaque` am äußeren GestureDetector
- Lehre: bei wechselnden Inhalten (mal Canvas vollflächig, mal kompakter Inhalt) immer `opaque` setzen

**PDF im Live-Modus: Properties müssen durchgereicht werden**
- DrawingCanvas hat ChordChart-Properties mit Defaults (`null`, `0.0`, `1.0`)
- Im Live-Modus wurden sie nicht übergeben → Chart unsichtbar, weil `chordChartFile == null`
- Lehre: bei Widget-Erweiterungen alle Aufrufer prüfen, ob neue Properties durchgereicht werden müssen

**Canvas-Strich-Cloning O(n²) (bekannt, nicht gefixt)**
- In `onPointerMove` wird `_currentStroke` jedes Mal neu gebaut mit `[..._currentStroke!.points, newPoint]`
- Bei 200 Punkten = 200 Kopien beim 200. Punkt
- Symptome: verspätete Striche, Kurven werden zu Polylinien (Punkt-Drops durch Frame-Skip)
- Fix verschoben: Backlog HOCH "Canvas-Performance: Strich-Cloning O(n²) → mutable Append"

**Live-Modus Empty-State**
- `_items`-Liste leer (Setliste ohne Songs) führte zu RangeError bei `_items[0]`
- Fix: `_currentItem` nullable gemacht, `_buildMainContent` fängt `_items.isEmpty` mit Empty-State ab
- `_appBarTitle` gibt bei null „Live" zurück

**updateSetlist muss Gigs mitführen**
- Setliste nur in globaler Liste zu aktualisieren reicht nicht, wenn sie in einem Gig bearbeitet wird
- `updateSetlist` durchsucht jetzt auch `_gigs[bandId]` und ersetzt per ID

**deleteBand: Chart-Cleanup VOR dem Entfernen der Map-Einträge**
- Umgekehrt sind die Dateinamen weg, bevor sie gelesen werden → stille
  Orphan-Files auf Disk, die nie jemand bemerkt.

**Bottom Sheet: Provider einmal capturen, Grid-Context für den Folge-Dialog**
- Nach dem Sheet-pop ist der sheetContext tot. Das bestehende Setlist-Muster
  macht es andersherum und funktioniert nur zufällig.

**Fehler-toleranter Loader + Referenz-Entfernung = stiller Datenverlust**
- `exportBackupJson()`: `loadChart` gibt bei fehlender Datei `null` zurück,
  `chordChartFile` wird trotzdem entfernt → Song im Backup ohne jede
  Chart-Referenz, Meldung trotzdem "successful".
- Lehre: Wo ein Loader Fehler schluckt, darf der Aufrufer die Referenz
  nicht wegwerfen. Fehlschläge zählen und melden, aber nie das ganze
  Backup abbrechen — ein unvollständiges Backup schlägt keins.

**Backup umfasst seit der Chart-Migration zwei Artefakte**
- Prefs-XML allein ist kein vollständiges Backup mehr.

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

**Drag/Skalier-Operationen: Persist onEnd, nicht onUpdate**
- Während Drag: nur lokaler State (Live-Visualisierung)
- Beim Loslassen: einmal Callback → einmal `updateSong` → einmal `_save`
- Gilt für jede Operation, die kontinuierliche Inputs erzeugt und teure Persistenz hat

**Amber (`AppTheme.practiceColor`, #FFC107)** = Practice-Feature durchgängig (Badges, Icons, Selektoren). Abgegrenzt von Solo-Rot, Backing-Blau, Key-Lila. Neue Practice-UI nutzt diese Konstante, kein hartkodiertes Amber.

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

## Tooling

**Claude Code für Implementierung (ab Juli 2026)**
- Multi-File-Features über Claude Code (CLI, editiert Repo direkt) statt Copy-paste im Chat — Grund: Copy-paste-Fehler waren wiederholt teuer.
- Sparring/Architektur/Priorisierung bleiben im `Nota`-Chat.
- Guardrails: `CLAUDE.md` im Repo-Root.