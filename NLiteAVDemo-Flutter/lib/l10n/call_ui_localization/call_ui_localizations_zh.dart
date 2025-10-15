// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'call_ui_localizations.dart';

/// The translations for Chinese (`zh`).
class CallKitClientLocalizationsZh extends CallKitClientLocalizations {
  CallKitClientLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get youHaveANewCall => '您有一个新的通话';

  @override
  String get initEngineFail => '引擎初始化失败';

  @override
  String get callFailedUserIdEmpty => '呼叫失败，用户ID为空';

  @override
  String get permissionResultFail => '权限校验失败';

  @override
  String get startCameraPermissionDenied => '启动摄像头权限被拒绝';

  @override
  String get applyForMicrophonePermission => '申请麦克风权限';

  @override
  String get applyForMicrophoneAndCameraPermissions => '申请麦克风、摄像头权限';

  @override
  String get needToAccessMicrophonePermission =>
      '需要访问您的麦克风权限，开启后用于语音通话、视频通话等功能。请点击“前往设置”按钮进入权限相关页面，进行设置。';

  @override
  String get errorInPeerBlacklist => '发起通话失败，用户在黑名单中，禁止发起！';

  @override
  String get insufficientPermissions => '新通话呼入，但因权限不足，无法接听。请确认摄像头/麦克风权限已开启。';

  @override
  String
      get displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions =>
          '请同时打开后台弹出界面和显示悬浮窗权限';

  @override
  String get needToAccessMicrophoneAndCameraPermissions =>
      '需要访问您的麦克风和摄像头权限，开启后用于语音通话、视频通话等功能。请点击“前往设置”按钮进入权限相关页面，进行设置';

  @override
  String get noFloatWindowPermission => '浮窗权限未获取';

  @override
  String get needFloatWindowPermission => '你的手机没有授权应用获得浮窗权限,通话最小化不能正常使用';

  @override
  String get accept => '接听';

  @override
  String get cameraIsOn => '摄像头已开启';

  @override
  String get cameraIsOff => '摄像头已关闭';

  @override
  String get speakerIsOn => '扬声器已开启';

  @override
  String get speakerIsOff => '扬声器已关闭';

  @override
  String get microphoneIsOn => '麦克风已开启';

  @override
  String get microphoneIsOff => '麦克风已关闭';

  @override
  String get blurBackground => '模糊背景';

  @override
  String get switchCamera => '切换摄像头';

  @override
  String get waiting => '等待接听';

  @override
  String get hangUp => '挂断';

  @override
  String get userBusy => '对方占线';

  @override
  String get userInCall => '用户已在通话中';

  @override
  String get remoteUserReject => '对方已拒绝';
}
