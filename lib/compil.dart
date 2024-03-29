import 'package:flutter/foundation.dart';

import 'package:logger/logger.dart';
import 'package:logger_flutter_viewer/logger_flutter_viewer.dart';

const bool showLogConsole = false;
const bool dioFineLogs = kDebugMode;

//logger
class ScreenOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    LogConsole.output(event);
  }
}

final Logger logger =
    showLogConsole ? Logger(printer: PrettyPrinter()) : Logger();
