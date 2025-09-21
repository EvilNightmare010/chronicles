// Pruebas unitarias para el parser de Chronicles

import 'package:test/test.dart'; // Framework test
import '../lib/src/lexer.dart'; // Lexer
import '../lib/src/parser.dart'; // Parser
import '../lib/src/ast.dart'; // Definiciones AST

void main() { // Entrada pruebas
  test('Parsea declaración de variable', () { // Caso var
    final code = 'var x = 42\n'; // Fuente
  final lexer = Lexer(code, '<test>'); // Lexer
  final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    expect(ast.statements.first, isA<VarDecl>()); // Es VarDecl
  }); // Fin test var

  test('Parsea función simple', () { // Caso función
    final code = 'fun suma(a, b):\n    return a + b\n'; // Fuente
  final lexer = Lexer(code, '<test>'); // Lexer
  final tokens = lexer.scanTokens(); // Tokens
    final parser = Parser(tokens); // Parser
    final ast = parser.parse(); // AST
    expect(ast.statements.first, isA<FunDecl>()); // Es FunDecl
  });
}