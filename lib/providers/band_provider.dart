import 'package:flutter/material.dart';
import '../models/band.dart';
import '../models/song.dart';
import '../models/setlist.dart';
import '../models/song_slot.dart';
import '../models/gig.dart';

class BandProvider extends ChangeNotifier {
  final List<Band> _bands = [
    Band(id: '1', name: 'PRIMEBEATS', genre: 'Rockabilly / 50s Rock\'n\'Roll'),
    Band(id: '2', name: 'Jukebox22', genre: 'Rockabilly / 50s Rock\'n\'Roll'),
    Band(id: '3', name: 'Solo', genre: ''),
  ];

  final Map<String, List<Song>> _songs = {
    '1': [
      Song(id: '1', title: 'Johnny B. Goode', artist: 'Chuck Berry', key: 'A', bpm: 130),
      Song(id: '2', title: 'Blue Suede Shoes', artist: 'Elvis Presley', key: 'C', bpm: 120),
      Song(id: '3', title: 'Rock Around the Clock', artist: 'Bill Haley', key: 'D', bpm: 175),
      Song(id: '4', title: 'Jailhouse Rock', artist: 'Elvis Presley', key: 'E', bpm: 168),
      Song(id: '5', title: 'Peggy Sue', artist: 'Buddy Holly', key: 'A', bpm: 160),
    ],
    '2': [],
    '3': [],
  };

  final Map<String, List<Setlist>> _setlists = {
    '1': [
      Setlist(
        id: '1',
        name: 'Stadtfest – Set 1',
        slots: [
          SongSlot(id: 's1', songId: '1', order: 0),
          SongSlot(id: 's2', songId: '2', order: 1),
          SongSlot(id: 's3', songId: '3', order: 2),
        ],
      ),
      Setlist(
        id: '2',
        name: 'Stadtfest – Set 2',
        slots: [
          SongSlot(id: 's4', songId: '4', order: 0),
          SongSlot(id: 's5', songId: '5', order: 1),
        ],
      ),
      Setlist(id: '3', name: 'Standard Evening', slots: []),
    ],
    '2': [],
    '3': [],
  };

  final Map<String, List<Gig>> _gigs = {
    '1': [
      Gig(
        id: '1',
        name: 'Stadtfest Musterstadt',
        venue: 'Marktplatz',
        date: DateTime(2026, 4, 19),
        setlists: [
          Setlist(id: '1', name: 'Set 1'),
          Setlist(id: '2', name: 'Set 2'),
        ],
      ),
      Gig(
        id: '2',
        name: 'Rockabilly Night',
        venue: 'Blue Moon Club',
        date: DateTime(2026, 5, 3),
        setlists: [Setlist(id: '3', name: 'Set 1')],
      ),
      Gig(
        id: '3',
        name: 'Frühlingsmarkt',
        venue: 'Rathausplatz',
        date: DateTime(2026, 3, 15),
        setlists: [],
      ),
    ],
    '2': [],
    '3': [],
  };

  // Getters
  List<Band> get bands => List.unmodifiable(_bands);

  List<Song> getSongs(String bandId) =>
      List.unmodifiable(_songs[bandId] ?? []);

  List<Setlist> getSetlists(String bandId) =>
      List.unmodifiable(_setlists[bandId] ?? []);

  List<Gig> getGigs(String bandId) =>
      List.unmodifiable(_gigs[bandId] ?? []);

  // Songs aus einer Setlist auflösen
  List<Song> getSongsForSetlist(String bandId, Setlist setlist) {
    final allSongs = _songs[bandId] ?? [];
    return setlist.slots
        .map((slot) => allSongs.firstWhere(
              (s) => s.id == slot.songId,
              orElse: () => Song(id: '', title: 'Unknown', key: ''),
            ))
        .toList();
  }

  // Bands
  void addBand(Band band) {
    _bands.add(band);
    _songs[band.id] = [];
    _setlists[band.id] = [];
    _gigs[band.id] = [];
    notifyListeners();
  }

  // Songs
  void addSong(String bandId, Song song) {
    _songs[bandId]?.add(song);
    notifyListeners();
  }

  void updateSong(String bandId, Song song) {
    final list = _songs[bandId];
    if (list == null) return;
    final index = list.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      list[index] = song;
      notifyListeners();
    }
  }

  // Setlists
  void addSetlist(String bandId, Setlist setlist) {
    _setlists[bandId]?.add(setlist);
    notifyListeners();
  }

  // Gigs
  void addGig(String bandId, Gig gig) {
    _gigs[bandId]?.add(gig);
    notifyListeners();
  }
}