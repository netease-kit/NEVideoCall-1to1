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
  String get applyForMicrophonePermission => 'youHaveANewCall';

  @override
  String get applyForMicrophoneAndCameraPermissions => 'youHaveANewCall';

  @override
  String get needToAccessMicrophonePermission => 'youHaveANewCall';

  @override
  String get errorInPeerBlacklist => 'youHaveANewCall';

  @override
  String get insufficientPermissions => 'youHaveANewCall';

  @override
  String get displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions =>
      'displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions';

  @override
  String get needToAccessMicrophoneAndCameraPermissions =>
      'needToAccessMicrophoneAndCameraPermissions';

  @override
  String get noFloatWindowPermission => 'noFloatWindowPermission';

  @override
  String get needFloatWindowPermission => 'needFloatWindowPermission';

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
