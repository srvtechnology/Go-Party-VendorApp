import 'package:logger/logger.dart';

class CustomLogger {
  static Logger logger = Logger();
  static void error(var error){
    logger.e(error);
  }
  static void debug(var debug){
    logger.d(debug);
  }
}