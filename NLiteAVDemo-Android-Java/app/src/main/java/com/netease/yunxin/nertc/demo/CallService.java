package com.netease.yunxin.nertc.demo;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.blankj.utilcode.util.ServiceUtils;
import com.netease.nimlib.sdk.avsignalling.event.InvitedEvent;
import com.netease.videocall.demo.R;
import com.netease.yunxin.nertc.nertcvideocalldemo.model.NERTCCallingDelegate;
import com.netease.yunxin.nertc.nertcvideocalldemo.model.NERTCVideoCall;
import com.netease.yunxin.nertc.nertcvideocalldemo.ui.NERTCVideoCallActivity;

public class CallService extends Service {
    private static final int NOTIFICATION_ID = 1024;

    private NERTCVideoCall nertcVideoCall;
    private NERTCCallingDelegate callingDelegate = new NERTCCallingDelegate() {

        @Override
        public void onError(int errorCode, String errorMsg) {

        }

        @Override
        public void onInvitedByUser(InvitedEvent invitedEvent) {
            NERTCVideoCallActivity.startBeingCall(CallService.this, invitedEvent);
        }


        @Override
        public void onUserEnter(long userId) {

        }

        @Override
        public void onUserHangup(long userId) {

        }


        @Override
        public void onRejectByUserId(String userId) {

        }


        @Override
        public void onUserBusy(String userId) {

        }

        @Override
        public void onCancelByUserId(String userId) {

        }


        @Override
        public void onCameraAvailable(long userId, boolean isVideoAvailable) {

        }

        @Override
        public void onAudioAvailable(long userId, boolean isVideoAvailable) {

        }

        @Override
        public void timeOut() {

        }

    };

    public static void start(Context context) {
        if (ServiceUtils.isServiceRunning(CallService.class)) {
            return;
        }
        Intent starter = new Intent(context, CallService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(starter);
        } else {
            context.startService(starter);
        }
    }

    public static void stop(Context context) {
        Intent intent = new Intent(context, CallService.class);
        context.stopService(intent);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        // 获取服务通知
        Notification notification = createForegroundNotification();
        //将服务置于启动状态 ,NOTIFICATION_ID指的是创建的通知的ID
        startForeground(NOTIFICATION_ID, notification);
        initNERTCCall();
    }

    private Notification createForegroundNotification() {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        // 唯一的通知通道的id.
        String notificationChannelId = "notification_channel_id_01";

        // Android8.0以上的系统，新建消息通道
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            //用户可见的通道名称
            String channelName = "NERTC Foreground Service Notification";
            //通道的重要程度
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel notificationChannel = new NotificationChannel(notificationChannelId, channelName, importance);
            notificationChannel.setDescription("Channel description");
            //震动
            notificationChannel.setVibrationPattern(new long[]{0, 1000, 500, 1000});
            notificationChannel.enableVibration(true);
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(notificationChannel);
            }
        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, notificationChannelId);
        //通知小图标
        builder.setSmallIcon(R.mipmap.ic_launcher);
        //通知标题
        builder.setContentTitle(getString(R.string.app_name));
        //通知内容
        builder.setContentText("正在运行中");
        //设定通知显示的时间
        builder.setWhen(System.currentTimeMillis());

        //创建通知并返回
        return builder.build();
    }

    private void initNERTCCall() {
        nertcVideoCall = NERTCVideoCall.sharedInstance(this);
        nertcVideoCall.addDelegate(callingDelegate);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (nertcVideoCall != null) {
            nertcVideoCall.removeDelegate(callingDelegate);
        }
        NERTCVideoCall.destroySharedInstance();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
