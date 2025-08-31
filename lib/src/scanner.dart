// Analizador léxico para Chronicles con soporte de indentación y comentarios

import 'token.dart';

/// Scanner (lexer) para Chronicles
/// Convierte el código fuente en una lista de tokens
class Scanner {
  final String source;
  final String fileName;
  int _pos = 0;
  int _line = 1;
  int _col = 1;
  final List<Token> _tokens = [];
  final List<int> _indentStack = [0];

  Scanner(this.source, this.fileName);

  /// Escanea todos los tokens del código fuente
  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _scanToken();
    }
    // Emitir DEDENTs al final
    while (_indentStack.length > 1) {
      _tokens.add(Token(TokenType.dedent, '', _line, _col));
      _indentStack.removeLast();
    }
    _tokens.add(Token(TokenType.eof, '', _line, _col));
    return _tokens;
  }

  // Escanea un token individual
  void _scanToken() {
    final c = _advance();
    // Manejo de saltos de línea e indentación
    if (c == '\n') {
      _line++;
      _col = 1;
      _tokens.add(Token(TokenType.newline, '', _line, _col));
      _handleIndentation();
      return;
    }
    // Comentarios
    if (c == '#') {
      while (!_isAtEnd() && _peek() != '\n') _advance();
      _tokens.add(Token(TokenType.comment, '', _line, _col));
      return;
    }
    // Espacios y tabulaciones (solo para indentación)
    if (c == ' ' || c == '\t') {
      // Se ignoran aquí, se manejan en _handleIndentation
      return;
    }
    // Símbolos y operadores
    switch (c) {
      case '(': _add(TokenType.lparen); break;
      case ')': _add(TokenType.rparen); break;
      case '{': _add(TokenType.lbrace); break;
      case '}': _add(TokenType.rbrace); break;
      case ':': _add(TokenType.colon); break;
      case ',': _add(TokenType.comma); break;
      case '.': _add(TokenType.dot); break;
      case '+': _add(TokenType.plus); break;
      case '-':
        if (_peek() == '>') {
          _advance();
          _add(TokenType.arrow);
        } else {
          _add(TokenType.minus);
        }
        break;
      case '*': _add(TokenType.star); break;
      case '/': _add(TokenType.slash); break;
      case '%': _add(TokenType.percent); break;
      case '=':
        if (_peek() == '=') {
          _advance();
          _add(TokenType.eq);
        } else {
          _add(TokenType.assign);
        }
        break;
      case '!':
        if (_peek() == '=') {
          _advance();
          _add(TokenType.neq);
        }
        break;
      case '<':
        if (_peek() == '=') {
          _advance();
          _add(TokenType.le);
        } else {
          _add(TokenType.lt);
        }
        break;
      case '>':
        if (_peek() == '=') {
          _advance();
          _add(TokenType.ge);
        } else {
          _add(TokenType.gt);
        }
        break;
      case '"':
      case '\'':
        _scanString(c);
        break;
      default:
        if (_isDigit(c)) {
          _scanNumber(c);
        } else if (_isAlpha(c)) {
          _scanIdentifier(c);
        }
        break;
    }
  }

  // Maneja la indentación al inicio de línea
  void _handleIndentation() {
    int count = 0;
    while (!_isAtEnd() && (_peek() == ' ' || _peek() == '\t')) {
      count += (_peek() == ' ') ? 1 : 4; // Tab = 4 espacios
      _advance();
    }
    if (count > _indentStack.last) {
      _indentStack.add(count);
      _tokens.add(Token(TokenType.indent, '', _line, _col));
    } else if (count < _indentStack.last) {
      while (_indentStack.length > 1 && count < _indentStack.last) {
        _indentStack.removeLast();
        _tokens.add(Token(TokenType.dedent, '', _line, _col));
      }
    }
  }

  // Avanza y retorna el siguiente carácter
  String _advance() {
    if (_isAtEnd()) return '';
    final c = source[_pos];
    _pos++;
    _col++;
    return c;
  }

  // Mira el siguiente carácter sin avanzar
  String _peek() => _isAtEnd() ? '' : source[_pos];

  // Verifica si se llegó al final
  bool _isAtEnd() => _pos >= source.length;

  // Agrega un token
  void _add(TokenType type) {
    _tokens.add(Token(type, '', _line, _col));
  }

  // Escanea un número
  void _scanNumber(String first) {
    var numStr = first;
    while (!_isAtEnd() && _isDigit(_peek())) {
      numStr += _advance();
    }
    if (!_isAtEnd() && _peek() == '.') {
      numStr += _advance();
      while (!_isAtEnd() && _isDigit(_peek())) {
        numStr += _advance();
      }
    }
    _tokens.add(Token(TokenType.number, numStr, _line, _col));
  }

  // Escanea un identificador o palabra clave
  void _scanIdentifier(String first) {
    var id = first;
    while (!_isAtEnd() && (_isAlphaNum(_peek()))) {
      id += _advance();
    }
    // Palabras clave
    switch (id) {
      case 'var': _tokens.add(Token(TokenType.var_, id, _line, _col)); break;
      case 'fun': _tokens.add(Token(TokenType.fun, id, _line, _col)); break;
      case 'class': _tokens.add(Token(TokenType.class_, id, _line, _col)); break;
      case 'if': _tokens.add(Token(TokenType.if_, id, _line, _col)); break;
      case 'elif': _tokens.add(Token(TokenType.elif_, id, _line, _col)); break;
      case 'else': _tokens.add(Token(TokenType.else_, id, _line, _col)); break;
      case 'while': _tokens.add(Token(TokenType.while_, id, _line, _col)); break;
      case 'return': _tokens.add(Token(TokenType.return_, id, _line, _col)); break;
      case 'print': _tokens.add(Token(TokenType.print_, id, _line, _col)); break;
      case 'number': _tokens.add(Token(TokenType.number_, id, _line, _col)); break;
      case 'string': _tokens.add(Token(TokenType.string_, id, _line, _col)); break;
      case 'bool': _tokens.add(Token(TokenType.bool_, id, _line, _col)); break;
      case 'null': _tokens.add(Token(TokenType.null_, id, _line, _col)); break;
      case 'object': _tokens.add(Token(TokenType.object_, id, _line, _col)); break;
      case 'function': _tokens.add(Token(TokenType.function_, id, _line, _col)); break;
      case 'true': _tokens.add(Token(TokenType.bool, id, _line, _col)); break;
      case 'false': _tokens.add(Token(TokenType.bool, id, _line, _col)); break;
      default: _tokens.add(Token(TokenType.identifier, id, _line, _col)); break;
    }
  }

  // Escanea una cadena de texto
  void _scanString(String quote) {
    var str = '';
    while (!_isAtEnd() && _peek() != quote) {
      str += _advance();
    }
    if (!_isAtEnd()) _advance(); // Cierra la comilla
    _tokens.add(Token(TokenType.string, str, _line, _col));
  }

  // Utilidades
  bool _isDigit(String c) => c.codeUnitAt(0) >= '0'.codeUnitAt(0) && c.codeUnitAt(0) <= '9'.codeUnitAt(0);
  bool _isAlpha(String c) => (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) && c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) || (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) && c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) || c == '_';
  bool _isAlphaNum(String c) => _isAlpha(c) || _isDigit(c);
}