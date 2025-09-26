// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:netease_callkit_ui/src/call_define.dart';

class User {
  String id = '';
  String avatar = '';
  String nickname = '';
  String remark = '';
  NECallRole callRole = NECallRole.none;
  NECallStatus callStatus = NECallStatus.none;
  bool audioAvailable = true;
  bool videoAvailable = false;
  int playOutVolume = 0;
  int viewID = 0;
  bool networkQualityReminder = false;
  var key = GlobalKey();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['avatar'] = avatar;
    data['nickname'] = nickname;
    data['remark'] = remark;
    data['callRole'] = callRole.index;
    data['callStatus'] = callStatus.index;
    data['audioAvailable'] = audioAvailable;
    data['videoAvailable'] = videoAvailable;
    data['playOutVolume'] = playOutVolume;
    data['viewID'] = viewID;
    data['networkQualityReminder'] = networkQualityReminder;
    return data;
  }

  static String getUserDisplayName(User user) {
    if (user.remark.isNotEmpty) {
      return user.remark;
    }
    if (user.nickname.isNotEmpty) {
      return user.nickname;
    }
    return user.id;
  }
}
