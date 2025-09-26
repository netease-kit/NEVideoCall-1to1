// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/impl/boot.dart';
import 'package:netease_callkit_ui/src/extensions/calling_bell_feature.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/ui/call_main_widget.dart';

class NECallKitNavigatorObserver extends NavigatorObserver {
  static const _tag = "NECallKitNavigatorObserver";
  static final NECallKitNavigatorObserver _instance =
      NECallKitNavigatorObserver();
  static bool isClose = true;
  static CallPage currentPage = CallPage.none;

  static NECallKitNavigatorObserver getInstance() {
    return _instance;
  }

  NECallKitNavigatorObserver() {
    CallKitUILog.i(_tag, 'NECallKitNavigatorObserver Init');
    Boot.instance;
  }

  void enterCallingPage() async {
    CallKitUILog.i(
        _tag, 'NECallKitNavigatorObserver enterCallingPage：[isClose：$isClose]');
    if (!isClose) {
      return;
    }
    currentPage = CallPage.callingPage;
    NECallKitNavigatorObserver.getInstance()
        .navigator
        ?.push(MaterialPageRoute(builder: (widget) {
      return NECallKitWidget(close: () {
        if (!isClose) {
          isClose = true;
          NECallKitPlatform.instance.stopForegroundService();
          CallingBellFeature.stopRing();
          NECallKitNavigatorObserver.getInstance().exitCallingPage();
        }
      });
    }));
    isClose = false;
  }

  void exitCallingPage() async {
    CallKitUILog.i(_tag,
        'NECallKitNavigatorObserver exitCallingPage：[currentPage：$currentPage]');
    if (currentPage == CallPage.callingPage) {
      NECallKitNavigatorObserver.getInstance().navigator?.pop();
    }
    currentPage = CallPage.none;
  }
}

enum CallPage { none, callingPage }
