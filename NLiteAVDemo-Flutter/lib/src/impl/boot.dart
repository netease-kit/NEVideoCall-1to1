// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_callkit_ui/src/impl/call_manager.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';

class Boot {
  static final Boot instance = Boot._internal();

  factory Boot() {
    return instance;
  }

  NEEventCallback loginSuccessCallBack = (arg) {
    CallManager.instance.handleLoginSuccess(arg['accountId'], arg['token']);
  };

  NEEventCallback logoutSuccessCallBack = (arg) {
    CallManager.instance.handleLogoutSuccess();
  };

  NEEventCallback imSDKInitSuccessCallBack = (arg) {};

  Boot._internal() {
    NECallKitPlatform.instance;
    NEEventNotify().register(loginSuccessEvent, loginSuccessCallBack);
    NEEventNotify().register(logoutSuccessEvent, logoutSuccessCallBack);
    NEEventNotify().register(imSDKInitSuccessEvent, imSDKInitSuccessCallBack);
  }
}
