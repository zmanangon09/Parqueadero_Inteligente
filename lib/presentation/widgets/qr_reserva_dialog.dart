import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/entities/reserva_entity.dart';

/// Muestra el QR de la reserva (su id) para presentarlo en la puerta
/// al hacer check-in / check-out.
Future<void> showQrReservaDialog(BuildContext context, ReservaEntity reserva) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Tu código de acceso',
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700, color: const Color(0xFF134E4A)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: reserva.qrCode ?? reserva.id,
            size: 220,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text('Placa ${reserva.placa}',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'Muéstralo en la entrada para tu check-in y al salir para tu check-out.',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
