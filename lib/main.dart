import 'package:flutter/material.dart';
// import 'package:marketers/pages/home.dart';

// import 'package:marketers/pages/login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/pages/main_shell.dart';
import 'package:marketers/service/auth_session_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthSessionStore.restore();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainShell(),
    );
  }
}
