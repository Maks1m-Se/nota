import 'package:flutter/material.dart';
import '../../models/band.dart';
import '../../theme/app_theme.dart';
import '../library/library_screen.dart';
import '../setlists/setlists_screen.dart';
import '../gigs/gigs_screen.dart';

class BandScaffold extends StatefulWidget {
  final Band band;

  const BandScaffold({super.key, required this.band});

  @override
  State<BandScaffold> createState() => _BandScaffoldState();
}

class _BandScaffoldState extends State<BandScaffold> {
  int _selectedIndex = 0;
  bool _sidebarOpen = true;

  final _navigatorKey = GlobalKey<NavigatorState>();

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.library_music, label: 'Library'),
    _NavItem(icon: Icons.list, label: 'Setlists'),
    _NavItem(icon: Icons.calendar_today, label: 'Gigs'),
  ];

  void _onNavTap(int index) {
    if (index == _selectedIndex) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _selectedIndex = index);
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return LibraryScreen(bandId: widget.band.id);
      case 1:
        return SetlistsScreen(bandId: widget.band.id);
      case 2:
        return GigsScreen(bandId: widget.band.id);
      default:
        return LibraryScreen(bandId: widget.band.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _sidebarOpen ? 200 : 0,
            child: _sidebarOpen
                ? _Sidebar(
                    band: widget.band,
                    items: _navItems,
                    selectedIndex: _selectedIndex,
                    onItemTap: _onNavTap,
                    onClose: () => setState(() => _sidebarOpen = false),
                  )
                : const SizedBox.shrink(),
          ),

          // Main content mit eigenem Navigator
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 56,
                  color: AppTheme.surfaceColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
                        onPressed: () =>
                            setState(() => _sidebarOpen = !_sidebarOpen),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _navItems[_selectedIndex].label,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.surfaceColor),
                // Eigener Navigator für den rechten Bereich
                Expanded(
                  child: Navigator(
                    key: _navigatorKey,
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        builder: (context) => _buildScreen(_selectedIndex),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final Band band;
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  final VoidCallback onClose;

  const _Sidebar({
    required this.band,
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Band header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    band.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    band.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: AppTheme.textMuted, size: 20),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.backgroundColor),
          const SizedBox(height: 8),
          // Nav items
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isSelected = i == selectedIndex;
            return GestureDetector(
              onTap: () => onItemTap(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}