import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../viewmodels/case_viewmodel.dart';
import '../services/sync_service.dart';
import '../theme/legal_theme.dart';
import '../widgets/neumorphic.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int _dayBeforeHour = 9;
  int _dayOfHour = 8;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dayBeforeHour = prefs.getInt('dayBeforeHour') ?? 9;
      _dayOfHour = prefs.getInt('dayOfHour') ?? 8;
    });
  }

  Future<void> _saveDayBeforeTime(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dayBeforeHour', hour);
    setState(() => _dayBeforeHour = hour);
    if (mounted) {
      context.read<CaseViewModel>().setReminderTimes(dayBefore: _dayBeforeHour, dayOf: _dayOfHour);
    }
  }

  Future<void> _saveDayOfTime(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dayOfHour', hour);
    setState(() => _dayOfHour = hour);
    if (mounted) {
      context.read<CaseViewModel>().setReminderTimes(dayBefore: _dayBeforeHour, dayOf: _dayOfHour);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CaseViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          const NeuSectionTitle(title: 'Reminder Times'),
          NeuContainer(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.alarm_rounded, color: LegalColors.gold),
                  title: const Text('Day-Before Reminder'),
                  trailing: Text(
                    '${_dayBeforeHour.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: LegalColors.textPrimary),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: _dayBeforeHour, minute: 0),
                    );
                    if (picked != null) _saveDayBeforeTime(picked.hour);
                  },
                ),
                const Divider(height: 1, color: LegalColors.borderLight),
                ListTile(
                  leading: const Icon(Icons.alarm_on_rounded, color: LegalColors.gold),
                  title: const Text('Day-Of Check-In'),
                  trailing: Text(
                    '${_dayOfHour.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: LegalColors.textPrimary),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: _dayOfHour, minute: 0),
                    );
                    if (picked != null) _saveDayOfTime(picked.hour);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const NeuSectionTitle(title: 'Cloud Backup'),
          NeuContainer(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                ListTile(
                  leading: _buildSyncStatusIcon(vm.syncStatus),
                  title: const Text('Sync Status'),
                  subtitle: Text(_getSyncStatusText(vm.syncStatus)),
                  trailing: vm.syncStatus == SyncStatus.syncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: LegalColors.blue),
                        )
                      : null,
                ),
                if (vm.lastSyncedAt != null) ...[
                  const Divider(height: 1, color: LegalColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.access_time_rounded, color: LegalColors.textMuted),
                    title: const Text('Last Synced'),
                    trailing: Text(
                      _formatDateTime(vm.lastSyncedAt!),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                if (vm.syncError != null) ...[
                  const Divider(height: 1, color: LegalColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                    title: const Text('Last Error'),
                    subtitle: Text(vm.syncError!, style: const TextStyle(color: Colors.redAccent)),
                    trailing: TextButton(
                      onPressed: () => vm.refresh(),
                      child: const Text('Retry', style: TextStyle(color: LegalColors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
                const Divider(height: 1, color: LegalColors.borderLight),
                ListTile(
                  leading: Icon(vm.isSignedIn ? Icons.logout_rounded : Icons.login_rounded, color: LegalColors.teal),
                  title: Text(vm.isSignedIn ? 'Sign Out' : 'Sign In (Anonymous)'),
                  onTap: () async {
                    if (vm.isSignedIn) {
                      await vm.signOut();
                    } else {
                      await vm.signInAnonymously();
                    }
                  },
                ),
                const Divider(height: 1, color: LegalColors.borderLight),
                ListTile(
                  leading: const Icon(Icons.sync_rounded, color: LegalColors.textMuted),
                  title: const Text('Manual Sync'),
                  subtitle: const Text('Force sync with cloud'),
                  trailing: vm.syncStatus == SyncStatus.syncing
                      ? null
                      : TextButton(
                          onPressed: () => vm.refresh(),
                          child: const Text('Sync Now', style: TextStyle(color: LegalColors.blue, fontWeight: FontWeight.bold)),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const NeuSectionTitle(title: 'About'),
          NeuContainer(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: LegalColors.textMuted),
                  title: Text('Version'),
                  trailing: Text('1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Divider(height: 1, color: LegalColors.borderLight),
                ListTile(
                  leading: Icon(Icons.apps_rounded, color: LegalColors.textMuted),
                  title: Text('App Name'),
                  trailing: Text('CaseTrack', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done_rounded, color: LegalColors.emerald);
      case SyncStatus.syncing:
        return const Icon(Icons.sync_rounded, color: LegalColors.blue);
      case SyncStatus.offline:
        return const Icon(Icons.cloud_off_rounded, color: LegalColors.amber);
      case SyncStatus.error:
        return const Icon(Icons.cloud_off_rounded, color: Colors.redAccent);
    }
  }

  String _getSyncStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'All changes synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.offline:
        return 'Offline (local only)';
      case SyncStatus.error:
        return 'Sync error';
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}