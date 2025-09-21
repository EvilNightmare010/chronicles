// REPL interactivo para Chronicles con historial y modo verbose

import 'dart:io'; // Importa IO estándar
import 'lexer.dart'; // Importa lexer léxico
import 'parser.dart'; // Importa parser sintáctico
import 'interpreter.dart'; // Importa intérprete

void startRepl({bool verbose = false}) { // Función inicio REPL
  print('Chronicles REPL (Ctrl+C para salir)'); // Mensaje bienvenida
  final history = <String>[]; // Lista historial de comandos
  final interpreter = Interpreter(verbose: verbose); // Instancia intérprete
  while (true) { // Bucle infinito
    stdout.write('>>> '); // Prompt
    final line = stdin.readLineSync(); // Lee línea
    if (line == null) break; // Salir si null (EOF)
    history.add(line); // Agrega a historial
    try { // Bloque try ejecución
  final lexer = Lexer(line, '<repl>'); // Crea lexer
  final tokens = lexer.scanTokens(); // Tokeniza entrada
      final parserChron = Parser(tokens); // Crea parser
      final ast = parserChron.parse(); // Genera AST
      interpreter.run(ast); // Ejecuta AST
    } catch (e) { // Captura errores
      print('Error: $e'); // Imprime error
    }
  }
}