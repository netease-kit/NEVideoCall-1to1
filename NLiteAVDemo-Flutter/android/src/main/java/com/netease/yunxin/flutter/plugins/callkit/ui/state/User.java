// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.state;

import androidx.annotation.NonNull;
import java.util.Objects;

public class User {
  public String id = "";
  public String avatar = "";
  public String remark = "";
  public String nickname = "";
  public CallState.CallRole callRole = CallState.CallRole.None;
  public CallState.CallStatus callStatus = CallState.CallStatus.None;
  public boolean audioAvailable = false;
  public boolean videoAvailable = false;
  public int playoutVolume = 0;

  public boolean isSameUser(User user) {
    if (id != user.id
        || avatar != user.avatar
        || nickname != user.nickname
        || audioAvailable != user.audioAvailable
        || videoAvailable != user.videoAvailable
        || playoutVolume != user.playoutVolume) {
      return false;
    }
    return true;
  }

  public String getUserDisplayName() {
    if (!Objects.equals(remark, "")) {
      return remark;
    }
    if (!Objects.equals(nickname, "")) {
      return nickname;
    }
    return id;
  }

  @NonNull
  @Override
  public String toString() {
    return "User:{"
        + "id: "
        + id
        + ", avatar: "
        + avatar
        + ", nickname: "
        + nickname
        + ", audioAvailable: "
        + audioAvailable
        + ", videoAvailable: "
        + videoAvailable
        + ", playoutVolume: "
        + playoutVolume
        + "}";
  }
}
