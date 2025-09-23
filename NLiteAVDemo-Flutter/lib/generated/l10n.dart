// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `You have a new call`
  String get youHaveANewCall {
    return Intl.message(
      'You have a new call',
      name: 'youHaveANewCall',
      desc: '',
      args: [],
    );
  }

  /// `youHaveANewCall`
  String get applyForMicrophonePermission {
    return Intl.message(
      'youHaveANewCall',
      name: 'applyForMicrophonePermission',
      desc: '',
      args: [],
    );
  }

  /// `youHaveANewCall`
  String get applyForMicrophoneAndCameraPermissions {
    return Intl.message(
      'youHaveANewCall',
      name: 'applyForMicrophoneAndCameraPermissions',
      desc: '',
      args: [],
    );
  }

  /// `youHaveANewCall`
  String get needToAccessMicrophonePermission {
    return Intl.message(
      'youHaveANewCall',
      name: 'needToAccessMicrophonePermission',
      desc: '',
      args: [],
    );
  }

  /// `youHaveANewCall`
  String get errorInPeerBlacklist {
    return Intl.message(
      'youHaveANewCall',
      name: 'errorInPeerBlacklist',
      desc: '',
      args: [],
    );
  }

  /// `youHaveANewCall`
  String get insufficientPermissions {
    return Intl.message(
      'youHaveANewCall',
      name: 'insufficientPermissions',
      desc: '',
      args: [],
    );
  }

  /// `displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions`
  String
      get displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions {
    return Intl.message(
      'displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions',
      name:
          'displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions',
      desc: '',
      args: [],
    );
  }

  /// `needToAccessMicrophoneAndCameraPermissions`
  String get needToAccessMicrophoneAndCameraPermissions {
    return Intl.message(
      'needToAccessMicrophoneAndCameraPermissions',
      name: 'needToAccessMicrophoneAndCameraPermissions',
      desc: '',
      args: [],
    );
  }

  /// `accept`
  String get accept {
    return Intl.message(
      'accept',
      name: 'accept',
      desc: '',
      args: [],
    );
  }

  /// `cameraIsOn`
  String get cameraIsOn {
    return Intl.message(
      'cameraIsOn',
      name: 'cameraIsOn',
      desc: '',
      args: [],
    );
  }

  /// `cameraIsOff`
  String get cameraIsOff {
    return Intl.message(
      'cameraIsOff',
      name: 'cameraIsOff',
      desc: '',
      args: [],
    );
  }

  /// `speakerIsOn`
  String get speakerIsOn {
    return Intl.message(
      'speakerIsOn',
      name: 'speakerIsOn',
      desc: '',
      args: [],
    );
  }

  /// `speakerIsOff`
  String get speakerIsOff {
    return Intl.message(
      'speakerIsOff',
      name: 'speakerIsOff',
      desc: '',
      args: [],
    );
  }

  /// `microphoneIsOn`
  String get microphoneIsOn {
    return Intl.message(
      'microphoneIsOn',
      name: 'microphoneIsOn',
      desc: '',
      args: [],
    );
  }

  /// `microphoneIsOff`
  String get microphoneIsOff {
    return Intl.message(
      'microphoneIsOff',
      name: 'microphoneIsOff',
      desc: '',
      args: [],
    );
  }

  /// `invitedToAudioCall`
  String get invitedToAudioCall {
    return Intl.message(
      'invitedToAudioCall',
      name: 'invitedToAudioCall',
      desc: '',
      args: [],
    );
  }

  /// `invitedToVideoCall`
  String get invitedToVideoCall {
    return Intl.message(
      'invitedToVideoCall',
      name: 'invitedToVideoCall',
      desc: '',
      args: [],
    );
  }

  /// `blurBackground`
  String get blurBackground {
    return Intl.message(
      'blurBackground',
      name: 'blurBackground',
      desc: '',
      args: [],
    );
  }

  /// `switchCamera`
  String get switchCamera {
    return Intl.message(
      'switchCamera',
      name: 'switchCamera',
      desc: '',
      args: [],
    );
  }

  /// `waiting`
  String get waiting {
    return Intl.message(
      'waiting',
      name: 'waiting',
      desc: '',
      args: [],
    );
  }

  /// `hangUp`
  String get hangUp {
    return Intl.message(
      'hangUp',
      name: 'hangUp',
      desc: '',
      args: [],
    );
  }

  /// `Other party is busy`
  String get userBusy {
    return Intl.message(
      'Other party is busy',
      name: 'userBusy',
      desc: '',
      args: [],
    );
  }

  /// `User is already in a call`
  String get userInCall {
    return Intl.message(
      'User is already in a call',
      name: 'userInCall',
      desc: '',
      args: [],
    );
  }

  /// `remote user rejected`
  String get remoteUserReject {
    return Intl.message(
      'remote user rejected',
      name: 'remoteUserReject',
      desc: '',
      args: [],
    );
  }

  /// `remote user rejected`
  String get noFloatWindowPermission {
    return Intl.message(
      'no float window permission',
      name: 'noFloatWindowPermission',
      desc: '',
      args: [],
    );
  }

  /// `remote user rejected`
  String get needFloatWindowPermission {
    return Intl.message(
      'need float window permission',
      name: 'needFloatWindowPermission',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
