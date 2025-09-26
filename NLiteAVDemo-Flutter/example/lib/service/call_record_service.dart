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

/// 通话记录存储配置
class CallRecordStorageConfig {
  /// 存储键前缀
  static const String keyPrefix = 'call_records_';

  /// 最大记录数量
  static const int maxRecordCount = 100;

  /// 是否启用自动清理过期记录
  static const bool enableAutoCleanup = true;

  /// 记录过期天数
  static const int recordExpireDays = 30;
}

/// 通话记录存储管理类
class CallRecordStorage {
  static final CallRecordStorage _instance = CallRecordStorage._internal();
  factory CallRecordStorage() => _instance;
  CallRecordStorage._internal();

  SharedPreferences? _prefs;

  /// 初始化存储
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  /// 获取存储key
  String _getStorageKey(String accountId) {
    return '${CallRecordStorageConfig.keyPrefix}$accountId';
  }

  /// 保存通话记录列表
  Future<bool> saveCallRecords(
      String accountId, List<CallRecord> records) async {
    try {
      await _ensureInitialized();
      final key = _getStorageKey(accountId);
      final jsonList = records.map((record) => record.toJson()).toList();
      return await _prefs!.setString(key, jsonEncode(jsonList));
    } catch (e) {
      print('Failed to save call records: $e');
      return false;
    }
  }

  /// 加载通话记录列表
  Future<List<CallRecord>> loadCallRecords(String accountId) async {
    try {
      await _ensureInitialized();
      final key = _getStorageKey(accountId);
      final jsonString = _prefs!.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final records = jsonList
          .map((json) => CallRecord.fromJson(json as Map<String, dynamic>))
          .toList();

      // 自动清理过期记录
      if (CallRecordStorageConfig.enableAutoCleanup) {
        final cleanedRecords = _cleanupExpiredRecords(records);
        if (cleanedRecords.length != records.length) {
          await saveCallRecords(accountId, cleanedRecords);
        }
        return cleanedRecords;
      }

      return records;
    } catch (e) {
      print('Failed to load call records: $e');
      return [];
    }
  }

  /// 添加单个通话记录
  Future<bool> addCallRecord(String accountId, CallRecord record) async {
    try {
      final records = await loadCallRecords(accountId);
      records.insert(0, record);

      // 限制记录数量
      if (records.length > CallRecordStorageConfig.maxRecordCount) {
        records.removeRange(
            CallRecordStorageConfig.maxRecordCount, records.length);
      }

      return await saveCallRecords(accountId, records);
    } catch (e) {
      print('Failed to add call record: $e');
      return false;
    }
  }

  /// 批量添加通话记录
  Future<bool> addCallRecords(
      String accountId, List<CallRecord> newRecords) async {
    try {
      final records = await loadCallRecords(accountId);
      records.insertAll(0, newRecords);

      // 限制记录数量
      if (records.length > CallRecordStorageConfig.maxRecordCount) {
        records.removeRange(
            CallRecordStorageConfig.maxRecordCount, records.length);
      }

      return await saveCallRecords(accountId, records);
    } catch (e) {
      print('Failed to add call records: $e');
      return false;
    }
  }

  /// 删除指定记录
  Future<bool> deleteCallRecord(String accountId, CallRecord record) async {
    try {
      final records = await loadCallRecords(accountId);
      records.removeWhere((r) => r == record);
      return await saveCallRecords(accountId, records);
    } catch (e) {
      print('Failed to delete call record: $e');
      return false;
    }
  }

  /// 清除所有通话记录
  Future<bool> clearCallRecords(String accountId) async {
    try {
      await _ensureInitialized();
      final key = _getStorageKey(accountId);
      return await _prefs!.remove(key);
    } catch (e) {
      print('Failed to clear call records: $e');
      return false;
    }
  }

  /// 获取记录数量
  Future<int> getRecordCount(String accountId) async {
    try {
      final records = await loadCallRecords(accountId);
      return records.length;
    } catch (e) {
      print('Failed to get record count: $e');
      return 0;
    }
  }

  /// 搜索通话记录
  Future<List<CallRecord>> searchCallRecords(
    String accountId, {
    String? keyword,
    DateTime? startDate,
    DateTime? endDate,
    NECallType? callType,
    bool? isIncoming,
  }) async {
    try {
      final records = await loadCallRecords(accountId);
      return records.where((record) {
        // 关键词搜索
        if (keyword != null && keyword.isNotEmpty) {
          if (!record.accountId.toLowerCase().contains(keyword.toLowerCase())) {
            return false;
          }
        }

        // 日期范围搜索
        if (startDate != null && record.timestamp.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && record.timestamp.isAfter(endDate)) {
          return false;
        }

        // 通话类型搜索
        if (callType != null && record.callType != callType) {
          return false;
        }

        // 呼入/呼出搜索
        if (isIncoming != null && record.isIncoming != isIncoming) {
          return false;
        }

        return true;
      }).toList();
    } catch (e) {
      print('Failed to search call records: $e');
      return [];
    }
  }

  /// 清理过期记录
  List<CallRecord> _cleanupExpiredRecords(List<CallRecord> records) {
    final expireDate = DateTime.now()
        .subtract(Duration(days: CallRecordStorageConfig.recordExpireDays));
    return records
        .where((record) => record.timestamp.isAfter(expireDate))
        .toList();
  }

  /// 导出通话记录
  Future<String> exportCallRecords(String accountId) async {
    try {
      final records = await loadCallRecords(accountId);
      return jsonEncode(records.map((record) => record.toJson()).toList());
    } catch (e) {
      print('Failed to export call records: $e');
      return '[]';
    }
  }

  /// 导入通话记录
  Future<bool> importCallRecords(String accountId, String jsonData) async {
    try {
      final jsonList = jsonDecode(jsonData) as List<dynamic>;
      final records = jsonList
          .map((json) => CallRecord.fromJson(json as Map<String, dynamic>))
          .toList();
      return await addCallRecords(accountId, records);
    } catch (e) {
      print('Failed to import call records: $e');
      return false;
    }
  }

  /// 获取所有账号的通话记录统计
  Future<Map<String, int>> getAllAccountsRecordCount() async {
    try {
      await _ensureInitialized();
      final keys = _prefs!.getKeys();
      final callRecordKeys = keys
          .where((key) => key.startsWith(CallRecordStorageConfig.keyPrefix));

      final result = <String, int>{};
      for (final key in callRecordKeys) {
        final accountId =
            key.substring(CallRecordStorageConfig.keyPrefix.length);
        final count = await getRecordCount(accountId);
        result[accountId] = count;
      }
      return result;
    } catch (e) {
      print('Failed to get all accounts record count: $e');
      return {};
    }
  }

  /// 清理所有过期记录
  Future<void> cleanupAllExpiredRecords() async {
    try {
      await _ensureInitialized();
      final keys = _prefs!.getKeys();
      final callRecordKeys = keys
          .where((key) => key.startsWith(CallRecordStorageConfig.keyPrefix));

      for (final key in callRecordKeys) {
        final accountId =
            key.substring(CallRecordStorageConfig.keyPrefix.length);
        final records = await loadCallRecords(accountId);
        final cleanedRecords = _cleanupExpiredRecords(records);
        if (cleanedRecords.length != records.length) {
          await saveCallRecords(accountId, cleanedRecords);
        }
      }
    } catch (e) {
      print('Failed to cleanup all expired records: $e');
    }
  }
}

/// 通话记录服务类 - 提供高级功能
abstract class CallRecordService {
  final CallRecordStorage _storage = CallRecordStorage();

  /// 获取当前登录账号ID的抽象方法
  /// 子类需要实现此方法来获取实际的账号ID
  Future<String?> getCurrentAccountId() async {
    throw UnimplementedError('getCurrentAccountId must be implemented');
  }

  /// 加载当前账号的通话记录
  Future<List<CallRecord>> loadCurrentAccountRecords() async {
    final accountId = await getCurrentAccountId();
    if (accountId == null) return [];
    return await _storage.loadCallRecords(accountId);
  }

  /// 为当前账号添加通话记录
  Future<bool> addRecordToCurrentAccount(CallRecord record) async {
    final accountId = await getCurrentAccountId();
    if (accountId == null) return false;
    return await _storage.addCallRecord(accountId, record);
  }

  /// 清除当前账号的通话记录
  Future<bool> clearCurrentAccountRecords() async {
    final accountId = await getCurrentAccountId();
    if (accountId == null) return false;
    return await _storage.clearCallRecords(accountId);
  }

  /// 搜索当前账号的通话记录
  Future<List<CallRecord>> searchCurrentAccountRecords({
    String? keyword,
    DateTime? startDate,
    DateTime? endDate,
    NECallType? callType,
    bool? isIncoming,
  }) async {
    final accountId = await getCurrentAccountId();
    if (accountId == null) return [];
    return await _storage.searchCallRecords(
      accountId,
      keyword: keyword,
      startDate: startDate,
      endDate: endDate,
      callType: callType,
      isIncoming: isIncoming,
    );
  }

  /// 获取当前账号的记录数量
  Future<int> getCurrentAccountRecordCount() async {
    final accountId = await getCurrentAccountId();
    if (accountId == null) return 0;
    return await _storage.getRecordCount(accountId);
  }

  /// 导出当前账号的通话记录
  Future<String> exportCurrentAccountRecords() async {
    final accountId = await getCurrentAccountId();
    if (accountId == null) return '[]';
    return await _storage.exportCallRecords(accountId);
  }

  /// 导入通话记录到当前账号
  Future<bool> importRecordsToCurrentAccount(String jsonData) async {
    final accountId = await getCurrentAccountId();
    if (accountId == null) return false;
    return await _storage.importCallRecords(accountId, jsonData);
  }
}
