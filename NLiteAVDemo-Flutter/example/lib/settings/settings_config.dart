// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class SettingsConfig {
  static const defaultAvatar =
      "https://yx-web-nosdn.netease.im/common/28150847a7871d8cb031efc5dc62e909/avatar_meinv.png";
  static const version = '1.0.0';

  static String userId = '';
  static String avatar = '';
  static String nickname = '';

  static bool muteMode = false;
  static bool enableFloatWindow = true;
  static bool showBlurBackground = false;
  static bool showIncomingBanner = true;

  static int intRoomId = 0;
  static String strRoomId = "";
  static int timeout = 30;
  static String extendInfo = "";
}
