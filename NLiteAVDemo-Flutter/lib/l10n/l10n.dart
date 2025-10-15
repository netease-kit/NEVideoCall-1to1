// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/l10n/call_ui_localization/call_ui_localizations.dart';
import 'package:netease_callkit_ui/l10n/call_ui_localization/call_ui_localizations_en.dart';
import 'package:netease_callkit_ui/l10n/call_ui_localization/call_ui_localizations_zh.dart';
import 'package:netease_common_ui/base/default_language.dart';

class S {
  static const LocalizationsDelegate<CallKitClientLocalizations> delegate =
      CallKitClientLocalizations.delegate;

  static CallKitClientLocalizations of([BuildContext? context]) {
    CallKitClientLocalizations? localizations;
    if (CommonUIDefaultLanguage.commonDefaultLanguage == languageZh) {
      return CallKitClientLocalizationsZh();
    }
    if (CommonUIDefaultLanguage.commonDefaultLanguage == languageEn) {
      return CallKitClientLocalizationsEn();
    }
    if (context != null) {
      localizations = CallKitClientLocalizations.of(context);
    }
    if (localizations == null) {
      var local = PlatformDispatcher.instance.locale;
      try {
        localizations = lookupCallKitClientLocalizations(local);
      } catch (e) {
        localizations = CallKitClientLocalizationsEn();
      }
    }
    return localizations;
  }
}
