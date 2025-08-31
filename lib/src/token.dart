// Definición de tokens para el lenguaje Chronicles

/// Tipos de token soportados
enum TokenType {
  // Palabras clave
  var_, fun, class_, if_, elif_, else_, while_, return_, print_,
  // Tipos
  number_, string_, bool_, null_, object_, function_,
  // Símbolos
  lparen, rparen, lbrace, rbrace, colon, comma, dot, arrow, assign,
  // Operadores
  plus, minus, star, slash, percent, eq, neq, lt, gt, le, ge,
  // Literales
  identifier, number, string, bool, null,
  // Indentación
  indent, dedent, newline,
  // Comentario
  comment,
  // Fin de archivo
  eof,
}

/// Representa un token individual
class Token {
  final TokenType type;
  final String lexeme;
  final int line;
  final int column;

  Token(this.type, this.lexeme, this.line, this.column);

  @override
  String toString() => 'Token($type, "$lexeme", línea: $line, columna: $column)';
}