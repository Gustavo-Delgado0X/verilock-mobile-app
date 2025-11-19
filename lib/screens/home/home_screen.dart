import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lock_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_card.dart';
import '../../utils/app_theme.dart';
import '../../widgets/camera_feed.dart';
import '../verification/verify_screen.dart'; // Import VerifyScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh status immediately when screen loads
    Future.microtask(() =>
        Provider.of<LockProvider>(context, listen: false).refreshStatus());
  }

  @override
  Widget build(BuildContext context) {
    final lockProvider = Provider.of<LockProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'VeriLock',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            StatusCard(
              locked: lockProvider.isLocked,
              message: lockProvider.statusMessage.isEmpty
                  ? (lockProvider.isLocked ? 'Door is LOCKED' : 'Door is UNLOCKED')
                  : lockProvider.statusMessage,
            ),
            const SizedBox(height: 16),

            // === CAMERA WIDGET ===
            const CameraFeed(),

            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      lockProvider.isLocked ? Icons.lock : Icons.lock_open,
                      size: 80,
                      color:
                      lockProvider.isLocked ? Colors.redAccent : Colors.green,
                    ),
                    const SizedBox(height: 24),
                    
                    // 1. Main Lock/Unlock Button
                    PrimaryButton(
                      label: lockProvider.isLocked ? 'Unlock Door' : 'Lock Door',
                      loading: lockProvider.isLoading,
                      onPressed: () {
                        if (lockProvider.isLocked) {
                          lockProvider.unlock();
                        } else {
                          lockProvider.lock();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 2. Key Override Button
                    OutlinedButton.icon(
                      onPressed: lockProvider.isLoading 
                          ? null 
                          : () => lockProvider.keyOverride(),
                      icon: const Icon(Icons.key),
                      label: const Text('Key Override (Auto-Relock)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryNavy,
                        side: const BorderSide(color: AppTheme.primaryNavy),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // 3. 2FA Biometric Unlock Button (THIS WAS MISSING)
                    OutlinedButton.icon(
                      onPressed: () {
                         Navigator.of(context).push(
                           MaterialPageRoute(builder: (_) => const VerifyScreen()),
                         );
                      },
                      icon: const Icon(Icons.face),
                      label: const Text('2FA Biometric Unlock'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryNavy,
                        side: const BorderSide(color: AppTheme.primaryNavy),
                      ),
                    ),

                    const SizedBox(height: 16),
                    
                    // 4. Refresh Button
                    TextButton.icon(
                      onPressed: lockProvider.isLoading
                          ? null
                          : lockProvider.refreshStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Status'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
