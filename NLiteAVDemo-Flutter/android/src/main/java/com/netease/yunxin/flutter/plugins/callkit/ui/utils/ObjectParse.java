// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.utils;

import com.netease.yunxin.flutter.plugins.callkit.ui.state.CallState;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.User;
import com.netease.yunxin.kit.call.p2p.model.NECallType;
import java.util.Map;

public class ObjectParse {

  public static int getMediaType(int index) {
    switch (index) {
      case 0:
        return NECallType.AUDIO;
      case 1:
        return NECallType.AUDIO;
      case 2:
        return NECallType.VIDEO;
      default:
        break;
    }
    return NECallType.AUDIO;
  }

  public static CallState.CallStatus getStatusType(int index) {
    switch (index) {
      case 0:
        return CallState.CallStatus.None;
      case 1:
        return CallState.CallStatus.Waiting;
      case 2:
        return CallState.CallStatus.Accept;
      default:
        break;
    }
    return CallState.CallStatus.None;
  }

  public static CallState.CallRole getRoleType(int index) {
    switch (index) {
      case 0:
        return CallState.CallRole.None;
      case 1:
        return CallState.CallRole.Caller;
      case 2:
        return CallState.CallRole.Called;
      default:
        break;
    }
    return CallState.CallRole.None;
  }

  public static User getUserByMap(Map map) {
    if (map == null || map.size() <= 0) {
      return null;
    }
    User user = new User();
    if (map.get("id") != null) {
      user.id = (String) map.get("id");
    }
    if (map.get("avatar") != null) {
      user.avatar = (String) map.get("avatar");
    }
    if (map.get("remark") != null) {
      user.remark = (String) map.get("remark");
    }
    if (map.get("nickname") != null) {
      user.nickname = (String) map.get("nickname");
    }
    if (map.get("callRole") != null) {
      int callRoleIndex = (int) map.get("callRole");
      user.callRole = ObjectParse.getRoleType(callRoleIndex);
    }
    if (map.get("callStatus") != null) {
      int callStatusIndex = (int) map.get("callStatus");
      user.callStatus = ObjectParse.getStatusType(callStatusIndex);
    }
    if (map.get("audioAvailable") != null) {
      user.audioAvailable = (boolean) map.get("audioAvailable");
    }
    if (map.get("videoAvailable") != null) {
      user.videoAvailable = (boolean) map.get("videoAvailable");
    }
    if (map.get("playOutVolume") != null) {
      user.playoutVolume = (int) map.get("playOutVolume");
    }
    return user;
  }
}
