// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.model;

import java.io.Serializable;
import java.util.List;

public class CallOrder implements Serializable {

  private String sessionId; //对方的imAccount

  private long receivedTime; //收到时间

  private boolean isSelf; //方向

  private String nickname; //昵称

  /** 话单类型，参考V2NIMSignallingChannelType */
  private int type;

  /** 话单频道ID */
  private String channelId;

  /** 通话状态 */
  private int status;

  /** 通话成员时长列表 */
  private List<CallDuration> durationList;

  public CallOrder(String sessionId, long receivedTime, boolean isSelf, String nickname) {
    this.sessionId = sessionId;
    this.receivedTime = receivedTime;
    this.isSelf = isSelf;
    this.nickname = nickname;
  }

  public CallOrder(
      String sessionId,
      long receivedTime,
      boolean isSelf,
      String nickname,
      int type,
      String channelId,
      int status,
      List<CallDuration> durationList) {
    this.sessionId = sessionId;
    this.receivedTime = receivedTime;
    this.isSelf = isSelf;
    this.nickname = nickname;
    this.type = type;
    this.channelId = channelId;
    this.status = status;
    this.durationList = durationList;
  }

  public static class CallDuration implements Serializable {
    private String accountId;
    private int duration;

    public CallDuration(String accountId, int duration) {
      this.accountId = accountId;
      this.duration = duration;
    }

    public String getAccountId() {
      return accountId;
    }

    public void setAccountId(String accountId) {
      this.accountId = accountId;
    }

    public int getDuration() {
      return duration;
    }

    public void setDuration(int duration) {
      this.duration = duration;
    }

    @Override
    public String toString() {
      return "CallDuration{" + "accountId='" + accountId + '\'' + ", duration=" + duration + '}';
    }
  }

  public String getSessionId() {
    return sessionId;
  }

  public void setSessionId(String sessionId) {
    this.sessionId = sessionId;
  }

  public long getReceivedTime() {
    return receivedTime;
  }

  public void setReceivedTime(long receivedTime) {
    this.receivedTime = receivedTime;
  }

  public boolean isSelf() {
    return isSelf;
  }

  public void setSelf(boolean self) {
    isSelf = self;
  }

  public String getNickname() {
    return nickname;
  }

  public void setNickname(String nickname) {
    this.nickname = nickname;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public String getChannelId() {
    return channelId;
  }

  public void setChannelId(String channelId) {
    this.channelId = channelId;
  }

  public int getStatus() {
    return status;
  }

  public void setStatus(int status) {
    this.status = status;
  }

  public List<CallDuration> getDurationList() {
    return durationList;
  }

  public void setDurationList(List<CallDuration> durationList) {
    this.durationList = durationList;
  }

  @Override
  public String toString() {
    return "CallOrder{"
        + "sessionId='"
        + sessionId
        + '\''
        + ", receivedTime="
        + receivedTime
        + ", isSelf="
        + isSelf
        + ", nickname='"
        + nickname
        + '\''
        + ", type="
        + type
        + ", channelId='"
        + channelId
        + '\''
        + ", status="
        + status
        + ", durationList="
        + durationList
        + '}';
  }
}
