# BTG Funds App

Aplicacion desarrollada en Flutter como prueba tecnica para la gestion de fondos FPV/FIC. La app permite consultar fondos disponibles, suscribirse, cancelar suscripciones y revisar el historial de transacciones, aplicando reglas de negocio basicas sobre saldo y estado de suscripcion.

## Stack Tecnologico

- Flutter
- `flutter_bloc` para manejo de estado
- `auto_route` para navegacion
- `Hive` para persistencia local
- `Kiwi` para inyeccion de dependencias
- `intl` para formato de fechas y moneda

## Arquitectura

El proyecto esta organizado por capas:

- `lib/domain`: modelos, contratos y reglas del negocio
- `lib/infrastructure`: datasources, adapters y repositorios concretos
- `lib/presentation`: UI, navegacion y manejo de estado

Dentro de `presentation` la estructura se organizo por funcionalidad para mantener juntos el `screen`, `cubit` y `state` de cada feature:

- `home`
- `funds`
- `portfolio`
- `transaction_history`
- `subscribe`
- `widgets` para componentes reutilizables

## Funcionalidades Principales

- Consulta de fondos disponibles
- Filtro y busqueda de fondos e historial
- Suscripcion a fondos validando saldo minimo
- Cancelacion de suscripciones con devolucion al saldo
- Registro de historial de transacciones
- Persistencia local de saldo, suscripciones e historial

## Ejecucion

### Web

Ejecutar siempre en `localhost:8090`:

- Desde Cursor/VS Code usa `Run and Debug` con la configuracion `Flutter (Chrome 8090)`.
- Si ejecutas por terminal, usa:

```bash
flutter run -d chrome --web-hostname localhost --web-port 8090
```

### Dependencias

```bash
flutter pub get
```

### Tests

```bash
flutter test
```

## Notas Tecnicas

- Los fondos se cargan desde un datasource mock (`MockApiDatasource`).
- La informacion local se guarda en Hive mediante `HiveLocalDatasource`.
- Se implementaron adapters para desacoplar DTOs y modelos de dominio.
- La inyeccion de dependencias se centraliza en `lib/core/di/injector.dart`.
- La navegacion se resuelve con `auto_route`, incluyendo manejo especial para web en la vista de suscripcion.

## Estructura Principal

```text
lib/
  core/
  domain/
  infrastructure/
  presentation/
    home/
    funds/
    portfolio/
    transaction_history/
    subscribe/
    widgets/
```

## Consideraciones Para Revision

- La solucion prioriza separacion de responsabilidades y mantenibilidad.
- El dominio no depende de detalles de infraestructura.
- La UI reutiliza widgets compartidos para mantener consistencia visual.
- Se incluyen pruebas unitarias para cubits y adapters.
