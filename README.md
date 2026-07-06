# 🅿️ Parqueadero Inteligente

Aplicación móvil desarrollada en **Flutter** para la gestión y control inteligente de parqueaderos. Permite a los usuarios buscar parqueaderos cercanos en un mapa interactivo, reservar espacios, realizar pagos y gestionar su historial. Los administradores pueden controlar el check-in/out mediante escaneo QR y detectar vehículos con inteligencia artificial (TensorFlow Lite).

> Proyecto académico — 7mo semestre, Desarrollo Móvil.

## 📸 Características

- 🗺️ **Mapa interactivo** con Google Maps y geolocalización en tiempo real
- 🔐 **Autenticación** de usuarios con Firebase Auth
- 📋 **Reserva de espacios** de estacionamiento disponibles
- 💳 **Módulo de pagos** integrado
- 📷 **Escaneo QR** para check-in/check-out (administrador)
- 🤖 **Detección de vehículos** con TensorFlow Lite (SSD MobileNet COCO)
- 📊 **Historial** de reservas y pagos
- 👤 **Perfil de usuario** editable
- 🛡️ **Panel de administración** para gestión de parqueaderos y espacios

## 🏗️ Arquitectura

El proyecto sigue los principios de **Clean Architecture + MVVM**:

```
lib/
├── core/            # Constantes, temas, utilidades compartidas
├── data/            # Repositorios (implementación), datasources
├── domain/          # Entidades, repositorios (contratos), casos de uso
│   ├── entities/    # User, Parqueadero, Espacio, Reserva, Pago
│   ├── repositories/
│   └── usecases/
├── presentation/    # UI
│   ├── views/       # Pantallas (auth, home, parking, admin, pago, etc.)
│   ├── viewmodels/  # Lógica de presentación (ChangeNotifier)
│   └── widgets/     # Componentes reutilizables
└── main.dart
```

## 🛠️ Tech Stack

| Categoría | Tecnologías |
|---|---|
| **Framework** | Flutter + Dart |
| **Backend** | Firebase Auth, Cloud Firestore, Firebase Storage |
| **Estado** | Provider |
| **Navegación** | GoRouter |
| **Mapas** | Google Maps Flutter + Geolocator |
| **IA** | TensorFlow Lite (tflite_flutter) |
| **QR** | qr_flutter (generación) + mobile_scanner (escaneo) |
| **DI** | get_it |
| **Tipografía** | Google Fonts (Outfit + Work Sans) |
| **Testing** | flutter_test + mocktail |

## ⚙️ Configuración del proyecto

### Prerrequisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (≥ 3.11.4)
- Android Studio o VS Code con extensiones de Flutter
- Una cuenta de Google Cloud con la API de Maps habilitada

### 1. Clonar el repositorio

```bash
git clone https://github.com/zmanangon09/Parqueadero_Inteligente.git
cd Parqueadero_Inteligente
```

### 2. Configurar variables de entorno

Este proyecto utiliza una **API Key de Google Maps** que no se incluye en el repositorio por seguridad. Debes crear los siguientes archivos manualmente:

#### Archivo `.env` (en la raíz del proyecto)

```env
GOOGLE_MAPS_API_KEY=TU_API_KEY_DE_GOOGLE_MAPS
```

#### Archivo `android/local.properties`

Este archivo ya debería existir tras abrir el proyecto en Android Studio (contiene la ruta del SDK). Agrega la siguiente línea al final:

```properties
MAPS_API_KEY=TU_API_KEY_DE_GOOGLE_MAPS
```

> **Nota:** Solicita la API Key al propietario del repositorio o genera la tuya desde la [Google Cloud Console](https://console.cloud.google.com/apis/credentials) habilitando la **Maps SDK for Android**.

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Configurar Firebase

```bash
flutterfire configure
```

### 5. Ejecutar la aplicación

```bash
flutter run
```

### 6. Ejecutar tests

```bash
flutter test --reporter expanded
```

## 📄 Licencia

Proyecto académico con fines educativos.
