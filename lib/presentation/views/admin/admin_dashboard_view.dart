import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/reserva_entity.dart';
import '../../viewmodels/admin_dashboard_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardViewModel>().init();
    });
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authVm) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cerrar sesión',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Text('¿Deseas cerrar la sesión de administrador?',
            style: GoogleFonts.workSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              authVm.logout();
            },
            child: Text('Cerrar sesión',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLiberar(
    BuildContext context,
    AdminDashboardViewModel vm,
    String id,
    String nombre,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Liberar espacios',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Text(
          '¿Liberar todos los espacios de "$nombre" y cancelar sus reservas activas?',
          style: GoogleFonts.workSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Liberar'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    final error = await vm.liberarEspacios(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Espacios liberados.'),
        backgroundColor:
            error == null ? const Color(0xFF0F766E) : const Color(0xFFDC2626),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Panel de Administración',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(context, authVm),
          ),
        ],
      ),
      body: Consumer<AdminDashboardViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 64, color: Color(0xFFDC2626)),
                    const SizedBox(height: 16),
                    Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                          fontSize: 16, color: const Color(0xFF134E4A)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: vm.refresh,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de bienvenida
                  Text(
                    '¡Hola, Administrador!',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF134E4A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aquí tienes el resumen del sistema hoy.',
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fila de Estadísticas
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Usuarios',
                          value: '${vm.totalUsers}',
                          icon: Icons.people_rounded,
                          color: const Color(0xFF0F766E),
                          bg: const Color(0xFFCCFBF1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Parqueaderos',
                          value: '${vm.totalParkings}',
                          icon: Icons.local_parking_rounded,
                          color: const Color(0xFF0369A1),
                          bg: const Color(0xFFE0F2FE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botón registrar parqueadero
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: cs.primary.withAlpha(25),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => context.push('/admin/add_parking'),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cs.primary.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_location_alt_rounded,
                                  color: cs.primary, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nuevo Parqueadero',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: const Color(0xFF134E4A),
                                    ),
                                  ),
                                  Text(
                                    'Registrar usando visión artificial',
                                    style: GoogleFonts.workSans(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: cs.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Parqueaderos — liberar espacios
                  Text(
                    'Parqueaderos',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: const Color(0xFF134E4A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (vm.parkingNames.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No hay parqueaderos registrados.',
                        style: GoogleFonts.workSans(
                            color: Colors.black38, fontSize: 14),
                      ),
                    )
                  else
                    ...vm.parkingNames.entries.map(
                      (e) => _ParkingLiberarItem(
                        parkingName: e.value,
                        onLiberar: () =>
                            _confirmLiberar(context, vm, e.key, e.value),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Historial de reservas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historial de Reservas',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: const Color(0xFF134E4A),
                        ),
                      ),
                      Text(
                        '(${vm.reservas.length})',
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (vm.reservas.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No hay reservas registradas en el sistema.',
                          style: GoogleFonts.workSans(
                              color: Colors.black38, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.reservas.length,
                      itemBuilder: (context, index) {
                        final res = vm.reservas[index];
                        final user = vm.userNames[res.usuarioId] ?? 'Cargando...';
                        final parking = vm.parkingNames[res.parqueaderoId] ?? 'Cargando...';
                        return _ReservaItem(
                          reserva: res,
                          userName: user,
                          parkingName: parking,
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ParkingLiberarItem extends StatelessWidget {
  final String parkingName;
  final VoidCallback onLiberar;

  const _ParkingLiberarItem({
    required this.parkingName,
    required this.onLiberar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
        child: Row(
          children: [
            const Icon(Icons.local_parking_rounded,
                size: 20, color: Color(0xFF0F766E)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                parkingName,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF134E4A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: onLiberar,
              icon: const Icon(Icons.lock_open_rounded, size: 18),
              label: const Text('Liberar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservaItem extends StatelessWidget {
  final ReservaEntity reserva;
  final String userName;
  final String parkingName;

  const _ReservaItem({
    required this.reserva,
    required this.userName,
    required this.parkingName,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (reserva.estado) {
      EstadoReserva.pendiente => const Color(0xFFD97706),
      EstadoReserva.activa => const Color(0xFF0F766E),
      EstadoReserva.completada => const Color(0xFF0369A1),
      EstadoReserva.cancelada => const Color(0xFFDC2626),
    };

    final statusBg = switch (reserva.estado) {
      EstadoReserva.pendiente => const Color(0xFFFEF3C7),
      EstadoReserva.activa => const Color(0xFFCCFBF1),
      EstadoReserva.completada => const Color(0xFFE0F2FE),
      EstadoReserva.cancelada => const Color(0xFFFEE2E2),
    };

    final statusText = switch (reserva.estado) {
      EstadoReserva.pendiente => 'Pendiente',
      EstadoReserva.activa => 'Activa',
      EstadoReserva.completada => 'Completada',
      EstadoReserva.cancelada => 'Cancelada',
    };

    final formattedDate =
        '${reserva.fechaInicio.day}/${reserva.fechaInicio.month} ${reserva.fechaInicio.hour.toString().padLeft(2, '0')}:${reserva.fechaInicio.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    parkingName,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: const Color(0xFF134E4A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.workSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    size: 14, color: Colors.black45),
                const SizedBox(width: 4),
                Text(
                  userName,
                  style: GoogleFonts.workSans(
                      fontSize: 13, color: Colors.black87),
                ),
                const Spacer(),
                Text(
                  'Placa: ${reserva.placa}',
                  style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0x0D000000)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.workSans(
                      fontSize: 11, color: Colors.black45),
                ),
                Text(
                  '\$${reserva.montoTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF134E4A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
