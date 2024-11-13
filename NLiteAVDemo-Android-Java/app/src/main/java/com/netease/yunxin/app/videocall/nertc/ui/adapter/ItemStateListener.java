// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.ui.adapter;

import com.netease.yunxin.app.videocall.login.model.LoginModel;

public interface ItemStateListener {
  int ADD = 1;
  int REMOVE = 2;
  int CONNECTION = 3;

  int onItemState(LoginModel data);
}