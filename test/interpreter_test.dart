// Pruebas unitarias para el intérprete de Chronicles

import 'package:test/test.dart'; // Framework test
import '../lib/src/lexer.dart'; // Lexer
import '../lib/src/parser.dart'; // Parser
import '../lib/src/interpreter.dart'; // Intérprete

void main() { // Entrada pruebas intérprete
  test('Ejecuta suma simple', () { // Caso suma
    final code = 'var x = 2\nvar y = 3\nprint(x + y)\n'; // Fuente
  final lexer = Lexer(code, '<test>'); // Lexer
  final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    final interpreter = Interpreter(); // Intérprete
    interpreter.run(ast); // Ejecuta
    // Verifica ausencia de errores // Sin assert de salida
  }); // Fin test suma

  test('Ejecuta función y return', () { // Caso función/return
    final code = 'fun doble(n):\n    return n * 2\nprint(doble(4))\n'; // Fuente
  final lexer = Lexer(code, '<test>'); // Lexer
  final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    final interpreter = Interpreter(); // Intérprete
    interpreter.run(ast); // Ejecuta
  }); // Fin test función

  test('Bucle for simple', () { // Caso for
    final code = 'var acc = 0\nfor i in 5:\n    acc = acc + 1\nprint(acc)\n'; // Fuente
  final lexer = Lexer(code, '<test>'); // Lexer
  final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    final interpreter = Interpreter(); // Intérprete
    interpreter.run(ast); // Ejecuta
  }); // Fin test for

  test('Recursión factorial', () { // Caso recursión
    final code = 'fun fact(n):\n    if n == 0:\n        return 1\n    return n * fact(n - 1)\nprint(fact(5))\n'; // Fuente
  final lexer = Lexer(code, '<test>'); // Lexer
  final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    final interpreter = Interpreter(); // Intérprete
    interpreter.run(ast); // Ejecuta
  }); // Fin test factorial

  test('Operadores lógicos y negación', () { // Caso lógicos
    final code = 'var a = 1\nvar b = 2\nprint((a < b) and (b < 5))\nprint((a > b) or (b == 2))\nprint(!(a == b))\n'; // Fuente
  final lexer = Lexer(code, '<test>'); // Lexer
  final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    final interpreter = Interpreter(); // Intérprete
    interpreter.run(ast); // Ejecuta
  }); // Fin test lógicos

  test('Clases: instanciación y método', () { // Caso clases básicos
    final code = 'class Persona:\n    fun __init__(nombre):\n        this.nombre = nombre\n    fun saludar():\n        print(this.nombre)\n\nvar p = Persona(\"Ana\")\np.saludar()\n'; // Fuente clase
  final lexer = Lexer(code, '<test>'); // Lexer
  final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    final interpreter = Interpreter(); // Intérprete
    interpreter.run(ast); // Ejecuta
  }); // Fin test clase método

  test('Asignación de propiedad posterior', () { // Caso set propiedad
    final code = 'class Caja:\n    fun __init__():\n        this.valor = 0\n\nvar c = Caja()\nc.valor = 10\nprint(c.valor)\n'; // Fuente caja
  final lexer = Lexer(code, '<test>'); // Lexer
  final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    final interpreter = Interpreter(); // Intérprete
    interpreter.run(ast); // Ejecuta
  }); // Fin test propiedad

  test('Tipado: declaración y asignación compatible', () { // Caso tipado ok
    final code = 'var x: number = 3\nvar y: string = \"hola\"\nx = 5\n'; // Fuente tipado
    final lexer = Lexer(code, '<test>'); // Lexer
    final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    final interpreter = Interpreter(); // Intérprete
    interpreter.run(ast); // Ejecuta sin error
  }); // Fin test tipado ok

  test('Tipado: error de tipo en asignación', () { // Caso tipado error
    final code = 'var x: number = 3\nx = \"cadena\"\n'; // Fuente error tipo
    final lexer = Lexer(code, '<test>'); // Lexer
    final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    final interpreter = Interpreter(); // Intérprete
    expect(() => interpreter.run(ast), throwsA(isA<Exception>())); // Debe lanzar
  });
}