# Decisiones de arquitectura de chronicles-lang

- El lexer soporta INDENT/DEDENT como Python, usando una pila de niveles de indentación.
- El parser es de descenso recursivo, con precedencia de operadores.
- El AST es extensible y usa el patrón visitante.
- El intérprete camina el AST y maneja ámbitos anidados.
- Los valores se representan con clases Dart para tipos nativos y objetos.
- Las funciones nativas se definen en builtins.dart.
- El REPL usa historial simple y modo verbose.
- La salida se puede capturar para pruebas.
