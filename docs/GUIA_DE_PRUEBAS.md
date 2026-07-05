# Guía de pruebas — Control Inteligente de Parqueaderos

Para compañeros que van a correr y probar la app. Explica cómo levantarla y el flujo completo de cada módulo.

## 1. Antes de correr la app

Clona el repo y corre `flutter pub get`. Luego crea estos 3 archivos (están gitignored, no vienen en el repo):

1. **`.env`** en la raíz del proyecto:
   ```
   GOOGLE_MAPS_API_KEY=<pide la key al equipo>
   ```
2. **`android/local.properties`** — agrega esta línea al final:
   ```
   MAPS_API_KEY=<la misma key>
   ```
3. **`lib/firebase_options.dart`** — si no lo tienes, corre `flutterfire configure` y selecciona el proyecto Firebase **`smart-parking-mrcc`** (pide acceso si no lo tienes).

Verifica en Firebase Console (proyecto `smart-parking-mrcc`):
- Authentication → Email/Password habilitado.
- Firestore Database creada (modo prueba está bien).
- Storage con el bucket default creado (si no existe, la foto de perfil falla con un mensaje de error, el resto de la app funciona igual).

Corre `flutter test` y `flutter analyze` para confirmar que todo está en verde antes de probar manualmente.

## 2. Cómo entrar

- **Cliente**: regístrate desde la pantalla de Login → "Crear cuenta" (nombre, correo, teléfono, contraseña). Cualquier correo válido sirve.
- **Administrador**: usa el correo `admin@parqueadero.com` / contraseña `adminparqueadero`. La primera vez que alguien entra con esa cuenta, la app la crea sola en Firebase Auth y en Firestore con rol admin — no hace falta crearla a mano.

La app te manda a un flujo distinto según el rol: cliente ve el mapa (`/home`), admin ve el panel (`/admin_dashboard`).

## 3. Flujo del cliente

### 3.1 Home (mapa)
- Pide permiso de ubicación. Si lo niegas, usa Quito como fallback.
- Muestra parqueaderos cercanos (radio 5 km) como marcadores: azul = seleccionado, cian = con espacios libres, rojo = lleno.
- Toca un marcador → aparece una tarjeta abajo con el resumen → "Ver detalle".
- Iconos en la barra superior (de izquierda a derecha): **Historial** (recibo), **Perfil** (persona), **Cerrar sesión**.

### 3.2 Detalle de parqueadero
- Info del parqueadero + grid de espacios en tiempo real (colores por estado: libre/ocupado/reservado, además icono si es discapacitado o eléctrico).
- Toca un espacio **libre** → abre el sheet de reserva.

### 3.3 Reservar
- Si ya tienes vehículos guardados en tu perfil, eliges la placa de un dropdown; si no, escribes la placa (formato `ABC-1234` o `ABC1234`).
- Eliges duración (1 a 4 horas) y ves el total calculado con la tarifa del parqueadero.
- Al confirmar: el espacio pasa a `ocupado` y la reserva queda `pendiente` de pago. **Ojo**: tienes una ventana de 10 minutos para hacer check-in una vez que la reserva esté activa (pagada) — si no, se libera sola (ver 3.5).

### 3.4 Pago (modo test, estilo Stripe)
- Tarjetas de prueba:
  - `4242 4242 4242 4242` → pago aprobado.
  - Cualquier otro número de 16 dígitos → pago declinado.
- Expiración en formato `MM/YY` (no puede estar vencida), CVC de 3 dígitos.
- Pago exitoso → la reserva pasa a `activa` y puedes tocar **"Ver mi QR"** en el diálogo de confirmación (o más tarde desde el Historial).
- Puedes cancelar la reserva desde esta pantalla ("Cancelar y liberar espacio") si te arrepientes antes de pagar.

### 3.5 Check-in / Check-out (QR)
- Tu QR (visible desde el diálogo de pago exitoso o desde Historial → reserva activa → "Ver QR") hay que mostrarlo al administrador en la entrada/salida del parqueadero.
- El administrador es quien escanea (ver sección 4.4) — el cliente no escanea nada, solo muestra su código.
- **No-show**: si no haces check-in dentro de los 10 minutos desde que la reserva quedó activa, se cancela sola y el espacio vuelve a estar libre para otros. Esto se revisa automáticamente cada vez que entras al Historial o el admin abre su dashboard.

### 3.6 Historial (`/historial`)
- **Activas**: incluye pendientes de pago (con botones Pagar/Cancelar) y activas (con botón Ver QR).
- **Pasadas**: completadas y canceladas, solo consulta.
- Desliza hacia abajo para refrescar.

### 3.7 Perfil (`/perfil`)
- Ver correo, teléfono, fecha de registro.
- **Vehículos**: botón "Agregar" para nuevas placas (se validan), tap en la ✕ de un chip para eliminarla. Estas placas son las que aparecen luego en el dropdown al reservar.
- **Foto de perfil**: toca el icono de cámara sobre el avatar → elige una foto de la galería → se sube a Firebase Storage.

## 4. Flujo del administrador

Entra con `admin@parqueadero.com` / `adminparqueadero`.

### 4.1 Dashboard (`/admin_dashboard`)
- Tarjetas con total de usuarios y de parqueaderos registrados.
- Botón **"Nuevo Parqueadero"** (ver 4.2).
- Botón **"Check-in / Check-out"** (ver 4.4).
- Lista de parqueaderos con dos acciones por cada uno: icono de cámara (evaluar ocupación, ver 4.3) y botón "Liberar" (resetea todos sus espacios a libre y cancela sus reservas activas/pendientes — útil si algo quedó en un estado raro durante las pruebas).
- Historial completo de reservas de todos los usuarios, con estado y monto.

### 4.2 Registrar un parqueadero nuevo
1. Llena nombre, tarifa por hora y dirección; ubica el punto en el mapa (arrastra el marcador, toca el mapa, o usa el botón de GPS).
2. Toca "Registrar usando visión artificial" → te lleva a la cámara.
3. **Toma una foto** de un espacio con vehículos (puede ser cualquier foto con autos/motos/buses/camiones — funciona con fotos de internet también si estás en emulador sin cámara real). El modelo TensorFlow Lite (SSD MobileNet, real, no simulado) cuenta los vehículos detectados y genera un espacio "ocupado" por cada uno.
4. En la pantalla de revisión puedes: alternar libre/ocupado tocando una celda, cambiar el tipo (normal/discapacitado/eléctrico), renombrar el número, agregar o quitar espacios manualmente, o ajustar la capacidad total directamente.
5. Guardar → el parqueadero y sus espacios quedan en Firestore y aparecen inmediatamente en el mapa del cliente.

### 4.3 Evaluar espacios libres con la cámara (parqueadero ya existente)
- Desde el dashboard, icono de cámara junto al parqueadero → abre `/admin/evaluate/:id`.
- Toca "Abrir cámara" y toma una foto del estado actual del parqueadero.
- El modelo cuenta los vehículos y arma una propuesta: los espacios `reservado` (con una reserva vigente) **no se tocan**; el resto se reparte entre ocupado/libre según cuántos vehículos se detectaron.
- Verás un resumen (N vehículos detectados, cuántos quedan libres/ocupados/reservados) y un grid con el color de cada espacio propuesto.
- "Aplicar ocupación" guarda los cambios en Firestore. "Tomar otra foto" descarta y repite.

### 4.4 Check-in / Check-out de clientes
- Desde el dashboard → "Check-in / Check-out" → abre la cámara en modo escáner QR.
- El cliente te muestra su QR (ver 3.5). Apunta la cámara al código.
- La app decide sola qué hacer según el estado de esa reserva:
  - **Check-in**: reserva activa, sin check-in aún, dentro de los 10 min → confirma bienvenida.
  - **Check-out**: reserva activa que ya tenía check-in → la completa y libera el espacio.
  - **No-show**: reserva activa sin check-in y con la ventana vencida → la cancela y libera el espacio.
  - **Rechazado**: reserva pendiente de pago, o ya completada/cancelada → mensaje de error explicando por qué.
- Después de cada escaneo aparece un diálogo con el resultado; toca "Seguir escaneando" para el siguiente cliente.

## 5. Cosas a tener en cuenta al probar

- Los datos son compartidos entre todos los que prueben contra el mismo Firestore (`smart-parking-mrcc`) — si alguien deja espacios en un estado raro, usa "Liberar" desde el dashboard admin para resetear ese parqueadero.
- El modelo TensorFlow Lite corre en el dispositivo/emulador; en emulador sin cámara real, `image_picker` puede pedir elegir una foto de la galería en su lugar — usa cualquier imagen con autos.
- Los pagos son 100% simulados (no se cobra nada real, no hay claves de Stripe reales en el proyecto).
- Si algo no aparece en el mapa después de registrarlo, revisa que la ubicación esté dentro del radio de 5 km de tu posición actual (o la de Quito si no diste permiso de ubicación).
