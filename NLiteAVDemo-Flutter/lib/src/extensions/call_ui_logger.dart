import 'package:netease_common/netease_common.dart';

enum TRTCLoggerLevel { info, warning, error }

class CallKitUILogger {
  static const moduleName = 'CallKitUI';

  static void info(String message, {String logTag = ""}) async {
    Alog.i(tag: logTag, moduleName: moduleName, content: message);
  }

  static void warning(String message, {String logTag = ""}) async {
    Alog.w(tag: logTag, moduleName: moduleName, content: message);
  }

  static void error(String message, {String logTag = ""}) async {
    Alog.e(tag: logTag, moduleName: moduleName, content: message);
  }
}
