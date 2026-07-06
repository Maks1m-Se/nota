import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/band.dart';
import '../../models/practice_item.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import 'band_scaffold.dart';
import '../settings/settings_screen.dart';

class BandListScreen extends StatelessWidget {
  const BandListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BandProvider>();
    final bands = provider.bands;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bands'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.textMuted),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget-Zone: Gig links, Practice rechts, gleiche Höhe
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _GigWidget()),
                  SizedBox(width: 12),
                  Expanded(child: _PracticeWidget()),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('BANDS',
                style: TextStyle(
                    color: AppTheme.textMuted, fontSize: 11, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
              children: bands.map((band) => _BandCard(band: band)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gemeinsamer Rahmen für die Dashboard-Widgets.
class _DashboardCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;

  const _DashboardCard({required this.child, this.onTap, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: borderColor != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor!),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class _GigWidget extends StatelessWidget {
  const _GigWidget();

  static const _months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BandProvider>();
    final today = provider.todayGig();
    final entry = today ?? provider.nextUpcomingGig();
    final isToday = today != null;

    if (entry == null) {
      return const _DashboardCard(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: AppTheme.textMuted, size: 24),
              SizedBox(height: 8),
              Text('Keine anstehenden Gigs',
                  style: TextStyle(color: AppTheme.textMuted)),
            ],
          ),
        ),
      );
    }

    final gig = entry.gig;
    final band = provider.bands.where((b) => b.id == entry.bandId).firstOrNull;
    final date = gig.date!;

    String label;
    if (isToday) {
      label = 'HEUTE';
    } else {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final days =
          DateTime(date.year, date.month, date.day).difference(todayDate).inDays;
      label = days == 1 ? 'IN 1 TAG' : 'IN $days TAGEN';
    }

    // Detail-Zeile: heute Venue + Zeit, sonst Venue + Datum
    final details = [
      if (gig.venue.isNotEmpty) gig.venue,
      if (isToday && gig.time.isNotEmpty) gig.time,
      if (!isToday) '${date.day}. ${_months[date.month - 1]}',
    ].join(' · ');

    return _DashboardCard(
      borderColor: isToday
          ? AppTheme.primaryColor.withValues(alpha: 0.6)
          : null,
      onTap: band == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BandScaffold(band: band, initialGig: gig),
                ),
              );
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isToday
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (band != null)
            Text(band.name,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 2),
          Text(
            gig.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: isToday ? 20 : 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(details,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

class _PracticeWidget extends StatelessWidget {
  const _PracticeWidget();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BandProvider>();
    final open = provider.allPracticeItems
        .where((e) => !e.item.done)
        .toList()
      ..sort((a, b) {
        final byPrio = a.item.priority.index.compareTo(b.item.priority.index);
        if (byPrio != 0) return byPrio;
        return b.item.createdAt.compareTo(a.item.createdAt);
      });
    final top5 = open.take(5).toList();

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center,
                  color: AppTheme.practiceColor, size: 16),
              const SizedBox(width: 8),
              const Text('Practice',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              if (open.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.practiceColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color:
                            AppTheme.practiceColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '${open.length}',
                    style: const TextStyle(
                      color: AppTheme.practiceColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if (top5.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Nichts zu üben',
                    style: TextStyle(color: AppTheme.textMuted)),
              ),
            )
          else ...[
            const SizedBox(height: 8),
            ...top5.map((e) => _PracticeDashboardRow(entry: e)),
          ],
        ],
      ),
    );
  }
}

class _PracticeDashboardRow extends StatelessWidget {
  final ({String bandId, PracticeItem item}) entry;

  const _PracticeDashboardRow({required this.entry});

  String _prioLabel() {
    switch (entry.item.priority) {
      case PracticePriority.high: return 'H';
      case PracticePriority.medium: return 'M';
      case PracticePriority.low: return 'N';
    }
  }

  Color _prioColor() {
    switch (entry.item.priority) {
      case PracticePriority.high: return AppTheme.practiceColor;
      case PracticePriority.medium: return AppTheme.textSecondary;
      case PracticePriority.low: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BandProvider>();
    final band = provider.bands.where((b) => b.id == entry.bandId).firstOrNull;
    final prioColor = _prioColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: entry.item.done,
              onChanged: (_) => context
                  .read<BandProvider>()
                  .togglePracticeItemDone(entry.bandId, entry.item.id),
              activeColor: AppTheme.practiceColor,
              checkColor: Colors.black,
              side: const BorderSide(color: AppTheme.textSecondary),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          // Tap auf den Text → Practice-Tab der Band
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: band == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BandScaffold(band: band, initialIndex: 3),
                        ),
                      );
                    },
              child: Text(
                entry.item.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (band != null)
            Container(
              constraints: const BoxConstraints(maxWidth: 90),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: AppTheme.textMuted.withValues(alpha: 0.4)),
              ),
              child: Text(
                band.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 10),
              ),
            ),
          const SizedBox(width: 6),
          Container(
            width: 20,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: prioColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: prioColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              _prioLabel(),
              style: TextStyle(
                color: prioColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BandCard extends StatelessWidget {
  final Band band;

  const _BandCard({required this.band});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BandScaffold(band: band),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  band.name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      band.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (band.genre.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        band.genre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
