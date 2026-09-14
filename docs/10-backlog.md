# Nota – Backlog

**Letzter Stand:** 11.09.2026

## Aktuell in Arbeit

*Nichts. Letztes Feature: Band-Management Stufe 1+2 (Anlegen/Edit/Delete).*

**Nächster Schritt:** Stroke-Performance-Sprint (größter Hebel).

## ⚠ Offene Architektur-Entscheidung (BLOCKER für Gig-Setlist-Bearbeitung)

**Gig-Setlisten: Referenz oder Snapshot?**
- Aktueller Ist-Zustand: Setlisten in Gigs teilen die ID mit der Standalone-Setliste → sie sind effektiv **dieselbe** Setliste (Referenz).
- Symptom: „Gig → Setliste → + Song" fügt den Song auch in der Standalone-Version hinzu (gleiche ID, eine Quelle).
- `updateSetlist` wurde erweitert, sodass es Setlisten sowohl in der globalen Liste als auch in Gigs per ID aktualisiert. Funktioniert technisch, aber das Verhalten (shared) ist nicht bewusst entschieden.
- **Zu entscheiden:**
  - **Option 1 (Referenz/shared):** Eine Quelle der Wahrheit. Änderung wirkt überall. Einfacher.
  - **Option 2 (Snapshot/Kopie):** Jeder Gig hat eigene Setlist-Version mit eigener ID. Flexibler für Bühne, mehr Code.
- ⚠ Datenformat-Entscheidung → doppelt nachfragen, Backup vor Umsetzung.

## Prio HOCH

- [ ] Mehrere Songs/Setlists gleichzeitig hinzufügen
- [ ] Gig Kartenlayout überarbeiten
- [ ] Setlists-Screen Sortierung (Parität mit Library)
- [ ] Library Alphabet-Quick-Nav-Leiste (vertikal, bei alphabetischer + Key-Sortierung)
- [ ] Setlist-Copy-Rename defekt: Umbenennen kopierter Setlisten wirkt nicht. War als erledigt geführt → Regression oder nie sauber gefixt. Verdacht: `updateSetlist` trifft die Kopie-Instanz nicht / Rename schreibt auf falsche ID. Nächste Sequenz, hypothesengetrieben.
- [ ] Canvas-Performance: Strich-Cloning O(n²) → mutable Append (verspätete Striche / gerade Linien bei langem Schreiben) Zusätzlich zum Cloning läuft bei jedem Pointer-Event ein `setState` (kompletter Widget-Rebuild) — Fix über `ValueNotifier` für den laufenden Strich.
- [ ] **Render-Pfad Canvas** — `shouldRepaint => true` repaintet alle Striche + Hintergrund + Chart bei jedem Event. Fix: Zwei-Schichten-Painter (fertige Striche einmal in ui.Picture gecacht, nur aktiver Strich live) + RepaintBoundary. Kein Format-Change.
- [ ] Canvas Rest-Lag: periodische Save-Spikes bleiben. **Diagnose korrigiert (06.07.):** NICHT die Charts — der Blob (4,6 MB gemessen am Gerät) ist zu 99 % Strokes-JSON. Ursache: `DrawingStroke.toJson` schreibt jeden Punkt als `{"x":123.456789…,"y":…}` mit voller Double-Präzision (~66 chars/Punkt), dazu `widths` als volle Doubles. Fix ranked: (1) Koordinaten + Widths bei Serialisierung auf 1 Nachkommastelle runden (0,1 px unter Stift-Auflösung, ~1,5 MB, trivial, altes Format bleibt lesbar); (2) kompakte Punkt-Codierung (`[x,y]`-Arrays statt Objekte, ~40 % weniger, braucht Backwards-Load für beide Formate); (3) Isolate-Encoding — erst wenn (1)+(2) nicht reichen. Null Daten-Risiko. **Update 11.09.:** Blob jetzt 6,97 MB gemessen, 0 Base64-Reste — Diagnose bestätigt. Reihenfolge im Sprint aber: erst Input-Pfad, dann Render-Pfad, dann dieser Punkt. Die Save-Spikes sind die periodische Hängerei, nicht die Hängerei beim Zeichnen selbst.
- [ ] **Export: stiller Datenverlust** — `exportBackupJson()` band_provider.dart:376-382: bei fehlgeschlagenem `loadChart` wird `chordChartFile` trotzdem entfernt (remove außerhalb des if). Backup meldet "successful". Aktuell latent (1 Referenz = 1 Datei). Fix: Referenz behalten + Fehlschläge im UI melden, Backup nie ganz abbrechen.
- [ ] Songs zwischen Bands kopieren — Achtung: Chart-File muss mitkopiert werden (Dateiname = songId), sonst Delete-Hazard.

## Prio MITTEL

- [ ] Live-Modus-Indikator (Konzept nach erstem Gig)
- [ ] Setlist Template System (teilweise durch Duplicate abgedeckt)
- [ ] Gig Recap (Sterne, Highlights/Lowlights)
- [ ] Abbreviation-Vorschläge automatisch
- [ ] Gig Live Notes
- [ ] Cross-Band Practice-Startscreen: `allPracticeItems`-Getter liegt bereit, UI ausstehend.
- [ ] Practice-Screen cross-band: Sidebar-Badge zählt seit 06.07. alle Bands (`openPracticeCountAll`), der Screen dahinter (`PracticeScreen(bandId)`) ist aber weiter band-scoped → Badge N kann > angezeigte Items sein. Konsistenz-Fix: Screen ebenfalls cross-band (braucht Band-Zuordnung/-Label pro Item in der Liste). Eigener Scope.
- [ ] Backlog HOCH verifizieren: „Mehrere Songs/Setlists hinzufügen" + „Gig-Kartenlayout" gegen App-Stand prüfen.
- [ ] Backup-Roundtrip nach Chart→File-Umbau am Gerät verifizieren (Export→Restore, + altes Base64-Backup restoren). Beim Geräte-Test 06.07. übersprungen, weil Nextcloud-Server down. Code-Pfad (Export-Serializer bettet Base64 ein, Restore + `_load`-Migration extrahiert wieder zu Files) ist implementiert; Migrations-Zweig implizit ok (identisch zum App-Start-Load, der am Gerät fehlerfrei lief), aber der volle Roundtrip ist ungetestet.
- [ ] Band Stufe 3: Farbe + foundedYear + notes (ein gemeinsamer Format-Change)
- [ ] Band Logo — Stufe 4 des Band-Managements. File-Storage nach ChartStorage-Muster.
- [ ] Band Stufe 5: Besetzung (eigenes Modell BandMember, kein Feld)
- [ ] `copyWith` + `toJson`/`fromJson` für Band/Song — die 4-Stellen-Regel ist das Symptom einer fehlenden Serialisierungs-Schicht. Sinnvoll vor Stufe 3+4.
- [ ] Lokales Backup-Ziel + Zeitstempel-Kopie (Nextcloud überschreibt aktuell immer dieselbe Datei → keine Historie)
- [ ] Live-Screen-Layout überarbeiten

## Prio NIEDRIG

- [ ] Theming aus Logo-Farben
- [ ] Nextcloud Auto-Sync
- [ ] Mehrere Sketch-Seiten pro Song
- [ ] Startscreen (Recently Used, Upcoming Gigs)
- [ ] Canvas-Koordinaten relativ speichern (Sidebar-Scaling fix)
- [ ] Dark/Light Mode App-weit
- [ ] PDF Export Setlist
- [ ] Gerade Linie + Text Tool im Canvas
- [ ] Multilingual DE/EN
- [ ] Rotation für Chord Chart
- [ ] `band_home_screen.dart` ist toter Code seit Dashboard-Umbau → entfernen
- [ ] Sprach-Mix: Dialoge englisch, Dashboard deutsch → vereinheitlichen
- [ ] Degenerierte Ein-Punkt-Striche werden gespeichert (leeres widths-Array)
- [ ] Timestamp-IDs kollidieren bei Bulk-Add in derselben Millisekunde
- [ ] Delete-Dialog: "12 songs (incl. chord charts)" — Zählung präzisieren
- [ ] RAM-Peak beim Export (alle Charts gleichzeitig als Base64 im Speicher)
- [ ] Flutter 3.41.6 + 38 Packages veraltet — eigener Sprint, nicht nebenbei

## Offene Fragen

- Standard-Modus persistent speichern? (User wollte erst Erfahrung sammeln)
- Auto-Sync Nextcloud: bei jedem Save? Nur beim App-Verlassen?
- Multiple Sketch-Pages: Tabs? Swipe? UI noch unklar
- Band Theming aus Logo: welche Farben extrahieren?
- Gig Recap Timing: sofort nach Gig oder optional?
- PDF-Auflösung 2x – reicht das auf der Bühne? Noch nicht im Bühnenlicht getestet
- Live-Modus-Indikator: welche Form?

## Erledigt (chronologisch absteigend)

**2026 (September):**
- Band-Management: Anlegen, Bearbeiten, Löschen (inkl. Chart-File-Cleanup)
- adb-PATH dauerhaft gesetzt

**2026 (Juli):**
- Practice-Badge cross-band
- Chord Charts → Files (via Claude Code, 5 Phasen): Chart-PNGs raus aus dem Prefs-Blob, jetzt als Files in `Documents/charts/` (ChartStorage-Service, path_provider). Blob referenziert nur noch Dateinamen. `_load`-Migration Base64→File (greift auch nach Backup-Restore), Lösch-Hygiene in `updateSong`/`deleteSong`, Export-Serializer hält `nota_backup.json` formatidentisch (Base64 embedded). `quickStrokes`-Feld komplett entfernt. Nebenfix: mehrere `Song(...)`-Call-Sites kopierten `chordChartBase64`/`canvasBackground` nicht mit → jedes Metadaten-Edit verwarf das Chart; jetzt alle Felder explizit gesetzt. Geräte-Test bestätigte Migration/Import/Löschung — **aber** Save-Spikes NICHT behoben (siehe MITTEL: Blob ist Strokes-JSON, nicht Charts).
- Canvas-Save-Debounce: Stroke-Save aus dem Hot-Path (800ms + Lifecycle-Flush) → Zeichen-Lag massiv reduziert. Diagnose: `_save()` auskommentiert → Lag weg = Save als Täter bestätigt.
- Pre-Gig-Sprint: Library-Suche, Duplizieren (Songs/Setlists/Gigs), Drag&Drop (echt — war vorher fälschlich als erledigt geführt), Edit-Dialog, Vollbild-Fix, Live-Empty-Guard
- To-Practice Feature (via Claude Code, 4 Phasen): PracticeItem-Model, band-scoped Provider-Layer (backwards-compatible Load + inneres try-catch), Capture-Dialog (2 Entry-Points), Practice-Screen (Prio-Sort, Prio-Cycle, Erledigt-Sektion, Filter, Swipe-Delete), Amber-Badges (Library + Nav), Orphan-Delete (Items sterben mit dem Song).
- Startscreen-Dashboard (via Claude Code, 3 Phasen): Gig-Tag-Bug gefixt (tages-genauer Vergleich, HEUTE als dritter Zustand in Primary), zentrale Datums-Getter im Provider, `BandScaffold.initialIndex/initialGig`, Gig- + Practice-Widget (cross-band, Practice direkt abhakbar), Band-Grid 3-spaltig.

**2026 (Mai, Pre-Gig-Sprint):**
- Library-Suche (Filter title + artist, Live, mit Counter X/Y und Clear-Button)
- Setlist Duplicate (Setlists-Screen, Long-Press → „(Copy)")
- Rename-Bug-Fix (Provider vor await/pop, disposed-Context vermieden)
- Long-Press in Setlist/Gig öffnet Edit-Dialog statt Canvas
- Canvas-Vollbild konsistent aus Setlist/Gig (rootNavigator)
- Drag & Drop: Songs innerhalb Setlist + Setlists innerhalb Gig (Drag-Handle, Reihenfolge Key→Remove→Drag)
- Live-Modus Empty-State-Guard (kein Crash mehr bei leerer Setliste)
- updateSetlist erweitert: aktualisiert Setlisten auch in Gigs per ID
- Set-Übergang im Live-Modus: Pause-Screen, Swipe weiter, Sidebar-Headers, Next-Hint zeigt „Pause"
- PDF im Live-Modus sichtbar
- PDF-Lag beim Verschieben/Skalieren behoben (Save onScaleEnd statt 60×/s)

**Davor:**
- Chord Chart PDF Import als Hintergrund mit Verschieben/Skalieren
- Live-Modus aus Gig spielt korrekt nur Setlist-Songs
- Setting als Freitext, Backwards-Compat-Migration
- Tab-Stop-Layout, 3 Live-Modi, Solo/Backing Badges
- Nextcloud WebDAV Backup/Restore (manuell)
- Songs/Gigs/Setlists CRUD, Canvas-System, S Pen Support

## Termine / Pflege-Notizen

- Vor jedem Gig: Backup auf Nextcloud (manuell)
- Bei Datenformat-Änderung: 4 Stellen prüfen (Modell, `_load`, `_save`, alle UI-Stellen)