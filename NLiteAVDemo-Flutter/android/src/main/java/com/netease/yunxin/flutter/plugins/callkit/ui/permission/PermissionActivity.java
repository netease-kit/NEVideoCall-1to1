// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.permission;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import com.netease.yunxin.flutter.plugins.callkit.ui.R;
import com.netease.yunxin.flutter.plugins.callkit.ui.event.EventManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallUILog;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.DeviceUtils;
import java.util.HashMap;
import java.util.Map;

@RequiresApi(api = 23)
public class PermissionActivity extends Activity {
  private static final String TAG = "PermissionActivity";
  private static final int PERMISSION_REQUEST_CODE = 100;
  private TextView mRationaleTitleTv;
  private TextView mRationaleDescriptionTv;
  private ImageView mPermissionIconIv;
  private PermissionRequester.RequestData mRequestData;
  private PermissionRequester.Result mResult;

  public PermissionActivity() {
    this.mResult = PermissionRequester.Result.Denied;
  }

  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    this.mRequestData = this.getPermissionRequest();
    if (this.mRequestData != null && !this.mRequestData.isPermissionsExistEmpty()) {
      CallUILog.i("PermissionActivity", "onCreate : " + this.mRequestData.toString());
      if (DeviceUtils.getVersionInt() < 23) {
        this.finishWithResult(PermissionRequester.Result.Granted);
      } else {
        this.makeBackGroundTransparent();
        this.initView();
        this.showPermissionRationale();
        this.requestPermissions(this.mRequestData.getPermissions(), 100);
      }
    } else {
      CallUILog.e("PermissionActivity", "onCreate mRequestData exist empty permission");
      this.finishWithResult(PermissionRequester.Result.Denied);
    }
  }

  public void onRequestPermissionsResult(
      int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    this.hidePermissionRationale();
    if (this.isAllPermissionsGranted(grantResults)) {
      this.finishWithResult(PermissionRequester.Result.Granted);
    } else {
      this.showSettingsTip();
    }
  }

  private void showSettingsTip() {
    if (this.mRequestData != null) {
      View tipLayout =
          LayoutInflater.from(this)
              .inflate(R.layout.callkit_ui_permission_tip_layout, (ViewGroup) null);
      TextView tipsTv = (TextView) tipLayout.findViewById(R.id.tips);
      TextView positiveBtn = (TextView) tipLayout.findViewById(R.id.positive_btn);
      TextView negativeBtn = (TextView) tipLayout.findViewById(R.id.negative_btn);
      tipsTv.setText(this.mRequestData.getSettingsTip());
      Dialog permissionTipDialog =
          (new AlertDialog.Builder(this)).setView(tipLayout).setCancelable(false).create();
      positiveBtn.setOnClickListener(
          (v) -> {
            permissionTipDialog.dismiss();
            this.launchAppDetailsSettings();
            this.finishWithResult(PermissionRequester.Result.Requesting);
          });
      negativeBtn.setOnClickListener(
          (v) -> {
            permissionTipDialog.dismiss();
            this.finishWithResult(PermissionRequester.Result.Denied);
          });
      ((Dialog) permissionTipDialog)
          .setOnKeyListener(
              (dialog, keyCode, event) -> {
                if (keyCode == 4 && event.getAction() == 1) {
                  permissionTipDialog.dismiss();
                }

                return true;
              });
      Window dialogWindow = ((Dialog) permissionTipDialog).getWindow();
      dialogWindow.setBackgroundDrawable(new ColorDrawable());
      WindowManager.LayoutParams layoutParams = dialogWindow.getAttributes();
      layoutParams.width = -2;
      layoutParams.height = -2;
      dialogWindow.setAttributes(layoutParams);
      ((Dialog) permissionTipDialog).show();
    }
  }

  private void launchAppDetailsSettings() {
    Intent intent = new Intent("android.settings.APPLICATION_DETAILS_SETTINGS");
    intent.setData(Uri.parse("package:" + this.getPackageName()));
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    if (this.getPackageManager()
            .queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
            .size()
        <= 0) {
      CallUILog.e("PermissionActivity", "launchAppDetailsSettings can not find system settings");
    } else {
      this.startActivity(intent);
    }
  }

  private void finishWithResult(PermissionRequester.Result result) {
    CallUILog.i("PermissionActivity", "finishWithResult : " + result);
    this.mResult = result;
    this.finish();
  }

  protected void onDestroy() {
    super.onDestroy();
    Map<String, Object> result = new HashMap(1);
    result.put("PERMISSION_RESULT", this.mResult);
    EventManager.getInstance()
        .notifyEvent("PERMISSION_NOTIFY_EVENT_KEY", "PERMISSION_NOTIFY_EVENT_SUB_KEY", result);
  }

  private PermissionRequester.RequestData getPermissionRequest() {
    Intent intent = this.getIntent();
    return intent == null
        ? null
        : (PermissionRequester.RequestData) intent.getParcelableExtra("PERMISSION_REQUEST_KEY");
  }

  @SuppressLint({"NewApi"})
  private void makeBackGroundTransparent() {
    if (DeviceUtils.getVersionInt() >= 21) {
      View decorView = this.getWindow().getDecorView();
      decorView.setSystemUiVisibility(
          View.SYSTEM_UI_FLAG_LAYOUT_STABLE
              | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
              | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
              | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
              | View.SYSTEM_UI_FLAG_FULLSCREEN
              | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
      this.getWindow().setStatusBarColor(0);
      this.getWindow().setNavigationBarColor(0);
    }

    ActionBar actionBar = this.getActionBar();
    if (actionBar != null) {
      actionBar.hide();
    }
  }

  private void initView() {
    this.setContentView(R.layout.callkit_ui_permission_activity_layout);
    this.mRationaleTitleTv = (TextView) this.findViewById(R.id.permission_reason_title);
    this.mRationaleDescriptionTv = (TextView) this.findViewById(R.id.permission_reason);
    this.mPermissionIconIv = (ImageView) this.findViewById(R.id.permission_icon);
  }

  private void showPermissionRationale() {
    if (this.mRequestData != null) {
      this.mRationaleTitleTv.setText(this.mRequestData.getTitle());
      this.mRationaleDescriptionTv.setText(this.mRequestData.getDescription());
      this.mPermissionIconIv.setBackgroundResource(this.mRequestData.getPermissionIconId());
      this.mRationaleTitleTv.setVisibility(View.VISIBLE);
      this.mRationaleDescriptionTv.setVisibility(View.VISIBLE);
      this.mPermissionIconIv.setVisibility(View.VISIBLE);
    }
  }

  private void hidePermissionRationale() {
    this.mRationaleTitleTv.setVisibility(View.GONE);
    this.mRationaleDescriptionTv.setVisibility(View.GONE);
    this.mPermissionIconIv.setVisibility(View.GONE);
  }

  private boolean isAllPermissionsGranted(@NonNull int[] grantResults) {
    int[] var2 = grantResults;
    int var3 = grantResults.length;

    for (int var4 = 0; var4 < var3; ++var4) {
      int result = var2[var4];
      if (result != 0) {
        return false;
      }
    }

    return true;
  }

  public boolean onTouchEvent(MotionEvent event) {
    return true;
  }
}
