import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

class PinPad extends StatelessWidget {
  final String pin;
  final int pinLength;
  final ValueChanged<String> onChanged;
  final bool isConfirming;

  const PinPad({
    super.key,
    required this.pin,
    required this.onChanged,
    this.pinLength = 4,
    this.isConfirming = false,
  });

  void _onNumberPress(String number) {
    if (pin.length < pinLength) {
      HapticFeedback.lightImpact();
      onChanged(pin + number);
    }
  }

  void _onBackspace() {
    if (pin.isNotEmpty) {
      HapticFeedback.lightImpact();
      onChanged(pin.substring(0, pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // PIN Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pinLength, (index) {
            final isFilled = index < pin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppTheme.accentBlue : Colors.white24,
                border: isFilled
                    ? null
                    : Border.all(color: Colors.white54, width: 1.5),
              ),
            );
          }),
        ),
        const SizedBox(height: 60),

        // Numeric Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 30,
            ),
            itemBuilder: (context, index) {
              if (index == 9) return const SizedBox(); // Empty bottom-left
              if (index == 11) {
                // Backspace Button
                return InkWell(
                  onTap: _onBackspace,
                  borderRadius: BorderRadius.circular(40),
                  child: const Icon(Icons.backspace_outlined, color: Colors.white70, size: 28),
                );
              }
              
              // Number Buttons (0 is at index 10)
              final number = index == 10 ? '0' : '${index + 1}';
              return _NumberButton(
                number: number,
                onTap: () => _onNumberPress(number),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String number;
  final VoidCallback onTap;

  const _NumberButton({required this.number, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
