import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/parqueadero_entity.dart';

class ParkingBottomSheet extends StatelessWidget {
  final ParqueaderoEntity parqueadero;
  final VoidCallback onVerDetalle;
  final VoidCallback onClose;

  const ParkingBottomSheet({
    super.key,
    required this.parqueadero,
    required this.onVerDetalle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_parking_rounded,
                    color: cs.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parqueadero.nombre,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: const Color(0xFF134E4A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      parqueadero.direccion,
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        color: const Color(0xFF134E4A).withAlpha(153),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                color: const Color(0xFF134E4A).withAlpha(102),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(
                icon: Icons.directions_car_rounded,
                label:
                    '${parqueadero.espaciosDisponibles}/${parqueadero.capacidadTotal}',
                color: parqueadero.tieneEspacios
                    ? const Color(0xFF0F766E)
                    : const Color(0xFFDC2626),
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.attach_money_rounded,
                label:
                    '\$${parqueadero.tarifaPorHora.toStringAsFixed(0)}/h',
                color: cs.tertiary,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.schedule_rounded,
                label: parqueadero.horario,
                color: const Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: parqueadero.tieneEspacios ? onVerDetalle : null,
              child: Text(
                parqueadero.tieneEspacios ? 'Ver detalle' : 'Sin espacios disponibles',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
