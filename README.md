# Chronicles Language

Un lenguaje de programación educativo y expresivo, inspirado en la legibilidad de Python, la estructura de Java y la sencillez conceptual de Lox; implementado **desde cero en Dart**: lexer, parser, AST, intérprete, REPL y pruebas.

---

## Tabla de contenidos

1. [Visión general](#1-visión-general)
2. [Instalación y uso rápido](#2-instalación-y-uso-rápido)
3. [CLI y modos de ejecución](#3-cli-y-modos-de-ejecución)
4. [Ejemplos esenciales](#4-ejemplos-esenciales)
5. [Sintaxis del lenguaje (cheat-sheet)](#5-sintaxis-cheat-sheet)
6. [Gramática formal (EBNF simplificada)](#6-gramática-ebnf-simplificada)
7. [Sistema de tipos declarativo (básico)](#7-sistema-de-tipos-básico)
8. [Modelo de ejecución y arquitectura](#8-modelo-de-ejecución-y-arquitectura)
9. [Funciones nativas (builtins)](#9-funciones-nativas-builtins)
10. [Manejo de errores](#10-manejo-de-errores)
11. [Pruebas y verificación académica](#11-pruebas-y-verificación-académica)
12. [Diferencias y decisiones de diseño](#12-diferencias-y-decisiones-de-diseño)
13. [Limitaciones y trabajo futuro](#13-limitaciones-y-trabajo-futuro)
14. [Estructura del repositorio](#14-estructura-del-repositorio)
15. [Autores y licencia](#15-autores-y-licencia)

---

## 1. Visión general

Chronicles es un lenguaje imperativo con:

- Tipado dinámico en tiempo de ejecución + anotaciones nominales opcionales (`let x: Number = 10`).
- Indentación significativa (bloques por sangría) con tokens `INDENT/DEDENT` generados por el lexer.
- Funciones de primera clase con recursión directa.
- Clases, objetos, métodos enlazados y constructor especial `__init__`.
- Control de flujo: `if / elif / else`, `while`, y `for` numérico (rango inclusivo al estilo contador).
- Retorno mediante `return` (soporta retorno temprano dentro de bloques anidados).
- Comentarios de línea `#` y soporte interno en REPL.

Objetivo académico: demostrar el ciclo completo de implementación de un lenguaje (tokenización → parsing → AST → interpretación) con un código altamente comentado en español.

Repositorio oficial: <https://github.com/EvilNightmare010/chronicles.git>

---

## 2. Instalación y uso rápido

Requisitos: Dart >= 3.x instalado (<https://dart.dev/get-dart>)

```powershell
git clone https://github.com/EvilNightmare010/chronicles.git
cd chronicles-lang
dart pub get
```

Ejecutar un programa:

```powershell
dart run bin/chronicles.dart examples/hola.chron
```

REPL interactivo:

```powershell
dart run bin/chronicles.dart --repl
```

Modo detallado (rastreo interno):

```powershell
dart run bin/chronicles.dart -v examples/fib.chron
```

Ejecutar pruebas:

```powershell
dart test
```

---

## 3. CLI y modos de ejecución

`bin/chronicles.dart` admite:

- `chronicles <archivo.chron>`: Ejecuta un script.
- `chronicles --repl`: Inicia el entorno interactivo (multi‑línea).
- `chronicles -v <archivo>`: Traza pasos (tokens, AST, resultados intermedios) para depuración académica.

Salida de error estandarizada con línea y lexema cuando aplica.

---

## 4. Ejemplos esenciales

### 4.1 Fibonacci (recursión)

```chron
fun fib(n):
    if n <= 1:
        return n
    else:
        return fib(n - 1) + fib(n - 2)
print(fib(10))  # 55
```

### 4.2 Factorial con acumulador

```chron
fun fact(n, acc):
    if n <= 1:
        return acc
    return fact(n - 1, n * acc)
print(fact(5, 1))  # 120
```

### 4.3 Clase con constructor y método

```chron
class Persona:
    fun __init__(self, nombre):
        self.nombre = nombre

    fun saludar(self):
        print("Hola, soy", self.nombre)

let p = Persona("Ada")
p.saludar()
```

### 4.4 Bucle for (rango inclusivo)

```chron
for i in 1..5:
    print(i)
```

### 4.5 Bucle while

```chron
let i = 3
while i > 0:
    print(i)
    i = i - 1
```

### 4.6 Condicional encadenado

```chron
let x = 42
if x < 0:
    print("negativo")
elif x == 0:
    print("cero")
else:
    print("positivo")
```

### 4.7 Métodos y propiedades

```chron
class Caja:
    fun __init__(self, valor):
        self.valor = valor
    fun doble(self):
        return self.valor * 2
let c = Caja(7)
print(c.doble())  # 14
```

---

## 5. Sintaxis (Cheat-sheet)

| Concepto | Ejemplo |
|----------|---------|
| Variable | `let x = 10` / `let y: Number = 5` |
| Función  | `fun suma(a, b): return a + b` |
| Retorno  | `return expr` |
| If       | `if cond: ... elif cond: ... else: ...` |
| While    | `while cond: ...` |
| For      | `for i in 1..10: ...` |
| Clase    | `class Nombre: ...` |
| Constructor | `fun __init__(self, ...): ...` |
| Método   | `fun metodo(self, otros): ...` |
| Llamada método | `obj.metodo(args)` |
| Comentario | `# esto es un comentario` |
| Booleanos | `true`, `false` |
| Null | `null` |
| Operadores | `+ - * / % == != < <= > >= and or not` |

---

## 6. Gramática (EBNF simplificada)

Nota: El parser es de descenso recursivo. Se omiten reglas auxiliares menores para brevedad.

```ebnf
program        := declaration* EOF ;
declaration    := classDecl | funDecl | varDecl | statement ;
classDecl      := "class" IDENTIFIER ':' INDENT classMember* DEDENT ;
classMember    := funDecl | varDecl | statement ;
funDecl        := "fun" IDENTIFIER '(' parameters? ')' ':' INDENT declaration* DEDENT ;
parameters     := IDENTIFIER (',' IDENTIFIER)* ;
varDecl        := "let" IDENTIFIER (':' IDENTIFIER)? ('=' expression)? NEWLINE ;
statement      := ifStmt | whileStmt | forStmt | returnStmt | block | exprStmt ;
block          := ':' INDENT declaration* DEDENT ;
ifStmt         := "if" expression block ("elif" expression block)* ("else" block)? ;
whileStmt      := "while" expression block ;
forStmt        := "for" IDENTIFIER "in" expression '..' expression block ;
returnStmt     := "return" expression? NEWLINE ;
exprStmt       := expression NEWLINE? ;  // NEWLINE opcional tolerado
expression     := assignment ;
assignment     := or ( '=' assignment )? ;
or             := and ( 'or' and )* ;
and            := equality ( 'and' equality )* ;
equality       := comparison ( ( '==' | '!=' ) comparison )* ;
comparison     := term ( ( '>' | '>=' | '<' | '<=' ) term )* ;
term           := factor ( ( '+' | '-' ) factor )* ;
factor         := unary ( ( '*' | '/' | '%' ) unary )* ;
unary          := ( '!' | '-' | 'not' ) unary | call ;
call           := primary ( '(' arguments? ')' | '.' IDENTIFIER )* ;
arguments      := expression ( ',' expression )* ;
primary        := NUMBER | STRING | 'true' | 'false' | 'null' | IDENTIFIER | '(' expression ')' ;
```

Reglas léxicas destacadas:

- Sangría genera pares `INDENT/DEDENT` similares a Python.
- Comentarios: desde `#` hasta fin de línea (ignored tokens).
- Literales soportados: números (enteros), cadenas entre comillas dobles.

Tolerancia implementada: el parser actualmente permite (en modo relajado) omitir un `)` final aislado en algunos contextos internos de depuración; esto se documenta para transparencia académica.

---

## 7. Sistema de tipos (básico)

El runtime es dinámico; las anotaciones tras `:` en declaraciones de variables son meta‑datos que el entorno utiliza para validar asignaciones posteriores (consistencia nominal simple). Ejemplo:

```chron
let n: Number = 10
n = 20        # OK
n = "hola"    # Error de tipo (reportado en tiempo de ejecución)
```

Restricciones actuales:

- No existe inferencia avanzada ni coerción implícita.
- Las anotaciones no afectan la representación interna de valores, sirven para chequeo y documentación.

---

## 8. Modelo de ejecución y arquitectura

Pipeline: Código fuente → Lexer → Tokens (+ INDENT/DEDENT) → Parser → AST → Intérprete (visitor) → Salida.

Componentes (ver `ARCHITECTURE.md` para profundidad):

- `lexer.dart`: gestiona posición, genera tokens, controla pila de indentación.
- `parser.dart`: descenso recursivo, sincronización ante errores, saltos de ruido (`_skipNoise`).
- `ast.dart`: nodos inmutables + patrón visitante.
- `interpreter.dart`: evalúa expresiones y ejecuta declaraciones; soporte para recursión y métodos enlazados (binding de `self`).
- `environment.dart`: scopes encadenados y verificación de tipo nominal.
- `value.dart`: estructuras para funciones, clases, métodos vinculados y objetos.
- `builtins.dart`: registro de funciones nativas.
- `repl.dart`: loop interactivo multilinea con captura de acumulación hasta bloque completo.

Recursión: Las funciones se insertan en el entorno antes de evaluar su cuerpo (`hoisting` manual) permitiendo llamada recursiva directa.

Clases: Se crea un `ClassValue` con mapa de métodos. Instanciación produce `ObjectValue` con tabla de campos dinámica. `__init__` se invoca automáticamente si existe.

---

## 9. Funciones nativas (builtins)

Disponibles globalmente:

- `print(x, ...)`: Imprime argumentos.
- `len(x)`: Longitud de cadenas / listas futuras (por ahora solo cadenas).
- `clock()`: Tiempo (ms) desde epoch.
- `abs(n)`, `max(a,b)`, `min(a,b)`.

Extender: agregar en `builtins.dart` registrando nueva clave en el mapa global.

---

## 10. Manejo de errores

Tipos de errores:

- Léxicos: caracteres inválidos, indentación inconsistente.
- Sintácticos: token inesperado, falta de `:` o cierre de bloque.
- De ejecución: variable no definida, tipo incompatible en operación, acceso a propiedad inexistente.
- De retorno: implementado mediante excepción interna controlada (`ReturnSignal`).

Estrategias:

- Recuperación parcial en parser saltando hasta puntos seguros (NEWLINE / DEDENT / keywords).
- Mensajes detallan línea y lexema cuando aplica.

---

## 11. Pruebas y verificación académica

Ubicación: carpeta `test/`.

- `scanner/lexer` tests: tokens, indentación, comentarios.
- `parser` tests: clases, funciones, asignaciones, precedencia.
- `interpreter` tests: recursión, control de flujo, métodos, tipos.

Ejecutar: `dart test`.

Checklist para calificación:

1. Lexer propio con indentación → Sí (`lexer.dart`).
2. Parser recursivo con AST → Sí (`parser.dart` + `ast.dart`).
3. Evaluador/Intérprete completo → Sí (`interpreter.dart`).
4. REPL funcional → Sí (`repl.dart`).
5. Clases y métodos → Sí (constructor `__init__`, propiedades dinámicas).
6. Funciones y recursión → Sí (factorial, fibonacci).
7. Tipado declarativo opcional → Sí (`let x: Tipo = ...`).
8. Comentarios línea a línea en código → Sí (archivos en `lib/src/`).
9. Pruebas automatizadas → Sí (carpeta `test/`).
10. Ejemplos ejecutables → Sí (carpeta `examples/`).

---

## 12. Diferencias y decisiones de diseño

- Bloques por indentación: se implementa pila de niveles; reduce ruido sintáctico.
- Parser tolerante: se permite un `NEWLINE` opcional al final de una expresión suelta; facilita REPL.
- Tipos nominales simples: prioriza claridad sobre complejidad de inferencia.
- Sin herencia todavía: se decidió posponer para mantener foco en fundamentos.
- Semántica estricta de comparación: solo compara tipos compatibles (en pruebas). Falta coerción.
- Diseño educativo: nombres de métodos y variables explícitos, comentarios extensos.

---

## 13. Limitaciones y trabajo futuro

- Herencia de clases y super‑llamadas.
- Colecciones nativas (listas, diccionarios) enriquecidas.
- Tipado gradual real (chequeos estáticos parciales).
- Optimizaciones (memoización para recursión, tail‑call).
- Generación de bytecode o JIT tras el AST.
- Módulos / importación de archivos.

---

## 14. Estructura del repositorio

```text
bin/              # Entrada CLI
lib/src/          # Núcleo del lenguaje (lexer, parser, AST, intérprete, valores, entorno, builtins, REPL)
examples/         # Programas de demostración (.chron)
test/             # Pruebas unitarias
ARCHITECTURE.md   # Profundiza en decisiones técnicas
CONTRIBUTING.md   # Guía de colaboración
```

---

## 15. Autores y licencia

Autores:

- Juan José Ramírez Pulgarín
- Lucas Henao Fernández

Licencia: MIT (ver `LICENSE`).

Si deseas contribuir, revisa [CONTRIBUTING.md](CONTRIBUTING.md).

---

¿Duda o mejora sugerida? Abre un issue o comenta en el repositorio.
