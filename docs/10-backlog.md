# Nota – Backlog

**Letzter Stand:** [heutiges Datum eintragen]

## Aktuell in Arbeit

*Pre-Gig-Sprint abgeschlossen und committed. Offene Architekturfrage: Gig-Setlisten Referenz vs. Snapshot (siehe unten).*

**Nächster Schritt:** User hat 1–2 neue HOCH-Punkte (noch nicht spezifiziert) für nächste Session.

**Termine:** Gigs am 09.05. + 10.05.2026.

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

- [ ] **1–2 neue Punkte vom User** (in nächster Session spezifizieren)
- [ ] Mehrere Songs/Setlists gleichzeitig hinzufügen
- [ ] Duplizieren von Songs/Gigs (Setlist-Duplikat ist erledigt)
- [ ] Gig Kartenlayout überarbeiten
- [ ] Setlists-Screen Sortierung (Parität mit Library)
- [ ] Library Alphabet-Quick-Nav-Leiste (vertikal, bei alphabetischer + Key-Sortierung)

## Prio MITTEL

- [ ] Live-Modus-Indikator (Konzept nach erstem Gig)
- [ ] To-Practice-Feature (User-Wunsch hoch, nach Gig priorisieren)
- [ ] Setlist Template System (teilweise durch Duplicate abgedeckt)
- [ ] Gig Recap (Sterne, Highlights/Lowlights)
- [ ] Abbreviation-Vorschläge automatisch
- [ ] Gig Live Notes
- [ ] Canvas-Performance: Strich-Cloning O(n²) → mutable Append (verspätete Striche / gerade Linien bei langem Schreiben)

## Prio NIEDRIG

- [ ] Band Logo + Theming aus Logo-Farben
- [ ] Nextcloud Auto-Sync
- [ ] Mehrere Sketch-Seiten pro Song
- [ ] Startscreen (Recently Used, Upcoming Gigs)
- [ ] Canvas-Koordinaten relativ speichern (Sidebar-Scaling fix)
- [ ] Dark/Light Mode App-weit
- [ ] PDF Export Setlist
- [ ] Gerade Linie + Text Tool im Canvas
- [ ] Multilingual DE/EN
- [ ] Rotation für Chord Chart

## Offene Fragen

- Standard-Modus persistent speichern? (User wollte erst Erfahrung sammeln)
- Auto-Sync Nextcloud: bei jedem Save? Nur beim App-Verlassen?
- Multiple Sketch-Pages: Tabs? Swipe? UI noch unklar
- Band Theming aus Logo: welche Farben extrahieren?
- Gig Recap Timing: sofort nach Gig oder optional?
- PDF-Auflösung 2x – reicht das auf der Bühne? Noch nicht im Bühnenlicht getestet
- Live-Modus-Indikator: welche Form?

## Erledigt (chronologisch absteigend)

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