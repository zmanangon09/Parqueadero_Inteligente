import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/register_view.dart';

// Placeholder reemplazado en Módulo 2
class _PlaceholderHomeView extends StatelessWidget {
  const _PlaceholderHomeView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, ${vm.currentUser?.nombre ?? ""}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<AuthViewModel>().logout(),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppRouter {
  static GoRouter createRouter(AuthViewModel authViewModel) => GoRouter(
        initialLocation: '/login',
        refreshListenable: authViewModel,
        redirect: (context, state) {
          final isAuth = authViewModel.status == AuthStatus.authenticated;
          final onAuthRoute = state.matchedLocation == '/login' ||
              state.matchedLocation == '/register';
          if (!isAuth && !onAuthRoute) return '/login';
          if (isAuth && onAuthRoute) return '/home';
          return null;
        },
        routes: [
          GoRoute(path: '/login', builder: (_, __) => const LoginView()),
          GoRoute(path: '/register', builder: (_, __) => const RegisterView()),
          GoRoute(path: '/home', builder: (_, __) => const _PlaceholderHomeView()),
        ],
      );
}
