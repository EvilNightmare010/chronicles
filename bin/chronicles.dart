// CLI principal para el lenguaje Chronicles
// Permite ejecutar archivos .chron, iniciar el REPL y usar modo verbose

import 'dart:io';
import 'package:args/args.dart';
import '../lib/src/repl.dart';
import '../lib/src/interpreter.dart';
import '../lib/src/scanner.dart';
import '../lib/src/parser.dart';

void main(List<String> arguments) {
  // Configuración de argumentos CLI
  final parser = ArgParser()
    ..addFlag('repl', abbr: 'r', help: 'Iniciar REPL interactivo')
    ..addFlag('verbose', abbr: 'v', help: 'Modo verbose (detallado)')
    ..addFlag('help', abbr: 'h', help: 'Mostrar ayuda', negatable: false);

  final argResults = parser.parse(arguments);

  if (argResults['help'] as bool || arguments.isEmpty) {
    print('''
Chronicles CLI
Uso:
  dart run bin/chronicles.dart archivo.chron [opciones]
Opciones:
  -r, --repl      Iniciar REPL interactivo
  -v, --verbose   Modo verbose (detallado)
  -h, --help      Mostrar ayuda
''');
    exit(0);
  }

  if (argResults['repl'] as bool) {
    // Iniciar REPL
    startRepl(verbose: argResults['verbose'] as bool);
    return;
  }

  // Ejecutar archivo .chron
  final filePath = arguments.firstWhere((a) => a.endsWith('.chron'), orElse: () => '');
  if (filePath.isEmpty || !File(filePath).existsSync()) {
    print('Error: Debes especificar un archivo .chron existente.');
    exit(1);
  }

  final source = File(filePath).readAsStringSync();
  final scanner = Scanner(source, filePath);
  final tokens = scanner.scanTokens();
  final parserChron = Parser(tokens);
  final ast = parserChron.parse();
  final interpreter = Interpreter(verbose: argResults['verbose'] as bool);
  interpreter.run(ast);
}