// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class Constants {
  static const String pluginVersion = '3.0.0';
  static const String defaultAvatar =
      "https://yx-web-nosdn.netease.im/common/8aaaf3fb0524d941d603f32c877d897d/default-avatar.png";

  static const int blurLevelHigh = 3;
  static const int blurLevelClose = 0;
}

enum NetworkQualityHint {
  none,
  local,
  remote,
}

const setStateEvent = 'SET_STATE_EVENT';
const setStateEventOnCallReceived = 'SET_STATE_EVENT_ONCALLRECEIVED';
const setStateEventOnCallEnd = 'SET_STATE_EVENT_ONCALLEND';
const setStateEventRefreshTiming = 'SET_STATE_EVENT_REFRESH_TIMING';
const setStateEventOnCallBegin = 'SET_STATE_EVENT_CALLBEGIN';
const setStateEventGroupCallUserWidgetRefresh =
    'SET_STATE_EVENT_GROUP_CALL_USER_WIDGET_REFRESH';
