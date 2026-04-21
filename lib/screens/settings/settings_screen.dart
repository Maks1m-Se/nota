import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../services/nextcloud_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _statusMessage;
  bool _statusSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  Future<void> _loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('nextcloud_password') ?? '';
    _passwordController.text = saved;
  }

  Future<void> _savePassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nextcloud_password', _passwordController.text.trim());
  }

  Future<void> _testConnection() async {
    await _savePassword();
    setState(() { _isLoading = true; _statusMessage = null; });
    final service = NextcloudService(_passwordController.text.trim());
    final ok = await service.testConnection();
    setState(() {
      _isLoading = false;
      _statusSuccess = ok;
      _statusMessage = ok ? 'Connection successful!' : 'Connection failed. Check password.';
    });
  }

  Future<void> _backup(String jsonData) async {
    await _savePassword();
    setState(() { _isLoading = true; _statusMessage = null; });
    final service = NextcloudService(_passwordController.text.trim());
    final ok = await service.upload(jsonData);
    setState(() {
      _isLoading = false;
      _statusSuccess = ok;
      _statusMessage = ok ? 'Backup successful!' : 'Backup failed.';
    });
  }

  Future<void> _restore(Function(String) onRestore) async {
    await _savePassword();
    setState(() { _isLoading = true; _statusMessage = null; });
    final service = NextcloudService(_passwordController.text.trim());
    final data = await service.download();
    if (data != null) {
      onRestore(data);
      setState(() {
        _isLoading = false;
        _statusSuccess = true;
        _statusMessage = 'Restore successful! Restart app to apply.';
      });
    } else {
      setState(() {
        _isLoading = false;
        _statusSuccess = false;
        _statusMessage = 'Restore failed. No backup found.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Nextcloud Section
          const Text(
            'NEXTCLOUD BACKUP',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Password',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Nextcloud App Password',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: AppTheme.textMuted,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Status message
                  if (_statusMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _statusSuccess
                            ? Colors.green.withValues(alpha: 0.15)
                            : Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _statusSuccess ? Colors.green : Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (_statusMessage != null) const SizedBox(height: 12),
                  // Buttons
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _testConnection,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                            ),
                            child: const Text('Test Connection'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              final data = prefs.getString('nota_data') ?? '{}';
                              await _backup(data);
                            },
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Backup to Nextcloud'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppTheme.surfaceColor,
                                  title: const Text('Restore Backup', style: TextStyle(color: AppTheme.textPrimary)),
                                  content: const Text(
                                    'This will overwrite all current data. Are you sure?',
                                    style: TextStyle(color: AppTheme.textSecondary),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await _restore((data) async {
                                          final prefs = await SharedPreferences.getInstance();
                                          await prefs.setString('nota_data', data);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Restore'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.cloud_download),
                            label: const Text('Restore from Nextcloud'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
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