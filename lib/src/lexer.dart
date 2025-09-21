// Analizador léxico para Chronicles con soporte de indentación y comentarios

import 'token.dart'; // Importa definiciones de tokens

/// Convierte el código fuente en una lista de tokens
class Lexer { // Clase Lexer
  final String source; // Código fuente completo
  final String fileName; // Nombre del archivo fuente
  int _pos = 0; // Posición actual en la cadena
  int _line = 1; // Línea actual (1-based)
  int _col = 1; // Columna actual (1-based)
  final List<Token> _tokens = []; // Lista acumulada de tokens
  final List<int> _indentStack = [0]; // Pila de niveles de indentación

  Lexer(this.source, this.fileName); // Constructor

  /// Escanea todos los tokens del código fuente
  List<Token> scanTokens() { // Escanea todo el código
    while (!_isAtEnd()) { // Mientras queden caracteres
      _scanToken(); // Escanea un token
    }
    while (_indentStack.length > 1) { // Limpia indentaciones pendientes
      _tokens.add(Token(TokenType.dedent, '', _line, _col)); // Agrega dedent
      _indentStack.removeLast(); // Quita nivel
    }
    _tokens.add(Token(TokenType.eof, '', _line, _col)); // Token EOF
    return _tokens; // Devuelve lista final
  }

  // Escanea un token individual
  void _scanToken() { // Escanea un token
    final c = _advance(); // Obtiene carácter actual
    if (c == '\n') { // Salto de línea
      _line++; // Incrementa línea
      _col = 1; // Reinicia columna
      _tokens.add(Token(TokenType.newline, '', _line, _col)); // Añade token newline
      _handleIndentation(); // Procesa indentación siguiente línea
      return; // Termina
    }
    if (c == '#') { // Comentario
      while (!_isAtEnd() && _peek() != '\n') _advance(); // Consumir hasta fin
      _tokens.add(Token(TokenType.comment, '', _line, _col)); // Token comment
      return; // Termina
    }
    if (c == ' ' || c == '\t') { // Espacio o tab
      return; // Ignorar (indent manejado después)
    }
    switch (c) { // Selección según símbolo
      case '(': _add(TokenType.lparen, '('); break; // (
      case ')': _add(TokenType.rparen, ')'); break; // )
      case '{': _add(TokenType.lbrace, '{'); break; // {
      case '}': _add(TokenType.rbrace, '}'); break; // }
      case ':': _add(TokenType.colon, ':'); break; // :
      case ',': _add(TokenType.comma, ','); break; // ,
      case '.': _add(TokenType.dot, '.'); break; // .
      case '+': _add(TokenType.plus, '+'); break; // +
      case '-': // - o ->
        if (_peek() == '>') { // Si flecha
          _advance(); // Consumir >
          _add(TokenType.arrow, '->'); // Token flecha
        } else { // Solo -
          _add(TokenType.minus, '-'); // Token menos
        }
        break; // Fin -
      case '*': _add(TokenType.star, '*'); break; // *
      case '/': _add(TokenType.slash, '/'); break; // /
      case '%': _add(TokenType.percent, '%'); break; // %
      case '=': // = o ==
        if (_peek() == '=') { // Igualdad
          _advance(); // Consumir segundo =
          _add(TokenType.eq, '=='); // Token ==
        } else { // Asignación
          _add(TokenType.assign, '='); // Token =
        }
        break; // Fin =
      case '!': // ! o !=
        if (_peek() == '=') { // Desigualdad
          _advance(); // Consumir =
          _add(TokenType.neq, '!='); // Token !=
        } else { // Negación
          _add(TokenType.bang, '!'); // Token !
        }
        break; // Fin !
      case '<': // < o <=
        if (_peek() == '=') { // <=
          _advance(); // Consume =
          _add(TokenType.le, '<='); // Token <=
        } else { // <
          _add(TokenType.lt, '<'); // Token <
        }
        break; // Fin <
      case '>': // > o >=
        if (_peek() == '=') { // >=
          _advance(); // Consume =
          _add(TokenType.ge, '>='); // Token >=
        } else { // >
          _add(TokenType.gt, '>'); // Token >
        }
        break; // Fin >
      case '"': // Comilla doble
      case '\'': // Comilla simple
        _scanString(c); // Escanear string
        break; // Fin string
      default: // Otros
        if (_isDigit(c)) { // Número
          _scanNumber(c); // Procesa número
        } else if (_isAlpha(c)) { // Identificador o keyword
          _scanIdentifier(c); // Procesa identificador
        }
        break; // Fin default
    }
  }

  // Maneja la indentación al inicio de línea
  void _handleIndentation() { // Procesa indentación tras newline
    int count = 0; // Contador de espacios
    while (!_isAtEnd() && (_peek() == ' ' || _peek() == '\t')) { // Mientras espacios/tabs
      count += (_peek() == ' ') ? 1 : 4; // Tab cuenta como 4 espacios
      _advance(); // Avanza
    }
    if (count > _indentStack.last) { // Mayor indent => nuevo bloque
      _indentStack.add(count); // Apila nivel
      _tokens.add(Token(TokenType.indent, '', _line, _col)); // Token indent
    } else if (count < _indentStack.last) { // Menor indent => cerrar bloques
      while (_indentStack.length > 1 && count < _indentStack.last) { // Mientras haya niveles por cerrar
        _indentStack.removeLast(); // Quita nivel
        _tokens.add(Token(TokenType.dedent, '', _line, _col)); // Token dedent
      }
    } // Igual => no hace nada
  }

  // Avanza y retorna el siguiente carácter
  String _advance() { // Avanza en la fuente
    if (_isAtEnd()) return ''; // Si fin devuelve vacío
    final c = source[_pos]; // Carácter actual
    _pos++; // Incrementa posición
    _col++; // Incrementa columna
    return c; // Retorna carácter
  }

  // Mira el siguiente carácter sin avanzar
  String _peek() => _isAtEnd() ? '' : source[_pos]; // Retorna próximo char o vacío

  // Verifica si se llegó al final
  bool _isAtEnd() => _pos >= source.length; // Fin si posición >= longitud

  // Agrega un token con lexema opcional
  void _add(TokenType type, [String lexeme = '']) { // Inserta token con lexema
    _tokens.add(Token(type, lexeme, _line, _col)); // Añade a lista
  }

  // Escanea un número
  void _scanNumber(String first) { // Procesa literal numérico
    var numStr = first; // Acumulador
    while (!_isAtEnd() && _isDigit(_peek())) { // Dígitos sucesivos
      numStr += _advance(); // Añade dígito
    }
    if (!_isAtEnd() && _peek() == '.') { // Punto decimal
      numStr += _advance(); // Añade punto
      while (!_isAtEnd() && _isDigit(_peek())) { // Dígitos fracción
        numStr += _advance(); // Añade dígito
      }
    }
    _tokens.add(Token(TokenType.number, numStr, _line, _col)); // Token number
  }

  // Escanea un identificador o palabra clave
  void _scanIdentifier(String first) { // Procesa identificador/keyword
    var id = first; // Acumulador
    while (!_isAtEnd() && (_isAlphaNum(_peek()))) { // Continúa mientras alfanum
      id += _advance(); // Añade carácter
    }
    switch (id) { // Clasifica palabra
      case 'var': _tokens.add(Token(TokenType.var_, id, _line, _col)); break; // var
      case 'fun': _tokens.add(Token(TokenType.fun, id, _line, _col)); break; // fun
      case 'class': _tokens.add(Token(TokenType.class_, id, _line, _col)); break; // class
      case 'if': _tokens.add(Token(TokenType.if_, id, _line, _col)); break; // if
      case 'elif': _tokens.add(Token(TokenType.elif_, id, _line, _col)); break; // elif
      case 'else': _tokens.add(Token(TokenType.else_, id, _line, _col)); break; // else
      case 'while': _tokens.add(Token(TokenType.while_, id, _line, _col)); break; // while
      case 'for': _tokens.add(Token(TokenType.for_, id, _line, _col)); break; // for
      case 'in': _tokens.add(Token(TokenType.in_, id, _line, _col)); break; // in
      case 'return': _tokens.add(Token(TokenType.return_, id, _line, _col)); break; // return
      case 'print': _tokens.add(Token(TokenType.print_, id, _line, _col)); break; // print
      case 'and': _tokens.add(Token(TokenType.and_, id, _line, _col)); break; // and
      case 'or': _tokens.add(Token(TokenType.or_, id, _line, _col)); break; // or
      case 'number': _tokens.add(Token(TokenType.number_, id, _line, _col)); break; // number kw
      case 'string': _tokens.add(Token(TokenType.string_, id, _line, _col)); break; // string kw
      case 'bool': _tokens.add(Token(TokenType.bool_, id, _line, _col)); break; // bool kw
  case 'null': _tokens.add(Token(TokenType.null_kw, id, _line, _col)); break; // null keyword tipo
      case 'object': _tokens.add(Token(TokenType.object_, id, _line, _col)); break; // object kw
      case 'function': _tokens.add(Token(TokenType.function_, id, _line, _col)); break; // function kw
      case 'true': _tokens.add(Token(TokenType.bool, id, _line, _col)); break; // true literal
      case 'false': _tokens.add(Token(TokenType.bool, id, _line, _col)); break; // false literal
      default: _tokens.add(Token(TokenType.identifier, id, _line, _col)); break; // identificador
    }
  }

  // Escanea una cadena de texto
  void _scanString(String quote) { // Procesa literal string
    var str = ''; // Acumulador
    while (!_isAtEnd() && _peek() != quote) { // Mientras no cierre
      str += _advance(); // Añade carácter
    }
    if (!_isAtEnd()) _advance(); // Cierra comilla final
    _tokens.add(Token(TokenType.string, str, _line, _col)); // Token string
  }

  // Utilidades
  bool _isDigit(String c) => c.codeUnitAt(0) >= '0'.codeUnitAt(0) && c.codeUnitAt(0) <= '9'.codeUnitAt(0); // Dígito
  bool _isAlpha(String c) => (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) && c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) || (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) && c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) || c == '_'; // Letra/_
  bool _isAlphaNum(String c) => _isAlpha(c) || _isDigit(c); // Alfanumérico
}