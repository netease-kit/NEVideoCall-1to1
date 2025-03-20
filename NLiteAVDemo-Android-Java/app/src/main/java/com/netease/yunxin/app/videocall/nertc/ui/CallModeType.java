// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.ui;

public interface CallModeType {
  /** 音视频 1对1 视频呼叫 */
  int RTC_1V1_VIDEO_CALL = 1;

  /** pstn 1对1 语音呼叫 */
  int PSTN_1V1_AUDIO_CALL = 2;

  /** 群组呼叫 */
  int RTC_GROUP_CALL = 3;

  /** 群组邀请 */
  int RTC_GROUP_INVITE = 4;
}
