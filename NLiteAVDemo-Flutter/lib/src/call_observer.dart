// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/src/call_define.dart';

/// The NECallObserver class.
/// NECallObserver is used to observe NECallEngine event that you are interested in.
///
class NECallObserver {
  const NECallObserver({
    this.onError,
    this.onUserInviting,
    this.onCallReceived,
    this.onCallCancelled,
    this.onCallNotConnected,
    this.onCallBegin,
    this.onCallEnd,
    this.onCallMediaTypeChanged,
    this.onUserReject,
    this.onUserNoResponse,
    this.onUserLineBusy,
    this.onUserJoin,
    this.onUserLeave,
    this.onUserVideoAvailable,
    this.onUserAudioAvailable,
    this.onUserVoiceVolumeChanged,
    this.onUserNetworkQualityChanged,
    this.onKickedOffline,
    this.onUserSigExpired,
  });

  /// An error occurred inside the SDK.
  ///
  /// [code] Error code
  /// [messgae]  Error message
  ///
  final void Function(int code, String message)? onError;

  final void Function(String userId)? onUserInviting;

  /// Callback for receiving a call request (received only by the callee)
  ///
  /// [callId]        Unique identifier for this call
  /// [callerId]      Caller
  /// [calleeIdList]  List of callees
  /// [mediaType]     Call type，eg: audio、video
  /// [info]          Callback extension information
  ///
  final void Function(String callId, String callerId, List<String> calleeIdList,
      NECallType mediaType, CallObserverExtraInfo info)? onCallReceived;

  /// A user who cancel the call (Deprecated)
  ///
  /// **This interface has been deprecated. Please use onCallEnd instead.**
  ///
  /// [callerId]  User who cancel the call request
  ///
  @Deprecated(
      'This interface has been deprecated. Please use onCallNotConnected instead.')
  final void Function(String callerId)? onCallCancelled;

  /// The call was not connected on the current device
  ///
  /// [callId]        Unique identifier for this call
  /// [mediaType]     Call type，eg: audio、video
  /// [reason]        Call end reason.
  /// [userId]        Which user ended the call
  /// [info]          Callback extension information
  final void Function(String callId, NECallType mediaType, CallEndReason reason,
      String userId, CallObserverExtraInfo info)? onCallNotConnected;

  /// Call start(received by both caller and callee)
  ///
  /// [callId]        Unique identifier for this call
  /// [mediaType]     Call type，eg: audio、video
  /// [info]          Callback extension information
  final void Function(
          String callId, NECallType mediaType, CallObserverExtraInfo info)?
      onCallBegin;

  /// Call end(received by both caller and callee)
  ///
  /// [callId]        Unique identifier for this call
  /// [mediaType]     Call type，eg: audio、video
  /// [reason]        Call end reason.
  /// [userId]        Which user ended the call
  /// [totalTime ]    Total time of the call
  /// [info]          Callback extension information
  final void Function(String callId, NECallType mediaType, CallEndReason reason,
      String userId, double totalTime, CallObserverExtraInfo info)? onCallEnd;

  /// call type change
  ///
  /// [oldCallMediaType] Old call type
  /// [newCallMediaType] New call type
  final void Function(NECallType oldCallMediaType, NECallType newCallMediaType)?
      onCallMediaTypeChanged;

  /// A user who reject the call
  ///
  /// [userId] User who reject the call
  final void Function(String userId)? onUserReject;

  /// A user who did not answer the call
  ///
  /// [userId] User who did not answer the call
  final void Function(String userId)? onUserNoResponse;

  /// A user who is busy
  ///
  /// [userId] User who is busy
  final void Function(String onUserLineBusy)? onUserLineBusy;

  /// A user who join the call
  ///
  /// [userId] User who join the call
  final void Function(String userId)? onUserJoin;

  /// A user who leave the call
  ///
  /// [userId] User who leave the call
  final void Function(String userId)? onUserLeave;

  /// A remote user published/unpublished primary stream video
  ///
  /// [userId]           User ID of the remote user
  /// [isVideoAvailable] Whether the user published (or unpublished) primary stream video
  final void Function(String userId, bool isVideoAvailable)?
      onUserVideoAvailable;

  /// A remote user published/unpublished audio
  ///
  /// [userId]           User ID of the remote user
  /// [isAudioAvailable] Whether the user published (or unpublished) audio.
  final void Function(String userId, bool isAudioAvailable)?
      onUserAudioAvailable;

  /// All user volume change
  ///
  /// [volumeMap] The total volume of all users. Value range: 0-100
  final void Function(Map<String, int> volumeMap)? onUserVoiceVolumeChanged;

  /// Real-time network quality statistics
  ///
  /// [networkQualityList] All users Real-time network quality statistics
  final void Function(List<NENetworkQualityInfo> networkQualityList)?
      onUserNetworkQualityChanged;

  /// The callback of the current user being kicked off, the user can be prompted on the UI at this time, and call init() function of NECallEngine to log in again.
  ///
  final void Function()? onKickedOffline;

  /// The callback of the login credentials expired when online, you need to generate a new userSig and call init() function of NECallEngine to log in again.
  ///
  final void Function()? onUserSigExpired;
}
