import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../viewmodels/add_parqueadero_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class AddParqueaderoView extends StatefulWidget {
  const AddParqueaderoView({super.key});

  @override
  State<AddParqueaderoView> createState() => _AddParqueaderoViewState();
}

class _AddParqueaderoViewState extends State<AddParqueaderoView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  double _lat = AppConstants.defaultLat;
  double _lng = AppConstants.defaultLng;
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _direccionCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacionActual() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final request = await Geolocator.requestPermission();
        if (request == LocationPermission.denied ||
            request == LocationPermission.deniedForever) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_lat, _lng), 15),
      );
    } catch (_) {
      // Ignorar errores y usar la posición por defecto
    }
  }

  void _onMapTapped(LatLng pos) {
    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final precio = double.tryParse(_precioCtrl.text.trim()) ?? 0.0;
    
    // Guardar información básica en el ViewModel
    context.read<AddParqueaderoViewModel>().setBasicInfo(
          nombre: _nombreCtrl.text.trim(),
          tarifaPorHora: precio,
          direccion: _direccionCtrl.text.trim(),
          lat: _lat,
          lng: _lng,
        );

    // Navegar a la pantalla de escaneo
    context.push('/admin/scan_parking');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: Text(
          'Añadir nuevo parqueadero',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos del Parqueadero',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF134E4A),
                  ),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _nombreCtrl,
                  label: 'Nombre del parqueadero',
                  hint: 'Ej. Parqueadero El Sagrario',
                  prefixIcon: Icon(Icons.business_rounded, color: primaryColor),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _precioCtrl,
                  label: 'Precio por hora',
                  hint: 'Ej. 2.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icon(Icons.attach_money_rounded, color: primaryColor),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa la tarifa por hora';
                    }
                    if (double.tryParse(val) == null) {
                      return 'Ingresa un valor numérico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _direccionCtrl,
                  label: 'Dirección física',
                  hint: 'Ej. Av. Amazonas N21-14 y Patria',
                  prefixIcon: Icon(Icons.location_on_rounded, color: primaryColor),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor ingresa la dirección';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ubicación en el Mapa',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF134E4A),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _obtenerUbicacionActual,
                      icon: const Icon(Icons.my_location_rounded, size: 16),
                      label: Text(
                        'Mi ubicación',
                        style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Mapa de Google
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withAlpha(20)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_lat, _lng),
                        zoom: 14,
                      ),
                      onMapCreated: (ctrl) => _mapController = ctrl,
                      onTap: _onMapTapped,
                      markers: {
                        Marker(
                          markerId: const MarkerId('seleccion'),
                          position: LatLng(_lat, _lng),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueCyan),
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  label: 'Escanear parqueadero',
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
