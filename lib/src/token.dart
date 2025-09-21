// Definición de tokens para el lenguaje Chronicles

/// Tipos de token soportados
enum TokenType {
  // Palabras clave
  var_,   // Declaración de variable
  fun,    // Declaración de función
  class_, // Declaración de clase
  if_,    // Condicional if
  elif_,  // Rama intermedia elif
  else_,  // Rama else
  while_, // Bucle while
  for_,   // Bucle for
  in_,    // Palabra clave in para for
  return_,// Sentencia return
  print_, // Sentencia print
  and_,   // Operador lógico and
  or_,    // Operador lógico or
  // Tipos
  number_, string_, bool_, null_kw, object_, function_, // Palabras clave de tipos (null_kw)
  // Símbolos
  lparen, rparen, lbrace, rbrace, colon, comma, dot, arrow, assign, // Símbolos de puntuación
  // Operadores
  plus,   // + suma / concatenación
  minus,  // - resta / unario negativo
  star,   // * multiplicación
  slash,  // / división
  percent,// % módulo
  eq,     // == igualdad
  neq,    // != desigualdad
  lt,     // < menor que
  gt,     // > mayor que
  le,     // <= menor o igual
  ge,     // >= mayor o igual
  bang,   // ! negación lógica
  // Literales
  identifier, number, string, bool, null_, // Tokens de literales y nombres
  // Indentación
  indent, dedent, newline, // Control de bloques basado en indentación
  // Comentario
  comment, // Token de comentario (ignorado en parser)
  // Fin de archivo
  eof, // Fin de archivo
} // Fin enum TokenType

/// Representa un token individual // Comentario clase Token
class Token { // Inicio clase Token
  final TokenType type; // Tipo del token
  final String lexeme;  // Texto original asociado
  final int line;       // Línea donde aparece
  final int column;     // Columna donde inicia

  Token(this.type, this.lexeme, this.line, this.column); // Constructor asigna campos

  @override
  String toString() => 'Token($type, "$lexeme", línea: $line, columna: $column)';
}