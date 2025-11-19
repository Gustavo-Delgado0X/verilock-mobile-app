import 'package:flutter/material.dart';
import '../../utils/pin_utils.dart';
import '../../widgets/pin_pad.dart'; // Import PinPad
import '../home/main_home_screen.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _pin = "";
  String? _firstPin;
  String? _error;

  bool get _isConfirming => _firstPin != null;

  void _onPinChanged(String newPin) {
    setState(() {
      _pin = newPin;
      _error = null;
    });

    // When 4 digits are entered, move to next step
    if (_pin.length == 4) {
      if (_isConfirming) {
        _confirmAndSave();
      } else {
        _moveToConfirmStep();
      }
    }
  }

  void _moveToConfirmStep() {
    // Give a small delay so user sees the 4th dot fill
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _firstPin = _pin;
        _pin = ""; // Clear for confirmation
      });
    });
  }

  Future<void> _confirmAndSave() async {
    // Give a small delay so user sees the 4th dot fill
    await Future.delayed(const Duration(milliseconds: 150));

    if (_firstPin == _pin) {
      await savePin(_pin);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainHomeScreen()),
        );
      }
    } else {
      // If PINs don't match, reset the whole process
      setState(() {
        _error = 'PINs do not match. Please try again.';
        _firstPin = null;
        _pin = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            
            // Icon
            const Icon(Icons.security, size: 50, color: Colors.white),
            const SizedBox(height: 32),

            // Title
            Text(
              _isConfirming ? 'Confirm your PIN' : 'Create a PIN',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            const Text(
              'This will be used to unlock the app.',
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
              const SizedBox(height: 20), // Placeholder

            const Spacer(),

            // The PIN Pad
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
