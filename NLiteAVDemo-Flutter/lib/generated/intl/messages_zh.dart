// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accept": MessageLookupByLibrary.simpleMessage("接听"),
        "applyForMicrophoneAndCameraPermissions":
            MessageLookupByLibrary.simpleMessage("申请麦克风、摄像头权限"),
        "applyForMicrophonePermission":
            MessageLookupByLibrary.simpleMessage("申请麦克风权限"),
        "blurBackground": MessageLookupByLibrary.simpleMessage("模糊背景"),
        "cameraIsOff": MessageLookupByLibrary.simpleMessage("摄像头已关闭"),
        "cameraIsOn": MessageLookupByLibrary.simpleMessage("摄像头已开启"),
        "displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions":
            MessageLookupByLibrary.simpleMessage("请同时打开后台弹出界面和显示悬浮窗权限"),
        "errorInPeerBlacklist":
            MessageLookupByLibrary.simpleMessage("发起通话失败，用户在黑名单中，禁止发起！"),
        "hangUp": MessageLookupByLibrary.simpleMessage("挂断"),
        "insufficientPermissions": MessageLookupByLibrary.simpleMessage(
            "新通话呼入，但因权限不足，无法接听。请确认摄像头/麦克风权限已开启。"),
        "microphoneIsOff": MessageLookupByLibrary.simpleMessage("麦克风已关闭"),
        "microphoneIsOn": MessageLookupByLibrary.simpleMessage("麦克风已开启"),
        "needToAccessMicrophoneAndCameraPermissions":
            MessageLookupByLibrary.simpleMessage(
                "需要访问您的麦克风和摄像头权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。"),
        "needToAccessMicrophonePermission":
            MessageLookupByLibrary.simpleMessage(
                "需要访问您的麦克风权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。"),
        "remoteUserReject": MessageLookupByLibrary.simpleMessage("对方已拒绝"),
        "speakerIsOff": MessageLookupByLibrary.simpleMessage("扬声器已关闭"),
        "speakerIsOn": MessageLookupByLibrary.simpleMessage("扬声器已开启"),
        "switchCamera": MessageLookupByLibrary.simpleMessage("切换摄像头"),
        "userBusy": MessageLookupByLibrary.simpleMessage("对方占线"),
        "userInCall": MessageLookupByLibrary.simpleMessage("用户已在通话中"),
        "waiting": MessageLookupByLibrary.simpleMessage("等待接听"),
        "youHaveANewCall": MessageLookupByLibrary.simpleMessage("您有一个新的通话")
      };
}
