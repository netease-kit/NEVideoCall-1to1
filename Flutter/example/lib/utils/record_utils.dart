// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:callkit_example/service/call_record_service.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:nim_core_v2/nim_core.dart';

class RecordUtils {
  static Future<CallRecord?> parseForCallRecord(NIMMessage message) async {
    if (message.messageType == NIMMessageType.call &&
        message.sendingState == NIMMessageSendingState.succeeded) {
      var attachment = message.attachment;
      if (attachment == null) {
        print('handleNetCallAttachment attachment is null');
        return null;
      }

      // 检查是否为通话附件
      if (attachment is! NIMMessageCallAttachment) {
        return null;
      }

      // 获取会话目标ID
      var targetId = await _getTargetIdFromConversation(message);
      if (targetId == null || targetId.isEmpty) {
        print('handleNetCallAttachment targetId is null or empty');
        return null;
      }

      // 从通话附件中获取真实的通话类型
      NECallType callType = NECallType.audio; // 默认为音频
      // 根据type字段判断通话类型：1=音频，2=视频
      if (attachment.type == 2) {
        callType = NECallType.video;
      }

      // 创建通话记录
      final callRecord = CallRecord(
        accountId: targetId,
        isIncoming: !(message.isSelf ?? false), // 如果不是自己发送的，则为呼入
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          message.createTime ?? DateTime.now().millisecondsSinceEpoch,
        ),
        callType: callType,
      );
      return callRecord;
    }
    return null;
  }

  static Future<String?> _getTargetIdFromConversation(
      NIMMessage message) async {
    if (message.conversationId == null) {
      return null;
    }

    try {
      final result = await NimCore.instance.conversationIdUtil
          .conversationTargetId(message.conversationId!);
      return result.data;
    } catch (e) {
      print('Failed to get target ID: $e');
      return null;
    }
  }
}
