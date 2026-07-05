# Ejecución — Módulo 7: Historial

## Qué hace
- `/historial` (icono de recibo en la barra del Home): lista **Activas** y **Pasadas**.
- Por estado: `pendiente` → botones **Pagar** (va a `/pago/:id`) y **Cancelar** (libera el espacio); `activa` → **Ver QR** (check-in/out); pasadas solo se listan.
- Al abrir corre el barrido de no-shows, así el usuario ve su reserva vencida como cancelada.
- Pull-to-refresh.

## Archivos
- Creados: `get_reservas_usuario_usecase.dart`, `historial_viewmodel.dart`, `views/historial/historial_view.dart`.
- Modificados: `reserva_remote_datasource.dart` / repo (+`getReservasByUsuario`), `home_view.dart` (iconos historial y perfil), `app_router.dart`, `injection.dart`.
