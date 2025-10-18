// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/call_define.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/impl/call_manager.dart';
import 'package:netease_callkit_ui/src/impl/call_state.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/ui/call_navigator_observer.dart';
import 'package:netease_callkit_ui/src/ui/widget/calls/calls_function_widget.dart';
import 'package:netease_callkit_ui/src/ui/widget/calls/calls_user_widget_data.dart';
import 'package:netease_callkit_ui/src/ui/widget/common/timing_widget.dart';
import 'package:netease_callkit_ui/src/ui/widget/common/float_permission_dialog.dart';
import 'calls_single_call_widget.dart';

class CallsWidget extends StatefulWidget {
  static bool isFunctionExpand = true;
  final Function close;

  const CallsWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  State<CallsWidget> createState() => _CallsWidgetState();
}

class _CallsWidgetState extends State<CallsWidget>
    with TickerProviderStateMixin {
  static const String _tag = "CallsWidgetState";
  late NEEventCallback setStateCallBack;
  late NEEventCallback groupCallUserWidgetRefreshCallback;
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  bool isDirectMulti = false;
  bool isMultiPerson = false;
  bool isShowInvite = false;

  _initUsersViewWidget() {
    CallsIndividualUserWidgetData.isOnlyShowBigVideoView = false;
    CallsMultiUserWidgetData.initBlockCounter();
    CallsMultiUserWidgetData.updateBlockBigger(
        CallState.instance.remoteUserList.length + 1);
    CallsMultiUserWidgetData.initCanPlaceSquare(
        CallsMultiUserWidgetData.blockBigger,
        CallState.instance.remoteUserList.length + 1);

    CallsMultiUserWidgetData.blockCount++;

    for (var _ in CallState.instance.remoteUserList) {
      CallsMultiUserWidgetData.blockCount++;
    }
    setState(() {
      if (!isMultiPerson) {
        isMultiPerson = true;
        _controller.forward();
      }
    });
  }

  _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _fadeOutAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void initState() {
    super.initState();
    CallsWidget.isFunctionExpand = true;
    CallsIndividualUserWidgetData.initIndividualUserWidgetData();
    if (CallState.instance.groupId != '') {
      isDirectMulti = true;
      isShowInvite = true;
    }

    _initAnimation();

    setStateCallBack = (arg) {
      if (mounted) {
        CallKitUILog.i(_tag,
            "state callback isMultiPerson:$isMultiPerson, remoteUserList length:${CallState.instance.remoteUserList.length}");
        if (isMultiPerson || CallState.instance.remoteUserList.length >= 2) {
          _initUsersViewWidget();
        } else {
          setState(() {});
        }
      }
    };

    groupCallUserWidgetRefreshCallback = (arg) {
      if (mounted) {
        if (CallsMultiUserWidgetData.hasBiggerSquare()) {
          CallsWidget.isFunctionExpand = false;
        } else {
          CallsWidget.isFunctionExpand = true;
        }
        setState(() {});
      }
    };

    NEEventNotify().register(setStateEvent, setStateCallBack);
    NEEventNotify().register(setStateEventGroupCallUserWidgetRefresh,
        groupCallUserWidgetRefreshCallback);

    CallsMultiUserWidgetData.initBlockBigger();
    if (isDirectMulti || CallState.instance.remoteUserList.length >= 2) {
      isDirectMulti = true;
      _initUsersViewWidget();
    }
  }

  @override
  void dispose() {
    // Stop animations and unregister listeners before calling super.dispose()
    _controller.dispose();
    NEEventNotify().unregister(setStateEvent, setStateCallBack);
    NEEventNotify().unregister(setStateEventGroupCallUserWidgetRefresh,
        groupCallUserWidgetRefreshCallback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // padding: const EdgeInsets.only(top: 40),
        color: const Color.fromRGBO(45, 45, 45, 1.0),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            Visibility(
              visible: !isDirectMulti && _fadeOutAnimation.value != 0 ||
                  !isMultiPerson,
              child: FadeTransition(
                opacity: _fadeOutAnimation,
                child: CallsIndividualUserWidget(close: widget.close),
              ),
            ),
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildTopWidget(),
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildFunctionWidget(),
          ],
        ),
      ),
    );
  }

  _buildTopWidget() {
    final floatWindowBtnWidget = CallState.instance.enableFloatWindow &&
            NECallStatus.accept == CallState.instance.selfUser.callStatus
        ? Visibility(
            visible: CallState.instance.enableFloatWindow &&
                NECallStatus.accept == CallState.instance.selfUser.callStatus,
            child: InkWell(
                onTap: () => _openFloatWindow(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      'assets/images/floating_button.png',
                      package: 'netease_callkit_ui',
                    ),
                  ),
                )),
          )
        : const SizedBox();

    final timerWidget =
        (NECallStatus.accept == CallState.instance.selfUser.callStatus)
            ? const SizedBox(width: 100, child: Center(child: TimingWidget()))
            : const SizedBox();

    return Positioned(
        top: 55,
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Stack(
          children: [
            Positioned(left: 16, child: floatWindowBtnWidget),
            Positioned(
                left: (MediaQuery.of(context).size.width / 2) - 50,
                child: timerWidget),
          ],
        ));
  }

  _buildFunctionWidget() {
    return Positioned(
      left: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Visibility(
            visible: !isDirectMulti && _fadeOutAnimation.value != 0 ||
                !isMultiPerson,
            child: FadeTransition(
              opacity: _fadeOutAnimation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 50),
                child: CallsFunctionWidget.buildIndividualFunctionWidget(
                    widget.close),
              ),
            ),
          ),
          isDirectMulti
              ? CallsFunctionWidget.buildMultiCallFunctionWidget(
                  context, widget.close)
              : Visibility(
                  visible: _fadeInAnimation.value != 0 || isMultiPerson,
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: CallsFunctionWidget.buildMultiCallFunctionWidget(
                        context, widget.close),
                  ),
                ),
        ],
      ),
    );
  }

  _openFloatWindow() async {
    if (Platform.isAndroid) {
      bool result = await NECallKitPlatform.instance.hasFloatPermission();
      if (!result) {
        // 显示浮窗权限对话框
        await FloatPermissionDialog.show(context);
        return;
      }
      CallManager.instance.openFloatWindow();
      NECallKitNavigatorObserver.getInstance().exitCallingPage();
    } else if (Platform.isIOS) {
      CallManager.instance.openFloatWindow();
      NECallKitNavigatorObserver.getInstance().exitCallingPage();
    }
  }
}
