# Cambios y Módulo de Administración

Este documento describe la estructura y los cambios realizados en el proyecto **Parqueadero Inteligente** para dar soporte al nuevo módulo de **Administración**.

---

## 1. Archivos Creados

### Servicios
* **[detector_service.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/core/services/detector_service.dart)**: Servicio que simula el procesamiento de visión artificial de TensorFlow Lite sobre una imagen capturada por la cámara, identificando celdas libres y ocupadas, y retornando un listado sugerido de espacios.

### Casos de Uso (Usecases)
* **[save_parqueadero_usecase.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/domain/usecases/parking/save_parqueadero_usecase.dart)**: Caso de uso para registrar un nuevo parqueadero y persistir de manera atómica todos sus espacios correspondientes en Firestore.

### Modelos de Vista (ViewModels)
* **[admin_dashboard_viewmodel.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/presentation/viewmodels/admin_dashboard_viewmodel.dart)**: Gestiona el estado y la obtención de estadísticas del panel (total de usuarios, total de parqueaderos e historial completo de reservas) mapeando los IDs de usuario y parqueadero a sus nombres reales para una visualización amigable.
* **[add_parqueadero_viewmodel.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/presentation/viewmodels/add_parqueadero_viewmodel.dart)**: Mantiene el estado interactivo durante el flujo de creación de un parqueadero (información básica, captura de foto, control de visión artificial y ajustes manuales en caliente del grid de espacios).

### Vistas (Screens/Views)
* **[admin_dashboard_view.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/presentation/views/admin/admin_dashboard_view.dart)**: Pantalla de inicio exclusiva para el administrador. Muestra las tarjetas con conteos totales, botón de registro y la lista de historial de reservas con estilos de estado.
* **[add_parqueadero_view.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/presentation/views/admin/add_parqueadero_view.dart)**: Formulario básico de información (nombre, tarifa, dirección) con un mapa interactivo de Google Maps integrado donde se puede arrastrar el marcador, dar tap para fijar coordenadas o centrar mediante GPS.
* **[scan_parqueadero_view.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/presentation/views/admin/scan_parqueadero_view.dart)**: Interfaz de cámara que utiliza el hardware nativo para capturar la foto y muestra una barra animada de escaneo simulando el procesamiento de TensorFlow Lite.
* **[review_parqueadero_view.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/presentation/views/admin/review_parqueadero_view.dart)**: Panel manual interactivo. Muestra el grid de espacios coloreados (Verde: Libre, Rojo: Ocupado) donde el administrador puede alternar estados al hacer click, renombrar números, cambiar tipos (Normal, Discapacitado, Eléctrico) o agregar/eliminar celdas antes de guardar.

---

## 2. Archivos Modificados

### Configuración del Proyecto
* **[pubspec.yaml](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/pubspec.yaml)**:
  * *Motivo:* Se agregó la dependencia `image_picker` para permitir el acceso nativo a la cámara y galería de imágenes.

### Capa de Datos (Data Layer)
* **[user_remote_datasource.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/data/datasources/remote/user_remote_datasource.dart)**:
  * *Motivo:* Añadidos métodos `getUsersCount` (para el conteo de usuarios mediante consultas optimizadas de Firestore) y `getAllUsers` (para construir un mapeo rápido de uid -> nombre).
* **[parqueadero_remote_datasource.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/data/datasources/remote/parqueadero_remote_datasource.dart)**:
  * *Motivo:* Implementado `saveParqueadero` (persiste en lote/batch el parqueadero y cada espacio individual en sus colecciones respectivas) y `getParqueaderosCount`.
* **[reserva_remote_datasource.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/data/datasources/remote/reserva_remote_datasource.dart)**:
  * *Motivo:* Añadido `getAllReservas` para cargar el historial completo de transacciones.
* **[auth_repository_impl.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/data/repositories/auth_repository_impl.dart)**:
  * *Motivo:* Implementado `getUsersCount` y `getAllUsers`. Además, se agregó lógica de **auto-recuperación / auto-semilla (auto-seed)** para el usuario Administrador: si se inicia sesión con `admin@parqueadero.com` y no existe su documento de Firestore en la colección `usuarios`, el repositorio lo crea automáticamente asignándole el rol `UserRole.admin`. También, si la credencial no existe en Firebase Auth, la crea automáticamente en el primer intento de inicio de sesión de prueba.
* **[parqueadero_repository_impl.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/data/repositories/parqueadero_repository_impl.dart)**:
  * *Motivo:* Implementado `saveParqueadero` y `getParqueaderosCount`.
* **[reserva_repository_impl.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/data/repositories/reserva_repository_impl.dart)**:
  * *Motivo:* Implementado `getAllReservas`.

### Capa de Dominio (Domain Layer)
* **[auth_repository.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/domain/repositories/auth_repository.dart)**:
  * *Motivo:* Declarados métodos `getUsersCount` y `getAllUsers`.
* **[parqueadero_repository.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/domain/repositories/parqueadero_repository.dart)**:
  * *Motivo:* Declarados métodos `saveParqueadero` y `getParqueaderosCount`.
* **[reserva_repository.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/domain/repositories/reserva_repository.dart)**:
  * *Motivo:* Declarado método `getAllReservas`.

### Capa de Presentación e Inyección (Presentation Layer & Routing)
* **[injection.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/core/di/injection.dart)**:
  * *Motivo:* Se configuró e inyectó `SpaceDetectorService`, `SaveParqueaderoUseCase`, `AdminDashboardViewModel` y `AddParqueaderoViewModel` en GetIt (`sl`).
* **[app_router.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/core/router/app_router.dart)**:
  * *Motivo:* Se declararon las 4 nuevas rutas del módulo administrativo y se actualizó la lógica del método `redirect`. Ahora, si el usuario autenticado tiene el rol de Administrador (`isAdmin == true`), es redirigido automáticamente al dashboard de administración. Si un cliente normal intenta acceder a cualquier ruta administrativa `/admin/`, es devuelto a `/home`.
* **[main.dart](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/lib/main.dart)**:
  * *Motivo:* Cambiado de `ChangeNotifierProvider.value` a `MultiProvider` para proveer de forma global el `AddParqueaderoViewModel` al árbol de widgets, garantizando que el estado temporal del formulario y espacios no se pierda al cambiar entre pantallas de GoRouter.

---

## 3. Integración con el Resto del Proyecto

1. **Autenticación Directa**: Durante el flujo de login, `AuthViewModel` evalúa el rol del usuario mediante `isAdmin`. Al usar la cuenta `admin@parqueadero.com` (con clave `adminparqueadero`), la aplicación reconoce el rol y redirige automáticamente al flujo de administración.
2. **Visualización en el Mapa**: Dado que el parqueadero y sus espacios individuales son guardados respetando la arquitectura de datos existente, cuando el cliente abre su aplicación, el parqueadero aparece en el mapa gracias a que `GetParqueaderosCercanosUseCase` realiza la búsqueda por geolocalización.
3. **Reservas y Disponibilidad**: Los espacios registrados son creados dentro de la colección global `espacios` vinculados al `parqueaderoId`. Al estar disponibles y ordenados por número, se integran perfectamente con la vista del cliente `ParqueaderoDetailView`, permitiéndole reservar celdas y generar códigos QR sin ninguna modificación adicional en las pantallas del cliente.

---

## 4. Configuración y Permisos Adicionales

1. **Permisos de Cámara (Android / iOS)**:
   * **Android**: Por defecto `image_picker` no requiere permisos en la mayoría de versiones, pero para dar soporte completo en versiones antiguas, puede añadir la siguiente línea a su [AndroidManifest.xml](file:///C:/Users/PACO/Desktop/MOVILES/U3/Parqueadero_Inteligente/android/app/src/main/AndroidManifest.xml):
     ```xml
     <uses-permission android:name="android.permission.CAMERA" />
     ```
   * **iOS**: Se debe agregar la siguiente llave al archivo `Info.plist` para solicitar permiso de cámara:
     ```xml
     <key>NSCameraUsageDescription</key>
     <string>Esta aplicación requiere acceso a la cámara para capturar la distribución de espacios del parqueadero.</string>
     ```
2. **Firebase y Credenciales**:
   * Las credenciales por defecto son:
     * **Email**: `admin@parqueadero.com`
     * **Contraseña**: `adminparqueadero`
   * Si la cuenta no existe en Firebase Auth, intente iniciar sesión normalmente. El sistema la creará en segundo plano en Firebase Auth y guardará su documento con rol de `admin` en Firestore de forma automática.
