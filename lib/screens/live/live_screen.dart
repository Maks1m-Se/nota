import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../models/setlist.dart';
import '../../theme/app_theme.dart';
import '../../widgets/drawing_canvas.dart';

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
  LiveMode _mode = LiveMode.withSidebar;
  double _dragStart = 0;

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
              color: _mode == LiveMode.fullscreen ? AppTheme.primaryColor : AppTheme.textMuted,
            ),
            onPressed: () => setState(() => _mode = LiveMode.fullscreen),
            tooltip: 'Fullscreen',
          ),
          IconButton(
            icon: Icon(
              Icons.view_sidebar,
              color: _mode == LiveMode.withSidebar ? AppTheme.primaryColor : AppTheme.textMuted,
            ),
            onPressed: () => setState(() => _mode = LiveMode.withSidebar),
            tooltip: 'With sidebar',
          ),
          IconButton(
            icon: Icon(
              Icons.list,
              color: _mode == LiveMode.setlistOnly ? AppTheme.primaryColor : AppTheme.textMuted,
            ),
            onPressed: () => setState(() => _mode = LiveMode.setlistOnly),
            tooltip: 'Setlist only',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragStart: (details) => _dragStart = details.globalPosition.dx,
        onHorizontalDragEnd: (details) {
          final diff = details.globalPosition.dx - _dragStart;
          if (diff < -120) _next();
          if (diff > 120) _previous();
        },
        child: _mode == LiveMode.setlistOnly
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
                        width: 200,
                        child: _SetlistView(
                          setlist: widget.setlist,
                          songs: widget.songs,
                          currentIndex: _currentIndex,
                          onSongTap: (i) => setState(() => _currentIndex = i),
                          useAbbreviation: true,
                        ),
                      ),
                      const VerticalDivider(width: 1, color: AppTheme.surfaceColor),
                      Expanded(
                        child: _SongView(
                          song: _currentSong,
                          songs: widget.songs,
                          currentIndex: _currentIndex,
                          total: widget.songs.length,
                          onNext: _next,
                          onPrevious: _previous,
                          singleSongMode: widget.singleSongMode,
                          showCanvas: true,
                        ),
                      ),
                    ],
                  )
                : _SongView(
                    song: _currentSong,
                    songs: widget.songs,
                    currentIndex: _currentIndex,
                    total: widget.songs.length,
                    onNext: _next,
                    onPrevious: _previous,
                    singleSongMode: widget.singleSongMode,
                    showCanvas: true,
                  ),
      ),
    );
  }
}

class _SongView extends StatefulWidget {
  final Song song;
  final List<Song> songs;
  final int currentIndex;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool singleSongMode;
  final bool showCanvas;

  const _SongView({
    required this.song,
    required this.songs,
    required this.currentIndex,
    required this.total,
    required this.onNext,
    required this.onPrevious,
    this.singleSongMode = false,
    this.showCanvas = false,
  });

  @override
  State<_SongView> createState() => _SongViewState();
}

class _SongViewState extends State<_SongView> {
  bool _showOverlay = true;

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
    if (_showOverlay) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showOverlay = false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showOverlay = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleOverlay,
      child: Stack(
        children: [
          // Canvas füllt alles
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titel Zeile
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.song.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.song.key.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Text(
                        widget.song.key,
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (widget.song.hasSolo)
                      Container(
                        margin: const EdgeInsets.only(left: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red),
                        ),
                        child: const Text('S', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    if (widget.song.hasBacking)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Text('B', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              // Canvas
              Expanded(
                child: widget.showCanvas
                    ? FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: DrawingCanvas(
                            strokes: widget.song.strokes,
                            editable: false,
                            background: CanvasBackground.dark,
                          ),
                        ),
                      )
                    : widget.song.notes.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Text(
                              widget.song.notes,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                                height: 1.7,
                              ),
                            ),
                          )
                        : const SizedBox(),
              ),
            ],
          ),

          // Navigation Overlay
          if (!widget.singleSongMode && _showOverlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.currentIndex < widget.total - 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              widget.songs[widget.currentIndex + 1].abbreviation.isNotEmpty
                                  ? widget.songs[widget.currentIndex + 1].abbreviation
                                  : widget.songs[widget.currentIndex + 1].title,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: widget.currentIndex > 0 ? widget.onPrevious : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          child: const Text('← Back'),
                        ),
                        const Spacer(),
                        Text(
                          '${widget.currentIndex + 1} / ${widget.total}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: widget.currentIndex < widget.total - 1 ? widget.onNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                          child: const Text('Next →'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SetlistView extends StatelessWidget {
  final Setlist setlist;
  final List<Song> songs;
  final int currentIndex;
  final ValueChanged<int> onSongTap;
  final bool useAbbreviation;

  const _SetlistView({
    required this.setlist,
    required this.songs,
    required this.currentIndex,
    required this.onSongTap,
    this.useAbbreviation = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isCurrent = index == currentIndex;
        return GestureDetector(
          onTap: () => onSongTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 4),
            padding: EdgeInsets.all(isCurrent ? 10 : 8),
            decoration: BoxDecoration(
              color: isCurrent ? AppTheme.primaryColor.withValues(alpha: 0.15) : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent ? AppTheme.primaryColor : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: TextStyle(
                        color: isCurrent ? AppTheme.primaryColor : AppTheme.textMuted,
                        fontSize: isCurrent ? 13 : 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        useAbbreviation && song.abbreviation.isNotEmpty
                            ? song.abbreviation
                            : song.title,
                        style: TextStyle(
                          color: isCurrent ? AppTheme.textPrimary : AppTheme.textSecondary,
                          fontSize: isCurrent ? 16 : 13,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isCurrent) ...[
                      if (song.key.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          song.key,
                          style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                        ),
                      ],
                      if (song.hasSolo)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text('S', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      if (song.hasBacking)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text('B', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ],
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (song.key.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(song.key, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      if (song.bpm != null)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${song.bpm} BPM', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                        ),
                      if (song.hasSolo)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Text('S', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      if (song.hasBacking)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: const Text('B', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}