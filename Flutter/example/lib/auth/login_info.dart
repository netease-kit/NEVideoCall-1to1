// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class LoginInfo {
  final String accountId;
  final String accountToken;
  final String? nickname;
  final String? avatar;
  final String? account;

  LoginInfo({
    required this.accountId,
    required this.accountToken,
    this.nickname,
    this.avatar,
    this.account,
  });

  factory LoginInfo.fromJson(Map<String, dynamic> json) {
    return LoginInfo(
      accountId: json['accountId'] ?? '',
      accountToken: json['accountToken'] ?? '',
      nickname: json['nickname'],
      avatar: json['avatar'],
      account: json['account'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountToken': accountToken,
      'nickname': nickname,
      'avatar': avatar,
      'account': account,
    };
  }
}
