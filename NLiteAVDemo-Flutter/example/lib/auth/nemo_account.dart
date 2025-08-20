// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class NemoAccount {
  final String userUuid;
  final String userName;
  final String userToken;
  final String? icon;

  NemoAccount({
    required this.userUuid,
    required this.userName,
    required this.userToken,
    this.icon,
  });

  factory NemoAccount.fromJson(Map<String, dynamic> json) {
    return NemoAccount(
      userUuid: json['userUuid'] ?? '',
      userName: json['userName'] ?? '',
      userToken: json['userToken'] ?? '',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userUuid': userUuid,
      'userName': userName,
      'userToken': userToken,
      'icon': icon,
    };
  }

  @override
  String toString() {
    return 'NemoAccount{userUuid: $userUuid, userName: $userName, userToken: $userToken, icon: $icon}';
  }
}
