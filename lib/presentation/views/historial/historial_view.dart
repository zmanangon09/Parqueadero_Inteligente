import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/reserva_entity.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/historial_viewmodel.dart';
import '../../widgets/qr_reserva_dialog.dart';

const _primary = Color(0xFF0F766E);
const _dark = Color(0xFF134E4A);

class HistorialView extends StatefulWidget {
  const HistorialView({super.key});

  @override
  State<HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<HistorialView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthViewModel>().currentUser?.uid;
      if (uid != null) context.read<HistorialViewModel>().init(uid);
    });
  }

  Future<void> _cancelar(ReservaEntity reserva) async {
    final vm = context.read<HistorialViewModel>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancelar reserva',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Text('¿Cancelar esta reserva y liberar el espacio?',
            style: GoogleFonts.workSans()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sí, cancelar')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final error = await vm.cancelar(reserva);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error), backgroundColor: const Color(0xFFDC2626)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistorialViewModel>();
    final uid = context.read<AuthViewModel>().currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text('Mis reservas',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(vm.errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(color: _dark)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    if (uid != null) await vm.init(uid);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _SectionTitle('Activas (${vm.activas.length})'),
                      if (vm.activas.isEmpty)
                        const _EmptyText('No tienes reservas activas.'),
                      ...vm.activas.map((r) => _ReservaCard(
                            reserva: r,
                            parkingName:
                                vm.parkingNames[r.parqueaderoId] ?? 'Parqueadero',
                            onVerQr: () => showQrReservaDialog(context, r),
                            onPagar: () =>
                                context.push('/pago/${r.id}', extra: r),
                            onCancelar: () => _cancelar(r),
                          )),
                      const SizedBox(height: 20),
                      _SectionTitle('Pasadas (${vm.pasadas.length})'),
                      if (vm.pasadas.isEmpty)
                        const _EmptyText('Aún no tienes reservas pasadas.'),
                      ...vm.pasadas.map((r) => _ReservaCard(
                            reserva: r,
                            parkingName:
                                vm.parkingNames[r.parqueaderoId] ?? 'Parqueadero',
                          )),
                    ],
                  ),
                ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w700, color: _dark)),
      );
}

class _EmptyText extends StatelessWidget {
  final String text;
  const _EmptyText(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(text,
            style:
                GoogleFonts.workSans(color: Colors.black38, fontSize: 14)),
      );
}

class _ReservaCard extends StatelessWidget {
  final ReservaEntity reserva;
  final String parkingName;
  final VoidCallback? onVerQr;
  final VoidCallback? onPagar;
  final VoidCallback? onCancelar;

  const _ReservaCard({
    required this.reserva,
    required this.parkingName,
    this.onVerQr,
    this.onPagar,
    this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final (statusText, statusColor, statusBg) = switch (reserva.estado) {
      EstadoReserva.pendiente => (
          'Pendiente de pago',
          const Color(0xFFD97706),
          const Color(0xFFFEF3C7)
        ),
      EstadoReserva.activa => (
          reserva.checkInRealizado ? 'En curso' : 'Activa',
          _primary,
          const Color(0xFFCCFBF1)
        ),
      EstadoReserva.completada => (
          'Completada',
          const Color(0xFF0369A1),
          const Color(0xFFE0F2FE)
        ),
      EstadoReserva.cancelada => (
          'Cancelada',
          const Color(0xFFDC2626),
          const Color(0xFFFEE2E2)
        ),
    };

    final f = reserva.fechaInicio;
    final fecha =
        '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year} '
        '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(parkingName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: _dark)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(statusText,
                      style: GoogleFonts.workSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Placa ${reserva.placa} · $fecha',
                style:
                    GoogleFonts.workSans(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${reserva.montoTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _dark)),
                Row(
                  children: [
                    if (onCancelar != null &&
                        reserva.estado == EstadoReserva.pendiente)
                      TextButton(
                        onPressed: onCancelar,
                        child: const Text('Cancelar',
                            style: TextStyle(color: Color(0xFFDC2626))),
                      ),
                    if (onPagar != null &&
                        reserva.estado == EstadoReserva.pendiente)
                      TextButton.icon(
                        onPressed: onPagar,
                        icon: const Icon(Icons.payment_rounded, size: 18),
                        label: const Text('Pagar'),
                      ),
                    if (onVerQr != null &&
                        reserva.estado == EstadoReserva.activa)
                      TextButton.icon(
                        onPressed: onVerQr,
                        icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                        label: const Text('Ver QR'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
