import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/lock_provider.dart';
import 'screens/auth/enter_pin_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const VeriLockApp());
}

class VeriLockApp extends StatelessWidget {
  const VeriLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LockProvider()),
      ],
      child: MaterialApp(
        title: 'VeriLock',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const EnterPinScreen(),
      ),
    );
  }
}
