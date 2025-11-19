import 'package:flutter/material.dart';
import '../../utils/pin_utils.dart';
import '../../utils/app_theme.dart';
import 'create_pin_screen.dart';
import '../home/main_home_screen.dart';
import '../../widgets/pin_pad.dart'; // NEW IMPORT

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({super.key});

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  String _pin = "";
  String? _error;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkPinExists();
  }

  Future<void> _checkPinExists() async {
    final exists = await hasPin();
    if (!mounted) return;
    if (!exists) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CreatePinScreen()),
      );
    } else {
      setState(() => _checking = false);
    }
  }

  void _onPinChanged(String newPin) {
    setState(() {
      _pin = newPin;
      _error = null;
    });

    if (_pin.length == 4) {
      _submit();
    }
  }

  Future<void> _submit() async {
    // Give a small delay so the user sees the 4th dot fill
    await Future.delayed(const Duration(milliseconds: 150));

    final ok = await verifyPin(_pin);
    if (!ok) {
      setState(() {
        _error = 'Incorrect PIN';
        _pin = ""; // Clear input
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            
            // Updated Logo Display
            Container(
              height: 120, // Fixed height to look good
              width: 120,
              padding: const EdgeInsets.all(16), // Padding inside the box
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy, // Matches theme
                borderRadius: BorderRadius.circular(24), // Rounded corners (Squircle)
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              // Ensure your logo is rectangular and fits
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.contain, 
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Welcome',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your PIN to continue',
              style: TextStyle(fontSize: 16, color: Colors.white54),
            ),
            
            const SizedBox(height: 40),

            // Error Message
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
              )
            else 
              const SizedBox(height: 20), // Placeholder to prevent jump

            const Spacer(),

            // The New PIN Pad
            PinPad(
              pin: _pin,
              onChanged: _onPinChanged,
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
