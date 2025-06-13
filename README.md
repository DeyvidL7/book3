# BookReview 📚

Una aplicación móvil moderna para gestionar tu biblioteca personal y escribir reseñas de libros.

## 🚀 Características

- **Gestión de Biblioteca Personal**: Organiza tus libros en categorías (Por Leer, Leyendo, Leídos)
- **Sistema de Reseñas**: Escribe y lee reseñas de otros usuarios
- **Búsqueda de Libros**: Explora un amplio catálogo de libros
- **Estadísticas de Lectura**: Visualiza tu progreso y estadísticas
- **Favoritos**: Marca libros como favoritos para acceso rápido
- **Autenticación**: Sistema seguro con Firebase Auth

## 🎨 Tecnologías

- **Framework**: Flutter / Dart
- **Backend**: Firebase (Auth, Firestore)
- **Estado**: Provider
- **Imágenes**: Cached Network Image
- **Almacenamiento**: Flutter Secure Storage
- **HTTP**: Dio

## 📱 Pantallas

- **Autenticación**: Login y registro de usuarios
- **Biblioteca**: Explorar y buscar libros
- **Mis Libros**: Gestión personal con tabs organizados
- **Perfil**: Estadísticas y configuración del usuario
- **Detalles**: Información completa del libro y reseñas

## 🛠️ Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/DeyvidL7/book2.git
cd book2
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura Firebase:
   - Crea un proyecto en Firebase Console
   - Agrega tu `google-services.json` en `android/app/`
   - Configura las reglas de Firestore

4. Ejecuta la aplicación:
```bash
flutter run
```

## 🎯 Funcionalidades Clave

### Gestión de Libros
- Agregar libros a tu biblioteca personal
- Cambiar estado de lectura (Por Leer → Leyendo → Leído)
- Sistema de favoritos con animaciones

### Reseñas y Valoraciones
- Escribir reseñas detalladas
- Sistema de puntuación (1-5 estrellas)
- Ver reseñas de otros usuarios

### Interfaz Moderna
- Diseño Material 3
- Tema personalizado con colores profesionales
- Animaciones fluidas y transiciones suaves
- Estados vacíos informativos

## 📊 Arquitectura

```
lib/
├── models/          # Modelos de datos (Book, Review, UserBook)
├── services/        # Lógica de negocio y APIs
├── screens/         # Pantallas de la aplicación
├── widgets/         # Componentes reutilizables
├── navigation/      # Sistema de navegación
└── main.dart        # Punto de entrada
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

© 2024 David Aruquipa. Todos los derechos reservados.

---

**Desarrollado con ❤️ usando Flutter**