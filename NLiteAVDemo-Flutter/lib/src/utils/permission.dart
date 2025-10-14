// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';

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
      return NECallKitUI.localizations.applyForMicrophonePermission;
    } else {
      return NECallKitUI.localizations.applyForMicrophoneAndCameraPermissions;
    }
  }

  static String getPermissionRequestDescription(NECallType type) {
    if (NECallType.audio == type) {
      return NECallKitUI.localizations.needToAccessMicrophonePermission;
    } else {
      return NECallKitUI
          .localizations.needToAccessMicrophoneAndCameraPermissions;
    }
  }

  static String getPermissionRequestSettingsTip(NECallType type) {
    if (NECallType.audio == type) {
      return "${NECallKitUI.localizations.applyForMicrophonePermission}\n${NECallKitUI.localizations.needToAccessMicrophonePermission}";
    } else {
      return "${NECallKitUI.localizations.applyForMicrophoneAndCameraPermissions}\n${NECallKitUI.localizations.needToAccessMicrophoneAndCameraPermissions}";
    }
  }
}

class Permission {
  static String getPermissionRequestTitle(NECallType type) {
    if (NECallType.audio == type) {
      return NECallKitUI.localizations.applyForMicrophonePermission;
    } else {
      return NECallKitUI.localizations.applyForMicrophoneAndCameraPermissions;
    }
  }

  static String getPermissionRequestDescription(NECallType type) {
    if (NECallType.audio == type) {
      return NECallKitUI.localizations.needToAccessMicrophonePermission;
    } else {
      return NECallKitUI
          .localizations.needToAccessMicrophoneAndCameraPermissions;
    }
  }

  static String getPermissionRequestSettingsTip(NECallType type) {
    if (NECallType.audio == type) {
      return "${NECallKitUI.localizations.applyForMicrophonePermission}\n${NECallKitUI.localizations.needToAccessMicrophonePermission}";
    } else {
      return "${NECallKitUI.localizations.applyForMicrophoneAndCameraPermissions}\n${NECallKitUI.localizations.needToAccessMicrophoneAndCameraPermissions}";
    }
  }

  static Future<PermissionResult> request(NECallType type) async {
    PermissionResult result = PermissionResult.denied;
    if (NECallType.video == type) {
      result = await NECallKitPlatform.instance.requestPermissions(
          permissions: [PermissionType.camera, PermissionType.microphone],
          title: getPermissionRequestTitle(type),
          description: getPermissionRequestDescription(type),
          settingsTip: getPermissionRequestDescription(type));
    } else {
      result = await NECallKitPlatform.instance.requestPermissions(
          permissions: [PermissionType.microphone],
          title: getPermissionRequestTitle(type),
          description: getPermissionRequestDescription(type),
          settingsTip: getPermissionRequestDescription(type));
    }
    return result;
  }

  static Future<bool> has({required List<PermissionType> permissions}) async {
    return await NECallKitPlatform.instance
        .hasPermissions(permissions: permissions);
  }
}
