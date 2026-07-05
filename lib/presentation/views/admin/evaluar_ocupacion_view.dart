import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/espacio_entity.dart';
import '../../viewmodels/evaluar_ocupacion_viewmodel.dart';
import '../../widgets/primary_button.dart';

const _primary = Color(0xFF0F766E);
const _dark = Color(0xFF134E4A);

/// Panel admin: abre la cámara sobre un parqueadero existente, corre el
/// modelo TFLite para contar vehículos y actualiza los espacios libres.
class EvaluarOcupacionView extends StatefulWidget {
  final String parqueaderoId;
  const EvaluarOcupacionView({super.key, required this.parqueaderoId});

  @override
  State<EvaluarOcupacionView> createState() => _EvaluarOcupacionViewState();
}

class _EvaluarOcupacionViewState extends State<EvaluarOcupacionView> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvaluarOcupacionViewModel>().init(widget.parqueaderoId);
    });
  }

  Future<void> _abrirCamara() async {
    final vm = context.read<EvaluarOcupacionViewModel>();
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        await vm.evaluarFoto(photo.path);
      }
    } catch (_) {
      // Cámara cancelada o sin permisos: no hay nada que hacer.
    }
  }

  Future<void> _aplicar() async {
    final vm = context.read<EvaluarOcupacionViewModel>();
    final ok = await vm.aplicar();
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocupación actualizada.'),
          backgroundColor: _primary,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'No se pudo actualizar.'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EvaluarOcupacionViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text('Evaluar espacios libres',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (vm.espacios.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        'Este parqueadero no tiene espacios registrados.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(color: Colors.black54),
                      ),
                    )
                  else if (vm.fotoPath == null) ...[
                    Icon(Icons.camera_enhance_rounded,
                        size: 72, color: _primary.withAlpha(160)),
                    const SizedBox(height: 16),
                    Text(
                      'Captura el estado actual',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _dark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toma una foto del parqueadero. El modelo TensorFlow Lite '
                      'contará los vehículos (auto, camioneta, bus, moto) y '
                      'propondrá qué espacios quedan libres y ocupados. '
                      'Los espacios reservados no se modifican.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                          fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Abrir cámara',
                      onPressed: _abrirCamara,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Espacios actuales: ${vm.espacios.length}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                          fontSize: 13, color: Colors.black45),
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(File(vm.fotoPath!),
                          height: 220, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 16),
                    if (vm.isDetecting) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 12),
                      Text(
                        'Corriendo inferencia TensorFlow Lite...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(color: Colors.black54),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${vm.vehiculosDetectados} vehículo(s) detectado(s)',
                              style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _dark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Propuesta: ${vm.propuestaLibres} libres · '
                              '${vm.propuestaOcupados} ocupados · '
                              '${vm.propuestaReservados} reservados (sin cambios)',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.workSans(
                                  fontSize: 13, color: _dark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: vm.propuesta
                            .map((e) => _EspacioChip(espacio: e))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      if (vm.errorMessage != null) ...[
                        Text(vm.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFFDC2626))),
                        const SizedBox(height: 12),
                      ],
                      PrimaryButton(
                        label: vm.isSaving
                            ? 'Guardando...'
                            : 'Aplicar ocupación',
                        onPressed: vm.isSaving ? null : _aplicar,
                      ),
                      TextButton(
                        onPressed: vm.isSaving
                            ? null
                            : () {
                                vm.descartarFoto();
                                _abrirCamara();
                              },
                        child: const Text('Tomar otra foto'),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}

class _EspacioChip extends StatelessWidget {
  final EspacioEntity espacio;
  const _EspacioChip({required this.espacio});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (espacio.estado) {
      EstadoEspacio.libre => (const Color(0xFFD1FAE5), const Color(0xFF047857)),
      EstadoEspacio.ocupado =>
        (const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
      EstadoEspacio.reservado =>
        (const Color(0xFFFEF3C7), const Color(0xFFD97706)),
    };
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${espacio.numero}',
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
