// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_callkit/netease_callkit.dart';

class NEValueCallback {
  const NEValueCallback({this.onSuccess, this.onError});

  final void Function(Object? data)? onSuccess;
  final void Function(int code, String message)? onError;
}

class NECallDefine {
  static const String version = "0.0.0.0";
}

/// Indicates the error code during the calls.
///
class NECallError {
  /// You have not purchased the calls capability package, please go to the IM console to activate the free experience or purchase the official version.
  static const int errorPackageNotPurchased = -1001;

  /// The calls capability package you currently purchased does not support this function. It is recommended that you upgrade the package type.
  static const int errorPackageNotSupported = -1002;
}

/// Indicates the role in the calls.
///
enum NECallRole {
  /// 0: Default value, no role.
  none,

  /// 1: Caller, the member who initiated the calls.
  caller,

  /// 2: Called, the member invited to the calls.
  called
}

/// Indicates the calls status
///
enum NECallStatus {
  /// 0: Default value, Idle state.
  none,

  /// 1: Waiting accept/reject state.
  waiting,

  /// 2: In calling state.
  accept
}

/// Indicates the call scene, including 1v1 calls, group calls etc.
enum NECallScene {
  /// 0: 1v1 calls.
  singleCall,

  /// 1: Group call.
  /// notes: you need to create an IM group in advance
  groupCall,
}

enum NECamera {
  front,
  back,
}

enum NEAudioPlaybackDevice {
  speakerphone,
  earpiece,
}

enum NECallResultType {
  unknown,
  missed,
  incoming,
  outgoing,
}

/// network quality
enum NENetworkQuality {
  /// 0: unknow
  unknown,

  /// 1: excellent
  excellent,

  /// 2: good
  good,

  /// 3: poor
  poor,

  /// 4: bad
  bad,

  /// 5: very bad
  veryBad,

  /// 6: down
  down,
}

/// 证书配置参数
class NECertificateConfig {
  final String? apnsCername; // APNS 证书名称
  final String? pkCername; // PushKit 证书名称

  NECertificateConfig({
    this.apnsCername,
    this.pkCername,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['apnsCername'] = apnsCername;
    data['pkCername'] = pkCername;
    return data;
  }
}

/// 额外配置参数
class NEExtraConfig {
  final NELCKConfig? lckConfig; // Live Communication Kit 配置

  NEExtraConfig({
    this.lckConfig,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lckConfig != null) {
      data['lckConfig'] = {
        'enableLiveCommunicationKit': lckConfig!.enableLiveCommunicationKit,
        'ringtoneName': lckConfig!.ringtoneName,
      };
    }
    return data;
  }
}

/// network quality info
class NENetworkQualityInfo {
  /// user id
  String userId;

  /// network quality
  NENetworkQuality quality;

  NENetworkQualityInfo({required this.userId, required this.quality});
}

/// Generic function return type
class NEResult {
  int code;
  String? message;

  NEResult({
    required this.code,
    required this.message,
  });
}

class NECallParams {
  NECallPushConfig? pushConfig;
  NECallParams();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pushConfig != null) {
      data['pushConfig'] = {
        'pushTitle': pushConfig!.pushTitle,
        'pushContent': pushConfig!.pushContent,
        'pushPayload': pushConfig!.pushPayload,
        'needBadge': pushConfig!.needBadge,
        'needPush': pushConfig!.needPush,
      };
    }
    return data;
  }
}

class NECallRecords {
  String? callId;
  String? inviter;
  List<String>? inviteList;
  NECallScene? scene;
  NECallType? mediaType;
  String? groupId;
  NECallRole? role;
  NECallResultType? result;
  int? beginTime;
  int? totalTime;
}

class NECallRecentCallsFilter {
  double? begin;
  double? end;
  NECallResultType resultType = NECallResultType.unknown;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['begin'] = begin;
    data['end'] = end;
    data['resultType'] = resultType.index;
    return data;
  }
}

class CallObserverExtraInfo {
  NECallRole role = NECallRole.none;
  String userData = "";
  String chatGroupId = "";

  static CallObserverExtraInfo fromJson(Map data) {
    CallObserverExtraInfo info = CallObserverExtraInfo();
    info.role = NECallRole.values[data['role'] ?? 0];
    info.userData = data['userData'] ?? "";
    info.chatGroupId = data['chatGroupId'] ?? "";
    return info;
  }

  @override
  String toString() {
    return ' {'
        ' role: $role'
        ' userData: $userData'
        ' chatGroupId: $chatGroupId';
  }
}

enum CallEndReason {
  unknown,
  hangup,
  reject,
  noResponse,
  offline,
  lineBusy,
  canceled,
  otherDeviceAccepted,
  otherDeviceReject,
  endByServer,
}
