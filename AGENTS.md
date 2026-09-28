# Guía de trabajo para loadable_buttons

## Alcance y estructura

Package Flutter de botones Material con callbacks `FutureOr<void>`, carga interna
y externa, indicadores personalizables y transiciones. No es una aplicación ni
necesita una arquitectura de servicios, repositorios o gestión de estado externa.

- `lib/loadable_buttons.dart`: punto de entrada público y exports.
- `lib/src/async_*_button.dart`: seis familias públicas de botones y su estado.
- `lib/src/async_*_button_with_icon.dart`: implementaciones privadas mediante
  `part`/`part of`; no importarlas directamente.
- `lib/src/transition_animation_type.dart`: `stack`, `animatedSwitcher` y
  `customBuilder`.
- `test/src/`: pruebas de widgets por familia.
- `example/lib/main.dart`: demostración que depende del package mediante `path`.
- `.github/workflows/dart.yml`: CI actual; ejecuta `flutter test` en stable.

## Compatibilidad y API

- Consultar `pubspec.yaml` antes de usar APIs nuevas. Actualmente declara Dart
  `^3.13.0` y Flutter `>=3.47.0`; no elevar estos mínimos de forma incidental.
- Las dependencias de producción son Flutter y `material_ui: ^1.4.0`. Usar
  `package:material_ui/material_ui.dart` en biblioteca, ejemplo y tests; evitar
  mezclar tipos Material legacy con los del package. No añadir gestores de estado
  para compartir un booleano.
- Preservar nombres, constructores, valores por defecto, tipos y exports públicos.
  Un cambio de API requiere documentar la migración y su impacto de versionado.
- Mantener las propiedades Material en todas las rutas de construcción: normal,
  `.icon` con y sin icono, Filled tonal/tonalIcon, IconButton y FAB por variante.
- Evitar que implementaciones internas importen el barrel público del package.
- Mantener código, Dartdoc y documentación pública en inglés, como el repositorio.

## Contratos que deben proteger los cambios

Estos son los comportamientos deseados; no asumir que todas las variantes ya los
cumplen. Si se detecta un incumplimiento fuera del alcance, registrarlo por separado.

- Una operación pendiente impide reentradas incluso antes del siguiente frame.
- `loading` externo y la operación interna son fuentes independientes: poner
  `loading: false` no debe dar por terminado un Future pendiente.
- Restaurar el estado en `finally`; comprobar `mounted` después de un `await`.
  No silenciar excepciones ni introducir una política de errores ajena al consumidor.
- Sin callbacks utilizables, conservar el comportamiento disabled de Material.
  Durante carga, comprobar también pulsación larga, teclado y semántica.
- La `key` pública pertenece al wrapper. No reutilizar una `GlobalKey` en un hijo.
- Conservar foco, hover, estilo, selección, alineación y opciones de las variantes.
- Revisar transiciones con `loadingChild` custom, contenido de distinto tamaño,
  texto escalado, temas y accesibilidad. Un widget invisible no implica que sea
  inaccesible a gestos o al árbol semántico.
- Un refactor compartido debe preservar contratos específicos de IconButton y FAB.
  Preferir helpers privados pequeños a una jerarquía pública de botones nueva.

## Flujo de trabajo y validación

1. Leer el diff y las implementaciones hermanas antes de editar. Preservar los
   cambios previos del usuario, incluidos los lockfiles del ejemplo.
2. Identificar el SDK con `flutter --version`. Usar el mismo SDK para resolver,
   analizar y ejecutar tests. Si `.dart_tool/package_config.json` apunta a otro SDK,
   regenerarlo con `flutter pub get` y revisar los cambios derivados.
3. Para un fix, demostrar primero la regresión mediante el contrato observable.
   Mantener la modificación centrada en ese comportamiento.
4. Ejecutar, según el alcance:

   ```sh
   flutter pub get
   flutter test test/src/async_elevated_button_test.dart
   flutter analyze
   flutter test
   dart format --output=none --set-exit-if-changed lib test example/lib
   git diff --check
   ```

   El archivo de test del ejemplo del comando se sustituye por el afectado.
   Formatear únicamente los archivos Dart modificados; no mezclar una limpieza
   global con un fix. Los cambios solo documentales requieren comprobar el diff
   y sus enlaces, no añadir tests sin comportamiento que validar.
5. Antes de declarar compatibilidad, probar el mínimo Flutter declarado y stable.
   Si falta un SDK o falla la resolución, informar la limitación; no presentar una
   comprobación pendiente como aprobada.
6. Cambios públicos de comportamiento/API: actualizar README, ejemplo y CHANGELOG
   cuando corresponda. No publicar ni cambiar de versión por rutina.

## Calidad de los tests

- Priorizar interacción, disabled/semántica, finalización/error, dispose durante
  carga, actualización externa y forwarding con efectos observables.
- Usar `Completer<void>` para controlar Futures cuando se prueba concurrencia.
  Evitar esperas arbitrarias y `pumpAndSettle` mientras hay un spinner infinito.
- Comprobar ida y vuelta de las transiciones; montar una variante sin activarla
  no prueba su carga. Esperar la duración pertinente al comprobar contenido saliente.
- Una matriz pequeña puede cubrir un contrato común; conservar casos específicos
  para los riesgos propios de cada familia.
- No añadir pruebas de existencia, eco de propiedades o árboles internos salvo
  que protejan un contrato público independiente. No exponer API solo para tests.
- Si una prueba conserva un bug, corregir su expectativa desde el contrato; no
  borrarla únicamente para que pase la suite.

## Configuración y notas locales

El analyzer activa inferencia y tipos raw estrictos, además de `dart_code_linter`.
No añadir supresiones globales para ocultar nuevos problemas ni ejecutar
`dart fix --apply` indiscriminadamente. Revisar primero los diagnósticos y el diff.

`.local-review/` contiene una evaluación y propuestas locales ignoradas por Git.
Es opcional y no estará disponible en un clon limpio. No convertir sus propuestas
en alcance autorizado automáticamente ni forzar su inclusión con `git add -f`.
Mantener aquí las instrucciones duraderas y en esa carpeta los hallazgos fechados.
