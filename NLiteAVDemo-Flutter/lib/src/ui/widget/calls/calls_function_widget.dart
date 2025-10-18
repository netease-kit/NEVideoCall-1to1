// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/call_define.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/impl/call_manager.dart';
import 'package:netease_callkit_ui/src/impl/call_state.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/ui/widget/common/extent_button.dart';
import 'package:netease_callkit_ui/src/utils/permission.dart';

import 'calls_widget.dart';

class CallsFunctionWidget {
  static const String _tag = "CallsFunctionWidget";
  static bool _isAccepting = false; // 添加接听状态标志

  // 备用网络图片URL常量
  static const String _hangupNetworkUrl =
      "https://yx-web-nosdn.netease.im/common/e2ca6c0b7a35174efde6e3ec7eaf1609/hangup.png";
  static const String _acceptNetworkUrl =
      "https://yx-web-nosdn.netease.im/common/ed23abfde97d28036502095c071264e6/dialing.png";

  static Widget buildIndividualFunctionWidget(Function close) {
    CallKitUILog.i(_tag,
        "buildIndividualFunctionWidget current callStatus = ${CallState.instance.selfUser.callStatus}");
    if (NECallStatus.waiting == CallState.instance.selfUser.callStatus) {
      if (NECallRole.caller == CallState.instance.selfUser.callRole) {
        if (NECallType.audio == CallState.instance.mediaType) {
          return _buildAudioCallerWaitingAndAcceptedView(close);
        } else {
          if (CallState.instance.showVirtualBackgroundButton) {
            return _buildVBgVideoCallerWaitingView(close);
          } else {
            return _buildVideoCallerWaitingView(close);
          }
        }
      } else {
        return _buildAudioAndVideoCalleeWaitingView(close);
      }
    } else if (NECallStatus.accept == CallState.instance.selfUser.callStatus) {
      if (NECallType.audio == CallState.instance.mediaType) {
        return _buildAudioCallerWaitingAndAcceptedView(close);
      } else {
        return _buildVideoCallerAndCalleeAcceptedView(close);
      }
    } else {
      return Container();
    }
  }

  static Widget buildMultiCallFunctionWidget(
      BuildContext context, Function close) {
    Widget functionWidget;
    if (NECallStatus.waiting == CallState.instance.selfUser.callStatus &&
        NECallRole.called == CallState.instance.selfUser.callRole) {
      functionWidget = _buildAudioAndVideoCalleeWaitingFunctionView(close);
    } else {
      functionWidget =
          _buildVideoCallerAndCalleeAcceptedFunctionView(context, close);
    }

    return functionWidget;
  }

  static _buildAudioAndVideoCalleeWaitingFunctionView(Function close) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendButton(
              imgUrl: "assets/images/hangup.png",
              fallbackNetworkUrl: _hangupNetworkUrl,
              tips: NECallKitUI.localizations.hangUp,
              textColor: Colors.white,
              imgHeight: 64,
              onTap: () {
                _handleReject(close);
              },
            ),
            ExtendButton(
              imgUrl: "assets/images/dialing.png",
              fallbackNetworkUrl: _acceptNetworkUrl,
              tips: NECallKitUI.localizations.accept,
              textColor: Colors.white,
              imgHeight: 64,
              onTap: () {
                _handleAccept(close);
              },
            ),
          ],
        ),
        const SizedBox(height: 80)
      ],
    );
  }

  static _buildVideoCallerAndCalleeAcceptedFunctionView(
      BuildContext context, Function close) {
    double bigBtnHeight = 52;
    double smallBtnHeight = 35;
    double edge = 40;
    double bottomEdge = 10;
    int duration = 300;
    int btnWidth = 100;
    Curve curve = Curves.easeInOut;
    return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: GestureDetector(
            onVerticalDragUpdate: (details) =>
                _functionWidgetVerticalDragUpdate(details),
            child: AnimatedContainer(
                curve: curve,
                height: CallsWidget.isFunctionExpand ? 200 : 90,
                duration: Duration(milliseconds: duration),
                color: const Color.fromRGBO(52, 56, 66, 1.0),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: CallsWidget.isFunctionExpand
                          ? ((MediaQuery.of(context).size.width / 4) -
                              (btnWidth / 2))
                          : (MediaQuery.of(context).size.width * 2 / 6 -
                              btnWidth / 2),
                      bottom: CallsWidget.isFunctionExpand
                          ? bottomEdge + bigBtnHeight + edge
                          : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.isMicrophoneMute
                            ? "assets/images/mute_on.png"
                            : "assets/images/mute.png",
                        tips: CallsWidget.isFunctionExpand
                            ? (CallState.instance.isMicrophoneMute
                                ? NECallKitUI.localizations.microphoneIsOff
                                : NECallKitUI.localizations.microphoneIsOn)
                            : '',
                        textColor: Colors.white,
                        imgHeight: CallsWidget.isFunctionExpand
                            ? bigBtnHeight
                            : smallBtnHeight,
                        onTap: () {
                          _handleSwitchMic();
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: CallsWidget.isFunctionExpand
                          ? (MediaQuery.of(context).size.width / 2 -
                              btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 3 / 6 -
                              btnWidth / 2),
                      bottom: CallsWidget.isFunctionExpand
                          ? bottomEdge + bigBtnHeight + edge
                          : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.isEnableSpeaker
                            ? "assets/images/handsfree_on.png"
                            : "assets/images/handsfree.png",
                        tips: CallsWidget.isFunctionExpand
                            ? (CallState.instance.isEnableSpeaker
                                ? NECallKitUI.localizations.speakerIsOn
                                : NECallKitUI.localizations.speakerIsOff)
                            : '',
                        textColor: Colors.white,
                        imgHeight: CallsWidget.isFunctionExpand
                            ? bigBtnHeight
                            : smallBtnHeight,
                        onTap: () {
                          _handleSwitchAudioDevice();
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: CallsWidget.isFunctionExpand
                          ? (MediaQuery.of(context).size.width * 3 / 4 -
                              btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 4 / 6 -
                              btnWidth / 2),
                      bottom: CallsWidget.isFunctionExpand
                          ? bottomEdge + bigBtnHeight + edge
                          : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.isCameraOpen
                            ? "assets/images/camera_on.png"
                            : "assets/images/camera_off.png",
                        tips: CallsWidget.isFunctionExpand
                            ? (CallState.instance.isCameraOpen
                                ? NECallKitUI.localizations.cameraIsOn
                                : NECallKitUI.localizations.cameraIsOff)
                            : '',
                        textColor: Colors.white,
                        imgHeight: CallsWidget.isFunctionExpand
                            ? bigBtnHeight
                            : smallBtnHeight,
                        onTap: () {
                          _handleOpenCloseCamera();
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: CallsWidget.isFunctionExpand
                          ? (MediaQuery.of(context).size.width / 2 -
                              btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 5 / 6 -
                              btnWidth / 2),
                      bottom: bottomEdge,
                      child: ExtendButton(
                        imgUrl: "assets/images/hangup.png",
                        fallbackNetworkUrl: _hangupNetworkUrl,
                        textColor: Colors.white,
                        imgHeight: CallsWidget.isFunctionExpand
                            ? bigBtnHeight
                            : smallBtnHeight,
                        onTap: () {
                          _handleHangUp(close);
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                        curve: curve,
                        duration: Duration(milliseconds: duration),
                        left: (MediaQuery.of(context).size.width / 6 -
                            smallBtnHeight / 2),
                        bottom: CallsWidget.isFunctionExpand
                            ? bottomEdge + smallBtnHeight / 4 + 22
                            : bottomEdge + 22,
                        child: InkWell(
                          onTap: () {
                            CallsWidget.isFunctionExpand =
                                !CallsWidget.isFunctionExpand;
                            NEEventNotify().notify(setStateEvent);
                          },
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(
                                  1.0,
                                  CallsWidget.isFunctionExpand ? 1.0 : -1.0,
                                  1.0),
                            child: Image.asset(
                              'assets/images/arrow.png',
                              package: 'netease_callkit_ui',
                              width: smallBtnHeight,
                            ),
                          ),
                        ))
                  ],
                ))));
  }

  static _functionWidgetVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0 && !CallsWidget.isFunctionExpand) {
      CallsWidget.isFunctionExpand = true;
    } else if (details.delta.dy > 0 && CallsWidget.isFunctionExpand) {
      CallsWidget.isFunctionExpand = false;
    }
    NEEventNotify().notify(setStateEventGroupCallUserWidgetRefresh);
  }

  static Widget _buildAudioCallerWaitingAndAcceptedView(Function close) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMicControlButton(),
        _buildHangupButton(close),
        _buildSpeakerphoneButton(),
      ],
    );
  }

  static Widget _buildVideoCallerWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildSwitchCameraButton(),
          _buildHangupButton(close),
          _buildCameraControlButton(),
        ]),
      ],
    );
  }

  static Widget _buildVBgVideoCallerWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSwitchCameraButton(),
            _buildVirtualBackgroundButton(),
            _buildCameraControlButton(),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              width: 100,
            ),
            _buildHangupButton(close),
            const SizedBox(
              width: 100,
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildVideoCallerAndCalleeAcceptedView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMicControlButton(),
            _buildSpeakerphoneButton(),
            _buildCameraControlButton(),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          CallState.instance.showVirtualBackgroundButton
              ? _buildVirtualBackgroundSmallButton()
              : const SizedBox(
                  width: 100,
                ),
          _buildHangupButton(close),
          CallState.instance.isCameraOpen
              ? _buildSwitchCameraSmallButton()
              : const SizedBox(
                  width: 100,
                ),
        ]),
      ],
    );
  }

  static Widget _buildAudioAndVideoCalleeWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendButton(
              imgUrl: "assets/images/hangup.png",
              fallbackNetworkUrl: _hangupNetworkUrl,
              tips: NECallKitUI.localizations.hangUp,
              textColor: _getTextColor(),
              imgHeight: 60,
              onTap: () {
                _handleReject(close);
              },
            ),
            ExtendButton(
              imgUrl: "assets/images/dialing.png",
              fallbackNetworkUrl: _acceptNetworkUrl,
              tips: NECallKitUI.localizations.accept,
              textColor: _getTextColor(),
              imgHeight: 60,
              onTap: () {
                _handleAccept(close);
              },
            ),
          ],
        )
      ],
    );
  }

  static _handleSwitchMic() async {
    if (CallState.instance.isMicrophoneMute) {
      CallState.instance.isMicrophoneMute = false;
      await CallManager.instance.openMicrophone();
    } else {
      CallState.instance.isMicrophoneMute = true;
      await CallManager.instance.closeMicrophone();
    }
    NEEventNotify().notify(setStateEvent);
  }

  static _handleSwitchAudioDevice() async {
    if (CallState.instance.isEnableSpeaker) {
      CallState.instance.isEnableSpeaker = false;
    } else {
      CallState.instance.isEnableSpeaker = true;
    }
    await CallManager.instance
        .setSpeakerphoneOn(CallState.instance.isEnableSpeaker);
    NEEventNotify().notify(setStateEvent);
  }

  static Widget _buildSpeakerphoneButton() {
    return ExtendButton(
      imgUrl: CallState.instance.isEnableSpeaker
          ? "assets/images/handsfree_on.png"
          : "assets/images/handsfree.png",
      tips: CallState.instance.isEnableSpeaker
          ? NECallKitUI.localizations.speakerIsOn
          : NECallKitUI.localizations.speakerIsOff,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        _handleSwitchAudioDevice();
      },
    );
  }

  static Widget _buildCameraControlButton() {
    return ExtendButton(
      imgUrl: CallState.instance.isCameraOpen
          ? "assets/images/camera_on.png"
          : "assets/images/camera_off.png",
      tips: CallState.instance.isCameraOpen
          ? NECallKitUI.localizations.cameraIsOn
          : NECallKitUI.localizations.cameraIsOff,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        _handleOpenCloseCamera();
      },
    );
  }

  static Widget _buildMicControlButton() {
    return ExtendButton(
      imgUrl: CallState.instance.isMicrophoneMute
          ? "assets/images/mute_on.png"
          : "assets/images/mute.png",
      tips: CallState.instance.isMicrophoneMute
          ? NECallKitUI.localizations.microphoneIsOff
          : NECallKitUI.localizations.microphoneIsOn,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        _handleSwitchMic();
      },
    );
  }

  static Widget _buildHangupButton(Function close) {
    return ExtendButton(
      imgUrl: "assets/images/hangup.png",
      fallbackNetworkUrl: _hangupNetworkUrl,
      tips: NECallKitUI.localizations.hangUp,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        _handleHangUp(close);
      },
    );
  }

  static Widget _buildSwitchCameraSmallButton() {
    return ExtendButton(
      imgUrl: "assets/images/switch_camera.png",
      tips: '',
      textColor: _getTextColor(),
      imgHeight: 28,
      imgOffsetX: -16,
      onTap: () {
        _handleSwitchCamera();
      },
    );
  }

  static Widget _buildVirtualBackgroundSmallButton() {
    return ExtendButton(
      imgUrl: "assets/images/blur_background_accept.png",
      tips: '',
      textColor: _getTextColor(),
      imgHeight: 28,
      imgOffsetX: 16,
      onTap: () {
        _handleOpenBlurBackground();
      },
    );
  }

  static Widget _buildVirtualBackgroundButton() {
    return ExtendButton(
      imgUrl: CallState.instance.enableBlurBackground
          ? "assets/images/blur_background_waiting_enable.png"
          : "assets/images/blur_background_waiting_disable.png",
      tips: NECallKitUI.localizations.blurBackground,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        _handleOpenBlurBackground();
      },
    );
  }

  static Widget _buildSwitchCameraButton() {
    return ExtendButton(
      imgUrl: "assets/images/switch_camera_group.png",
      tips: NECallKitUI.localizations.switchCamera,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        _handleSwitchCamera();
      },
    );
  }

  static _handleHangUp(Function close) async {
    await CallManager.instance.hangup();
    close();
  }

  static _handleReject(Function close) async {
    await CallManager.instance.reject();
    close();
  }

  static _handleAccept(Function close) async {
    // 防止重复点击
    if (_isAccepting) {
      CallKitUILog.i(
          _tag, '_handleAccept already in progress, ignore duplicate click');
      return;
    }

    _isAccepting = true;
    CallKitUILog.i(_tag, '_handleAccept');

    try {
      PermissionResult permissionRequestResult = PermissionResult.requesting;
      if (Platform.isAndroid || Platform.isIOS) {
        permissionRequestResult =
            await Permission.request(CallState.instance.mediaType);
      }
      if (permissionRequestResult == PermissionResult.granted) {
        CallKitUILog.i(_tag,
            '_handleAccept permissionRequestResult = $permissionRequestResult');
        var result = await CallManager.instance.accept();
        if (result.code == 0) {
          CallState.instance.selfUser.callStatus = NECallStatus.accept;
        } else {
          CallState.instance.selfUser.callStatus = NECallStatus.none;
          close();
        }
      } else {
        CallManager.instance
            .showToast(NECallKitUI.localizations.insufficientPermissions);
      }
    } finally {
      _isAccepting = false; // 确保无论成功还是失败都重置状态
    }

    NEEventNotify().notify(setStateEvent);
  }

  static void _handleOpenCloseCamera() async {
    CallState.instance.isCameraOpen = !CallState.instance.isCameraOpen;
    if (CallState.instance.isCameraOpen) {
      await CallManager.instance.openCamera(
          CallState.instance.camera, CallState.instance.selfUser.viewID);
    } else {
      await CallManager.instance.closeCamera();
    }
    NEEventNotify().notify(setStateEvent);
  }

  static void _handleOpenBlurBackground() async {
    CallState.instance.enableBlurBackground =
        !CallState.instance.enableBlurBackground;
    await CallManager.instance
        .setBlurBackground(CallState.instance.enableBlurBackground);
    NEEventNotify().notify(setStateEvent);
  }

  static void _handleSwitchCamera() async {
    if (NECamera.front == CallState.instance.camera) {
      CallState.instance.camera = NECamera.back;
    } else {
      CallState.instance.camera = NECamera.front;
    }
    await CallManager.instance.switchCamera(CallState.instance.camera);
    NEEventNotify().notify(setStateEvent);
  }

  static Color _getTextColor() {
    return Colors.white;
  }
}
