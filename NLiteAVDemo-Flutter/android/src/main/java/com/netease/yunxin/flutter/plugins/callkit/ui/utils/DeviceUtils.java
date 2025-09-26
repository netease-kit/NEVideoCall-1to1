// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.utils;

import android.app.KeyguardManager;
import android.content.Context;
import android.os.Build;
import android.text.TextUtils;
import java.lang.reflect.Method;

public class DeviceUtils {
  public static Boolean isSamsungDevice() {
    String brand = Build.BRAND;
    String manufacturer = Build.MANUFACTURER;
    return "samsung".equalsIgnoreCase(brand) && "samsung".equalsIgnoreCase(manufacturer);
  }

  public static boolean isScreenLocked(Context context) {
    KeyguardManager keyguardManager =
        (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
      // >= Android 5.1
      return keyguardManager.isDeviceLocked();
    } else {
      // < Android 5.1
      return keyguardManager.inKeyguardRestrictedInputMode();
    }
  }

  private static final String TAG = "Devices";
  private static String MODEL = "";
  private static String BRAND = "";
  private static String DEVICE = "";
  private static String MANUFACTURER = "";
  private static String HARDWARE = "";
  private static String VERSION = "";
  private static String BOARD = "";
  private static String VERSION_INCREMENTAL = "";
  private static int VERSION_INT = 0;

  public DeviceUtils() {}

  public static void setModel(final String model) {
    Class var1 = DeviceUtils.class;
    synchronized (DeviceUtils.class) {
      MODEL = model;
    }
  }

  public static String getModel() {
    if (MODEL == null || MODEL.isEmpty()) {
      Class var0 = DeviceUtils.class;
      synchronized (DeviceUtils.class) {
        if (MODEL == null || MODEL.isEmpty()) {
          MODEL = Build.MODEL;
          CallUILog.i("Devices", "get MODEL by Build.MODEL :" + MODEL);
        }
      }
    }

    return MODEL;
  }

  public static void setBrand(final String brand) {
    Class var1 = DeviceUtils.class;
    synchronized (DeviceUtils.class) {
      BRAND = brand;
    }
  }

  public static String getBrand() {
    if (BRAND == null || BRAND.isEmpty()) {
      Class var0 = DeviceUtils.class;
      synchronized (DeviceUtils.class) {
        if (BRAND == null || BRAND.isEmpty()) {
          BRAND = Build.BRAND;
          CallUILog.i("Devices", "get BRAND by Build.BRAND :" + BRAND);
        }
      }
    }

    return BRAND;
  }

  public static void setDevice(final String device) {
    Class var1 = DeviceUtils.class;
    synchronized (DeviceUtils.class) {
      DEVICE = device;
    }
  }

  public static String getDevice() {
    if (DEVICE == null || DEVICE.isEmpty()) {
      Class var0 = DeviceUtils.class;
      synchronized (DeviceUtils.class) {
        if (DEVICE == null || DEVICE.isEmpty()) {
          DEVICE = Build.DEVICE;
          CallUILog.i("Devices", "get DEVICE by Build.DEVICE :" + DEVICE);
        }
      }
    }

    return DEVICE;
  }

  public static void setManufacturer(final String manufacturer) {
    Class var1 = DeviceUtils.class;
    synchronized (DeviceUtils.class) {
      MANUFACTURER = manufacturer;
    }
  }

  public static String getManufacturer() {
    if (MANUFACTURER == null || MANUFACTURER.isEmpty()) {
      Class var0 = DeviceUtils.class;
      synchronized (DeviceUtils.class) {
        if (MANUFACTURER == null || MANUFACTURER.isEmpty()) {
          MANUFACTURER = Build.MANUFACTURER;
          CallUILog.i("Devices", "get MANUFACTURER by Build.MANUFACTURER :" + MANUFACTURER);
        }
      }
    }

    return MANUFACTURER;
  }

  public static void setHardware(final String hardware) {
    Class var1 = DeviceUtils.class;
    synchronized (DeviceUtils.class) {
      HARDWARE = hardware;
    }
  }

  public static String getHardware() {
    if (HARDWARE == null || HARDWARE.isEmpty()) {
      Class var0 = DeviceUtils.class;
      synchronized (DeviceUtils.class) {
        if (HARDWARE == null || HARDWARE.isEmpty()) {
          HARDWARE = Build.HARDWARE;
          CallUILog.i("Devices", "get HARDWARE by Build.HARDWARE :" + HARDWARE);
        }
      }
    }

    return HARDWARE;
  }

  public static void setVersion(final String version) {
    Class var1 = DeviceUtils.class;
    synchronized (DeviceUtils.class) {
      VERSION = version;
    }
  }

  public static String getVersion() {
    if (VERSION == null || VERSION.isEmpty()) {
      Class var0 = DeviceUtils.class;
      synchronized (DeviceUtils.class) {
        if (VERSION == null || VERSION.isEmpty()) {
          VERSION = android.os.Build.VERSION.RELEASE;
          CallUILog.i("Devices", "get VERSION by Build.VERSION.RELEASE :" + VERSION);
        }
      }
    }

    return VERSION;
  }

  public static void setVersionInt(final int versionInt) {
    Class var1 = DeviceUtils.class;
    synchronized (DeviceUtils.class) {
      VERSION_INT = versionInt;
    }
  }

  public static int getVersionInt() {
    if (VERSION_INT == 0) {
      Class var0 = DeviceUtils.class;
      synchronized (DeviceUtils.class) {
        if (VERSION_INT == 0) {
          VERSION_INT = android.os.Build.VERSION.SDK_INT;
          CallUILog.i("Devices", "get VERSION_INT by Build.VERSION.SDK_INT :" + VERSION_INT);
        }
      }
    }

    return VERSION_INT;
  }

  public static void setVersionIncremental(final String versionIncremental) {
    Class var1 = DeviceUtils.class;
    synchronized (DeviceUtils.class) {
      VERSION_INCREMENTAL = versionIncremental;
    }
  }

  public static String getVersionIncremental() {
    if (VERSION_INCREMENTAL == null || VERSION_INCREMENTAL.isEmpty()) {
      Class var0 = DeviceUtils.class;
      synchronized (DeviceUtils.class) {
        if (VERSION_INCREMENTAL == null || VERSION_INCREMENTAL.isEmpty()) {
          VERSION_INCREMENTAL = android.os.Build.VERSION.INCREMENTAL;
          CallUILog.i(
              "Devices",
              "get VERSION_INCREMENTAL by Build.VERSION.INCREMENTAL :" + VERSION_INCREMENTAL);
        }
      }
    }

    return VERSION_INCREMENTAL;
  }

  public static void setBoard(final String board) {
    Class var1 = DeviceUtils.class;
    synchronized (DeviceUtils.class) {
      BOARD = board;
    }
  }

  public static String getBoard() {
    if (BOARD == null || BOARD.isEmpty()) {
      Class var0 = DeviceUtils.class;
      synchronized (DeviceUtils.class) {
        if (BOARD == null || BOARD.isEmpty()) {
          BOARD = Build.BOARD;
          CallUILog.i("Devices", "get BOARD by Build.BOARD :" + BOARD);
        }
      }
    }

    return BOARD;
  }

  public static boolean isBrandXiaoMi() {
    return "xiaomi".equalsIgnoreCase(getBrand()) || "xiaomi".equalsIgnoreCase(getManufacturer());
  }

  public static boolean isBrandHuawei() {
    return "huawei".equalsIgnoreCase(getBrand())
        || "huawei".equalsIgnoreCase(getManufacturer())
        || "honor".equalsIgnoreCase(getBrand());
  }

  public static boolean isBrandMeizu() {
    return "meizu".equalsIgnoreCase(getBrand())
        || "meizu".equalsIgnoreCase(getManufacturer())
        || "22c4185e".equalsIgnoreCase(getBrand());
  }

  public static boolean isBrandOppo() {
    return "oppo".equalsIgnoreCase(getBrand())
        || "realme".equalsIgnoreCase(getBrand())
        || "oneplus".equalsIgnoreCase(getBrand())
        || "oppo".equalsIgnoreCase(getManufacturer())
        || "realme".equalsIgnoreCase(getManufacturer())
        || "oneplus".equalsIgnoreCase(getManufacturer());
  }

  public static boolean isBrandVivo() {
    return "vivo".equalsIgnoreCase(getBrand()) || "vivo".equalsIgnoreCase(getManufacturer());
  }

  public static boolean isBrandHonor() {
    return "honor".equalsIgnoreCase(getBrand()) && "honor".equalsIgnoreCase(getManufacturer());
  }

  public static boolean isHarmonyOS() {
    try {
      Class clz = Class.forName("com.huawei.system.BuildEx");
      Method method = clz.getMethod("getOsBrand");
      return "harmony".equals(method.invoke(clz));
    } catch (Exception var2) {
      CallUILog.e("Devices", "the phone not support the harmonyOS");
      return false;
    }
  }

  public static boolean isMiuiOptimization() {
    String miuiOptimization = "";

    try {
      Class systemProperties = Class.forName("android.os.systemProperties");
      Method get = systemProperties.getDeclaredMethod("get", String.class, String.class);
      miuiOptimization = (String) get.invoke(systemProperties, "persist.sys.miuiOptimization", "");
      return TextUtils.isEmpty(miuiOptimization) | "true".equals(miuiOptimization);
    } catch (Exception var3) {
      CallUILog.e("Devices", "the phone not support the miui optimization");
      return false;
    }
  }
}
