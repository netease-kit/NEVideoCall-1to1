package com.netease.yunxin.flutter.plugins.callkit.ui.utils;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import com.netease.yunxin.flutter.plugins.callkit.ui.R;

public class NotificationUtils {

  private static final String INCOMING_CALL_CHANNEL = "incoming_call_notification_channel_id_133";

  private static final int INCOMING_CALL_NOTIFY_ID = 1025;

  public static void showNotification(Context context) {

    NotificationManager notificationManager =
        (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

    PendingIntent pendingIntent =
        PendingIntent.getActivity(
            context,
            INCOMING_CALL_NOTIFY_ID,
            getIntent(context),
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
                ? PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                : PendingIntent.FLAG_UPDATE_CURRENT);

    String channelId = INCOMING_CALL_CHANNEL;
    int iconId = R.drawable.callkit_dark_logo_icon;
    String title = context.getString(R.string.tip_new_incoming_call);
    String content = "【网络通话】";

    NotificationCompat.Builder builder =
        new NotificationCompat.Builder(context, channelId)
            .setContentTitle(title)
            .setContentText(content)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .setSmallIcon(iconId)
            .setTimeoutAfter(0)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(false)
            .setDefaults(Notification.DEFAULT_LIGHTS);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      // 用户可见的通道名称
      NotificationChannel notificationChannel =
          new NotificationChannel(
              channelId,
              context.getString(R.string.tip_notification_channel_name),
              NotificationManager.IMPORTANCE_HIGH);
      notificationChannel.setDescription(
          context.getString(R.string.tip_notification_channel_description));
      notificationChannel.enableLights(true);
      notificationChannel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
      notificationChannel.setBypassDnd(true);
      notificationChannel.enableVibration(true);
      notificationManager.createNotificationChannel(notificationChannel);
    }
    notificationManager.notify(INCOMING_CALL_NOTIFY_ID, builder.build());
  }

  public static void cancelNotification(Context context) {
    NotificationManager notificationManager =
        (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
    notificationManager.cancel(INCOMING_CALL_NOTIFY_ID);
  }

  public static Intent getIntent(Context context) {
    Intent intentLaunchMain =
        context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
    if (intentLaunchMain != null) {
      intentLaunchMain.putExtra("show_in_notification", true);
      intentLaunchMain.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    }
    return intentLaunchMain;
  }
}
