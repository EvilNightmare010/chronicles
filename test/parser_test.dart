// Pruebas unitarias para el parser de Chronicles

import 'package:test/test.dart';
import '../lib/src/scanner.dart';
import '../lib/src/token.dart';
import '../lib/src/parser.dart';
import '../lib/src/ast.dart';

void main() {
  test('Parsea declaración de variable', () {
    final code = 'var x = 42\n';
    final scanner = Scanner(code, '<test>');
    final tokens = scanner.scanTokens();
    final parser = Parser(tokens);
    final ast = parser.parse();
    expect(ast.statements.first, isA<VarDecl>());
  });

  test('Parsea función simple', () {
    final code = 'fun suma(a, b):\n    return a + b\n';
    final scanner = Scanner(code, '<test>');
    final tokens = scanner.scanTokens();
    final parser = Parser(tokens);
    final ast = parser.parse();
    expect(ast.statements.first, isA<FunDecl>());
  });
}