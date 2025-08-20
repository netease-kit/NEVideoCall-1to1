import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/call_define.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/impl/call_state.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/data/user.dart';
import 'package:netease_callkit_ui/src/extensions/calling_bell_feature.dart';
import 'package:netease_callkit_ui/src/extensions/call_ui_logger.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/ui/call_navigator_observer.dart';
import 'package:netease_callkit_ui/src/utils/nim_utils.dart';
import 'package:netease_callkit_ui/src/utils/permission.dart';
import 'package:netease_callkit_ui/src/utils/preference.dart';
import 'package:netease_callkit_ui/src/utils/string_stream.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'package:path_provider/path_provider.dart';

class CallManager {
  static final CallManager _instance = CallManager();

  static CallManager get instance => _instance;
  final _im = NimCore.instance;

  // 保存 appKey
  String? _appKey;

  // 获取 appKey
  String? get appKey => _appKey;

  CallManager() {
    NEEventNotify().register(setStateEventOnCallReceived, (arg) async {
      if (Platform.isAndroid &&
          await NECallKitPlatform.instance.isAppInForeground()) {
        var permissionResult =
            await PermissionUtils.request(CallState.instance.mediaType);

        if (PermissionResult.granted == permissionResult) {
          NECallKitNavigatorObserver.getInstance().enterCallingPage();
        } else {
          CallManager.instance.reject();
          CallingBellFeature.stopRing();
        }
      } else {
        NECallKitNavigatorObserver.getInstance().enterCallingPage();
      }
    });
  }

  Future<void> initEngine(String appKey, String accountId) async {
    CallKitUILogger.info(
        'CallManager initEngine(appKey:$appKey, accountId: $accountId)');
    CallState.instance.selfUser.id = accountId;
    NESetupConfig config = NESetupConfig(
      appKey: appKey,
      enableJoinRtcWhenCall: false,
      initRtcMode: NECallInitRtcMode.global,
    );
    final result = await NECallEngine.instance.setup(config);

    if (result.code == 0) {
    } else {
      CallManager.instance.showToast('Init Engine Fail');
    }
  }

  Future<NEResult> call(String accountId, NECallType callMediaType,
      [NECallParams? params]) async {
    CallKitUILogger.info(
        'CallManager call(userId:$accountId, callMediaType: $callMediaType, params:${params.toString()}), version:${Constants.pluginVersion}');
    if (accountId.isEmpty) {
      debugPrint("Call failed, userId is empty");
      return NEResult(code: -1, message: "Call failed, userId is empty");
    }

    // 使用 NECallParams 中的 pushConfig
    NECallPushConfig? pushConfig = params?.pushConfig;
    final permissionResult = await PermissionUtils.request(callMediaType);
    if (PermissionResult.granted == permissionResult) {
      final callResult = await NECallEngine.instance
          .call(accountId, callMediaType, pushConfig: pushConfig);
      if (callResult.code == 0) {
        User user = User();
        user.id = accountId;
        user.callRole = NECallRole.called;
        user.callStatus = NECallStatus.waiting;

        CallState.instance.remoteUserList.add(user);
        _getUserInfo();
        CallState.instance.mediaType = callMediaType;
        CallState.instance.scene = NECallScene.singleCall;
        CallState.instance.selfUser.callRole = NECallRole.caller;
        CallState.instance.selfUser.callStatus = NECallStatus.waiting;
        CallingBellFeature.startRing();
        launchCallingPage();
        CallManager.instance.enableWakeLock(true);
      } else if (callResult.code == 20002) {
        CallManager.instance.showToast(CallKitUIL10n.localizations.userInCall);
      } else {
        CallManager.instance.showToast(
            callResult.code.toString() + " " + (callResult.msg ?? ""));
      }
      CallKitUILogger.info(
          "callResult.code: ${callResult.code}, callResult.msg: ${callResult.msg}");
      return NEResult(code: callResult.code, message: callResult.msg);
    } else {
      CallManager.instance
          .showToast(CallKitUIL10n.localizations.insufficientPermissions);
      CallKitUILogger.info("Permission result fail");
      return NEResult(code: -1, message: "Permission result fail");
    }
  }

  Future<NEResult> accept() async {
    final result = await NECallEngine.instance.accept();
    if (result.code == 0) {
      CallState.instance.selfUser.callStatus = NECallStatus.accept;
    } else {
      CallState.instance.selfUser.callStatus = NECallStatus.none;
    }
    NECallKitPlatform.instance.updateCallStateToNative();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<NEResult> reject() async {
    final result = await NECallEngine.instance.hangup("");
    CallState.instance.selfUser.callStatus = NECallStatus.none;
    NECallKitPlatform.instance.updateCallStateToNative();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<void> switchCallMediaType(
      NECallType mediaType, NECallSwitchState state) async {
    NECallEngine.instance.switchCallType(mediaType, state);
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<NEResult> hangup() async {
    final result = await NECallEngine.instance.hangup("");
    CallState.instance.selfUser.callStatus = NECallStatus.none;
    NECallKitPlatform.instance.updateCallStateToNative();
    CallState.instance.cleanState();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<NEResult> openCamera(NECamera camera, int viewId) async {
    NEResult result = NEResult(code: 0, message: 'success');
    if (Platform.isAndroid) {
      CallKitUILogger.info('CallManager openCamera');
      PermissionResult permissionResult = PermissionResult.granted;
      if (await PermissionUtils.has(permissions: [PermissionType.camera])) {
        permissionResult = await PermissionUtils.request(NECallType.video);
      }
      if (PermissionResult.granted == permissionResult) {
        var ret = await NECallEngine.instance.enableLocalVideo(true);
        result = NEResult(code: ret.code, message: ret.msg);
      } else {
        result = NEResult(code: -1, message: "Start camera permission denied.");
      }
    } else {
      var ret = await NECallEngine.instance.enableLocalVideo(true);
      result = NEResult(code: ret.code, message: ret.msg);
    }

    if (result.code == 0 &&
        NECallStatus.none != CallState.instance.selfUser.callStatus) {
      CallState.instance.isCameraOpen = true;
      CallState.instance.camera = camera;
      CallState.instance.selfUser.videoAvailable = true;
    }
    NECallKitPlatform.instance.updateCallStateToNative();
    return result;
  }

  Future<void> closeCamera() async {
    CallKitUILogger.info('CallManager closeCamera');
    NECallEngine.instance.enableLocalVideo(false);
    CallState.instance.isCameraOpen = false;
    CallState.instance.selfUser.videoAvailable = false;
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> switchCamera(NECamera camera) async {
    NECallEngine.instance.switchCamera();
    CallState.instance.camera = camera;
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<NEResult> openMicrophone([bool notify = true]) async {
    final result = await NECallEngine.instance.muteLocalAudio(false);
    CallState.instance.isMicrophoneMute = false;
    NECallKitPlatform.instance.updateCallStateToNative();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<void> closeMicrophone([bool notify = true]) async {
    NECallEngine.instance.muteLocalAudio(true);
    CallState.instance.isMicrophoneMute = true;
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> setSpeakerphoneOn(bool enable) async {
    NECallEngine.instance.setSpeakerphoneOn(enable);
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> setupLocalView(int viewId) async {
    CallKitUILogger.info('CallManager setupLocalView(viewId:$viewId)');
    await NECallEngine.instance.setupLocalView(viewId);
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> setupRemoteView(String userId, int viewId) async {
    CallKitUILogger.info(
        'CallManager setupRemoteView(userId:$userId, viewId:$viewId)');
    await NECallEngine.instance.setupRemoteView(viewId);
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> stopRemoteView(String userId) async {
    // await NECallEngine.instance.setupRemoteView(userId);
  }

  Future<NEResult> setSelfInfo(String nickname, String avatar) async {
    // final result = await NECallEngine.instance.setSelfInfo(nickname, avatar);
    return NEResult(code: 0, message: "");
  }

  Future<NEResult> login(String appKey, String accountId, String token,
      {NECertificateConfig? certificateConfig}) async {
    CallKitUILogger.info(
        'CallManager login(appKey:$appKey, accountId:$accountId, certificateConfig:$certificateConfig) version:${Constants.pluginVersion}');

    // 保存 appKey
    _appKey = appKey;
    print('CallManager login: appKey saved = $_appKey');

    late NIMSDKOptions options;
    if (Platform.isAndroid) {
      options = NIMAndroidSDKOptions(
        appKey: appKey,
      );
      //若需要使用云端会话，请提前开启云端会话
      //enableV2CloudConversation: true,
    } else if (Platform.isIOS) {
      options = NIMIOSSDKOptions(
        appKey: appKey,
        //若需要使用云端会话，请提前开启云端会话
        //enableV2CloudConversation: true,
        apnsCername: certificateConfig?.apnsCername,
        pkCername: certificateConfig?.pkCername,
      );
    }
    var initRet = await NimCore.instance.initialize(options);
    if (initRet.code == 0) {
      NEEventNotify()
          .notify(loginSuccessEvent, {'accountId': accountId, 'token': token});
      NEEventNotify().notify(imSDKInitSuccessEvent, {});
    }
    NEResult result = NEResult(code: 0, message: 'success');
    var imRet = await NimCore.instance.loginService.login(
      accountId,
      token,
      NIMLoginOption(),
    );
    result = NEResult(code: imRet.code, message: imRet.errorDetails);
    return result;
  }

  Future<void> logout() async {
    CallKitUILogger.info('CallManager logout()');
    NEEventNotify().notify(logoutSuccessEvent, {});
    await _im.loginService.logout();
  }

  Future<void> setCallingBell(String assetName) async {
    String filePath = await CallingBellFeature.getAssetsFilePath(assetName);
    PreferenceUtils.getInstance()
        .saveString(CallingBellFeature.keyRingPath, filePath);
  }

  Future<void> enableFloatWindow(bool enable) async {
    CallState.instance.enableFloatWindow = enable;
  }

  Future<void> enableVirtualBackground(bool enable) async {
    CallState.instance.showVirtualBackgroundButton = enable;
  }

  Future<void> setBlurBackground(bool enable) async {
    int level = enable ? Constants.blurLevelHigh : Constants.blurLevelClose;
    CallState.instance.enableBlurBackground = enable;

    // NECallEngine.instance.setBlurBackground(
    //     level,
    //     (code, message) => {
    //           CallKitUILogger.error(
    //               "CallManager setBlurBackground() errorCode: $code, errorMessage: $message"),
    //           CallState.instance.enableBlurBackground = false
    //         });
  }

  void initAudioPlayDeviceAndCamera() {
    if (NECallType.audio == CallState.instance.mediaType) {
      CallState.instance.isEnableSpeaker = false;
      CallState.instance.isCameraOpen = false;
    } else {
      CallState.instance.isEnableSpeaker = true;
      CallState.instance.isCameraOpen = true;
    }

    CallManager.instance.setSpeakerphoneOn(CallState.instance.isEnableSpeaker);
  }

  void handleLoginSuccess(String accountId, String token) {
    CallKitUILogger.info('CallManager handleLoginSuccess()');
    print(
        'CallManager handleLoginSuccess: appKey = $_appKey, accountId = $accountId');
    CallManager.instance.initEngine(_appKey!, accountId);
  }

  void handleLogoutSuccess() {
    CallKitUILogger.info('CallManager handleLogoutSuccess()');
    NECallEngine.instance.destroy();
    CallingBellFeature.stopRing();
    CallState.instance.cleanState();
    CallState.instance.unRegisterEngineObserver();
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  void handleAppEnterForeground() async {
    CallKitUILogger.info('CallManager handleAppEnterForeground()');
    if (CallState.instance.selfUser.callStatus != NECallStatus.none &&
        NECallKitNavigatorObserver.currentPage == CallPage.none &&
        CallState.instance.isOpenFloatWindow == false &&
        CallState.instance.isInNativeIncomingBanner == false &&
        !(await CallManager.instance.isScreenLocked())) {
      launchCallingPage();
    }
  }

  void launchCallingPage() {
    CallKitUILogger.info('CallManager launchCallWidget()');
    _checkLocalSelfUserInfo();
    CallManager.instance.initAudioPlayDeviceAndCamera();
    NEEventNotify().notify(setStateEventOnCallReceived);
    NECallKitPlatform.instance.updateCallStateToNative();
    CallState.instance.isOpenFloatWindow = false;
  }

  void openFloatWindow() {
    NECallKitPlatform.instance.startFloatWindow();
    CallState.instance.isOpenFloatWindow = true;
    NECallKitNavigatorObserver.isClose = true;
  }

  void backCallingPageFormFloatWindow() {
    NECallKitNavigatorObserver.getInstance().enterCallingPage();
    CallState.instance.isOpenFloatWindow = false;
  }

  void showToast(String string) {
    Fluttertoast.showToast(msg: string);
  }

  void enableIncomingBanner(bool enable) {
    CallState.instance.enableIncomingBanner = enable;
  }

  Future<void> enableWakeLock(bool enable) async {
    CallKitUILogger.info('CallManager enableWakeLock($enable)');
    await NECallKitPlatform.instance.enableWakeLock(enable);
  }

  void showIncomingBanner() {
    CallKitUILogger.info('CallManager showIncomingBanner');
    NECallKitPlatform.instance.showIncomingBanner();
  }

  void pullBackgroundApp() {
    CallKitUILogger.info('CallManager pullBackgroundApp');
    NECallKitPlatform.instance.pullBackgroundApp();
  }

  void openLockScreenApp() {
    CallKitUILogger.info('CallManager openLockScreenApp');
    NECallKitPlatform.instance.openLockScreenApp();
  }

  Future<bool> isScreenLocked() async {
    return await NECallKitPlatform.instance.isScreenLocked();
  }

  Future<bool> isSamsungDevice() async {
    return await NECallKitPlatform.instance.isSamsungDevice();
  }

  _checkLocalSelfUserInfo() async {
    if (CallState.instance.selfUser.nickname == '' &&
        (CallState.instance.selfUser.avatar == Constants.defaultAvatar ||
            CallState.instance.selfUser.avatar.isEmpty)) {
      final userInfo =
          await NimUtils.getUserInfo(CallState.instance.selfUser.id);
      CallState.instance.selfUser.nickname =
          StringStream.makeNull(userInfo.nickname, '');
      CallState.instance.selfUser.avatar =
          StringStream.makeNull(userInfo.avatar, Constants.defaultAvatar);
    }
  }

  _getUserInfo() async {
    final copyList = List<User>.from(CallState.instance.remoteUserList);
    for (User user in copyList) {
      final userInfo = await NimUtils.getUserInfo(user.id);
      user.nickname = StringStream.makeNull(userInfo.nickname, '');
      user.avatar =
          StringStream.makeNull(userInfo.avatar, Constants.defaultAvatar);
    }
    NEEventNotify().notify(setStateEvent);
  }
}
