// Pruebas unitarias para el scanner de Chronicles

import 'package:test/test.dart';
import '../lib/src/scanner.dart';
import '../lib/src/token.dart';

void main() {
  test('Escanea tokens básicos', () {
    final code = 'var x = 5\nprint(x)\n';
    final scanner = Scanner(code, '<test>');
    final tokens = scanner.scanTokens();
    expect(tokens.any((t) => t.type == TokenType.var_), isTrue);
    expect(tokens.any((t) => t.type == TokenType.identifier), isTrue);
    expect(tokens.any((t) => t.type == TokenType.number), isTrue);
    expect(tokens.any((t) => t.type == TokenType.print_), isTrue);
  });
}