# Nota – Claude Code Guardrails

Flutter Setlist-Manager für Musiker, Tablet-optimiert (Samsung Galaxy Tab S6 Lite, Landscape, Immersive). Solo-Projekt.

## Vor jeder Aufgabe
- Lies `docs/01-tech-doc.md`, `docs/10-backlog.md`, `docs/11-transferwissen.md` für Stack, Konventionen, Entscheidungen.
- Relevante `lib/`-Files lesen, bevor du editierst.

## Arbeitsweise
- Deutsch, technische Begriffe Englisch.
- Konstruktiv, kritisch, analytisch. Kein Zustimmen aus Höflichkeit. Lob nur wo berechtigt.
- Effektiv: so viel wie nötig, so wenig wie möglich. Stichpunkte > Fließtext.
- Empfehlungen: ranked mit Begründung, keine offenen Fragen.
- Scope strikt: ein Feature pro Sequenz. Keine unbezogenen Files anfassen. Weiche ich ab, weise mich drauf hin.
- Schrittweise, bei größeren Schritten auf Bestätigung warten.
- Voice-to-Text: Transkriptionsfehler stillschweigend filtern, nicht nachfragen.

## Architektur-Fakten
- State: ein zentraler `BandProvider` (Provider-Package).
- Persistenz: alles als ein JSON-Blob in SharedPreferences (Key `nota_data`), Chord-Charts als Base64 im JSON.
- Stroke-Save ist debounced (`_scheduleStrokeSave`, 800ms) + Lifecycle-Flush (`flushPendingSave` in `app.dart`). Alle anderen Saves sofort.
- Hierarchie: Bands → Songs / Setlists / Gigs (SongSlots für Reihenfolge).

## Harte Regeln
- **Modell-Update = 4 Stellen:** Modell-Klasse, `BandProvider._load()`, `BandProvider._save()`, alle UI-Stellen die das Objekt bauen. Keine vergessen.
- **Datenformat-/Persistenz-Änderung:** erst Backup-Hinweis, doppelt nachfragen, bevor Umsetzung.
- **Bug-Jagd:** hypothesengetrieben — Vermutung → Diagnose → Fix. Keine Spekulation ohne Verifikation.
- Neue Songs/Gigs/Setlists: alle Felder explizit setzen (kein copy-with).
- `setState` nach async mit mounted-Check. Provider-Referenz vor `await`/`pop` capturen.

## Vor Commit
- `flutter analyze` → 0 issues.
- Commit-Message vorschlagen, `git push` erst nach meiner Bestätigung.
- Run/Test: `flutter run -d R52NC05R33J`.

## NIE
- Files ohne docs/-Check ändern.
- Persistenz-Format ohne Backup-Hinweis ändern.
- Bug-Ursachen ohne Diagnose annehmen.
- Scope über das aktuelle Feature hinaus ausweiten.