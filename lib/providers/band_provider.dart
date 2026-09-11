import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/band.dart';
import '../models/song.dart';
import '../models/setlist.dart';
import '../models/song_slot.dart';
import '../models/gig.dart';
import '../models/practice_item.dart';
import '../models/drawing_stroke.dart';
import '../services/chart_storage.dart';
import '../widgets/drawing_canvas.dart';

class BandProvider extends ChangeNotifier {
  static const _storageKey = 'nota_data';

  List<Band> _bands = [];
  Map<String, List<Song>> _songs = {};
  Map<String, List<Setlist>> _setlists = {};
  Map<String, List<Gig>> _gigs = {};
  Map<String, List<PracticeItem>> _practiceItems = {};

  // Debounce nur für den heißen Stroke-Save-Pfad
  Timer? _strokeSaveDebounce;

  BandProvider() {
    _load();
  }

  @override
  void dispose() {
    _strokeSaveDebounce?.cancel();
    super.dispose();
  }

  // Getters
  List<Band> get bands => List.unmodifiable(_bands);
  List<Song> getSongs(String bandId) => List.unmodifiable(_songs[bandId] ?? []);
  List<Setlist> getSetlists(String bandId) => List.unmodifiable(_setlists[bandId] ?? []);
  List<Gig> getGigs(String bandId) => List.unmodifiable(_gigs[bandId] ?? []);
  List<PracticeItem> getPracticeItems(String bandId) =>
      List.unmodifiable(_practiceItems[bandId] ?? []);

  /// Cross-Band-Aggregation (trägt den späteren Startscreen).
  List<({String bandId, PracticeItem item})> get allPracticeItems {
    final result = <({String bandId, PracticeItem item})>[];
    _practiceItems.forEach((bandId, items) {
      for (final item in items) {
        result.add((bandId: bandId, item: item));
      }
    });
    return result;
  }

  int openPracticeCount(String bandId) =>
      (_practiceItems[bandId] ?? []).where((p) => !p.done).length;

  /// Cross-Band: offene Practice-Items über alle Bands (Sidebar-Badge).
  int get openPracticeCountAll =>
      allPracticeItems.where((e) => !e.item.done).length;

  // Tages-genaue Datums-Logik zentral hier — Screens vergleichen nie selbst
  // gegen DateTime.now() (Gig-Datum ist Mitternacht via showDatePicker).
  /// True wenn [date] am heutigen Kalendertag liegt.
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// True wenn [date] vor dem heutigen Kalendertag liegt (Tages-genau).
  static bool isPastDay(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(date.year, date.month, date.day).isBefore(today);
  }

  /// Cross-Band: Gig mit Datum == heute, oder null. Gigs ohne Datum zählen nie.
  ({String bandId, Gig gig})? todayGig() {
    for (final entry in _gigs.entries) {
      for (final gig in entry.value) {
        if (isToday(gig.date)) {
          return (bandId: entry.key, gig: gig);
        }
      }
    }
    return null;
  }

  /// Cross-Band: Gig mit frühestem Datum >= heute (inkl. heute), oder null.
  ({String bandId, Gig gig})? nextUpcomingGig() {
    ({String bandId, Gig gig})? best;
    _gigs.forEach((bandId, gigs) {
      for (final gig in gigs) {
        final date = gig.date;
        if (date == null || isPastDay(date)) continue;
        if (best == null || date.isBefore(best!.gig.date!)) {
          best = (bandId: bandId, gig: gig);
        }
      }
    });
    return best;
  }

  int openPracticeCountForSong(String bandId, String songId) =>
      (_practiceItems[bandId] ?? [])
          .where((p) => !p.done && p.songId == songId)
          .length;

  List<Song> getSongsForSetlist(String bandId, Setlist setlist) {
    final allSongs = _songs[bandId] ?? [];
    return setlist.slots
        .map((slot) => allSongs.firstWhere(
              (s) => s.id == slot.songId,
              orElse: () => Song(id: '', title: 'Unknown', key: ''),
            ))
        .toList();
  }

  // Load
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    debugPrint('All keys: ${prefs.getKeys()}');
    debugPrint('Loaded nota_data: ${raw?.length ?? 0} chars');
    if (raw == null) {
      _loadDefaults();
    } else {
      try {
        final data = jsonDecode(raw);
        _bands = (data['bands'] as List)
            .map((b) => Band(id: b['id'], name: b['name'], genre: b['genre'] ?? ''))
            .toList();
        _songs = {};
        (data['songs'] as Map).forEach((bandId, songList) {
          _songs[bandId] = (songList as List).map((s) => Song(
            id: s['id'],
            title: s['title'],
            artist: s['artist'] ?? '',
            key: s['key'] ?? '',
            bpm: s['bpm'],
            notes: s['notes'] ?? '',
            abbreviation: s['abbreviation'] ?? '',
            intro: s['intro'] ?? '',
            outro: s['outro'] ?? '',
            hasSolo: s['hasSolo'] ?? false,
            hasBacking: s['hasBacking'] ?? false,
            // 'quickStrokes'-Key alter Blobs wird bewusst ignoriert (Feature entfernt).
            strokes: (s['strokes'] as List? ?? [])
                .map((stroke) => DrawingStroke.fromJson(stroke))
                .toList(),
            canvasBackground: CanvasBackground.values.firstWhere(
              (e) => e.name == s['canvasBackground'],
              orElse: () => CanvasBackground.dark,
            ),
            chordChartFile: s['chordChartFile'],
            chordChartBase64: s['chordChartBase64'],
            chordChartX: (s['chordChartX'] ?? 0.0).toDouble(),
            chordChartY: (s['chordChartY'] ?? 0.0).toDouble(),
            chordChartScale: (s['chordChartScale'] ?? 1.0).toDouble(),
          )).toList();
        });
        _setlists = {};
        (data['setlists'] as Map).forEach((bandId, setlistList) {
          _setlists[bandId] = (setlistList as List).map((sl) => Setlist(
            id: sl['id'],
            name: sl['name'],
            slots: (sl['slots'] as List).map((slot) => SongSlot(
              id: slot['id'],
              songId: slot['songId'],
              order: slot['order'],
            )).toList(),
          )).toList();
        });
        _gigs = {};
        (data['gigs'] as Map).forEach((bandId, gigList) {
          _gigs[bandId] = (gigList as List).map((g) => Gig(
            id: g['id'],
            name: g['name'],
            venue: g['venue'] ?? '',
            date: g['date'] != null ? DateTime.parse(g['date']) : null,
            time: g['time'] ?? '',
            soundcheckTime: g['soundcheckTime'] ?? '',
            setting: g['setting'] ?? (g['isOutdoor'] == true ? 'Outdoor' : ''),
            fee: g['fee'] ?? '',
            organizer: g['organizer'] ?? '',
            notes: g['notes'] ?? '',
            setlists: (g['setlists'] as List).map((sl) => Setlist(
              id: sl['id'],
              name: sl['name'],
              slots: (sl['slots'] as List? ?? []).map((slot) => SongSlot(
                id: slot['id'],
                songId: slot['songId'],
                order: slot['order'],
              )).toList(),
            )).toList(),
          )).toList();
        });
        // Backwards-compatible: alte Backups haben keinen 'practiceItems'-Key.
        // Eigenes try-catch: ein defektes Practice-Item darf niemals
        // Songs/Setlists/Gigs in _loadDefaults reißen (= Datenverlust).
        _practiceItems = {};
        try {
          ((data['practiceItems'] as Map?) ?? {}).forEach((bandId, itemList) {
            _practiceItems[bandId] = (itemList as List)
                .map((p) => PracticeItem.fromJson(p))
                .toList();
          });
        } catch (e) {
          _practiceItems = {};
        }
      } catch (e) {
        _loadDefaults();
      }
    }
    await _migrateChartsToFiles();
    notifyListeners();
  }

  /// Migration Base64 → File. Läuft bei jedem App-Start und greift damit
  /// auch nach einem Backup-Restore (Restore schreibt den Blob 1:1 in
  /// Prefs, Neustart lädt und migriert). Nur bei Schreib-Erfolg wird
  /// chordChartFile gesetzt und base64 genullt — bei Fehler bleibt base64
  /// erhalten und wird von _save als Fallback weiter persistiert.
  Future<void> _migrateChartsToFiles() async {
    var migrated = false;
    for (final songs in _songs.values) {
      for (final song in songs) {
        final base64 = song.chordChartBase64;
        if (base64 == null || song.chordChartFile != null) continue;
        try {
          final bytes = base64Decode(base64);
          song.chordChartFile = await ChartStorage.saveChart(song.id, bytes);
          song.chordChartBase64 = null;
          migrated = true;
        } catch (_) {
          // Decode-/Schreib-Fehler: base64 behalten (kein Datenverlust).
        }
      }
    }
    if (migrated) {
      await _save(); // persistiert den schlanken Blob einmalig
    }
  }

  void _loadDefaults() {
    _bands = [
      Band(id: '1', name: 'PRIMEBEATS', genre: 'Rockabilly / 50s Rock\'n\'Roll'),
      Band(id: '2', name: 'Jukebox22', genre: 'Rockabilly / 50s Rock\'n\'Roll'),
      Band(id: '3', name: 'Solo', genre: ''),
    ];
    _songs = {'1': [], '2': [], '3': []};
    _setlists = {'1': [], '2': [], '3': []};
    _gigs = {'1': [], '2': [], '3': []};
    _practiceItems = {'1': [], '2': [], '3': []};
  }

  // Stroke-Save debounced: schreibt erst ~800ms nach dem letzten Pen-Up/Erase.
  // Timer resettet pro Aufruf → nie während aktivem Zeichnen, nur in der Pause.
  void _scheduleStrokeSave() {
    _strokeSaveDebounce?.cancel();
    _strokeSaveDebounce = Timer(const Duration(milliseconds: 800), () {
      _strokeSaveDebounce = null;
      _save();
    });
  }

  // Sofort-Flush für App-Lifecycle (pause/inactive/detached).
  Future<void> flushPendingSave() async {
    if (_strokeSaveDebounce != null) {
      await _save(); // _save cancelt + nullt den Timer selbst
    }
  }

  // Save
  Future<void> _save() async {
    // Jeder Save befriedigt pending Strokes (bereits in-memory) → Timer clearen.
    _strokeSaveDebounce?.cancel();
    _strokeSaveDebounce = null;
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'bands': _bands.map((b) => {
        'id': b.id,
        'name': b.name,
        'genre': b.genre,
      }).toList(),
      'songs': _songs.map((bandId, songs) => MapEntry(
        bandId,
        songs.map((s) => {
          'id': s.id,
          'title': s.title,
          'artist': s.artist,
          'key': s.key,
          'bpm': s.bpm,
          'notes': s.notes,
          'abbreviation': s.abbreviation,
          'intro': s.intro,
          'outro': s.outro,
          'hasSolo': s.hasSolo,
          'hasBacking': s.hasBacking,
          'strokes': s.strokes.map((stroke) => stroke.toJson()).toList(),
          'canvasBackground': s.canvasBackground.name,
          'chordChartFile': s.chordChartFile,
          // Fallback nur für den Migrations-Fehlerfall — normal ist das null
          // und der Key fehlt (Blob bleibt schlank).
          if (s.chordChartBase64 != null) 'chordChartBase64': s.chordChartBase64,
          'chordChartX': s.chordChartX,
          'chordChartY': s.chordChartY,
          'chordChartScale': s.chordChartScale,
        }).toList(),
      )),
      'setlists': _setlists.map((bandId, setlists) => MapEntry(
        bandId,
        setlists.map((sl) => {
          'id': sl.id,
          'name': sl.name,
          'slots': sl.slots.map((slot) => {
            'id': slot.id,
            'songId': slot.songId,
            'order': slot.order,
          }).toList(),
        }).toList(),
      )),
      'gigs': _gigs.map((bandId, gigs) => MapEntry(
        bandId,
        gigs.map((g) => {
          'id': g.id,
          'name': g.name,
          'venue': g.venue,
          'date': g.date?.toIso8601String(),
          'time': g.time,
          'soundcheckTime': g.soundcheckTime,
          'setting': g.setting,
          'fee': g.fee,
          'organizer': g.organizer,
          'notes': g.notes,
          'setlists': g.setlists.map((sl) => {
            'id': sl.id,
            'name': sl.name,
            'slots': sl.slots.map((slot) => {
              'id': slot.id,
              'songId': slot.songId,
              'order': slot.order,
            }).toList(),
          }).toList(),
        }).toList(),
      )),
      'practiceItems': _practiceItems.map((bandId, items) => MapEntry(
        bandId,
        items.map((p) => p.toJson()).toList(),
      )),
    };
    final encoded = jsonEncode(data);
    debugPrint('Saved nota_data: ${encoded.length} chars');
    await prefs.setString(_storageKey, encoded);
  }

  /// Nextcloud-Export im ALTEN Backup-Format: Chart-Files werden als
  /// chordChartBase64 eingebettet, chordChartFile weggelassen —
  /// nota_backup.json bleibt damit zu allen App-Ständen kompatibel.
  Future<String?> exportBackupJson() async {
    await flushPendingSave();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return null;
    final data = jsonDecode(raw);
    final songsMap = data['songs'] as Map?;
    if (songsMap != null) {
      for (final songList in songsMap.values) {
        for (final s in songList as List) {
          final song = s as Map;
          final fileName = song['chordChartFile'];
          if (fileName is String) {
            final bytes = await ChartStorage.loadChart(fileName);
            if (bytes != null) {
              song['chordChartBase64'] = base64Encode(bytes);
            }
          }
          song.remove('chordChartFile');
        }
      }
    }
    return jsonEncode(data);
  }

  // Mutations
  void addBand(Band band) {
    _bands.add(band);
    _songs[band.id] = [];
    _setlists[band.id] = [];
    _gigs[band.id] = [];
    _practiceItems[band.id] = [];
    _save();
    notifyListeners();
  }

  void updateBand(Band band) {
    final index = _bands.indexWhere((b) => b.id == band.id);
    if (index != -1) {
      _bands[index] = band;
      _save();
      notifyListeners();
    }
  }

  /// Löscht die Band samt allem, was an ihrer bandId hängt.
  void deleteBand(String bandId) {
    // Lösch-Hygiene: Chart-Files aller Songs der Band mit abräumen —
    // sonst bleiben verwaiste PNGs in charts/ liegen.
    for (final song in _songs[bandId] ?? const <Song>[]) {
      final chartFile = song.chordChartFile;
      if (chartFile != null) {
        ChartStorage.deleteChart(chartFile);
      }
    }
    _bands.removeWhere((b) => b.id == bandId);
    _songs.remove(bandId);
    _setlists.remove(bandId);
    _gigs.remove(bandId);
    _practiceItems.remove(bandId);
    _save();
    notifyListeners();
  }

  void addSong(String bandId, Song song) {
    _songs[bandId] ??= [];  
    _songs[bandId]!.add(song);
    _save();
    debugPrint('Saved song: ${song.title}');
    notifyListeners();
  }

  void updateSong(String bandId, Song song) {
    final list = _songs[bandId];
    if (list == null) return;
    final index = list.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      // Lösch-Hygiene: Chart entfernt oder ersetzt → altes File abräumen.
      final oldFile = list[index].chordChartFile;
      if (oldFile != null && oldFile != song.chordChartFile) {
        ChartStorage.deleteChart(oldFile);
      }
      list[index] = song;
      _save();
      notifyListeners();
    }
  }

  void updateSongStrokes(String bandId, String songId, List<DrawingStroke> strokes) {
    final list = _songs[bandId];
    if (list == null) return;
    final index = list.indexWhere((s) => s.id == songId);
    if (index != -1) {
      list[index].strokes = strokes;
      _scheduleStrokeSave(); // debounced statt sofort — behebt den Save-Freeze
      notifyListeners();
    }
  }

  void deleteSong(String bandId, String songId) {
    // Lösch-Hygiene: Chart-File des Songs mit-löschen.
    final song = _songs[bandId]?.where((s) => s.id == songId).firstOrNull;
    final chartFile = song?.chordChartFile;
    if (chartFile != null) {
      ChartStorage.deleteChart(chartFile);
    }
    _songs[bandId]?.removeWhere((s) => s.id == songId);
    // Orphan-Handling: Practice-Items des Songs mit-löschen (Entscheidung 05.07.2026)
    _practiceItems[bandId]?.removeWhere((p) => p.songId == songId);
    _save();
    notifyListeners();
  }

  void addSetlist(String bandId, Setlist setlist) {
    _setlists[bandId] ??= [];
    _setlists[bandId]!.add(setlist);
    _save();
    notifyListeners();
  }

  void duplicateSetlist(String bandId, Setlist source) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final dup = Setlist(
      id: timestamp.toString(),
      name: '${source.name} (Copy)',
      slots: source.slots.asMap().entries.map((e) => SongSlot(
        id: '${timestamp}_${e.key}',
        songId: e.value.songId,
        order: e.value.order,
      )).toList(),
    );
    _setlists[bandId] ??= [];
    _setlists[bandId]!.add(dup);
    _save();
    notifyListeners();
  }

  void deleteSetlist(String bandId, String setlistId) {
  _setlists[bandId]?.removeWhere((s) => s.id == setlistId);
  _save();
  notifyListeners();
  }

  void updateSetlist(String bandId, Setlist setlist) {
    final list = _setlists[bandId];
    bool changed = false;
    if (list != null) {
      final index = list.indexWhere((s) => s.id == setlist.id);
      if (index != -1) {
        list[index] = setlist;
        changed = true;
      }
    }
    // Auch in Gigs aktualisieren, wo diese Setliste vorkommt
    final gigs = _gigs[bandId];
    if (gigs != null) {
      for (final gig in gigs) {
        final sIndex = gig.setlists.indexWhere((s) => s.id == setlist.id);
        if (sIndex != -1) {
          gig.setlists[sIndex] = setlist;
          changed = true;
        }
      }
    }
    if (changed) {
      _save();
      notifyListeners();
    }
  }

  void addGig(String bandId, Gig gig) {
    _gigs[bandId] ??= [];
    _gigs[bandId]!.add(gig);
    _save();
    notifyListeners();
  }

  void deleteGig(String bandId, String gigId) {
  _gigs[bandId]?.removeWhere((g) => g.id == gigId);
  _save();
  notifyListeners();
  }

  void updateGig(String bandId, Gig gig) {
    final list = _gigs[bandId];
    if (list == null) return;
    final index = list.indexWhere((g) => g.id == gig.id);
    if (index != -1) {
      list[index] = gig;
      _save();
      notifyListeners();
    }
  }

  // Practice Items
  void addPracticeItem(String bandId, PracticeItem item) {
    _practiceItems[bandId] ??= [];
    _practiceItems[bandId]!.add(item);
    _save();
    notifyListeners();
  }

  void updatePracticeItem(String bandId, PracticeItem item) {
    final list = _practiceItems[bandId];
    if (list == null) return;
    final index = list.indexWhere((p) => p.id == item.id);
    if (index != -1) {
      list[index] = item;
      _save();
      notifyListeners();
    }
  }

  void deletePracticeItem(String bandId, String itemId) {
    _practiceItems[bandId]?.removeWhere((p) => p.id == itemId);
    _save();
    notifyListeners();
  }

  void togglePracticeItemDone(String bandId, String itemId) {
    final list = _practiceItems[bandId];
    if (list == null) return;
    final index = list.indexWhere((p) => p.id == itemId);
    if (index != -1) {
      list[index].done = !list[index].done;
      _save();
      notifyListeners();
    }
  }

  void cyclePracticeItemPriority(String bandId, String itemId) {
    final list = _practiceItems[bandId];
    if (list == null) return;
    final index = list.indexWhere((p) => p.id == itemId);
    if (index != -1) {
      final current = list[index].priority;
      final next = PracticePriority.values[
          (current.index + 1) % PracticePriority.values.length];
      list[index].priority = next;
      _save();
      notifyListeners();
    }
  }
}
