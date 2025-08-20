// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:netease_callkit/netease_callkit.dart';

/// 通话记录数据模型
class CallRecord {
  final String accountId;
  final bool isIncoming;
  final DateTime timestamp;
  final NECallType callType;

  CallRecord({
    required this.accountId,
    required this.isIncoming,
    required this.timestamp,
    this.callType = NECallType.audio,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'isIncoming': isIncoming,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'callType': callType.index,
    };
  }

  /// 从JSON创建
  factory CallRecord.fromJson(Map<String, dynamic> json) {
    return CallRecord(
      accountId: json['accountId'] as String,
      isIncoming: json['isIncoming'] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      callType: NECallType.values[json['callType'] as int],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CallRecord &&
        other.accountId == accountId &&
        other.isIncoming == isIncoming &&
        other.timestamp == timestamp &&
        other.callType == callType;
  }

  @override
  int get hashCode {
    return accountId.hashCode ^
        isIncoming.hashCode ^
        timestamp.hashCode ^
        callType.hashCode;
  }

  @override
  String toString() {
    return 'CallRecord{accountId: $accountId, isIncoming: $isIncoming, timestamp: $timestamp, callType: $callType}';
  }
}
