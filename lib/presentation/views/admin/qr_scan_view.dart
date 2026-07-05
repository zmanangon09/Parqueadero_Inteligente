import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../domain/usecases/reservas/procesar_qr_usecase.dart';
import '../../viewmodels/qr_scan_viewmodel.dart';

const _primary = Color(0xFF0F766E);

/// Escáner QR del administrador para check-in / check-out en la puerta.
class QrScanView extends StatefulWidget {
  const QrScanView({super.key});

  @override
  State<QrScanView> createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> {
  final MobileScannerController _controller = MobileScannerController();
  bool _dialogOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_dialogOpen) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    final vm = context.read<QrScanViewModel>();
    if (vm.isProcessing) return;

    _dialogOpen = true;
    await _controller.stop();
    final ok = await vm.procesarQr(raw);
    if (!mounted) return;

    await _showResultDialog(vm, ok);
    if (!mounted) return;
    vm.reset();
    _dialogOpen = false;
    await _controller.start();
  }

  Future<void> _showResultDialog(QrScanViewModel vm, bool ok) {
    final (icon, color, title, message) = switch ((ok, vm.resultado?.accion)) {
      (true, QrAccion.checkIn) => (
          Icons.login_rounded,
          _primary,
          'Check-in exitoso',
          'Placa ${vm.resultado!.reserva.placa}. ¡Bienvenido!'
        ),
      (true, QrAccion.checkOut) => (
          Icons.logout_rounded,
          const Color(0xFF0369A1),
          'Check-out exitoso',
          'Reserva completada. El espacio quedó libre.'
        ),
      (true, QrAccion.noShow) => (
          Icons.timer_off_rounded,
          const Color(0xFFD97706),
          'Reserva expirada',
          'No hubo check-in dentro de los 10 minutos. '
              'La reserva se canceló y el espacio quedó libre.'
        ),
      _ => (
          Icons.error_outline_rounded,
          const Color(0xFFDC2626),
          'QR rechazado',
          vm.errorMessage ?? 'No se pudo procesar el código.'
        ),
    };

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(icon, size: 48, color: color),
        title: Text(title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(message,
            textAlign: TextAlign.center, style: GoogleFonts.workSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Seguir escaneando'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QrScanViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text('Check-in / Check-out',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Marco guía de escaneo
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70, width: 3),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                vm.isProcessing
                    ? 'Procesando reserva...'
                    : 'Apunta al código QR de la reserva del cliente.',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
