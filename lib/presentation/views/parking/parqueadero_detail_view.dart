import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/parqueadero_detail_viewmodel.dart';
import '../../widgets/espacio_grid.dart';

class ParqueaderoDetailView extends StatefulWidget {
  final String parqueaderoId;
  const ParqueaderoDetailView({super.key, required this.parqueaderoId});

  @override
  State<ParqueaderoDetailView> createState() => _ParqueaderoDetailViewState();
}

class _ParqueaderoDetailViewState extends State<ParqueaderoDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParqueaderoDetailViewModel>().init(widget.parqueaderoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParqueaderoDetailViewModel>(
      builder: (context, vm, _) {
        final p = vm.parqueadero;

        return Scaffold(
          backgroundColor: const Color(0xFFF0FDFA),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    p?.nombre ?? 'Detalle',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_parking_rounded,
                        size: 72,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                ),
              ),
              if (vm.status == DetailStatus.loading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (vm.status == DetailStatus.error)
                SliverFillRemaining(
                  child: Center(
                    child: Text(vm.errorMessage ?? 'Error',
                        style: GoogleFonts.workSans()),
                  ),
                )
              else if (p != null) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoCard(vm: vm),
                        const SizedBox(height: 16),
                        _CountsRow(vm: vm),
                        const SizedBox(height: 20),
                        Text(
                          'Espacios',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: const Color(0xFF134E4A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        EspacioGrid(espacios: vm.espacios),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          bottomNavigationBar: p != null && vm.espaciosLibres > 0
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: ElevatedButton(
                      onPressed: () {
                        // Módulo 4: Reserva
                      },
                      child: const Text('Reservar espacio'),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ParqueaderoDetailViewModel vm;
  const _InfoCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final p = vm.parqueadero!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 16, color: Color(0xFF0F766E)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  p.direccion,
                  style: GoogleFonts.workSans(
                      fontSize: 13, color: const Color(0xFF134E4A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Detail(
                icon: Icons.attach_money_rounded,
                label: '\$${p.tarifaPorHora.toStringAsFixed(0)}/hora',
              ),
              const SizedBox(width: 16),
              _Detail(icon: Icons.schedule_rounded, label: p.horario),
            ],
          ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Detail({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF0F766E)),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.workSans(
                fontSize: 13, color: const Color(0xFF134E4A))),
      ],
    );
  }
}

class _CountsRow extends StatelessWidget {
  final ParqueaderoDetailViewModel vm;
  const _CountsRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CountCard(
            value: vm.espaciosLibres,
            label: 'Libres',
            color: const Color(0xFF0F766E),
            bg: const Color(0xFFCCFBF1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountCard(
            value: vm.espaciosOcupados,
            label: 'Ocupados',
            color: const Color(0xFFDC2626),
            bg: const Color(0xFFFEE2E2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountCard(
            value: vm.espaciosReservados,
            label: 'Reservados',
            color: const Color(0xFFD97706),
            bg: const Color(0xFFFEF3C7),
          ),
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final Color bg;
  const _CountCard({
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(
            '$value',
            style: GoogleFonts.outfit(
                fontSize: 24, fontWeight: FontWeight.w700, color: color),
          ),
          Text(label,
              style: GoogleFonts.workSans(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}
