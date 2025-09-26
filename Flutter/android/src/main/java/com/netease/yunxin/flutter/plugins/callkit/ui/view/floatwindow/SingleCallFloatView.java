// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.view.floatwindow;

import static com.netease.yunxin.flutter.plugins.callkit.ui.utils.Constants.KEY_NESTATE_CHANGE;
import static com.netease.yunxin.flutter.plugins.callkit.ui.utils.Constants.SUBKEY_REFRESH_VIEW;

import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import com.bumptech.glide.Glide;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.video.NERtcTextureView;
import com.netease.yunxin.flutter.plugins.callkit.ui.R;
import com.netease.yunxin.flutter.plugins.callkit.ui.event.EventManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.CallState;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.User;
import com.netease.yunxin.kit.call.p2p.NECallEngine;
import com.netease.yunxin.kit.call.p2p.model.NECallType;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import java.util.Map;

public class SingleCallFloatView extends CallFloatView implements EventManager.INotifyEvent {
  private final Context mContext;

  private RelativeLayout mRelativeLayout;
  private NERtcTextureView mVideoView;
  private ImageView mImageAvatar;
  private ImageView mImageAudio;
  private boolean mIsCameraOpen = false;
  private Boolean mHadAccepted = false;

  public SingleCallFloatView(Context context) {
    super(context);
    mContext = context;
    initView(context);
    updateView();
    registerObserver();
  }

  private void initView(Context context) {
    LayoutInflater.from(context).inflate(R.layout.callkit_floatwindow_singlecall_layout, this);
    mRelativeLayout = findViewById(R.id.ll_root);
    mVideoView = findViewById(R.id.video_view);
    mVideoView.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_BALANCED);
    mImageAvatar = findViewById(R.id.iv_avatar);
    mImageAudio = findViewById(R.id.iv_audio_icon);
    mTextStatus = findViewById(R.id.tv_call_status);
  }

  private void registerObserver() {
    EventManager.getInstance().registerEvent(KEY_NESTATE_CHANGE, SUBKEY_REFRESH_VIEW, this);
  }

  private void unRegisterObserver() {
    EventManager.getInstance().unRegisterEvent(this);
  }

  @Override
  public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
    if (KEY_NESTATE_CHANGE.equals(key) && subKey.equals(SUBKEY_REFRESH_VIEW)) {
      updateView();
    }
  }

  @Override
  public void destory() {
    super.destory();
    unRegisterObserver();
  }

  private void updateView() {
    if (CallState.getInstance().mMediaType == NECallType.AUDIO) {
      mImageAudio.setVisibility(VISIBLE);
      mTextStatus.setVisibility(VISIBLE);
      mVideoView.setVisibility(GONE);
      mImageAvatar.setVisibility(GONE);

      RelativeLayout.LayoutParams textParams =
          new RelativeLayout.LayoutParams(
              RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
      textParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
      int topMargin =
          (int)
              TypedValue.applyDimension(
                  TypedValue.COMPLEX_UNIT_DIP, 48, getResources().getDisplayMetrics());
      textParams.topMargin = topMargin;
      mTextStatus.setLayoutParams(textParams);
      mTextStatus.setTextColor(Color.argb(255, 41, 204, 133));

      FrameLayout.LayoutParams layoutParams =
          (FrameLayout.LayoutParams) mRelativeLayout.getLayoutParams();
      layoutParams.width = SizeUtils.dp2px(72);
      layoutParams.height = SizeUtils.dp2px(72);
      mRelativeLayout.setLayoutParams(layoutParams);
      mRelativeLayout.setBackgroundColor(Color.argb(255, 255, 255, 255));
      if (CallState.getInstance().mSelfUser.callStatus == CallState.CallStatus.Accept) {
        if (!mHadAccepted) {
          startTiming();
        }
        mHadAccepted = true;
      } else {
        destory();
      }
      return;
    }

    if (CallState.getInstance().mMediaType == NECallType.VIDEO) {
      mImageAudio.setVisibility(GONE);

      FrameLayout.LayoutParams layoutParams =
          (FrameLayout.LayoutParams) mRelativeLayout.getLayoutParams();
      layoutParams.width = SizeUtils.dp2px(110);
      layoutParams.height = SizeUtils.dp2px(196);
      mRelativeLayout.setLayoutParams(layoutParams);
      mRelativeLayout.setBackgroundColor(Color.argb(255, 60, 60, 60));

      RelativeLayout.LayoutParams textParams =
          new RelativeLayout.LayoutParams(
              RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
      textParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
      int topMargin =
          (int)
              TypedValue.applyDimension(
                  TypedValue.COMPLEX_UNIT_DIP, 140, getResources().getDisplayMetrics());
      textParams.topMargin = topMargin;
      mTextStatus.setLayoutParams(textParams);
      mTextStatus.setTextColor(Color.argb(255, 214, 214, 214));

      if (CallState.getInstance().mSelfUser.callStatus == CallState.CallStatus.Accept) {
        mTextStatus.setVisibility(GONE);
        if (CallState.getInstance().mRemoteUserList.isEmpty()) {
          destory();
          return;
        }
        User remoteUser = CallState.getInstance().mRemoteUserList.get(0);

        if (remoteUser.videoAvailable) {
          if (mVideoView.getVisibility() == VISIBLE) {
            return;
          }
          mVideoView.setVisibility(VISIBLE);
          mImageAvatar.setVisibility(GONE);
          NECallEngine.sharedInstance().setupRemoteView(mVideoView);
        } else {
          mVideoView.setVisibility(GONE);
          mImageAvatar.setVisibility(VISIBLE);
          if (TextUtils.isEmpty(remoteUser.avatar)) {
            mImageAvatar.setImageResource(R.drawable.callkit_ic_avatar);
          } else {
            Glide.with(mContext)
                .load(remoteUser.avatar)
                .error(R.drawable.callkit_ic_avatar)
                .into(mImageAvatar);
          }
        }
        return;
      }
    }
    destory();
  }
}
