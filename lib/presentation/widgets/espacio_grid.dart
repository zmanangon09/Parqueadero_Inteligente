import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/espacio_entity.dart';

class EspacioGrid extends StatelessWidget {
  final List<EspacioEntity> espacios;
  final String? selectedId;
  final ValueChanged<EspacioEntity>? onTap;

  const EspacioGrid({
    super.key,
    required this.espacios,
    this.selectedId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (espacios.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No hay espacios registrados',
            style: GoogleFonts.workSans(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Legend(),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: espacios.length,
          itemBuilder: (context, i) => _EspacioCell(
            espacio: espacios[i],
            selected: espacios[i].id == selectedId,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _EspacioCell extends StatelessWidget {
  final EspacioEntity espacio;
  final bool selected;
  final ValueChanged<EspacioEntity>? onTap;
  const _EspacioCell({
    required this.espacio,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _colorsFor(espacio);
    final tappable = espacio.isLibre && onTap != null;

    return GestureDetector(
      onTap: tappable ? () => onTap!(espacio) : null,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: const Color(0xFF0F766E), width: 3)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 16),
            const SizedBox(height: 2),
            Text(
              '${espacio.numero}',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color bg, Color fg, IconData icon) _colorsFor(EspacioEntity e) {
    final typeIcon = switch (e.tipo) {
      TipoEspacio.discapacitado => Icons.accessible_rounded,
      TipoEspacio.electrico => Icons.electric_car_rounded,
      TipoEspacio.normal => Icons.directions_car_rounded,
    };

    return switch (e.estado) {
      EstadoEspacio.libre => (
          const Color(0xFFCCFBF1),
          const Color(0xFF0F766E),
          typeIcon,
        ),
      EstadoEspacio.ocupado => (
          const Color(0xFFFEE2E2),
          const Color(0xFFDC2626),
          typeIcon,
        ),
      EstadoEspacio.reservado => (
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
          typeIcon,
        ),
    };
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: const [
        _LegendItem(color: Color(0xFF0F766E), label: 'Libre'),
        _LegendItem(color: Color(0xFFDC2626), label: 'Ocupado'),
        _LegendItem(color: Color(0xFFD97706), label: 'Reservado'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.workSans(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
