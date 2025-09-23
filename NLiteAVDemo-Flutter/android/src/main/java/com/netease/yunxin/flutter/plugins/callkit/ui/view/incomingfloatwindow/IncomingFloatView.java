// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.view.incomingfloatwindow;

import android.content.Context;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Build;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import com.bumptech.glide.Glide;
import com.netease.yunxin.flutter.plugins.callkit.ui.CallKitUIPlugin;
import com.netease.yunxin.flutter.plugins.callkit.ui.R;
import com.netease.yunxin.flutter.plugins.callkit.ui.event.EventManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.permission.PermissionRequester;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.CallState;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.User;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallUILog;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.Constants;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.FloatWindowsPermission;
import com.netease.yunxin.flutter.plugins.callkit.ui.view.WindowManager;
import com.netease.yunxin.kit.call.p2p.NECallEngine;
import com.netease.yunxin.kit.call.p2p.model.NECallType;
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam;
import com.netease.yunxin.kit.common.utils.ScreenUtils;

public class IncomingFloatView {
  private static final String TAG = "IncomingFloatView";
  private android.view.WindowManager mWindowManager;
  private android.view.WindowManager.LayoutParams mWindowLayoutParams;

  private View layoutView;
  private ImageView imageFloatAvatar;
  private TextView textFloatTitle;
  private TextView textFloatDescription;
  private ImageView imageReject;
  private ImageView imageAccept;

  private User user;
  private int mediaType;

  private Context context;

  private int padding = 20;

  public IncomingFloatView(Context context) {
    this.context = context;
  }

  public void showIncomingView(User caller, int mediaType) {
    CallUILog.i(CallKitUIPlugin.TAG, "IncomingFloatView  showIncomingView | UserId:" + caller.id);

    this.user = caller;
    this.mediaType = mediaType;
    initWindow();
  }

  private void initWindow() {
    CallUILog.i(CallKitUIPlugin.TAG, "IncomingFloatView  initWindow");

    layoutView = LayoutInflater.from(context).inflate(R.layout.callkit_incoming_float_view, null);
    imageFloatAvatar = layoutView.findViewById(R.id.img_float_avatar);
    textFloatTitle = layoutView.findViewById(R.id.tv_float_title);
    textFloatDescription = layoutView.findViewById(R.id.tv_float_desc);
    imageReject = layoutView.findViewById(R.id.btn_float_decline);
    imageAccept = layoutView.findViewById(R.id.btn_float_accept);

    Uri avatarUri = Uri.parse(user.avatar);
    if (avatarUri == null) {
      if (imageFloatAvatar != null && R.drawable.callkit_ic_avatar != 0) {
        imageFloatAvatar.setImageResource(R.drawable.callkit_ic_avatar);
      }
    } else {
      Glide.with(context)
          .load(avatarUri)
          .error(R.drawable.callkit_ic_avatar)
          .into(imageFloatAvatar);
    }

    textFloatTitle.setText(user.getUserDisplayName());
    if (mediaType == NECallType.VIDEO) {
      String str = (String) CallState.getInstance().mResourceMap.get("k_0000002_1");
      textFloatDescription.setText(str);

      imageAccept.setImageResource(R.drawable.callkit_ic_dialing_video);
    } else {
      String str = (String) CallState.getInstance().mResourceMap.get("k_0000002");
      textFloatDescription.setText(str);

      imageAccept.setImageResource(R.drawable.callkit_ic_dialing);
    }
    imageReject.setOnClickListener(
        new View.OnClickListener() {
          @Override
          public void onClick(View v) {
            cancelIncomingView();
            NECallEngine.sharedInstance().hangup(new NEHangupParam(), null);
          }
        });

    layoutView.setOnClickListener(
        new View.OnClickListener() {
          @Override
          public void onClick(View v) {
            cancelIncomingView();
            if (FloatWindowsPermission.hasPermission(FloatWindowsPermission.BG_START_PERMISSION)) {
              WindowManager.launchMainActivity(context);
            }
            EventManager.getInstance()
                .notifyEvent(
                    Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
          }
        });

    imageAccept.setOnClickListener(
        new View.OnClickListener() {
          @Override
          public void onClick(View v) {
            cancelIncomingView();
            if (mediaType == NECallType.VIDEO
                && PermissionRequester.isGranted(FloatWindowsPermission.CAMERA_PERMISSION)
                && PermissionRequester.isGranted(FloatWindowsPermission.RECORD_AUDIO_PERMISSION)) {
              NECallEngine.sharedInstance().accept(null);
            } else if (mediaType == NECallType.AUDIO
                && PermissionRequester.isGranted(FloatWindowsPermission.RECORD_AUDIO_PERMISSION)) {
              NECallEngine.sharedInstance().accept(null);
            }

            if (FloatWindowsPermission.hasPermission(FloatWindowsPermission.BG_START_PERMISSION)) {
              WindowManager.launchMainActivity(context);
            }
            EventManager.getInstance()
                .notifyEvent(
                    Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
          }
        });

    mWindowManager = (android.view.WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
    mWindowManager.addView(layoutView, getViewParams());
  }

  private android.view.WindowManager.LayoutParams getViewParams() {
    mWindowLayoutParams = new android.view.WindowManager.LayoutParams();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      mWindowLayoutParams.type = android.view.WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
    } else {
      mWindowLayoutParams.type = android.view.WindowManager.LayoutParams.TYPE_PHONE;
    }
    mWindowLayoutParams.flags =
        android.view.WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
            | android.view.WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
            | android.view.WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS;

    mWindowLayoutParams.gravity = Gravity.START | Gravity.TOP;
    mWindowLayoutParams.x = padding;
    mWindowLayoutParams.y = 0;

    mWindowLayoutParams.width = ScreenUtils.getDisplayWidth() - padding * 2;
    mWindowLayoutParams.height = android.view.WindowManager.LayoutParams.WRAP_CONTENT;
    mWindowLayoutParams.format = PixelFormat.TRANSPARENT;

    return mWindowLayoutParams;
  }

  public void cancelIncomingView() {
    CallUILog.i(CallKitUIPlugin.TAG, "IncomingFloatView  cancelIncomingView");

    if (layoutView != null && layoutView.isAttachedToWindow() && mWindowManager != null) {
      mWindowManager.removeView(layoutView);
    }
    layoutView = null;
  }
}
