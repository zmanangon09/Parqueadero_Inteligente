import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/parqueadero_detail_viewmodel.dart';
import '../../presentation/viewmodels/admin_dashboard_viewmodel.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/register_view.dart';
import '../../presentation/views/home/home_view.dart';
import '../../presentation/views/parking/parqueadero_detail_view.dart';
import '../../presentation/views/admin/admin_dashboard_view.dart';
import '../../presentation/views/admin/add_parqueadero_view.dart';
import '../../presentation/views/admin/scan_parqueadero_view.dart';
import '../../presentation/views/admin/review_parqueadero_view.dart';
import '../di/injection.dart';

class AppRouter {
  static GoRouter createRouter(AuthViewModel authViewModel) => GoRouter(
        initialLocation: '/login',
        refreshListenable: authViewModel,
        redirect: (context, state) {
          final isAuth = authViewModel.status == AuthStatus.authenticated;
          final onAuthRoute = state.matchedLocation == '/login' ||
              state.matchedLocation == '/register';
          
          if (!isAuth) {
            return onAuthRoute ? null : '/login';
          }
          
          final isAdmin = authViewModel.isAdmin;
          final onAdminRoute = state.matchedLocation == '/admin_dashboard' ||
              state.matchedLocation.startsWith('/admin/');
          
          if (isAdmin) {
            if (!onAdminRoute) return '/admin_dashboard';
          } else {
            if (onAdminRoute || onAuthRoute) return '/home';
          }
          
          return null;
        },
        routes: [
          GoRoute(path: '/login', builder: (ctx, s) => const LoginView()),
          GoRoute(path: '/register', builder: (ctx, s) => const RegisterView()),
          GoRoute(
            path: '/home',
            builder: (context, _) => ChangeNotifierProvider<HomeViewModel>(
              create: (_) => sl<HomeViewModel>(),
              child: const HomeView(),
            ),
          ),
          GoRoute(
            path: '/parking/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ChangeNotifierProvider<ParqueaderoDetailViewModel>(
                create: (_) => sl<ParqueaderoDetailViewModel>(),
                child: ParqueaderoDetailView(parqueaderoId: id),
              );
            },
          ),
          GoRoute(
            path: '/admin_dashboard',
            builder: (context, _) => ChangeNotifierProvider<AdminDashboardViewModel>(
              create: (_) => sl<AdminDashboardViewModel>(),
              child: const AdminDashboardView(),
            ),
          ),
          GoRoute(
            path: '/admin/add_parking',
            builder: (context, _) => const AddParqueaderoView(),
          ),
          GoRoute(
            path: '/admin/scan_parking',
            builder: (context, _) => const ScanParqueaderoView(),
          ),
          GoRoute(
            path: '/admin/review_parking',
            builder: (context, _) => const ReviewParqueaderoView(),
          ),
        ],
      );
}
