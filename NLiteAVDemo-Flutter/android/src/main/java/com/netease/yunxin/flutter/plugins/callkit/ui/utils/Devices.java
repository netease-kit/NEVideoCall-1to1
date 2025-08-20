package com.netease.yunxin.flutter.plugins.callkit.ui.utils;

import android.app.KeyguardManager;
import android.content.Context;
import android.os.Build;

public class Devices {
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
}
