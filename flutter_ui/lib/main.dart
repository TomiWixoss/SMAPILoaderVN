import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/smapi_bridge_service.dart';
import 'screens/launcher_screen.dart';

void main() => runApp(const SMAPILauncherApp());

class SMAPILauncherApp extends StatelessWidget {
  const SMAPILauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LauncherState()),
      ],
      child: MaterialApp(
        title: 'SMAPI Launcher',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const LauncherScreen(),
      ),
    );
  }
}

class LauncherState extends ChangeNotifier {
  String _message = '';
  bool _isLoading = false;

  String get message => _message;
  bool get isLoading => _isLoading;

  void setMessage(String msg) {
    _message = msg;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
