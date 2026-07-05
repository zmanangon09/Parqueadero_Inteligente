import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../../domain/entities/reserva_entity.dart';
import '../../viewmodels/pago_viewmodel.dart';
import '../../widgets/qr_reserva_dialog.dart';

const _primary = Color(0xFF0F766E);
const _dark = Color(0xFF134E4A);

class PagoView extends StatefulWidget {
  final ReservaEntity reserva;
  const PagoView({super.key, required this.reserva});

  @override
  State<PagoView> createState() => _PagoViewState();
}

class _PagoViewState extends State<PagoView> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _expCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  Future<void> _pagar(PagoViewModel vm) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await vm.pagar(
      reserva: widget.reserva,
      numeroTarjeta: _numeroCtrl.text,
      expiracion: _expCtrl.text,
      cvc: _cvcCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: _primary, size: 48),
          title: const Text('¡Pago exitoso!'),
          content: Text(
            'Tu reserva quedó confirmada.\nTransacción: ${vm.pago?.transactionId ?? ''}\n\n'
            'Recuerda hacer check-in con tu QR dentro de los 10 minutos.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => showQrReservaDialog(context, widget.reserva),
              child: const Text('Ver mi QR'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
              child: const Text('Listo'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'No se pudo procesar el pago.'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _cancelar(PagoViewModel vm) async {
    await vm.cancelar(widget.reserva);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PagoViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: const Text('Pago'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total a pagar',
                        style: GoogleFonts.workSans(color: _dark)),
                    const SizedBox(height: 4),
                    Text(
                      '\$${widget.reserva.montoTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Datos de la tarjeta',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700, color: _dark, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numeroCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                ],
                validator: Validators.numeroTarjeta,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  hintText: '4242 4242 4242 4242',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expCtrl,
                      keyboardType: TextInputType.datetime,
                      validator: Validators.expiracionTarjeta,
                      decoration: const InputDecoration(
                        labelText: 'MM/YY',
                        hintText: '12/30',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvcCtrl,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: Validators.cvc,
                      decoration: const InputDecoration(
                        labelText: 'CVC',
                        hintText: '123',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Prueba: 4242 4242 4242 4242 aprueba; otra tarjeta se declina.',
                style: GoogleFonts.workSans(
                    fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.isProcesando ? null : () => _pagar(vm),
                  child: vm.isProcesando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Pagar \$${widget.reserva.montoTotal.toStringAsFixed(2)}'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: vm.isProcesando ? null : () => _cancelar(vm),
                  child: const Text('Cancelar y liberar espacio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
