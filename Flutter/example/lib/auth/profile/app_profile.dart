// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class AppProfile {
  static String accountToken = '';
  static String accountId = '';

  static void setAccountToken(String token) {
    accountToken = token;
  }

  static void setAccountId(String id) {
    accountId = id;
  }
}
