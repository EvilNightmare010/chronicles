// CLI principal para el lenguaje Chronicles
// Permite ejecutar archivos .chron, iniciar el REPL y usar modo verbose

import 'dart:io'; // IO para archivos y salida
import 'package:args/args.dart'; // Parser de argumentos
import '../lib/src/repl.dart'; // REPL interactivo
import '../lib/src/interpreter.dart'; // Intérprete
import '../lib/src/lexer.dart'; // Lexer
import '../lib/src/parser.dart'; // Parser

void main(List<String> arguments) { // Punto de entrada CLI
  // Configuración de argumentos CLI
  final parser = ArgParser() // Crea parser de opciones
    ..addFlag('repl', abbr: 'r', help: 'Iniciar REPL interactivo') // Flag REPL
    ..addFlag('verbose', abbr: 'v', help: 'Modo verbose (detallado)') // Flag verbose
    ..addFlag('help', abbr: 'h', help: 'Mostrar ayuda', negatable: false); // Flag ayuda

  final argResults = parser.parse(arguments); // Parsea argumentos

  if (argResults['help'] as bool || arguments.isEmpty) { // Mostrar ayuda
    print(''' // Imprime banner
Chronicles CLI // Título
Uso: // Uso
  dart run bin/chronicles.dart archivo.chron [opciones] // Comando
Opciones: // Lista
  -r, --repl      Iniciar REPL interactivo // Opción repl
  -v, --verbose   Modo verbose (detallado) // Opción verbose
  -h, --help      Mostrar ayuda // Opción help
'''); // Fin texto
    exit(0); // Sale con éxito
  }

  if (argResults['repl'] as bool) { // Modo REPL
    startRepl(verbose: argResults['verbose'] as bool); // Lanza REPL
    return; // Termina main
  }

  // Ejecutar archivo .chron
  final filePath = arguments.firstWhere((a) => a.endsWith('.chron'), orElse: () => ''); // Busca archivo .chron
  if (filePath.isEmpty || !File(filePath).existsSync()) { // Valida existencia
    print('Error: Debes especificar un archivo .chron existente.'); // Error
    exit(1); // Código fallo
  }

  final source = File(filePath).readAsStringSync(); // Lee fuente
  final lexer = Lexer(source, filePath); // Crea lexer
  final tokens = lexer.scanTokens(); // Tokeniza
  final parserChron = Parser(tokens); // Crea parser
  final ast = parserChron.parse(); // Genera AST
  final interpreter = Interpreter(verbose: argResults['verbose'] as bool); // Intérprete
  interpreter.run(ast); // Ejecuta
}