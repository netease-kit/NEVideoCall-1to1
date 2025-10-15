// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'call_ui_localizations.dart';

/// The translations for English (`en`).
class CallKitClientLocalizationsEn extends CallKitClientLocalizations {
  CallKitClientLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get youHaveANewCall => 'You have a new call';

  @override
  String get initEngineFail => 'Init engine failed';

  @override
  String get callFailedUserIdEmpty => 'Call failed, userId is empty';

  @override
  String get permissionResultFail => 'Permission result fail';

  @override
  String get startCameraPermissionDenied => 'Start camera permission denied.';

  @override
  String get applyForMicrophonePermission => 'apply for microphone permission';

  @override
  String get applyForMicrophoneAndCameraPermissions =>
      'apply for microphone and camera permissions';

  @override
  String get needToAccessMicrophonePermission =>
      'need to access microphone permission';

  @override
  String get errorInPeerBlacklist => 'error in peer blacklist';

  @override
  String get insufficientPermissions => 'insufficient permissions';

  @override
  String get displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions =>
      'display popUpWindow while running in the background and display popUpWindow permissions';

  @override
  String get needToAccessMicrophoneAndCameraPermissions =>
      'need to access microphone and camera permissions';

  @override
  String get noFloatWindowPermission => 'no float window permission';

  @override
  String get needFloatWindowPermission => 'need float window permission';

  @override
  String get accept => 'accept';

  @override
  String get cameraIsOn => 'cameraIsOn';

  @override
  String get cameraIsOff => 'cameraIsOff';

  @override
  String get speakerIsOn => 'speakerIsOn';

  @override
  String get speakerIsOff => 'speakerIsOff';

  @override
  String get microphoneIsOn => 'microphoneIsOn';

  @override
  String get microphoneIsOff => 'microphoneIsOff';

  @override
  String get blurBackground => 'blurBackground';

  @override
  String get switchCamera => 'switchCamera';

  @override
  String get waiting => 'waiting';

  @override
  String get hangUp => 'hangUp';

  @override
  String get userBusy => 'Other party is busy';

  @override
  String get userInCall => 'User is already in a call';

  @override
  String get remoteUserReject => 'remote user rejected';
}
