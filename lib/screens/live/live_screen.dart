import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../models/setlist.dart';
import '../../theme/app_theme.dart';

enum LiveMode { fullscreen, withSidebar, setlistOnly }

class LiveScreen extends StatefulWidget {
  final Setlist setlist;
  final List<Song> songs;
  final int initialIndex;
  final bool singleSongMode;

  const LiveScreen({
    super.key,
    required this.setlist,
    required this.songs,
    this.initialIndex = 0,
    this.singleSongMode = false,
  });

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  late int _currentIndex;
  LiveMode _mode = LiveMode.fullscreen;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Song get _currentSong => widget.songs[_currentIndex];

  void _next() {
    if (_currentIndex < widget.songs.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.setlist.name),
        actions: [
          IconButton(
            icon: Icon(
              Icons.crop_square,
              color: _mode == LiveMode.fullscreen
                  ? AppTheme.primaryColor
                  : AppTheme.textMuted,
            ),
            onPressed: () => setState(() => _mode = LiveMode.fullscreen),
            tooltip: 'Fullscreen',
          ),
          IconButton(
            icon: Icon(
              Icons.view_sidebar,
              color: _mode == LiveMode.withSidebar
                  ? AppTheme.primaryColor
                  : AppTheme.textMuted,
            ),
            onPressed: () => setState(() => _mode = LiveMode.withSidebar),
            tooltip: 'With sidebar',
          ),
          IconButton(
            icon: Icon(
              Icons.list,
              color: _mode == LiveMode.setlistOnly
                  ? AppTheme.primaryColor
                  : AppTheme.textMuted,
            ),
            onPressed: () => setState(() => _mode = LiveMode.setlistOnly),
            tooltip: 'Setlist only',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _mode == LiveMode.setlistOnly
          ? _SetlistView(
              setlist: widget.setlist,
              songs: widget.songs,
              currentIndex: _currentIndex,
              onSongTap: (i) => setState(() => _currentIndex = i),
            )
          : _mode == LiveMode.withSidebar
              ? Row(
                  children: [
                    SizedBox(
                      width: 220,
                      child: _SetlistView(
                        setlist: widget.setlist,
                        songs: widget.songs,
                        currentIndex: _currentIndex,
                        onSongTap: (i) => setState(() => _currentIndex = i),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: AppTheme.surfaceColor),
                    Expanded(
                      child: _SongView(
                        song: _currentSong,
                        currentIndex: _currentIndex,
                        total: widget.songs.length,
                        onNext: _next,
                        onPrevious: _previous,
                        singleSongMode: widget.singleSongMode,  // ← hinzufügen
                      ),
                    ),
                  ],
                )
              : _SongView(
                  song: _currentSong,
                  currentIndex: _currentIndex,
                  total: widget.songs.length,
                  onNext: _next,
                  onPrevious: _previous,
                  singleSongMode: widget.singleSongMode,  // ← hinzufügen
                ),
    );
  }
}

class _SongView extends StatelessWidget {
  final Song song;
  final int currentIndex;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool singleSongMode;

  const _SongView({
    required this.song,
    required this.currentIndex,
    required this.total,
    required this.onNext,
    required this.onPrevious,
    this.singleSongMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fortschrittsbalken
        LinearProgressIndicator(
          value: total > 1 ? currentIndex / (total - 1) : 1,
          backgroundColor: AppTheme.surfaceColor,
          valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
          minHeight: 3,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (song.key.isNotEmpty)
                      _LiveBadge(label: song.key),
                    if (song.bpm != null) ...[
                      const SizedBox(width: 8),
                      _LiveBadge(label: '${song.bpm} BPM'),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                if (song.notes.isNotEmpty)
                  Text(
                    song.notes,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Navigation
        if (!singleSongMode)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: currentIndex > 0 ? onPrevious : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.textMuted),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text('← Back'),
                ),
                const Spacer(),
                Text(
                  '${currentIndex + 1} / $total',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: currentIndex < total - 1 ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: const Text('Next →'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SetlistView extends StatelessWidget {
  final Setlist setlist;
  final List<Song> songs;
  final int currentIndex;
  final ValueChanged<int> onSongTap;

  const _SetlistView({
    required this.setlist,
    required this.songs,
    required this.currentIndex,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isCurrent = index == currentIndex;
        return GestureDetector(
          onTap: () => onSongTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent ? AppTheme.primaryColor.withValues(alpha: 0.15) : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent ? AppTheme.primaryColor : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: TextStyle(
                    color: isCurrent ? AppTheme.primaryColor : AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: TextStyle(
                          color: isCurrent ? AppTheme.textPrimary : AppTheme.textSecondary,
                          fontSize: isCurrent ? 15 : 13,
                          fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      if (isCurrent && song.key.isNotEmpty)
                        Text(
                          song.key,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final String label;

  const _LiveBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}