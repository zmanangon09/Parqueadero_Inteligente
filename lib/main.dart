import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupDependencies();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = sl<AuthViewModel>();
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: authViewModel,
      child: _RouterApp(authViewModel: authViewModel),
    );
  }
}

class _RouterApp extends StatefulWidget {
  final AuthViewModel authViewModel;
  const _RouterApp({required this.authViewModel});

  @override
  State<_RouterApp> createState() => _RouterAppState();
}

class _RouterAppState extends State<_RouterApp> {
  late final _router = AppRouter.createRouter(widget.authViewModel);

  @override
  void initState() {
    super.initState();
    widget.authViewModel.checkSession();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Control Inteligente de Parqueaderos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      );
}
