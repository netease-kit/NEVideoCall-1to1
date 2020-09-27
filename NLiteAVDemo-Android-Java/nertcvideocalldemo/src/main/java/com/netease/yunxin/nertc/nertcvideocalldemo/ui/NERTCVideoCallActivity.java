package com.netease.yunxin.nertc.nertcvideocalldemo.ui;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.netease.lava.nertc.sdk.NERtc;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.video.NERtcVideoConfig;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.avsignalling.builder.InviteParamBuilder;
import com.netease.nimlib.sdk.avsignalling.constant.ChannelType;
import com.netease.nimlib.sdk.avsignalling.event.InvitedEvent;
import com.netease.nimlib.sdk.uinfo.UserService;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;
import com.netease.yunxin.nertc.login.model.ProfileManager;
import com.netease.yunxin.nertc.login.model.UserModel;
import com.netease.yunxin.nertc.nertcvideocalldemo.R;
import com.netease.yunxin.nertc.nertcvideocalldemo.model.NERTCCallingDelegate;
import com.netease.yunxin.nertc.nertcvideocalldemo.model.NERTCVideoCall;

import java.util.ArrayList;
import java.util.List;

public class NERTCVideoCallActivity extends AppCompatActivity {

    public static final String INVENT_EVENT = "call_in_event";
    public static final String CALL_OUT_USER = "call_out_user";
    public static final String CALL_DIR = "call_dir";

    private NERTCVideoCall nertcVideoCall;

    private NERtcVideoView localVideoView;
    private NERtcVideoView remoteVideoView;
    private TextView tvRemoteVideoClose;
    private ImageView ivSwitch;
    private ImageView ivUserIcon;
    private TextView tvCallUser;
    private TextView tvCallComment;
    private ImageView ivMute;
    private ImageView ivVideo;
    private ImageView ivHungUp;
    private LinearLayout llyCancel;
    private LinearLayout llyBingCall;
    private LinearLayout llyDialogOperation;
    private ImageView ivAccept;
    private ImageView ivReject;
    private RelativeLayout rlyTopUserInfo;

    private UserModel callOutUser;//呼出用户
    private InvitedEvent invitedEvent;//来电事件
    private int callDir;//0 call out 1 call in

    private boolean isMute;//是否静音
    private boolean isCamOff;//是否关闭摄像头

    private static final int DELAY_TIME = 1000;//延时

    private NERTCCallingDelegate nertcCallingDelegate = new NERTCCallingDelegate() {
        @Override
        public void onError(int errorCode, String errorMsg) {
            ToastUtils.showLong(errorMsg + " errorCode:" + errorCode);
            finish();
        }

        @Override
        public void onInvitedByUser(InvitedEvent invitedEvent) {

        }


        @Override
        public void onUserEnter(long userId) {
            if (callDir == 0) {
                llyCancel.setVisibility(View.GONE);
                llyDialogOperation.setVisibility(View.VISIBLE);
                setupLocalVideo();
            }
        }

        @Override
        public void onUserHangup(long userId) {
            if (!isDestroyed() && !ProfileManager.getInstance().isCurrentUser(userId)) {
                ToastUtils.showLong("对方已经挂断");
                hungUpAndFinish();
                handler.postDelayed(() -> finish(), DELAY_TIME);
            }
        }

        @Override
        public void onRejectByUserId(String userId) {
            if (!isDestroyed() && callDir == 0) {
                ToastUtils.showLong("对方已经拒绝");
                hungUpAndFinish();
                handler.postDelayed(() -> {
                    finish();
                }, DELAY_TIME);
            }
        }


        @Override
        public void onUserBusy(String userId) {
            if (!isDestroyed() && callDir == 0) {
                ToastUtils.showLong("对方占线");
                hungUpAndFinish();
                handler.postDelayed(() -> {
                    finish();
                }, DELAY_TIME);
            }
        }

        @Override
        public void onCancelByUserId(String uid) {
            if (!isDestroyed() && callDir == 1) {
                ToastUtils.showLong("对方取消");
                hungUpAndFinish();
                handler.postDelayed(() -> {
                    finish();
                }, DELAY_TIME);
            }
        }


        @Override
        public void onCameraAvailable(long userId, boolean isVideoAvailable) {
            if (!ProfileManager.getInstance().isCurrentUser(userId)) {
                if (isVideoAvailable) {
                    rlyTopUserInfo.setVisibility(View.GONE);
                    remoteVideoView.setVisibility(View.VISIBLE);
                    tvRemoteVideoClose.setVisibility(View.GONE);
                    setupRemoteVideo(userId);
                } else {
                    remoteVideoView.setVisibility(View.GONE);
                    tvRemoteVideoClose.setVisibility(View.VISIBLE);
                }
            }

        }

        @Override
        public void onAudioAvailable(long userId, boolean isVideoAvailable) {

        }

        @Override
        public void timeOut() {
            ToastUtils.showLong("呼叫超时");
            hungUpAndFinish();
            finish();
        }
    };

    private Handler handler = new Handler();

    public static void startBeingCall(Context context, InvitedEvent invitedEvent) {
        Intent intent = new Intent(context, NERTCVideoCallActivity.class);
        intent.putExtra(INVENT_EVENT, invitedEvent);
        intent.putExtra(CALL_DIR, 1);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    public static void startCallOther(Context context, UserModel callOutUser) {
        Intent intent = new Intent(context, NERTCVideoCallActivity.class);
        intent.putExtra(CALL_OUT_USER, callOutUser);
        intent.putExtra(CALL_DIR, 0);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 应用运行时，保持不锁屏、全屏化
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.video_call_layout);
        initIntent();
        initView();
        initData();
    }


    private void initIntent() {
        invitedEvent = (InvitedEvent) getIntent().getSerializableExtra(INVENT_EVENT);
        callOutUser = (UserModel) getIntent().getSerializableExtra(CALL_OUT_USER);
        callDir = getIntent().getIntExtra(CALL_DIR, 0);
    }

    private void initData() {
        nertcVideoCall = NERTCVideoCall.sharedInstance(this);
        nertcVideoCall.setTimeOut(30 * 1000);
        nertcVideoCall.addDelegate(nertcCallingDelegate);
        ivSwitch.setOnClickListener(v -> {
            nertcVideoCall.switchCamera();
        });
        ivMute.setOnClickListener(view -> {
            isMute = !isMute;
            nertcVideoCall.setMicMute(isMute);
            if (isMute) {
                Glide.with(NERTCVideoCallActivity.this).load(R.drawable.voice_off).into(ivMute);
            } else {
                Glide.with(NERTCVideoCallActivity.this).load(R.drawable.voice_on).into(ivMute);
            }
        });

        ivHungUp.setOnClickListener(view -> {
            hungUpAndFinish();
            finish();
        });

        ivVideo.setOnClickListener(view -> {
            isCamOff = !isCamOff;
            nertcVideoCall.enableCamera(!isCamOff);
            if (isCamOff) {
                Glide.with(NERTCVideoCallActivity.this).load(R.drawable.cam_off).into(ivVideo);
            } else {
                Glide.with(NERTCVideoCallActivity.this).load(R.drawable.cam_on).into(ivVideo);
            }
        });
        if (callDir == 0 && callOutUser != null) {
            tvCallUser.setText("正在呼叫 " + callOutUser.mobile);
            llyCancel.setVisibility(View.VISIBLE);
            llyBingCall.setVisibility(View.GONE);
            llyCancel.setOnClickListener(v -> {
                nertcVideoCall.cancel();
                finish();
            });
            Glide.with(this).load(callOutUser.avatar).apply(RequestOptions.bitmapTransform(new RoundedCorners(5))).into(ivUserIcon);
        } else if (invitedEvent != null) {
            llyCancel.setVisibility(View.GONE);
            llyBingCall.setVisibility(View.VISIBLE);
        }

        PermissionUtils.permission(PermissionConstants.STORAGE, PermissionConstants.CAMERA, PermissionConstants.MICROPHONE)
                .callback(new PermissionUtils.FullCallback() {
                    @Override
                    public void onGranted(@NonNull List<String> granted) {
                        if (callDir == 0) {
                            callOUt();
                        } else {
                            callIn();
                        }
                    }

                    @Override
                    public void onDenied(@NonNull List<String> deniedForever, @NonNull List<String> denied) {

                    }
                }).request();
    }


    private void callOUt() {
        nertcVideoCall.call(String.valueOf(callOutUser.imAccid), ChannelType.VIDEO);
        NERtcVideoConfig videoConfig = new NERtcVideoConfig();
        videoConfig.frontCamera = true;
        NERtc.getInstance().setLocalVideoConfig(videoConfig);
    }

    private void callIn() {
        InviteParamBuilder invitedParam = new InviteParamBuilder(invitedEvent.getChannelBaseInfo().getChannelId(),
                invitedEvent.getFromAccountId(), invitedEvent.getRequestId());
        ivAccept.setOnClickListener(view -> {
            accept(invitedParam);
        });

        ivReject.setOnClickListener(view -> {
            nertcVideoCall.reject(invitedParam);
            finish();
        });
        List<String> userAccount = new ArrayList<>();
        userAccount.add(invitedEvent.getFromAccountId());
        NIMClient.getService(UserService.class).fetchUserInfo(userAccount).setCallback(new RequestCallback<List<NimUserInfo>>() {
            @Override
            public void onSuccess(List<NimUserInfo> param) {
                NimUserInfo userInfo = param.get(0);
                tvCallUser.setText(userInfo.getMobile());
                tvCallComment.setText("邀请您视频通话");
                Glide.with(NERTCVideoCallActivity.this).load(userInfo.getAvatar()).apply(RequestOptions.bitmapTransform(new RoundedCorners(5))).into(ivUserIcon);
            }

            @Override
            public void onFailed(int code) {

            }

            @Override
            public void onException(Throwable exception) {

            }
        });

    }


    private void initView() {
        localVideoView = findViewById(R.id.local_video_view);
        remoteVideoView = findViewById(R.id.remote_video_view);
        ivSwitch = findViewById(R.id.iv_camera_switch);
        ivUserIcon = findViewById(R.id.iv_call_user);
        tvCallUser = findViewById(R.id.tv_call_user);
        tvCallComment = findViewById(R.id.tv_call_comment);
        ivMute = findViewById(R.id.iv_audio_control);
        ivVideo = findViewById(R.id.iv_video_control);
        ivHungUp = findViewById(R.id.iv_hangup);
        llyCancel = findViewById(R.id.lly_cancel);
        ivAccept = findViewById(R.id.iv_accept);
        ivReject = findViewById(R.id.iv_reject);
        llyBingCall = findViewById(R.id.lly_invited_operation);
        llyDialogOperation = findViewById(R.id.lly_dialog_operation);
        rlyTopUserInfo = findViewById(R.id.rly_top_user_info);
        tvRemoteVideoClose = findViewById(R.id.tv_remote_video_close);
    }

    /**
     * 设置本地视频视图
     */
    private void setupLocalVideo() {
        NERtc.getInstance().enableLocalAudio(true);
        NERtc.getInstance().enableLocalVideo(true);
        localVideoView.setVisibility(View.VISIBLE);
        nertcVideoCall.setupLocalView(localVideoView);
    }

    private void accept(InviteParamBuilder invitedParam) {
        nertcVideoCall.accept(invitedParam);
        rlyTopUserInfo.setVisibility(View.GONE);
        setupLocalVideo();
        llyBingCall.setVisibility(View.GONE);
        llyDialogOperation.setVisibility(View.VISIBLE);
    }

    /**
     * 设置远程视频视图
     *
     * @param uid 远程用户Id
     */
    private void setupRemoteVideo(long uid) {
        nertcVideoCall.setupRemoteView(remoteVideoView, uid);
    }

    @Override
    public void onBackPressed() {
        showExitDialog();
    }

    private void showExitDialog() {
        final AlertDialog.Builder confirmDialog =
                new AlertDialog.Builder(NERTCVideoCallActivity.this);
        confirmDialog.setTitle("结束通话");
        confirmDialog.setMessage("是否结束通话？");
        confirmDialog.setPositiveButton("是",
                (dialog, which) -> {
                    hungUpAndFinish();
                    super.onBackPressed();
                });
        confirmDialog.setNegativeButton("否",
                (dialog, which) -> {

                });
        confirmDialog.show();
    }

    private void hungUpAndFinish() {
        nertcVideoCall.hangup();
        nertcVideoCall.removeDelegate(nertcCallingDelegate);
    }

    @Override
    protected void onDestroy() {
        handler.removeCallbacksAndMessages(null);
        super.onDestroy();
    }
}
