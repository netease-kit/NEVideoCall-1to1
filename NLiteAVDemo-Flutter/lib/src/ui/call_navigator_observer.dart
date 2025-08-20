import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/src/impl/boot.dart';
import 'package:netease_callkit_ui/src/extensions/calling_bell_feature.dart';
import 'package:netease_callkit_ui/src/extensions/call_ui_logger.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/ui/call_main_widget.dart';

import '../impl/boot.dart';

class NECallKitNavigatorObserver extends NavigatorObserver {
  static final NECallKitNavigatorObserver _instance =
      NECallKitNavigatorObserver();
  static bool isClose = true;
  static CallPage currentPage = CallPage.none;

  static NECallKitNavigatorObserver getInstance() {
    return _instance;
  }

  NECallKitNavigatorObserver() {
    CallKitUILogger.info('NECallKitNavigatorObserver Init');
    Boot.instance;
  }

  void enterCallingPage() async {
    CallKitUILogger.info(
        'NECallKitNavigatorObserver enterCallingPage：[isClose：$isClose]');
    print(
        'NECallKitNavigatorObserver enterCallingPage: isClose=$isClose, navigator=${navigator}');
    if (!isClose) {
      print('NECallKitNavigatorObserver enterCallingPage: 页面已打开，直接返回');
      return;
    }
    currentPage = CallPage.callingPage;
    print('NECallKitNavigatorObserver enterCallingPage: 准备导航到通话页面');
    NECallKitNavigatorObserver.getInstance()
        .navigator
        ?.push(MaterialPageRoute(builder: (widget) {
      print('NECallKitNavigatorObserver enterCallingPage: 创建 NECallKitWidget');
      return NECallKitWidget(close: () {
        print('NECallKitNavigatorObserver enterCallingPage: 关闭回调被调用');
        if (!isClose) {
          isClose = true;
          NECallKitPlatform.instance.stopForegroundService();
          CallingBellFeature.stopRing();
          NECallKitNavigatorObserver.getInstance().exitCallingPage();
        }
      });
    }));
    isClose = false;
    print('NECallKitNavigatorObserver enterCallingPage: 导航完成，isClose设置为false');
  }

  void exitCallingPage() async {
    CallKitUILogger.info(
        'NECallKitNavigatorObserver exitCallingPage：[currentPage：$currentPage]');
    if (currentPage == CallPage.callingPage) {
      NECallKitNavigatorObserver.getInstance().navigator?.pop();
    }
    currentPage = CallPage.none;
  }
}

enum CallPage { none, callingPage }
