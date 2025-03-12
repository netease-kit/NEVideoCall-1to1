// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.utils;

import android.annotation.SuppressLint;

import androidx.annotation.NonNull;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public final class TimeUtils {

  private static final ThreadLocal<Map<String, SimpleDateFormat>> SDF_THREAD_LOCAL =
      new ThreadLocal<Map<String, SimpleDateFormat>>() {
        @Override
        protected Map<String, SimpleDateFormat> initialValue() {
          return new HashMap<>();
        }
      };

  @SuppressLint("SimpleDateFormat")
  public static SimpleDateFormat getSafeDateFormat(String pattern) {
    Map<String, SimpleDateFormat> sdfMap = SDF_THREAD_LOCAL.get();
    //noinspection ConstantConditions
    SimpleDateFormat simpleDateFormat = sdfMap.get(pattern);
    if (simpleDateFormat == null) {
      simpleDateFormat = new SimpleDateFormat(pattern);
      sdfMap.put(pattern, simpleDateFormat);
    }
    return simpleDateFormat;
  }

  private TimeUtils() {
    throw new UnsupportedOperationException("u can't instantiate me...");
  }

  /**
   * Milliseconds to the formatted time string.
   *
   * @param millis The milliseconds.
   * @param pattern The pattern of date format, such as yyyy/MM/dd HH:mm
   * @return the formatted time string
   */
  public static String millis2String(long millis, @NonNull final String pattern) {
    return getSafeDateFormat(pattern).format(new Date(millis));
  }

  public static String unitFormat(int i) {
    String retStr = null;
    if (i >= 0 && i < 10) retStr = "0" + i;
    else retStr = "" + i;
    return retStr;
  }

  public static String secToTime(int time) {
    String timeStr = null;
    int hour = 0;
    int minute = 0;
    int second = 0;
    if (time <= 0) return "00:00";
    else {
      minute = time / 60;
      if (minute < 60) {
        second = time % 60;
        timeStr = unitFormat(minute) + ":" + unitFormat(second);
      } else {
        hour = minute / 60;
        if (hour > 99) return "99:59:59";
        minute = minute % 60;
        second = time - hour * 3600 - minute * 60;
        timeStr = unitFormat(hour) + ":" + unitFormat(minute) + ":" + unitFormat(second);
      }
    }
    return timeStr;
  }
}
