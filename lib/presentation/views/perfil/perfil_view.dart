import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../../domain/entities/user_entity.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/perfil_viewmodel.dart';

const _primary = Color(0xFF0F766E);
const _dark = Color(0xFF134E4A);

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  Future<void> _cambiarFoto(BuildContext context, UserEntity user) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );
    if (photo == null || !context.mounted) return;

    final vm = context.read<PerfilViewModel>();
    final authVm = context.read<AuthViewModel>();
    final ok = await vm.cambiarFoto(user, photo.path);
    if (!context.mounted) return;
    if (ok) {
      authVm.updateCurrentUser(vm.updatedUser!);
    } else {
      _showError(context, vm.errorMessage);
    }
  }

  Future<void> _agregarPlaca(BuildContext context, UserEntity user) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final placa = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Agregar vehículo',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            validator: Validators.placa,
            decoration: const InputDecoration(
              labelText: 'Placa',
              hintText: 'Ej. PBA1234',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, controller.text.trim().toUpperCase());
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (placa == null || !context.mounted) return;

    final vm = context.read<PerfilViewModel>();
    final authVm = context.read<AuthViewModel>();
    final ok = await vm.agregarPlaca(user, placa);
    if (!context.mounted) return;
    if (ok) {
      authVm.updateCurrentUser(vm.updatedUser!);
    } else {
      _showError(context, vm.errorMessage);
    }
  }

  Future<void> _eliminarPlaca(
      BuildContext context, UserEntity user, String placa) async {
    final vm = context.read<PerfilViewModel>();
    final authVm = context.read<AuthViewModel>();
    final ok = await vm.eliminarPlaca(user, placa);
    if (!context.mounted) return;
    if (ok) {
      authVm.updateCurrentUser(vm.updatedUser!);
    } else {
      _showError(context, vm.errorMessage);
    }
  }

  void _showError(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Ocurrió un error.'),
        backgroundColor: const Color(0xFFDC2626),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final vm = context.watch<PerfilViewModel>();

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text('Mi perfil',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: _primary,
                  backgroundImage: user.fotoUrl != null
                      ? NetworkImage(user.fotoUrl!)
                      : null,
                  child: user.fotoUrl == null
                      ? Text(
                          user.nombre.isNotEmpty
                              ? user.nombre[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.outfit(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: vm.isSaving ? null : () => _cambiarFoto(context, user),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 18, color: _primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(user.nombre,
                style: GoogleFonts.outfit(
                    fontSize: 22, fontWeight: FontWeight.w700, color: _dark)),
          ),
          const SizedBox(height: 24),

          // Datos
          _InfoTile(icon: Icons.email_rounded, label: 'Correo', value: user.email),
          _InfoTile(
              icon: Icons.phone_rounded, label: 'Teléfono', value: user.telefono),
          _InfoTile(
            icon: Icons.calendar_month_rounded,
            label: 'Miembro desde',
            value:
                '${user.fechaRegistro.day.toString().padLeft(2, '0')}/${user.fechaRegistro.month.toString().padLeft(2, '0')}/${user.fechaRegistro.year}',
          ),
          const SizedBox(height: 24),

          // Vehículos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mis vehículos',
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w700, color: _dark)),
              TextButton.icon(
                onPressed:
                    vm.isSaving ? null : () => _agregarPlaca(context, user),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (user.vehiculos.isEmpty)
            Text(
              'Registra las placas de tus vehículos para reservar más rápido.',
              style: GoogleFonts.workSans(color: Colors.black45, fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.vehiculos
                  .map((p) => Chip(
                        label: Text(p,
                            style: GoogleFonts.workSans(
                                fontWeight: FontWeight.w600, color: _dark)),
                        avatar: const Icon(Icons.directions_car_rounded,
                            size: 18, color: _primary),
                        backgroundColor: Colors.white,
                        deleteIcon: const Icon(Icons.close_rounded, size: 18),
                        onDeleted: vm.isSaving
                            ? null
                            : () => _eliminarPlaca(context, user, p),
                      ))
                  .toList(),
            ),
          if (vm.isSaving) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: _primary),
        title: Text(label,
            style: GoogleFonts.workSans(fontSize: 12, color: Colors.black45)),
        subtitle: Text(value,
            style: GoogleFonts.workSans(
                fontSize: 15, fontWeight: FontWeight.w500, color: _dark)),
      ),
    );
  }
}
