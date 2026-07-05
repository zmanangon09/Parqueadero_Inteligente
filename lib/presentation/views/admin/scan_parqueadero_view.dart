import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/add_parqueadero_viewmodel.dart';
import '../../widgets/primary_button.dart';

class ScanParqueaderoView extends StatefulWidget {
  const ScanParqueaderoView({super.key});

  @override
  State<ScanParqueaderoView> createState() => _ScanParqueaderoViewState();
}

class _ScanParqueaderoViewState extends State<ScanParqueaderoView>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _capturarFoto(AddParqueaderoViewModel vm) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        // Ejecutar la detección
        await vm.scanAndDetect(photo.path);
        
        if (mounted && vm.errorMessage == null) {
          // Navegar a la pantalla de revisión
          context.pushReplacement('/admin/review_parking');
        }
      }
    } catch (_) {
      // Manejar error de cámara
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddParqueaderoViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: Text(
          'Escanear Parqueadero',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (vm.isProcessingImage) ...[
                // Pantalla de procesamiento
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (vm.imagePath != null)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                height: 280,
                                width: double.infinity,
                                child: Image.file(
                                  File(vm.imagePath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Línea de escaneo animada
                            AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: _scanAnimation.value * 280,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.secondary.withAlpha(200),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 32),
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Procesando imagen...',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF134E4A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Corriendo inferencia TensorFlow Lite para detectar espacios libres y ocupados.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Pantalla inicial antes de capturar
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_enhance_rounded,
                          size: 72,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Captura el parqueadero',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF134E4A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Toma una foto clara de los espacios. El modelo TensorFlow Lite (SSD MobileNet) detectará los vehículos presentes; en la revisión podrás agregar los espacios libres y ajustar el resultado.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (vm.errorMessage != null) ...[
                  Text(
                    vm.errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                ],
                PrimaryButton(
                  label: 'Abrir Cámara y Capturar',
                  onPressed: () => _capturarFoto(vm),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
