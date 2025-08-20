import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionResult {
  granted,
  denied,
  requesting,
}

enum PermissionType {
  camera,
  microphone,
  bluetooth,
}

class PermissionUtils {
  static String getPermissionRequestTitle(NECallType type) {
    if (NECallType.audio == type) {
      return CallKitUIL10n.localizations.applyForMicrophonePermission;
    } else {
      return CallKitUIL10n.localizations.applyForMicrophoneAndCameraPermissions;
    }
  }

  static String getPermissionRequestDescription(NECallType type) {
    if (NECallType.audio == type) {
      return CallKitUIL10n.localizations.needToAccessMicrophonePermission;
    } else {
      return CallKitUIL10n
          .localizations.needToAccessMicrophoneAndCameraPermissions;
    }
  }

  static String getPermissionRequestSettingsTip(NECallType type) {
    if (NECallType.audio == type) {
      return "${CallKitUIL10n.localizations.applyForMicrophonePermission}\n${CallKitUIL10n.localizations.needToAccessMicrophonePermission}";
    } else {
      return "${CallKitUIL10n.localizations.applyForMicrophoneAndCameraPermissions}\n${CallKitUIL10n.localizations.needToAccessMicrophoneAndCameraPermissions}";
    }
  }

  static Future<PermissionResult> request(NECallType type) async {
    PermissionResult result = PermissionResult.denied;
    Map<Permission, PermissionStatus> statuses;
    if (NECallType.video == type) {
      statuses = await [
        Permission.microphone,
        Permission.camera,
      ].request();
    } else {
      statuses = await [
        Permission.microphone,
      ].request();
    }

    bool isAllGranted = !statuses.values.any((status) => !status.isGranted);

    if (isAllGranted) {
      result = PermissionResult.granted;
    } else {
      result = PermissionResult.denied;
    }
    return result;
  }

  static Future<bool> has({required List<PermissionType> permissions}) async {
    return await Permission.camera.status.isGranted;
  }
}
