// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/data/user.dart';
import 'package:netease_callkit_ui/src/utils/string_stream.dart';
import 'package:nim_core_v2/nim_core.dart';

class NimUtils {
  static Future<User> getUserInfo(String accountId) async {
    final imUserInfo = await getUserInfos([accountId]);
    User user = User();
    user.id = accountId;
    user.nickname = imUserInfo[0].nickname;
    user.avatar = imUserInfo[0].avatar;
    return user;
  }

  static Future<List<User>> getUserInfos(List<String> accountIds) async {
    List<User> userList = [];
    final imUserInfo =
        await NimCore.instance.userService.getUserList(accountIds);
    imUserInfo.data?.forEach((element) {
      User user = User();
      user.id = StringStream.makeNull(element.accountId, '');
      user.nickname = StringStream.makeNull(element.name, '');
      user.avatar =
          StringStream.makeNull(element.avatar, Constants.defaultAvatar);
      userList.add(user);
    });

    return userList;
  }
}
