import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screens.dart';
import 'screens/group_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    /* Session-only mode remains usable. */
  }
  runApp(SplitMateApp(state: AppState(prefs)));
}

class SplitMateApp extends StatelessWidget {
  final AppState state;
  const SplitMateApp({super.key, required this.state});
  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'SplitMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(Brightness.light),
        darkTheme: AppTheme.build(Brightness.dark),
        themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
        home: state.signedIn ? const GroupsScreen() : const AuthScreen(),
      ),
    ),
  );
}
