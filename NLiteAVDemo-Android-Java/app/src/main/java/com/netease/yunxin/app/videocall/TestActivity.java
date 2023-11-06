// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import androidx.annotation.NonNull;

import com.netease.yunxin.nertc.ui.base.CallParam;
import com.netease.yunxin.nertc.ui.p2p.P2PCallFragmentActivity;
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig;

public class TestActivity extends P2PCallFragmentActivity {

  @NonNull
  @Override
  protected P2PUIConfig provideUIConfig(CallParam param) {
    return new P2PUIConfig.Builder()
        .enableVirtualBlur(true)
        .enableFloatingWindow(true)
        .enableVirtualBlur(true)
        .enableForegroundService(true)
        .build();
  }
}
