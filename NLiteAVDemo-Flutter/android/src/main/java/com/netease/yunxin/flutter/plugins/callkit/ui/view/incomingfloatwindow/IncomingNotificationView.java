// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.view.incomingfloatwindow;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationChannelGroup;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.RemoteViews;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.SimpleTarget;
import com.bumptech.glide.request.transition.Transition;
import com.netease.yunxin.flutter.plugins.callkit.ui.CallKitUIPlugin;
import com.netease.yunxin.flutter.plugins.callkit.ui.R;
import com.netease.yunxin.flutter.plugins.callkit.ui.service.ServiceInitializer;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.User;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallUILog;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.Constants;
import com.netease.yunxin.kit.call.p2p.model.NECallType;

public class IncomingNotificationView {
  private static IncomingNotificationView sInstance;
  private String TAG = "IncomingNotificationView";
  private String channelID = "CallChannelId";
  private int notificationId = 9909;

  private Context context;
  private RemoteViews remoteViews;
  private NotificationManager notificationManager;
  private Notification notification;

  public IncomingNotificationView(Context context) {
    this.context = context;
    notificationManager =
        (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
  }

  public static IncomingNotificationView getInstance(Context context) {
    if (sInstance == null) {
      synchronized (IncomingNotificationView.class) {
        if (sInstance == null) {
          sInstance = new IncomingNotificationView(context);
        }
      }
    }
    return sInstance;
  }

  /**
   * 压缩Bitmap到指定尺寸，用于通知栏显示
   *
   * @param bitmap 原始Bitmap
   * @param targetWidthDp 目标宽度（dp）
   * @param targetHeightDp 目标高度（dp）
   * @return 压缩后的Bitmap
   */
  private Bitmap compressBitmapForNotification(
      Bitmap bitmap, int targetWidthDp, int targetHeightDp) {
    if (bitmap == null) {
      return null;
    }

    // 将dp转换为px
    DisplayMetrics metrics = context.getResources().getDisplayMetrics();
    int targetWidthPx = (int) (targetWidthDp * metrics.density);
    int targetHeightPx = (int) (targetHeightDp * metrics.density);

    // 如果原始尺寸已经小于等于目标尺寸，直接返回
    if (bitmap.getWidth() <= targetWidthPx && bitmap.getHeight() <= targetHeightPx) {
      return bitmap;
    }

    // 计算缩放比例，保持宽高比
    float scaleWidth = (float) targetWidthPx / bitmap.getWidth();
    float scaleHeight = (float) targetHeightPx / bitmap.getHeight();
    float scale = Math.min(scaleWidth, scaleHeight);

    int scaledWidth = (int) (bitmap.getWidth() * scale);
    int scaledHeight = (int) (bitmap.getHeight() * scale);

    // 创建压缩后的Bitmap
    Bitmap compressedBitmap = Bitmap.createScaledBitmap(bitmap, scaledWidth, scaledHeight, true);

    // 如果压缩后的尺寸仍然大于目标尺寸，进行裁剪
    if (scaledWidth > targetWidthPx || scaledHeight > targetHeightPx) {
      int x = (scaledWidth - targetWidthPx) / 2;
      int y = (scaledHeight - targetHeightPx) / 2;
      x = Math.max(0, x);
      y = Math.max(0, y);

      int cropWidth = Math.min(targetWidthPx, scaledWidth - x);
      int cropHeight = Math.min(targetHeightPx, scaledHeight - y);

      compressedBitmap = Bitmap.createBitmap(compressedBitmap, x, y, cropWidth, cropHeight);
    }

    return compressedBitmap;
  }

  public void showNotification(User caller, int mediaType) {
    CallUILog.i(
        CallKitUIPlugin.TAG, "IncomingNotificationView  showNotification | UserId:" + caller.id);

    String userId = caller.id;
    String userName = caller.nickname;
    String avatar = caller.avatar;

    createChannel();
    notification = createNotification();

    if (TextUtils.isEmpty(userName)) {
      remoteViews.setTextViewText(R.id.tv_incoming_title, userId);
    } else {
      remoteViews.setTextViewText(R.id.tv_incoming_title, userName);
    }

    if (mediaType == NECallType.VIDEO) {
      remoteViews.setTextViewText(R.id.tv_desc, context.getString(R.string.ui_video_call));
      remoteViews.setImageViewResource(R.id.img_media_type, R.drawable.callkit_ic_video_incoming);
      remoteViews.setImageViewResource(R.id.btn_accept, R.drawable.callkit_ic_dialing_video);
    } else {
      remoteViews.setTextViewText(R.id.tv_desc, context.getString(R.string.ui_audio_call));
      remoteViews.setImageViewResource(R.id.img_media_type, R.drawable.callkit_ic_float);
      remoteViews.setImageViewResource(R.id.btn_accept, R.drawable.callkit_bg_dialing);
    }

    Glide.with(context)
        .asBitmap()
        .load(Uri.parse(avatar))
        .diskCacheStrategy(DiskCacheStrategy.ALL)
        .placeholder(R.drawable.callkit_ic_avatar)
        .apply(RequestOptions.bitmapTransform(new RoundedCorners(15)))
        .into(
            new SimpleTarget<Bitmap>() {
              @Override
              public void onResourceReady(
                  @NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                // 压缩Bitmap到通知栏头像的合适尺寸（40dp x 40dp）
                Bitmap compressedBitmap = compressBitmapForNotification(resource, 40, 40);
                remoteViews.setImageViewBitmap(R.id.img_incoming_avatar, compressedBitmap);
                if (notificationManager != null) {
                  notificationManager.notify(notificationId, notification);
                }
              }

              @Override
              public void onLoadFailed(@Nullable Drawable errorDrawable) {
                remoteViews.setImageViewResource(
                    R.id.img_incoming_avatar, R.drawable.callkit_ic_avatar);
                if (notificationManager != null) {
                  notificationManager.notify(notificationId, notification);
                }
              }
            });
  }

  public void cancelNotification() {
    CallUILog.i(
        CallKitUIPlugin.TAG,
        "IncomingNotificationView  cancelNotification | notificationManager is "
            + "exist:"
            + (notificationManager != null));
    if (notificationManager != null) {
      notificationManager.cancel(notificationId);
    }
  }

  private void createChannel() {
    CallUILog.i(CallKitUIPlugin.TAG, "IncomingNotificationView  createChannel");
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      String channelName = "CallChannel";
      String groupID = "CallGroupId";
      String groupName = "CallGroup";

      NotificationChannelGroup channelGroup = new NotificationChannelGroup(groupID, groupName);
      notificationManager.createNotificationChannelGroup(channelGroup);
      NotificationChannel channel =
          new NotificationChannel(channelID, channelName, NotificationManager.IMPORTANCE_HIGH);
      channel.setGroup(groupID);
      channel.enableLights(true);
      channel.setShowBadge(true);
      channel.setSound(null, null);
      notificationManager.createNotificationChannel(channel);
    }
  }

  private Notification createNotification() {
    CallUILog.i(CallKitUIPlugin.TAG, "IncomingNotificationView  createNotification");
    NotificationCompat.Builder builder =
        new NotificationCompat.Builder(context, channelID)
            .setOngoing(true)
            .setWhen(System.currentTimeMillis())
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setTimeoutAfter(30 * 1000L); // todo

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      builder.setCategory(NotificationCompat.CATEGORY_CALL);
      builder.setPriority(NotificationCompat.PRIORITY_MAX);
    }

    builder.setChannelId(channelID);
    builder.setTimeoutAfter(30 * 1000L); // todo
    builder.setSmallIcon(R.drawable.callkit_ic_avatar);
    builder.setSound(null);

    remoteViews =
        new RemoteViews(context.getPackageName(), R.layout.callkit_incoming_notification_view);

    if (ServiceInitializer.isAppInForeground(context)) {
      remoteViews.setOnClickPendingIntent(R.id.ll_notification, getPendingIntent());
      remoteViews.setOnClickPendingIntent(R.id.btn_accept, getAcceptIntent());
      remoteViews.setOnClickPendingIntent(R.id.btn_decline, getDeclineIntent());
    } else {
      builder.setContentIntent(getBgPendingIntent());
      remoteViews.setViewVisibility(R.id.btn_accept, View.GONE);
      remoteViews.setViewVisibility(R.id.btn_decline, View.GONE);
    }

    builder.setCustomContentView(remoteViews);
    builder.setCustomBigContentView(remoteViews);
    return builder.build();
  }

  private PendingIntent getBgPendingIntent() {
    Intent intentLaunchMain =
        context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
    if (intentLaunchMain != null) {
      intentLaunchMain.putExtra("show_in_foreground", true);
      intentLaunchMain.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      return PendingIntent.getActivity(context, 0, intentLaunchMain, PendingIntent.FLAG_IMMUTABLE);
    } else {
      CallUILog.e(TAG, "Failed to get launch intent for package: " + context.getPackageName());
      return PendingIntent.getActivity(context, 0, null, PendingIntent.FLAG_IMMUTABLE);
    }
  }

  private PendingIntent getPendingIntent() {
    Intent intent = new Intent(context, IncomingCallReceiver.class);
    intent.setAction(Constants.SUB_KEY_HANDLE_CALL_RECEIVED);
    return PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_IMMUTABLE);
  }

  private PendingIntent getDeclineIntent() {
    Intent intent = new Intent(context, IncomingCallReceiver.class);
    intent.setAction(Constants.REJECT_CALL_ACTION);
    return PendingIntent.getBroadcast(context, 1, intent, PendingIntent.FLAG_IMMUTABLE);
  }

  private PendingIntent getAcceptIntent() {
    Intent intent = new Intent(context, IncomingCallReceiver.class);
    intent.setAction(Constants.ACCEPT_CALL_ACTION);
    return PendingIntent.getBroadcast(context, 2, intent, PendingIntent.FLAG_IMMUTABLE);
  }
}
