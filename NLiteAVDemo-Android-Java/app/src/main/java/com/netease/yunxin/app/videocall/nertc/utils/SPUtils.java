// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.utils;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.NonNull;

import com.netease.yunxin.app.videocall.DemoApplication;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

@SuppressLint("ApplySharedPref")
public final class SPUtils {

  private static final Map<String, SPUtils> SP_UTILS_MAP = new HashMap<>();

  private final SharedPreferences sp;

  /**
   * Return the single {@link SPUtils} instance
   *
   * @return the single {@link SPUtils} instance
   */
  public static SPUtils getInstance() {
    return getInstance("", Context.MODE_PRIVATE);
  }

  /**
   * Return the single {@link SPUtils} instance
   *
   * @param mode Operating mode.
   * @return the single {@link SPUtils} instance
   */
  public static SPUtils getInstance(final int mode) {
    return getInstance("", mode);
  }

  /**
   * Return the single {@link SPUtils} instance
   *
   * @param spName The name of sp.
   * @return the single {@link SPUtils} instance
   */
  public static SPUtils getInstance(String spName) {
    return getInstance(spName, Context.MODE_PRIVATE);
  }

  /**
   * Return the single {@link SPUtils} instance
   *
   * @param spName The name of sp.
   * @param mode Operating mode.
   * @return the single {@link SPUtils} instance
   */
  public static SPUtils getInstance(String spName, final int mode) {
    if (isSpace(spName)) spName = "spUtils";
    SPUtils spUtils = SP_UTILS_MAP.get(spName);
    if (spUtils == null) {
      synchronized (SPUtils.class) {
        spUtils = SP_UTILS_MAP.get(spName);
        if (spUtils == null) {
          spUtils = new SPUtils(spName, mode);
          SP_UTILS_MAP.put(spName, spUtils);
        }
      }
    }
    return spUtils;
  }

  private SPUtils(final String spName, final int mode) {
    sp = DemoApplication.app.getSharedPreferences(spName, mode);
  }

  /**
   * Put the string value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   */
  public void put(@NonNull final String key, final String value) {
    put(key, value, false);
  }

  /**
   * Put the string value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   * @param isCommit True to use {@link SharedPreferences.Editor#commit()}, false to use {@link
   *     SharedPreferences.Editor#apply()}
   */
  public void put(@NonNull final String key, final String value, final boolean isCommit) {
    if (isCommit) {
      sp.edit().putString(key, value).commit();
    } else {
      sp.edit().putString(key, value).apply();
    }
  }

  /**
   * Return the string value in sp.
   *
   * @param key The key of sp.
   * @return the string value if sp exists or {@code ""} otherwise
   */
  public String getString(@NonNull final String key) {
    return getString(key, "");
  }

  /**
   * Return the string value in sp.
   *
   * @param key The key of sp.
   * @param defaultValue The default value if the sp doesn't exist.
   * @return the string value if sp exists or {@code defaultValue} otherwise
   */
  public String getString(@NonNull final String key, final String defaultValue) {
    return sp.getString(key, defaultValue);
  }

  /**
   * Return the long value in sp.
   *
   * @param key The key of sp.
   * @param defaultValue The default value if the sp doesn't exist.
   * @return the long value if sp exists or {@code defaultValue} otherwise
   */
  public long getLong(@NonNull final String key, final long defaultValue) {
    return sp.getLong(key, defaultValue);
  }

  /**
   * Return the int value in sp.
   *
   * @param key The key of sp.
   * @param defaultValue The default value if the sp doesn't exist.
   * @return the int value if sp exists or {@code defaultValue} otherwise
   */
  public int getInt(@NonNull final String key, final int defaultValue) {
    return sp.getInt(key, defaultValue);
  }

  /**
   * Return the boolean value in sp.
   *
   * @param key The key of sp.
   * @return the boolean value if sp exists or {@code false} otherwise
   */
  public boolean getBoolean(@NonNull final String key) {
    return getBoolean(key, false);
  }

  /**
   * Return the boolean value in sp.
   *
   * @param key The key of sp.
   * @param defaultValue The default value if the sp doesn't exist.
   * @return the boolean value if sp exists or {@code defaultValue} otherwise
   */
  public boolean getBoolean(@NonNull final String key, final boolean defaultValue) {
    return sp.getBoolean(key, defaultValue);
  }

  /**
   * Put the int value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   */
  public void put(@NonNull final String key, final int value) {
    put(key, value, false);
  }

  /**
   * Put the int value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   * @param isCommit True to use {@link SharedPreferences.Editor#commit()}, false to use {@link
   *     SharedPreferences.Editor#apply()}
   */
  public void put(@NonNull final String key, final int value, final boolean isCommit) {
    if (isCommit) {
      sp.edit().putInt(key, value).commit();
    } else {
      sp.edit().putInt(key, value).apply();
    }
  }

  /**
   * Put the long value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   */
  public void put(@NonNull final String key, final long value) {
    put(key, value, false);
  }

  /**
   * Put the long value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   * @param isCommit True to use {@link SharedPreferences.Editor#commit()}, false to use {@link
   *     SharedPreferences.Editor#apply()}
   */
  public void put(@NonNull final String key, final long value, final boolean isCommit) {
    if (isCommit) {
      sp.edit().putLong(key, value).commit();
    } else {
      sp.edit().putLong(key, value).apply();
    }
  }

  /**
   * Put the float value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   */
  public void put(@NonNull final String key, final float value) {
    put(key, value, false);
  }

  /**
   * Put the float value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   * @param isCommit True to use {@link SharedPreferences.Editor#commit()}, false to use {@link
   *     SharedPreferences.Editor#apply()}
   */
  public void put(@NonNull final String key, final float value, final boolean isCommit) {
    if (isCommit) {
      sp.edit().putFloat(key, value).commit();
    } else {
      sp.edit().putFloat(key, value).apply();
    }
  }

  /**
   * Put the boolean value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   */
  public void put(@NonNull final String key, final boolean value) {
    put(key, value, false);
  }

  /**
   * Put the boolean value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   * @param isCommit True to use {@link SharedPreferences.Editor#commit()}, false to use {@link
   *     SharedPreferences.Editor#apply()}
   */
  public void put(@NonNull final String key, final boolean value, final boolean isCommit) {
    if (isCommit) {
      sp.edit().putBoolean(key, value).commit();
    } else {
      sp.edit().putBoolean(key, value).apply();
    }
  }

  /**
   * Put the set of string value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   */
  public void put(@NonNull final String key, final Set<String> value) {
    put(key, value, false);
  }

  /**
   * Put the set of string value in sp.
   *
   * @param key The key of sp.
   * @param value The value of sp.
   * @param isCommit True to use {@link SharedPreferences.Editor#commit()}, false to use {@link
   *     SharedPreferences.Editor#apply()}
   */
  public void put(@NonNull final String key, final Set<String> value, final boolean isCommit) {
    if (isCommit) {
      sp.edit().putStringSet(key, value).commit();
    } else {
      sp.edit().putStringSet(key, value).apply();
    }
  }

  private static boolean isSpace(final String s) {
    if (s == null) return true;
    for (int i = 0, len = s.length(); i < len; ++i) {
      if (!Character.isWhitespace(s.charAt(i))) {
        return false;
      }
    }
    return true;
  }
}
