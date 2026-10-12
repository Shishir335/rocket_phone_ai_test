import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/contacts/presentation/screens/contacts_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDependencies();
  runApp(const ProviderScope(child: ContactsApp()));
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts Search',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ContactsScreen(),
    );
  }
}
