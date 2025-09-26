// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:netease_callkit_ui/generated/l10n.dart';

class CallKitUIL10n {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  static BuildContext get _context => navigatorKey.currentContext!;

  static S get localizations {
    return S.of(_context);
  }

  static AppLocalizationDelegate get delegate {
    return S.delegate;
  }
}
