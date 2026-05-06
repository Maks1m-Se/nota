import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../models/setlist.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/drawing_canvas.dart';

enum LiveMode { fullscreen, withSidebar, setlistOnly }

/// Item in der flachen Live-Sequenz: entweder ein Song oder eine Pause zwischen zwei Sets.
class _LiveItem {
  final Song? song; // null = Pause
  final int setIndex;
  final String currentSetName;
  final String? nextSetName; // nur bei Pause

  bool get isPause => song == null;

  _LiveItem.song(this.song, this.setIndex, this.currentSetName) : nextSetName = null;
  _LiveItem.pause(this.setIndex, this.currentSetName, this.nextSetName) : song = null;
}

class LiveScreen extends StatefulWidget {
  final List<Setlist> sets;
  final String bandId;
  final int initialSetIndex;
  final int initialSongIndex;
  final bool singleSongMode;

  const LiveScreen({
    super.key,
    required this.sets,
    required this.bandId,
    this.initialSetIndex = 0,
    this.initialSongIndex = 0,
    this.singleSongMode = false,
  });

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  late List<_LiveItem> _items;
  late int _currentIndex;
  LiveMode _mode = LiveMode.withSidebar;
  double _dragStart = 0;
  bool _showFullscreenOverlay = false;

  void _toggleFullscreenOverlay() {
    setState(() => _showFullscreenOverlay = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showFullscreenOverlay = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _items = _buildItems();
    _currentIndex = _findInitialIndex(widget.initialSetIndex, widget.initialSongIndex);
  }

  List<_LiveItem> _buildItems() {
    final provider = context.read<BandProvider>();
    final result = <_LiveItem>[];
    for (int i = 0; i < widget.sets.length; i++) {
      final set = widget.sets[i];
      final songs = provider.getSongsForSetlist(widget.bandId, set);
      for (final song in songs) {
        result.add(_LiveItem.song(song, i, set.name));
      }
      if (i < widget.sets.length - 1) {
        result.add(_LiveItem.pause(i, set.name, widget.sets[i + 1].name));
      }
    }
    return result;
  }

  int _findInitialIndex(int setIdx, int songIdx) {
    int songCount = 0;
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (!item.isPause && item.setIndex == setIdx) {
        if (songCount == songIdx) return i;
        songCount++;
      }
    }
    return 0;
  }

  _LiveItem get _currentItem => _items[_currentIndex];
  bool get _hasMultipleSets => widget.sets.length > 1;

  String get _appBarTitle {
    if (_currentItem.isPause) return 'Pause';
    if (_hasMultipleSets) return _currentItem.currentSetName;
    return widget.sets.first.name;
  }

  void _next() {
    if (_currentIndex < _items.length - 1) {
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
      appBar: _mode == LiveMode.fullscreen ? null : AppBar(
        title: Text(_appBarTitle),
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
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_mode == LiveMode.fullscreen) {
            _toggleFullscreenOverlay();
          }
        },
        onHorizontalDragStart: (details) => _dragStart = details.globalPosition.dx,
        onHorizontalDragEnd: (details) {
          final diff = details.globalPosition.dx - _dragStart;
          if (diff < -120) _next();
          if (diff > 120) _previous();
        },
        child: Stack(
          children: [
            // Hauptinhalt
            _buildMainContent(),
            // Fullscreen Overlay
            if (_mode == LiveMode.fullscreen && _showFullscreenOverlay)
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.crop_square, color: Colors.white),
                          onPressed: () => setState(() => _mode = LiveMode.fullscreen),
                        ),
                        IconButton(
                          icon: const Icon(Icons.view_sidebar, color: Colors.white),
                          onPressed: () => setState(() => _mode = LiveMode.withSidebar),
                        ),
                        IconButton(
                          icon: const Icon(Icons.list, color: Colors.white),
                          onPressed: () => setState(() => _mode = LiveMode.setlistOnly),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_mode == LiveMode.setlistOnly) {
      return _SetlistView(
        items: _items,
        currentIndex: _currentIndex,
        onSongTap: (i) => setState(() => _currentIndex = i),
        showSetHeaders: _hasMultipleSets,
      );
    }

    final centerView = _currentItem.isPause
        ? _PauseView(
            item: _currentItem,
            nextSong: _currentIndex + 1 < _items.length
                ? _items[_currentIndex + 1].song
                : null,
          )
        : _SongView(
            onTap: () => _toggleFullscreenOverlay(),
            song: _currentItem.song!,
            items: _items,
            currentIndex: _currentIndex,
            onNext: _next,
            onPrevious: _previous,
            singleSongMode: widget.singleSongMode,
            showCanvas: true,
          );

    if (_mode == LiveMode.withSidebar) {
      return Row(
        children: [
          SizedBox(
            width: 200,
            child: _SetlistView(
              items: _items,
              currentIndex: _currentIndex,
              onSongTap: (i) => setState(() => _currentIndex = i),
              useAbbreviation: true,
              showSetHeaders: _hasMultipleSets,
            ),
          ),
          const VerticalDivider(width: 1, color: AppTheme.surfaceColor),
          Expanded(child: centerView),
        ],
      );
    }

    // Fullscreen
    return centerView;
  }
}

class _PauseView extends StatelessWidget {
  final _LiveItem item;
  final Song? nextSong;

  const _PauseView({required this.item, this.nextSong});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'PAUSE',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 96,
              fontWeight: FontWeight.w200,
              letterSpacing: 12,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 120,
            height: 1,
            color: AppTheme.textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 32),
          Text(
            'Ende — ${item.currentSetName}',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'NÄCHSTES SET',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.nextSetName ?? '',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 36,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (nextSong != null) ...[
            const SizedBox(height: 8),
            Text(
              '↳ ${nextSong!.title}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
          const SizedBox(height: 56),
          Text(
            'Swipe →',
            style: TextStyle(
              color: AppTheme.textMuted.withValues(alpha: 0.5),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SongView extends StatefulWidget {
  final Song song;
  final List<_LiveItem> items;
  final int currentIndex;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool singleSongMode;
  final bool showCanvas;
  final VoidCallback? onTap;

  const _SongView({
    required this.song,
    required this.items,
    required this.currentIndex,
    required this.onNext,
    required this.onPrevious,
    this.singleSongMode = false,
    this.showCanvas = false,
    this.onTap,
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

  int get _songCount =>
      widget.items.where((it) => !it.isPause).length;

  int get _currentSongPosition {
    int count = 0;
    for (int i = 0; i <= widget.currentIndex; i++) {
      if (!widget.items[i].isPause) count++;
    }
    return count;
  }

  /// Was kommt als nächstes auf einen Swipe? Zeigt "Pause" wenn das nächste Item eine Pause ist.
  String? get _nextHintText {
    if (widget.currentIndex >= widget.items.length - 1) return null;
    final next = widget.items[widget.currentIndex + 1];
    if (next.isPause) return 'Pause';
    final song = next.song!;
    return song.abbreviation.isNotEmpty ? song.abbreviation : song.title;
  }

  bool get _hasNext => widget.currentIndex < widget.items.length - 1;
  bool get _hasPrevious => widget.currentIndex > 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _toggleOverlay();
        widget.onTap?.call();
      },
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
                    // Titel mit fester Breite
                    SizedBox(
                      width: 400,
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
                    // Tab-Stop: Key immer an fester Position
                    SizedBox(
                      width: 80,
                      child: widget.song.key.isNotEmpty
                          ? Text(
                              widget.song.key,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    // S/B Badges
                    if (widget.song.hasSolo)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
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
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Text('B', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    // Trennlinie + Intro/Outro
                    if (widget.song.intro.isNotEmpty || widget.song.outro.isNotEmpty) ...[
                      Container(
                        width: 1,
                        height: 32,
                        color: AppTheme.textMuted,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      if (widget.song.intro.isNotEmpty)
                        Row(
                          children: [
                            const Text('↑ ', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                            Text(
                              widget.song.intro,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                            ),
                          ],
                        ),
                      if (widget.song.intro.isNotEmpty && widget.song.outro.isNotEmpty)
                        const SizedBox(width: 16),
                      if (widget.song.outro.isNotEmpty)
                        Row(
                          children: [
                            const Text('→ ', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                            Text(
                              widget.song.outro,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                            ),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
              // Canvas
              Expanded(
                child: widget.showCanvas
                    ? ClipRect(
                        child: LayoutBuilder(
                          builder: (context, constraints) => FittedBox(
                            fit: BoxFit.fill,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              child: DrawingCanvas(
                                strokes: widget.song.strokes,
                                editable: false,
                                background: widget.song.canvasBackground,
                                chordChartBase64: widget.song.chordChartBase64,
                                chordChartX: widget.song.chordChartX,
                                chordChartY: widget.song.chordChartY,
                                chordChartScale: widget.song.chordChartScale,
                              ),
                            ),
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
                    if (_nextHintText != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _nextHintText!,
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
                          onPressed: _hasPrevious ? widget.onPrevious : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          child: const Text('← Back'),
                        ),
                        const Spacer(),
                        Text(
                          '$_currentSongPosition / $_songCount',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _hasNext ? widget.onNext : null,
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
  final List<_LiveItem> items;
  final int currentIndex;
  final ValueChanged<int> onSongTap;
  final bool useAbbreviation;
  final bool showSetHeaders;

  const _SetlistView({
    required this.items,
    required this.currentIndex,
    required this.onSongTap,
    this.useAbbreviation = false,
    this.showSetHeaders = false,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    String? lastSetName;
    int songCounter = 0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.isPause) continue;

      if (showSetHeaders && item.currentSetName != lastSetName) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 8));
        widgets.add(_SetHeader(name: item.currentSetName));
        lastSetName = item.currentSetName;
      }

      songCounter++;
      widgets.add(_SongTile(
        song: item.song!,
        position: songCounter,
        isCurrent: i == currentIndex,
        onTap: () => onSongTap(i),
        useAbbreviation: useAbbreviation,
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: widgets,
    );
  }
}

class _SetHeader extends StatelessWidget {
  final String name;
  const _SetHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      child: Text(
        name.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final Song song;
  final int position;
  final bool isCurrent;
  final VoidCallback onTap;
  final bool useAbbreviation;

  const _SongTile({
    required this.song,
    required this.position,
    required this.isCurrent,
    required this.onTap,
    required this.useAbbreviation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  '$position'.padLeft(2, '0'),
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
  }
}