import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/parking_bottom_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
    });
  }

  Future<void> _centerOnUser() async {
    final vm = context.read<HomeViewModel>();
    final ctrl = await _mapController.future;
    await ctrl.animateCamera(
      CameraUpdate.newLatLngZoom(vm.currentPosition, 15),
    );
  }

  Future<void> _animateTo(LatLng pos) async {
    final ctrl = await _mapController.future;
    await ctrl.animateCamera(CameraUpdate.newLatLng(pos));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        final markers = _buildMarkers(vm);

        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: vm.currentPosition,
                  zoom: 14,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: markers,
                onMapCreated: (ctrl) => _mapController.complete(ctrl),
                onTap: (_) => vm.clearSelection(),
              ),
              _TopBar(),
              if (vm.status == HomeStatus.loadingLocation ||
                  vm.status == HomeStatus.loadingParking)
                const _LoadingOverlay(),
              if (vm.status == HomeStatus.error && vm.selectedParqueadero == null)
                _ErrorBanner(message: vm.errorMessage ?? 'Error desconocido'),
              if (vm.selectedParqueadero != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ParkingBottomSheet(
                    parqueadero: vm.selectedParqueadero!,
                    onVerDetalle: () {
                      // Módulo 3: detalle de parqueadero
                    },
                    onClose: vm.clearSelection,
                  ),
                ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'refresh',
                onPressed: vm.status == HomeStatus.loadingParking ||
                        vm.status == HomeStatus.loadingLocation
                    ? null
                    : vm.refresh,
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'location',
                onPressed: _centerOnUser,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.my_location_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  Set<Marker> _buildMarkers(HomeViewModel vm) {
    return vm.parqueaderos.map((p) {
      final isSelected = vm.selectedParqueadero?.id == p.id;
      return Marker(
        markerId: MarkerId(p.id),
        position: LatLng(p.lat, p.lng),
        icon: isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
            : p.tieneEspacios
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueCyan)
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
        onTap: () {
          vm.selectParqueadero(p);
          _animateTo(LatLng(p.lat, p.lng));
        },
        infoWindow: InfoWindow(
          title: p.nombre,
          snippet: '${p.espaciosDisponibles} espacios disponibles',
        ),
      );
    }).toSet();
  }
}

class _TopBar extends StatelessWidget {
  void _showLogoutDialog(BuildContext context, AuthViewModel authVm) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cerrar sesión',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Text('¿Deseas cerrar la sesión?',
            style: GoogleFonts.workSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              authVm.logout();
            },
            child: Text('Cerrar sesión',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final nombre = authVm.currentUser?.nombre.split(' ').first ?? 'Usuario';
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_parking_rounded,
                        color: cs.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hola, $nombre',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFF134E4A),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showLogoutDialog(context, authVm),
                      child: Icon(
                        Icons.logout_rounded,
                        color: cs.primary.withAlpha(180),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<HomeViewModel>().status;
    final msg = status == HomeStatus.loadingLocation
        ? 'Obteniendo ubicación...'
        : 'Buscando parqueaderos...';

    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(msg,
                  style: GoogleFonts.workSans(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.workSans(
                    color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
