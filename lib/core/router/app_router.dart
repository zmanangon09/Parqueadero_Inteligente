import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/reserva_entity.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/viewmodels/evaluar_ocupacion_viewmodel.dart';
import '../../presentation/viewmodels/historial_viewmodel.dart';
import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/pago_viewmodel.dart';
import '../../presentation/viewmodels/parqueadero_detail_viewmodel.dart';
import '../../presentation/viewmodels/perfil_viewmodel.dart';
import '../../presentation/viewmodels/qr_scan_viewmodel.dart';
import '../../presentation/viewmodels/admin_dashboard_viewmodel.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/register_view.dart';
import '../../presentation/views/historial/historial_view.dart';
import '../../presentation/views/home/home_view.dart';
import '../../presentation/views/parking/parqueadero_detail_view.dart';
import '../../presentation/views/pago/pago_view.dart';
import '../../presentation/views/perfil/perfil_view.dart';
import '../../presentation/views/admin/admin_dashboard_view.dart';
import '../../presentation/views/admin/add_parqueadero_view.dart';
import '../../presentation/views/admin/evaluar_ocupacion_view.dart';
import '../../presentation/views/admin/qr_scan_view.dart';
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
            path: '/pago/:reservaId',
            builder: (context, state) {
              final reserva = state.extra as ReservaEntity;
              return ChangeNotifierProvider<PagoViewModel>(
                create: (_) => sl<PagoViewModel>(),
                child: PagoView(reserva: reserva),
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
          GoRoute(
            path: '/historial',
            builder: (context, _) => ChangeNotifierProvider<HistorialViewModel>(
              create: (_) => sl<HistorialViewModel>(),
              child: const HistorialView(),
            ),
          ),
          GoRoute(
            path: '/perfil',
            builder: (context, _) => ChangeNotifierProvider<PerfilViewModel>(
              create: (_) => sl<PerfilViewModel>(),
              child: const PerfilView(),
            ),
          ),
          GoRoute(
            path: '/admin/scan_qr',
            builder: (context, _) => ChangeNotifierProvider<QrScanViewModel>(
              create: (_) => sl<QrScanViewModel>(),
              child: const QrScanView(),
            ),
          ),
          GoRoute(
            path: '/admin/evaluate/:id',
            builder: (context, state) =>
                ChangeNotifierProvider<EvaluarOcupacionViewModel>(
              create: (_) => sl<EvaluarOcupacionViewModel>(),
              child: EvaluarOcupacionView(
                parqueaderoId: state.pathParameters['id']!,
              ),
            ),
          ),
        ],
      );
}
