
# chronicles-lang

Un lenguaje de programación moderno inspirado en la sintaxis de Python y la disciplina de Java, implementado en Dart.

## Repositorio

Repositorio oficial: [https://github.com/EvilNightmare010/chronicles.git](https://github.com/EvilNightmare010/chronicles.git)

## Autores

- Juan José Ramírez Pulgarín
- Lucas Henao Fernández

## Instalación

```sh
git clone https://github.com/EvilNightmare010/chronicles.git
cd chronicles-lang
dart pub get
```

## Ejecución rápida

```sh
dart run bin/chronicles.dart examples/hola.chron
```

### Modo REPL

```sh
dart run bin/chronicles.dart --repl
```

### Verbose

```sh
dart run bin/chronicles.dart -v examples/hola.chron
```

## Ejemplo de código Chronicles

```chron
# Ejemplo: Fibonacci
def fib(n):
     if n <= 1:
          return n
     else:
          return fib(n-1) + fib(n-2)
print(fib(10))
```

## Verificación y pruebas del lenguaje

Este proyecto implementa **Chronicles**, un lenguaje de programación propio, desarrollado completamente en Dart. El repositorio incluye:

- Analizador léxico (scanner) con soporte de indentación y comentarios.
- Analizador sintáctico (parser) por descenso recursivo, siguiendo la gramática definida.
- Árbol de sintaxis abstracta (AST) y patrón visitante.
- Intérprete walk-the-ast, con manejo de variables, funciones, clases y bloques.
- Funciones nativas (print, len, clock, helpers matemáticos).
- REPL interactivo y CLI para ejecutar archivos `.chron`.
- Ejemplos de programas Chronicles y pruebas unitarias para cada módulo.
- Documentación, guía de estilo y arquitectura.

### ¿Cómo verificar que es un lenguaje propio?

1. **Todo el código fuente está en Dart** y se encuentra en la carpeta `lib/src/`.
1. **El CLI** (`bin/chronicles.dart`) ejecuta archivos `.chron` y permite usar el REPL.
1. **La extensión de archivos fuente es `.chron`**, exclusiva de Chronicles.
1. **El scanner y parser** procesan la sintaxis definida en este README y en `ARCHITECTURE.md`.
1. **El intérprete ejecuta el AST** generado por el parser, soportando variables, funciones, clases, condicionales y bucles.
1. **Las pruebas unitarias** en la carpeta `test/` validan el funcionamiento de scanner, parser e intérprete.
1. **Ejemplos de código** en la carpeta `examples/` muestran el uso real del lenguaje.
1. **El workflow de CI** en `.github/workflows/dart.yml` verifica automáticamente el código y las pruebas.

### ¿Cómo ejecutar y probar Chronicles?

1. Instala Dart ([https://dart.dev/get-dart](https://dart.dev/get-dart)).

1. Clona el repositorio y entra a la carpeta:

    ```sh
    git clone https://github.com/EvilNightmare010/chronicles.git
    cd chronicles-lang
    dart pub get
    ```

1. Ejecuta cualquier archivo `.chron`:

    ```sh
    dart run bin/chronicles.dart examples/hola.chron
    ```

1. Usa el modo REPL interactivo:

    ```sh
    dart run bin/chronicles.dart --repl
    ```

1. Ejecuta en modo verbose (detallado):

    ```sh
    dart run bin/chronicles.dart -v examples/hola.chron
    ```

1. Ejecuta las pruebas unitarias:

    ```sh
    dart test
    ```

## Estructura del proyecto

- `bin/chronicles.dart`: CLI principal y REPL.
- `lib/src/`: Módulos del lenguaje (scanner, parser, ast, interpreter, etc).
- `examples/`: Programas de ejemplo en Chronicles.
- `test/`: Pruebas unitarias para cada módulo.
- `.github/workflows/dart.yml`: CI automático.
- `ARCHITECTURE.md`: Decisiones de diseño y arquitectura.

## ¿Cómo funciona el CLI?

El archivo `bin/chronicles.dart` permite:

- Ejecutar cualquier archivo `.chron` y mostrar la salida.
- Iniciar el REPL interactivo para probar código línea a línea.
- Usar el modo verbose para ver el proceso interno del intérprete.

Ejemplo de uso:

```sh
dart run bin/chronicles.dart examples/fib.chron
```

## ¿Cómo verificar el funcionamiento del lenguaje?

1. Revisa los ejemplos en `examples/` y ejecútalos con el CLI.
1. Revisa las pruebas en `test/` y ejecútalas con `dart test`.
1. Lee los comentarios en español en cada archivo fuente para entender la lógica.
1. Consulta la arquitectura en `ARCHITECTURE.md`.

## ¿Qué hace único a Chronicles?

- Sintaxis inspirada en Python y Java, con indentación obligatoria y tipado opcional.
- Implementación 100% propia en Dart, sin dependencias externas para el core del lenguaje.
- Soporte para clases, funciones, variables, condicionales, bucles y funciones nativas.
- Extensión `.chron` exclusiva.

---

Lee [CONTRIBUTING.md](CONTRIBUTING.md) para detalles.

## Licencia

MIT
