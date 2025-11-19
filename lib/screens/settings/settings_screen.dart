import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/pin_utils.dart';
import '../../utils/app_theme.dart';
import '../auth/create_pin_screen.dart';
import 'profiles_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('custom_base_url') ?? 'http://192.168.1.100:8000';
    _urlController.text = url;
  }

  Future<void> _saveUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_base_url', _urlController.text.trim());
    if (!mounted) return;
    Navigator.pop(context); // Close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device IP Saved!')),
    );
  }

  // Shows a dialog to edit the IP (Hidden inside "Device Info")
  void _showIpConfigDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Configure Device IP', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the Raspberry Pi IP address:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'http://192.168.1.X:8000',
                hintStyle: TextStyle(color: Colors.white30),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveUrl,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPin(BuildContext context) async {
    await resetPin();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CreatePinScreen()),
          (route) => false,
    );
  }

  Future<void> _factoryReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Factory Reset?', style: TextStyle(color: Colors.white)),
        content: const Text('This will erase all app data and your PIN.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await resetPin();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CreatePinScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Unlock Phrase Card (Top)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Unlock Phrase', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('"open door"', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  ],
                ),
                Icon(Icons.edit, color: AppTheme.accentBlue),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // === NEW: Manage Profiles ===
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Profiles'),
            subtitle: const Text('View and delete enrolled users', style: TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilesScreen()),
              );
            },
          ),
          
          const Divider(),

          // 2. Change PIN
          ListTile(
            leading: const Icon(Icons.password), // Or Icons.pin
            title: const Text('Change PIN'),
            onTap: () => _resetPin(context),
          ),

          const Divider(),

          // 3. Device Info (Tap to config IP)
          ListTile(
            leading: const Icon(Icons.memory), // Chip icon
            title: const Text('Device Info'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Model: VeriLock Pi 5', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text('Firmware: v1.0.0', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text('Connection: Wi-Fi', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            onTap: _showIpConfigDialog, // Hidden feature to change IP
          ),

          const Divider(),

          // 4. Wi-Fi Setup
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Wi-Fi Setup'),
            subtitle: const Text('Reconnect or change your device\'s network', style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {
              // TODO: Navigate to WiFi Scan screen
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon')));
            },
          ),

          const Divider(),

          // 5. Factory Reset
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Factory Reset'),
            subtitle: const Text('Erase all VeriLock app data on this phone', style: TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: _factoryReset,
          ),

          const Divider(),

          // 6. About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About VeriLock'),
            subtitle: const Text('Version 1.0.0\nDeveloped by VeriLock LLC', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
