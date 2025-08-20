import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/src/call_define.dart';
import 'package:netease_callkit_ui/src/impl/call_manager.dart';
import 'package:netease_callkit_ui/src/ui/call_navigator_observer.dart';

class NECallKitUI {
  static final NECallKitUI _instance = NECallKitUI();

  static NECallKitUI get instance => _instance;

  static NECallKitNavigatorObserver navigatorObserver =
      NECallKitNavigatorObserver.getInstance();

  /// login NECallKit
  ///
  /// @param appKey      appKey
  /// @param userId        userId
  /// @param userSig       userSig
  /// @param certificateConfig 证书配置参数
  Future<NEResult> login(String appKey, String userId, String userSig,
      {NECertificateConfig? certificateConfig}) async {
    return await CallManager.instance
        .login(appKey, userId, userSig, certificateConfig: certificateConfig);
  }

  /// logout NECallKit
  ///
  Future<void> logout() async {
    return await CallManager.instance.logout();
  }

  /// Set user profile
  ///
  /// @param nickname User name, which can contain up to 500 bytes
  /// @param avatar   User profile photo URL, which can contain up to 500 bytes
  ///                 For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
  /// @param callback Set the result callback
  Future<NEResult> setSelfInfo(String nickname, String avatar) async {
    return await CallManager.instance.setSelfInfo(nickname, avatar);
  }

  /// Make a call
  ///
  /// @param userId        callees
  /// @param callMediaType Call type
  Future<NEResult> call(String userId, NECallType callMediaType,
      [NECallParams? params]) async {
    return await CallManager.instance.call(userId, callMediaType, params);
  }

  /// Set the ringtone (preferably shorter than 30s)
  ///
  /// First introduce the ringtone resource into the project
  /// Then set the resource as a ringtone
  ///
  /// @param filePath Callee ringtone path
  Future<void> setCallingBell(String assetName) async {
    return await CallManager.instance.setCallingBell(assetName);
  }

  ///Enable the floating window
  Future<void> enableFloatWindow(bool enable) async {
    return await CallManager.instance.enableFloatWindow(enable);
  }

  Future<void> enableVirtualBackground(bool enable) async {
    return await CallManager.instance.enableVirtualBackground(enable);
  }

  void enableIncomingBanner(bool enable) {
    CallManager.instance.enableIncomingBanner(enable);
  }
}
