// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.permission;

import android.annotation.SuppressLint;
import android.app.AppOpsManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Binder;
import android.os.Build.VERSION;
import android.os.Parcel;
import android.os.Parcelable;
import android.os.Process;
import android.provider.Settings;
import android.text.TextUtils;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.annotation.Size;
import androidx.core.content.ContextCompat;
import com.netease.yunxin.flutter.plugins.callkit.ui.R;
import com.netease.yunxin.flutter.plugins.callkit.ui.event.EventManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallUILog;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.DeviceUtils;
import com.netease.yunxin.kit.corekit.XKit;
import java.lang.String;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

public class PermissionRequester {
  private static final String TAG = "PermissionRequester";
  public static final String PERMISSION_NOTIFY_EVENT_KEY = "PERMISSION_NOTIFY_EVENT_KEY";
  public static final String PERMISSION_NOTIFY_EVENT_SUB_KEY = "PERMISSION_NOTIFY_EVENT_SUB_KEY";
  public static final String PERMISSION_RESULT = "PERMISSION_RESULT";
  public static final String PERMISSION_REQUEST_KEY = "PERMISSION_REQUEST_KEY";
  private static final Object sLock = new Object();
  private static AtomicBoolean sIsRequesting = new AtomicBoolean(false);
  private PermissionCallback mPermissionCallback;
  private String[] mPermissions;
  private String mTitle;
  private String mDescription;
  private String mSettingsTip;
  private EventManager.INotifyEvent mPermissionNotification;
  public static final String FLOAT_PERMISSION = "PermissionOverlayWindows";
  public static final String BG_START_PERMISSION = "PermissionStartActivityFromBackground";
  private List<String> mDirectPermissionList = new ArrayList();
  private List<String> mIndirectPermissionList = new ArrayList();

  private PermissionRequester(String... permissions) {
    this.mPermissions = permissions;
    String[] var2 = this.mPermissions;
    int var3 = var2.length;

    for (int var4 = 0; var4 < var3; ++var4) {
      String permission = var2[var4];
      if (!"PermissionOverlayWindows".equals(permission)
          && !"PermissionStartActivityFromBackground".equals(permission)) {
        this.mDirectPermissionList.add(permission);
      } else {
        this.mIndirectPermissionList.add(permission);
      }
    }

    this.mPermissionNotification =
        (key, subKey, param) -> {
          if (param != null) {
            Object result = param.get("PERMISSION_RESULT");
            if (result != null) {
              this.notifyPermissionRequestResult((Result) result);
            }
          }
        };
  }

  public static PermissionRequester newInstance(@NonNull @Size(min = 1L) String... permissions) {
    return new PermissionRequester(permissions);
  }

  public PermissionRequester title(@NonNull String title) {
    this.mTitle = title;
    return this;
  }

  public PermissionRequester description(@NonNull String description) {
    this.mDescription = description;
    return this;
  }

  public PermissionRequester settingsTip(@NonNull String settingsTip) {
    this.mSettingsTip = settingsTip;
    return this;
  }

  public PermissionRequester callback(@NonNull PermissionCallback callback) {
    this.mPermissionCallback = callback;
    return this;
  }

  @SuppressLint({"NewApi"})
  public void request() {
    CallUILog.i(
        "PermissionRequester",
        "request, directPermissionList: "
            + this.mDirectPermissionList
            + " ,indirectPermissionList:  "
            + this.mIndirectPermissionList);
    if (this.mDirectPermissionList != null && this.mDirectPermissionList.size() > 0) {
      this.requestDirectPermission((String[]) this.mDirectPermissionList.toArray(new String[0]));
    }

    if (this.mIndirectPermissionList != null && this.mIndirectPermissionList.size() > 0) {
      this.startAppDetailsSettingsByBrand();
    }
  }

  @SuppressLint({"NewApi"})
  private void requestDirectPermission(String[] permissions) {
    synchronized (sLock) {
      if (sIsRequesting.get()) {
        CallUILog.e("PermissionRequester", "can not request during requesting");
        if (this.mPermissionCallback != null) {
          this.mPermissionCallback.onDenied();
        }

        return;
      }

      sIsRequesting.set(true);
    }

    EventManager.getInstance()
        .registerEvent(
            "PERMISSION_NOTIFY_EVENT_KEY",
            "PERMISSION_NOTIFY_EVENT_SUB_KEY",
            this.mPermissionNotification);
    if (android.os.Build.VERSION.SDK_INT < 23) {
      CallUILog.i("PermissionRequester", "current version is lower than 23");
      this.notifyPermissionRequestResult(PermissionRequester.Result.Granted);
    } else {
      String[] unauthorizedPermissions = this.findUnauthorizedPermissions(permissions);
      if (unauthorizedPermissions.length <= 0) {
        this.notifyPermissionRequestResult(PermissionRequester.Result.Granted);
      } else {
        RequestData realRequest =
            new RequestData(
                this.mTitle, this.mDescription, this.mSettingsTip, unauthorizedPermissions);
        this.startPermissionActivity(realRequest);
      }
    }
  }

  public boolean has() {
    if (!this.mIndirectPermissionList.contains("PermissionStartActivityFromBackground")) {
      if (this.mIndirectPermissionList.contains("PermissionOverlayWindows")) {
        return this.hasFloatPermission();
      } else {
        Iterator var1 = this.mDirectPermissionList.iterator();

        String permission;
        do {
          if (!var1.hasNext()) {
            return true;
          }

          permission = (String) var1.next();
        } while (this.has(permission));

        return false;
      }
    } else {
      return this.hasFloatPermission() && this.hasBgStartPermission();
    }
  }

  private boolean has(final String permission) {
    return android.os.Build.VERSION.SDK_INT < 23
        || 0
            == ContextCompat.checkSelfPermission(
                XKit.Companion.instance().getApplicationContext(), permission);
  }

  private void notifyPermissionRequestResult(Result result) {
    EventManager.getInstance()
        .unRegisterEvent(
            "PERMISSION_NOTIFY_EVENT_KEY",
            "PERMISSION_NOTIFY_EVENT_SUB_KEY",
            this.mPermissionNotification);
    sIsRequesting.set(false);
    if (this.mPermissionCallback != null) {
      if (PermissionRequester.Result.Granted.equals(result)) {
        this.mPermissionCallback.onGranted();
      } else if (PermissionRequester.Result.Requesting.equals(result)) {
        this.mPermissionCallback.onRequesting();
      } else {
        this.mPermissionCallback.onDenied();
      }

      this.mPermissionCallback = null;
    }
  }

  private String[] findUnauthorizedPermissions(String[] permissions) {
    Context appContext = XKit.Companion.instance().getApplicationContext();
    if (appContext == null) {
      CallUILog.e("PermissionRequester", "findUnauthorizedPermissions appContext is null");
      return permissions;
    } else {
      List<String> unauthorizedList = new LinkedList();
      String[] var4 = permissions;
      int var5 = permissions.length;

      for (int var6 = 0; var6 < var5; ++var6) {
        String permission = var4[var6];
        if (0 != ContextCompat.checkSelfPermission(appContext, permission)) {
          unauthorizedList.add(permission);
        }
      }

      return (String[]) unauthorizedList.toArray(new String[0]);
    }
  }

  @RequiresApi(api = 23)
  private void startPermissionActivity(RequestData request) {
    Context context = XKit.Companion.instance().getApplicationContext();
    if (context != null) {
      Intent intent = new Intent(context, PermissionActivity.class);
      intent.putExtra("PERMISSION_REQUEST_KEY", request);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
    }
  }

  private void startAppDetailsSettingsByBrand() {
    if (DeviceUtils.isBrandVivo()) {
      this.startVivoPermissionSettings(XKit.Companion.instance().getApplicationContext());
    } else if (DeviceUtils.isBrandHuawei()) {
      this.startHuaweiPermissionSettings(XKit.Companion.instance().getApplicationContext());
    } else if (DeviceUtils.isBrandXiaoMi()) {
      this.startXiaomiPermissionSettings(XKit.Companion.instance().getApplicationContext());
    } else {
      this.startCommonSettings(XKit.Companion.instance().getApplicationContext());
    }
  }

  private void startCommonSettings(Context context) {
    try {
      if (VERSION.SDK_INT >= 23) {
        Intent intent = new Intent("android.settings.action.MANAGE_OVERLAY_PERMISSION");
        intent.setData(Uri.parse("package:" + context.getPackageName()));
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
      }
    } catch (Exception var3) {
      Exception e = var3;
      e.printStackTrace();
    }
  }

  private void startVivoPermissionSettings(Context context) {
    try {
      Intent intent = new Intent();
      intent.setClassName(
          "com.vivo.permissionmanager",
          "com.vivo.permissionmanager.activity.SoftPermissionDetailActivity");
      intent.setAction("secure.intent.action.softPermissionDetail");
      intent.putExtra("packagename", context.getPackageName());
      intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
      Toast.makeText(context, R.string.ui_float_permission_hint, Toast.LENGTH_SHORT).show();
    } catch (Exception var3) {
      CallUILog.w("PermissionRequester", "startVivoPermissionSettings: open common settings");
      this.startCommonSettings(context);
    }
  }

  private void startHuaweiPermissionSettings(Context context) {
    if (!DeviceUtils.isHarmonyOS()) {
      CallUILog.i("PermissionRequester", "The device is not Harmony or cannot get system operator");
      this.startCommonSettings(context);
    } else {
      try {
        Intent intent = new Intent();
        intent.putExtra("packageName", context.getPackageName());
        ComponentName comp =
            new ComponentName(
                "com.huawei.systemmanager", "com.huawei.permissionmanager.ui.MainActivity");
        intent.setComponent(comp);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
        Toast.makeText(context, R.string.ui_float_permission_hint_harmony, Toast.LENGTH_SHORT)
            .show();
      } catch (Exception var4) {
        CallUILog.w("PermissionRequester", "startHuaweiPermissionSettings: open common settings");
        this.startCommonSettings(context);
      }
    }
  }

  private void startXiaomiPermissionSettings(Context context) {
    if (!DeviceUtils.isMiuiOptimization()) {
      CallUILog.i(
          "PermissionRequester",
          "The device do not open miuiOptimization or cannot get miui property");
      this.startCommonSettings(context);
    } else {
      try {
        Intent intent = new Intent("miui.intent.action.APP_PERM_EDITOR");
        intent.setClassName(
            "com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity");
        intent.putExtra("extra_pkgname", context.getPackageName());
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
        Toast.makeText(context, R.string.ui_float_permission_hint, Toast.LENGTH_SHORT).show();
      } catch (Exception var3) {
        CallUILog.w("PermissionRequester", "startXiaomiPermissionSettings: open common settings");
        this.startCommonSettings(context);
      }
    }
  }

  private boolean hasBgStartPermission() {
    if (DeviceUtils.isBrandHuawei() && DeviceUtils.isHarmonyOS()) {
      return this.isHarmonyBgStartPermissionAllowed(
          XKit.Companion.instance().getApplicationContext());
    } else if (DeviceUtils.isBrandVivo()) {
      return this.isVivoBgStartPermissionAllowed(XKit.Companion.instance().getApplicationContext());
    } else {
      return DeviceUtils.isBrandXiaoMi() && DeviceUtils.isMiuiOptimization()
          ? this.isXiaomiBgStartPermissionAllowed(XKit.Companion.instance().getApplicationContext())
          : this.hasFloatPermission();
    }
  }

  private boolean hasFloatPermission() {
    try {
      Context context = XKit.Companion.instance().getApplicationContext();
      if (VERSION.SDK_INT >= 23) {
        return Settings.canDrawOverlays(context);
      }

      if (VERSION.SDK_INT >= 19) {
        AppOpsManager manager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
        if (manager == null) {
          return false;
        }

        Method method =
            AppOpsManager.class.getMethod("checkOp", Integer.TYPE, Integer.TYPE, String.class);
        int result =
            (Integer) method.invoke(manager, 24, Binder.getCallingUid(), context.getPackageName());
        CallUILog.i("PermissionRequester", "hasFloatPermission, result: " + (0 == result));
        return 0 == result;
      }
    } catch (Exception var5) {
      Exception e = var5;
      e.printStackTrace();
    }

    return false;
  }

  private boolean isHarmonyBgStartPermissionAllowed(Context context) {
    try {
      if (VERSION.SDK_INT >= 19) {
        AppOpsManager manager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
        if (manager == null) {
          return false;
        }

        Class<?> clz = Class.forName("com.huawei.android.app.AppOpsManagerEx");
        Method method =
            clz.getDeclaredMethod(
                "checkHwOpNoThrow", AppOpsManager.class, Integer.TYPE, Integer.TYPE, String.class);
        int result =
            (Integer)
                method.invoke(
                    clz.newInstance(), manager, 100000, Process.myUid(), context.getPackageName());
        CallUILog.i(
            "PermissionRequester", "isHarmonyBgStartPermissionAllowed, result: " + (result == 0));
        return result == 0;
      }
    } catch (Exception var6) {
      Exception e = var6;
      e.printStackTrace();
    }

    return false;
  }

  private boolean isVivoBgStartPermissionAllowed(Context context) {
    try {
      Uri uri =
          Uri.parse("content://com.vivo.permissionmanager.provider.permission/start_bg_activity");
      Cursor cursor =
          context
              .getContentResolver()
              .query(
                  uri,
                  (String[]) null,
                  "pkgname = ?",
                  new String[] {context.getPackageName()},
                  (String) null);
      if (cursor == null) {
        return false;
      }

      if (cursor.moveToFirst()) {
        int columnIndex = cursor.getColumnIndex("currentstate");
        if (columnIndex >= 0) {
          int result = cursor.getInt(columnIndex);
          cursor.close();
          CallUILog.i(
              "PermissionRequester", "isVivoBgStartPermissionAllowed, result: " + (0 == result));
          return 0 == result;
        } else {
          cursor.close();
          CallUILog.w(
              "PermissionRequester",
              "isVivoBgStartPermissionAllowed, column 'currentstate' not found");
          return false;
        }
      }

      cursor.close();
    } catch (Exception var5) {
      Exception e = var5;
      e.printStackTrace();
    }

    return false;
  }

  private boolean isXiaomiBgStartPermissionAllowed(Context context) {
    try {
      AppOpsManager appOpsManager = null;
      if (VERSION.SDK_INT >= 19) {
        appOpsManager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
      }

      if (appOpsManager == null) {
        return false;
      } else {
        int op = 10021;
        Method method =
            appOpsManager
                .getClass()
                .getMethod("checkOpNoThrow", Integer.TYPE, Integer.TYPE, String.class);
        method.setAccessible(true);
        int result =
            (Integer)
                method.invoke(
                    appOpsManager, Integer.valueOf(op), Process.myUid(), context.getPackageName());
        CallUILog.i(
            "PermissionRequester", "isXiaomiBgStartPermissionAllowed, result: " + (0 == result));
        return 0 == result;
      }
    } catch (Exception var6) {
      Exception e = var6;
      e.printStackTrace();
      return false;
    }
  }

  public static boolean isGranted(final String... permissions) {
    String[] var1 = permissions;
    int var2 = permissions.length;

    for (int var3 = 0; var3 < var2; ++var3) {
      String permission = var1[var3];
      if (!isGranted(permission)) {
        return false;
      }
    }

    return true;
  }

  public static boolean isGranted(final String permission) {
    return android.os.Build.VERSION.SDK_INT < 23
        || 0
            == ContextCompat.checkSelfPermission(
                XKit.Companion.instance().getApplicationContext(), permission);
  }

  static class RequestData implements Parcelable {
    private final String[] mPermissions;
    private final String mTitle;
    private final String mDescription;
    private final String mSettingsTip;
    private int mPermissionIconId;
    public static final Parcelable.Creator<RequestData> CREATOR =
        new Parcelable.Creator<RequestData>() {
          public RequestData createFromParcel(Parcel in) {
            return new RequestData(in);
          }

          public RequestData[] newArray(int size) {
            return new RequestData[size];
          }
        };

    public RequestData(
        @NonNull String title,
        @NonNull String description,
        @NonNull String settingsTip,
        @NonNull String... perms) {
      this.mTitle = title;
      this.mDescription = description;
      this.mSettingsTip = settingsTip;
      this.mPermissions = perms.clone();
    }

    protected RequestData(Parcel in) {
      this.mPermissions = in.createStringArray();
      this.mTitle = in.readString();
      this.mDescription = in.readString();
      this.mSettingsTip = in.readString();
      this.mPermissionIconId = in.readInt();
    }

    public boolean isPermissionsExistEmpty() {
      if (this.mPermissions != null && this.mPermissions.length > 0) {
        String[] var1 = this.mPermissions;
        int var2 = var1.length;

        for (int var3 = 0; var3 < var2; ++var3) {
          String permission = var1[var3];
          if (TextUtils.isEmpty(permission)) {
            return true;
          }
        }

        return false;
      } else {
        return true;
      }
    }

    public String[] getPermissions() {
      return (String[]) this.mPermissions.clone();
    }

    public String getTitle() {
      return this.mTitle;
    }

    public String getDescription() {
      return this.mDescription;
    }

    public String getSettingsTip() {
      return this.mSettingsTip;
    }

    public int getPermissionIconId() {
      return this.mPermissionIconId;
    }

    public void setPermissionIconId(int permissionIconId) {
      this.mPermissionIconId = permissionIconId;
    }

    public String toString() {
      return "PermissionRequest{mPermissions="
          + Arrays.toString(this.mPermissions)
          + ", mTitle="
          + this.mTitle
          + ", mDescription='"
          + this.mDescription
          + ", mSettingsTip='"
          + this.mSettingsTip
          + '}';
    }

    public int describeContents() {
      return 0;
    }

    public void writeToParcel(Parcel dest, int flags) {
      dest.writeStringArray(this.mPermissions);
      dest.writeString(this.mTitle);
      dest.writeString(this.mDescription);
      dest.writeString(this.mSettingsTip);
      dest.writeInt(this.mPermissionIconId);
    }
  }

  public static enum Result {
    Granted,
    Denied,
    Requesting;

    private Result() {}
  }
}
