// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/data/user.dart';
import 'package:netease_callkit_ui/src/extensions/calling_bell_feature.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/utils/nim_utils.dart';

class CallState {
  static const String _tag = "CallState";
  static final CallState instance = CallState._internal();

  factory CallState() {
    return instance;
  }

  CallState._internal() {
    init();
  }

  User selfUser = User();
  User caller = User();
  List<User> calleeList = [];
  List<String> calleeIdList = [];
  List<User> remoteUserList = [];
  NECallScene scene = NECallScene.singleCall;
  NECallType mediaType = NECallType.audio;
  int timeCount = 0;
  int startTime = 0;
  Timer? _timer;
  String groupId = '';
  bool isCameraOpen = false;
  NECamera camera = NECamera.front;
  bool isMicrophoneMute = false;
  bool isEnableSpeaker = false;
  bool enableFloatWindow = false;
  bool showVirtualBackgroundButton = false;
  bool enableBlurBackground = false;
  NetworkQualityHint networkQualityReminder = NetworkQualityHint.none;

  bool isChangedBigSmallVideo = false;
  bool isOpenFloatWindow = false;
  bool enableIncomingBanner = false;
  bool isInNativeIncomingBanner = false;

  final NECallEngineDelegate observer = NECallEngineDelegate(
    onReceiveInvited: (NEInviteInfo info) async {
      CallKitUILog.i(_tag,
          'NECallObserver onReceiveInvited(callerAccId:${info.callerAccId}, callType:${info.callType})');
      CallingBellFeature.startRing();
      // 处理来电逻辑
      await CallState.instance.handleCallReceivedData(
          info.callerAccId, [], info.channelId ?? '', info.callType);
      await NECallKitPlatform.instance.updateCallStateToNative();
      // await CallManager.instance.enableWakeLock(true);
      if (Platform.isIOS) {
        if (CallState.instance.enableIncomingBanner) {
          CallState.instance.isInNativeIncomingBanner = true;
          await NECallKitPlatform.instance.showIncomingBanner();
        } else {
          CallState.instance.isInNativeIncomingBanner = false;
          CallManager.instance.launchCallingPage();
        }
      } else if (Platform.isAndroid) {
        if (await CallManager.instance.isScreenLocked()) {
          CallManager.instance.openLockScreenApp();
          return;
        }
        if (CallState.instance.enableIncomingBanner &&
            await NECallKitPlatform.instance.hasFloatPermission() &&
            !(await CallManager.instance.isSamsungDevice())) {
          CallState.instance.isInNativeIncomingBanner = true;
          CallManager.instance.showIncomingBanner();
        } else {
          if (await NECallKitPlatform.instance.isAppInForeground()) {
            CallState.instance.isInNativeIncomingBanner = false;
            CallManager.instance.launchCallingPage();
          } else {
            CallManager.instance.pullBackgroundApp();
          }
        }
      }
    },
    onCallEnd: (NECallEndInfo info) {
      CallKitUILog.i(_tag,
          'NECallObserver onCallEnd(reasonCode:${info.reasonCode}, message:${info.message})');
      if (info.reasonCode == NECallTerminalCode.busy) {
        CallManager.instance.showToast(NECallKitUI.localizations.userBusy);
      } else if (info.reasonCode == NECallTerminalCode.calleeReject ||
          info.reasonCode == NECallTerminalCode.callerRejected) {
        if (CallState.instance.selfUser.callRole == NECallRole.caller) {
          CallManager.instance
              .showToast(NECallKitUI.localizations.remoteUserReject);
        }
      } else {
        CallKitUILog.i(_tag, 'NECallObserver onCallEnd: ${info.reasonCode}');
      }
      CallingBellFeature.stopRing();
      if (CallState.instance.mediaType == NECallType.video &&
          CallState.instance.isCameraOpen) {
        CallManager.instance.closeCamera();
      }
      CallState.instance.cleanState();
      NEEventNotify().notify(setStateEventOnCallEnd);
      CallManager.instance.enableWakeLock(false);
      CallState.instance.stopTimer();
      NECallKitPlatform.instance.updateCallStateToNative();
    },
    onCallConnected: (NECallInfo info) {
      CallKitUILog.i(_tag,
          'NECallObserver onCallConnected(callId:${info.callId}, callType:${info.callType})');
      NECallKitPlatform.instance.startForegroundService(info.callType);
      CallState.instance.startTime =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
      CallingBellFeature.stopRing();
      CallState.instance.mediaType = info.callType;
      CallState.instance.selfUser.callStatus = NECallStatus.accept;
      if (CallState.instance.isMicrophoneMute) {
        CallManager.instance.closeMicrophone();
      } else {
        CallManager.instance.openMicrophone();
      }
      CallManager.instance
          .setSpeakerphoneOn(CallState.instance.isEnableSpeaker);
      CallState.instance.startTimer();
      CallState.instance.isChangedBigSmallVideo = true;
      CallState.instance.isInNativeIncomingBanner = false;
      NEEventNotify().notify(setStateEvent);
      NEEventNotify().notify(setStateEventOnCallBegin);
      NECallKitPlatform.instance.updateCallStateToNative();
    },
    onCallTypeChange: (NECallTypeChangeInfo info) {
      CallKitUILog.i(_tag,
          'NECallObserver onCallTypeChange(callType:${info.callType}, state:${info.state})');
      CallState.instance.mediaType = info.callType;
      NEEventNotify().notify(setStateEvent);
      NECallKitPlatform.instance.updateCallStateToNative();
    },
    onVideoAvailable: (bool available, String userID) {
      CallKitUILog.i(_tag,
          'NECallObserver onVideoAvailable(userId:$userID, isVideoAvailable:$available)');
      for (var remoteUser in CallState.instance.remoteUserList) {
        if (remoteUser.id == userID) {
          remoteUser.videoAvailable = available;
          NEEventNotify().notify(setStateEvent);
          NECallKitPlatform.instance.updateCallStateToNative();
          return;
        }
      }
    },
    onVideoMuted: (bool muted, String userID) {
      CallKitUILog.i(
          _tag, 'NECallObserver onVideoMuted(userId:$userID, muted:$muted)');
      // 处理视频静音逻辑
    },
    onAudioMuted: (bool muted, String userID) {
      CallKitUILog.i(
          _tag, 'NECallObserver onAudioMuted(userId:$userID, muted:$muted)');
      for (var remoteUser in CallState.instance.remoteUserList) {
        if (remoteUser.id == userID) {
          remoteUser.audioAvailable = !muted;
          NEEventNotify().notify(setStateEvent);
          return;
        }
      }
      NECallKitPlatform.instance.updateCallStateToNative();
    },
    onLocalAudioMuted: (bool muted) {
      CallKitUILog.i(_tag, 'NECallObserver onLocalAudioMuted(muted:$muted)');
      CallState.instance.isMicrophoneMute = muted;
      NECallKitPlatform.instance.updateCallStateToNative();
    },
    onRtcInitEnd: () {
      CallKitUILog.i(_tag, 'NECallObserver onRtcInitEnd()');
      NECallKitPlatform.instance.updateCallStateToNative();
      // RTC 初始化完成
    },
    onRecordSend: (NERecordConfig config) {
      CallKitUILog.i(
          _tag, 'NECallObserver onRecordSend(accId:${config.accId})');
      NECallKitPlatform.instance.updateCallStateToNative();
      // 处理话单发送
    },
    onNERtcEngineVirtualBackgroundSourceEnabled: (bool enabled, int reason) {
      CallKitUILog.i(_tag,
          'NECallObserver onNERtcEngineVirtualBackgroundSourceEnabled(enabled:$enabled, reason:$reason)');
      // 处理虚拟背景
      NECallKitPlatform.instance.updateCallStateToNative();
    },
  );

  void init() {}

  Future<void> registerEngineObserver() async {
    CallKitUILog.i(_tag, 'registerEngineObserver');
    NECallEngine.instance.addCallDelegate(observer);
  }

  void unRegisterEngineObserver() {
    CallKitUILog.i(_tag, 'unRegisterEngineObserver');
    NECallEngine.instance.removeCallDelegate(observer);
  }

  Future<void> handleCallReceivedData(
      String callerId,
      List<String> calleeIdList,
      String groupId,
      NECallType callMediaType) async {
    CallKitUILog.i(_tag,
        'handleCallReceivedData callerId = $callerId callMediaType = $callMediaType');
    CallState.instance.caller.id = callerId;
    CallState.instance.calleeIdList.clear();
    CallState.instance.calleeIdList.addAll(calleeIdList);
    // CallState.instance.groupId = groupId;
    CallState.instance.mediaType = callMediaType;
    CallState.instance.selfUser.callStatus = NECallStatus.waiting;

    // if (calleeIdList.isEmpty) {
    //   return;
    // }

    // if (calleeIdList.length >= Constants.groupCallMaxUserCount) {
    //   CallManager.instance.showToast(CallKit_t('exceededMaximumNumber'));
    //   return;
    // }

    // CallState.instance.groupId = groupId;
    // if (CallState.instance.groupId.isNotEmpty || calleeIdList.length > 1) {
    //   CallState.instance.scene = NECallScene.groupCall;
    // } else {
    //   CallState.instance.scene = NECallScene.singleCall;
    // }
    CallState.instance.scene = NECallScene.singleCall;

    CallState.instance.mediaType = callMediaType;

    CallState.instance.selfUser.callRole = NECallRole.called;

    final allUserId = [callerId] + calleeIdList;

    for (var userId in allUserId) {
      if (CallState.instance.selfUser.id == userId) {
        if (userId == callerId) {
          CallState.instance.caller = CallState.instance.selfUser;
        } else {
          CallState.instance.calleeList.add(CallState.instance.selfUser);
        }
        continue;
      }

      final user = User();
      user.id = userId;

      if (userId == callerId) {
        CallState.instance.caller = user;
      } else {
        CallState.instance.calleeList.add(user);
      }
    }

    User callerInfo = await NimUtils.getUserInfo(callerId);
    CallState.instance.caller.id = callerInfo.id;
    CallState.instance.caller.nickname = callerInfo.nickname;
    CallState.instance.caller.avatar = callerInfo.avatar;
    CallState.instance.caller.callRole = NECallRole.caller;

    CallState.instance.remoteUserList.clear();
    if (CallState.instance.caller.id.isNotEmpty &&
        CallState.instance.selfUser.id != CallState.instance.caller.id) {
      CallState.instance.remoteUserList.add(CallState.instance.caller);
    }
    for (var callee in CallState.instance.calleeList) {
      if (CallState.instance.selfUser.id == callee.id) {
        continue;
      }
      CallState.instance.remoteUserList.add(callee);
    }
  }

  void startTimer() {
    CallState.instance.timeCount = 0;
    CallState.instance._timer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (NECallStatus.accept != CallState.instance.selfUser.callStatus) {
        stopTimer();
        return;
      }
      CallState.instance.timeCount++;
      NEEventNotify().notify(setStateEventRefreshTiming);
    });
  }

  void stopTimer() {
    CallState.instance._timer?.cancel();
  }

  void cleanState() {
    CallKitUILog.i(_tag, 'cleanState');
    stopTimer();
    CallState.instance.selfUser.callRole = NECallRole.none;
    CallState.instance.selfUser.callStatus = NECallStatus.none;

    CallState.instance.remoteUserList.clear();
    CallState.instance.caller = User();
    CallState.instance.calleeList.clear();
    CallState.instance.calleeIdList.clear();

    CallState.instance.mediaType = NECallType.audio;
    CallState.instance.timeCount = 0;
    CallState.instance.groupId = '';

    CallState.instance.isMicrophoneMute = false;
    CallState.instance.camera = NECamera.front;
    CallState.instance.isCameraOpen = false;
    CallState.instance.isEnableSpeaker = false;

    CallState.instance.isChangedBigSmallVideo = false;
    CallState.instance.enableBlurBackground = false;
  }

  bool isBadNetwork(NENetworkQuality quality) {
    return quality == NENetworkQuality.bad ||
        quality == NENetworkQuality.veryBad ||
        quality == NENetworkQuality.down;
  }
}
