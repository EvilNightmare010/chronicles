# Decisiones de arquitectura de chronicles-lang

## Lexer

- Implementado en `lib/src/lexer.dart`.
- Genera tokens incluyendo indent/dedent para bloques basados en sangría.
- Normaliza tabs como 4 espacios para consistencia.
- Reconoce palabras clave, literales, operadores y comentarios línea completa (`#`).

## Parser

- Descenso recursivo con funciones por nivel de precedencia (or, and, equality, comparison, term, factor, unary, call, primary).
- Maneja clases con métodos indentados, funciones, variables tipadas opcionalmente, bucles `for` numérico y `while`, condicionales `if/elif/else`, llamadas encadenadas y acceso/asignación a propiedades.

## AST

- Nodos definidos en `ast.dart` con patrón Visitor para separación de sintaxis y semántica.
- Incluye nodos para propiedades (`Get`, `Set`) y clases (`ClassDecl`).

## Intérprete

- Implementación walk-the-AST en `interpreter.dart`.
- Maneja scopes anidados (`Environment`), retorno con excepción controlada, clases, binding de métodos mediante `BoundMethod` y constructor `__init__`.
- Tipado básico declarativo validado en asignaciones de variables.

## Valores

- Jerarquía en `value.dart`: números, cadenas, booleanos, null, funciones, clases, instancias y métodos ligados.

## Builtins

- Definidos en `builtins.dart` (`print`, `len`, `clock`, `abs`, `max`, `min`).

## REPL

- En `repl.dart`, reutiliza pipeline completo (lexer → parser → intérprete) línea a línea.

## Pruebas y CLI

- CLI en `bin/chronicles.dart` para ejecutar archivos `.chron` o iniciar REPL.
- Pruebas en `test/` abarcan lexer, parser, intérprete, clases y tipado.

## Salida y Captura

- `io_sink.dart` provee utilitario de captura (extensible si se desea redirigir print).
