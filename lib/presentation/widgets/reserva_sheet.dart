import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/espacio_entity.dart';
import '../../domain/entities/parqueadero_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../viewmodels/reserva_viewmodel.dart';

const _primary = Color(0xFF0F766E);
const _dark = Color(0xFF134E4A);

/// Muestra el bottom sheet de reserva. Devuelve `true` si la reserva se creó.
Future<bool?> showReservaSheet(
  BuildContext context, {
  required EspacioEntity espacio,
  required ParqueaderoEntity parqueadero,
  required UserEntity usuario,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ChangeNotifierProvider<ReservaViewModel>(
      create: (_) => sl<ReservaViewModel>(),
      child: _ReservaSheetContent(
        espacio: espacio,
        parqueadero: parqueadero,
        usuario: usuario,
      ),
    ),
  );
}

class _ReservaSheetContent extends StatefulWidget {
  final EspacioEntity espacio;
  final ParqueaderoEntity parqueadero;
  final UserEntity usuario;

  const _ReservaSheetContent({
    required this.espacio,
    required this.parqueadero,
    required this.usuario,
  });

  @override
  State<_ReservaSheetContent> createState() => _ReservaSheetContentState();
}

class _ReservaSheetContentState extends State<_ReservaSheetContent> {
  static const _duraciones = [1, 2, 3, 4];

  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();

  String? _placaSeleccionada;
  int _duracionHoras = 1;

  bool get _tieneVehiculos => widget.usuario.vehiculos.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_tieneVehiculos) {
      _placaSeleccionada = widget.usuario.vehiculos.first;
    }
  }

  @override
  void dispose() {
    _placaController.dispose();
    super.dispose();
  }

  double get _monto => _duracionHoras * widget.parqueadero.tarifaPorHora;

  Future<void> _confirmar(ReservaViewModel vm) async {
    final placa = _tieneVehiculos
        ? (_placaSeleccionada ?? '')
        : _placaController.text.trim();

    if (!_tieneVehiculos && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final ok = await vm.reservar(
      usuarioId: widget.usuario.uid,
      espacioId: widget.espacio.id,
      parqueaderoId: widget.parqueadero.id,
      placa: placa,
      duracionHoras: _duracionHoras,
      tarifaPorHora: widget.parqueadero.tarifaPorHora,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'No se pudo crear la reserva.'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReservaViewModel>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reservar espacio ${widget.espacio.numero}',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
            const SizedBox(height: 20),
            Text('Placa del vehículo',
                style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600, color: _dark)),
            const SizedBox(height: 8),
            if (_tieneVehiculos)
              _PlacaDropdown(
                vehiculos: widget.usuario.vehiculos,
                value: _placaSeleccionada,
                onChanged: (v) => setState(() => _placaSeleccionada = v),
              )
            else
              TextFormField(
                controller: _placaController,
                textCapitalization: TextCapitalization.characters,
                validator: Validators.placa,
                decoration: const InputDecoration(
                  hintText: 'Ej. PBA1234',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 20),
            Text('Duración',
                style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600, color: _dark)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _duraciones.map((h) {
                final selected = h == _duracionHoras;
                return ChoiceChip(
                  label: Text('$h h'),
                  selected: selected,
                  onSelected: (_) => setState(() => _duracionHoras = h),
                  selectedColor: _primary,
                  labelStyle: GoogleFonts.workSans(
                    color: selected ? Colors.white : _dark,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total a pagar',
                      style: GoogleFonts.workSans(color: _dark)),
                  Text(
                    '\$${_monto.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : () => _confirmar(vm),
                child: vm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirmar reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacaDropdown extends StatelessWidget {
  final List<String> vehiculos;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _PlacaDropdown({
    required this.vehiculos,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: vehiculos
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
