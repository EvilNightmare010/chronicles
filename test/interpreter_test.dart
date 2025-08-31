// Pruebas unitarias para el intérprete de Chronicles

import 'package:test/test.dart';
import '../lib/src/scanner.dart';
import '../lib/src/parser.dart';
import '../lib/src/interpreter.dart';

void main() {
  test('Ejecuta suma simple', () {
    final code = 'var x = 2\nvar y = 3\nprint(x + y)\n';
    final scanner = Scanner(code, '<test>');
    final tokens = scanner.scanTokens();
    final parser = Parser(tokens);
    final ast = parser.parse();
    final interpreter = Interpreter();
    interpreter.run(ast);
    // No hay aserción de salida, solo verifica que no haya error
  });

  test('Ejecuta función y return', () {
    final code = 'fun doble(n):\n    return n * 2\nprint(doble(4))\n';
    final scanner = Scanner(code, '<test>');
    final tokens = scanner.scanTokens();
    final parser = Parser(tokens);
    final ast = parser.parse();
    final interpreter = Interpreter();
    interpreter.run(ast);
  });
}