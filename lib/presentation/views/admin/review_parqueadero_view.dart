import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/espacio_entity.dart';
import '../../viewmodels/add_parqueadero_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/primary_button.dart';

class ReviewParqueaderoView extends StatelessWidget {
  const ReviewParqueaderoView({super.key});

  void _showRenameDialog(BuildContext context, AddParqueaderoViewModel vm, int index, int currentNum) {
    final controller = TextEditingController(text: '$currentNum');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Renombrar Espacio',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número del espacio',
            hintText: 'Ej. 10',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final newNum = int.tryParse(controller.text);
              if (newNum != null) {
                vm.renameSpace(index, newNum);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showTypeDialog(BuildContext context, AddParqueaderoViewModel vm, int index, TipoEspacio currentTipo) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tipo de Espacio',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TipoEspacio.values.map((tipo) {
            final label = switch (tipo) {
              TipoEspacio.normal => 'Normal',
              TipoEspacio.discapacitado => 'Discapacitado',
              TipoEspacio.electrico => 'Eléctrico',
            };
            return ListTile(
              title: Text(label, style: GoogleFonts.workSans()),
              leading: Radio<TipoEspacio>(
                value: tipo,
                groupValue: currentTipo,
                onChanged: (val) {
                  if (val != null) {
                    vm.updateSpaceTipo(index, val);
                  }
                  Navigator.pop(ctx);
                },
              ),
              onTap: () {
                vm.updateSpaceTipo(index, tipo);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _guardar(BuildContext context, AddParqueaderoViewModel vm) async {
    final adminId = context.read<AuthViewModel>().currentUser?.uid ?? '';
    final success = await vm.saveParqueadero(adminId);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Parqueadero guardado con éxito!'),
          backgroundColor: Color(0xFF0F766E),
        ),
      );
      // Regresa al panel
      context.go('/admin_dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddParqueaderoViewModel>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: Text(
          'Revisión y Ajuste Manual',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Resumen de datos generales
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vm.nombre,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF134E4A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: Colors.black45),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vm.direccion,
                          style: GoogleFonts.workSans(fontSize: 12, color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${vm.tarifaPorHora.toStringAsFixed(0)}/h',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0x0D000000)),
                  const SizedBox(height: 12),

                  // Fila de conteos
                  Row(
                    children: [
                      Expanded(
                        child: _MiniCountCard(
                          label: 'Capacidad',
                          value: vm.capacidadTotal,
                          color: const Color(0xFF134E4A),
                          bg: Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniCountCard(
                          label: 'Libres',
                          value: vm.espaciosDisponibles,
                          color: const Color(0xFF0F766E),
                          bg: const Color(0xFFCCFBF1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniCountCard(
                          label: 'Ocupados',
                          value: vm.espaciosOcupados,
                          color: const Color(0xFFDC2626),
                          bg: const Color(0xFFFEE2E2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Controles de ajuste de capacidad y agregar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Capacidad:',
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF134E4A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => vm.setCapacidadTotal(vm.capacidadTotal - 1),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                      Text(
                        '${vm.capacidadTotal}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => vm.setCapacidadTotal(vm.capacidadTotal + 1),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: vm.addSpace,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(
                      'Añadir espacio',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Grid de espacios
            Expanded(
              child: vm.detectedSpaces.isEmpty
                  ? Center(
                      child: Text(
                        'No hay espacios en la lista.\nAgrega uno usando el botón superior.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(color: Colors.black45),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: vm.detectedSpaces.length,
                      itemBuilder: (context, i) {
                        final space = vm.detectedSpaces[i];
                        final isLibre = space.estado == EstadoEspacio.libre;
                        final bg = isLibre ? const Color(0xFFCCFBF1) : const Color(0xFFFEE2E2);
                        final fg = isLibre ? const Color(0xFF0F766E) : const Color(0xFFDC2626);
                        
                        final icon = switch (space.tipo) {
                          TipoEspacio.normal => Icons.directions_car_rounded,
                          TipoEspacio.discapacitado => Icons.accessible_rounded,
                          TipoEspacio.electrico => Icons.electric_car_rounded,
                        };

                        return Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: fg.withAlpha(50),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => vm.toggleSpaceEstado(i),
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              children: [
                                // Número e ícono
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(icon, color: fg, size: 24),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Espacio ${space.numero}',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: fg,
                                        ),
                                      ),
                                      Text(
                                        isLibre ? 'Libre' : 'Ocupado',
                                        style: GoogleFonts.workSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: fg.withAlpha(200),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Menú de acciones
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.more_vert_rounded, size: 16, color: fg),
                                    iconSize: 16,
                                    onSelected: (action) {
                                      if (action == 'rename') {
                                        _showRenameDialog(context, vm, i, space.numero);
                                      } else if (action == 'type') {
                                        _showTypeDialog(context, vm, i, space.tipo);
                                      } else if (action == 'delete') {
                                        vm.removeSpace(i);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'rename',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_rounded, size: 16),
                                            SizedBox(width: 8),
                                            Text('Renombrar'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'type',
                                        child: Row(
                                          children: [
                                            Icon(Icons.category_rounded, size: 16),
                                            SizedBox(width: 8),
                                            Text('Tipo de Espacio'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded,
                                                size: 16, color: Colors.red.shade700),
                                            const SizedBox(width: 8),
                                            Text('Eliminar',
                                                style: TextStyle(color: Colors.red.shade700)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            if (vm.errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  vm.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Botón de guardar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(
                label: 'Guardar Parqueadero',
                isLoading: vm.isLoading,
                onPressed: () => _guardar(context, vm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCountCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color bg;

  const _MiniCountCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 10,
              color: color.withAlpha(180),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
