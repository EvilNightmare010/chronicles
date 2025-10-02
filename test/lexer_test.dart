// Pruebas unitarias para el lexer de Chronicles

import 'package:test/test.dart'; // Framework de pruebas
import '../lib/src/lexer.dart'; // Lexer a probar
import '../lib/src/token.dart'; // Tipos de tokens

void main() { // Entrada pruebas
  test('Escanea tokens básicos', () { // Caso básico
    final code = 'var x = 5\nprint(x)\n'; // Código fuente
    final lexer = Lexer(code, '<test>'); // Instancia lexer
    final tokens = lexer.scanTokens(); // Obtiene tokens
    expect(tokens.any((t) => t.type == TokenType.var_), isTrue); // Contiene var
    expect(tokens.any((t) => t.type == TokenType.identifier), isTrue); // Contiene id
    expect(tokens.any((t) => t.type == TokenType.number), isTrue); // Contiene número
    // print ahora es un identificador normal, no una palabra clave especial
    expect(tokens.where((t) => t.type == TokenType.identifier).length >= 2, isTrue); // Al menos 2 identificadores (x y print)
  });
}
