package com.netease.yunxin.flutter.plugins.callkit.ui.utils;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.HandlerThread;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioMixingOption;

public class CallingBellPlayer {
  private final Context mContext;

  private MediaPlayer mMediaPlayer;
  private Handler mHandler;
  private HandlerThread mHandlerThread;
  private Runnable mPlayRunnable;
  private String mRingFilePath = "";
  private int AUDIO_DIAL_ID = 48;

  public CallingBellPlayer(Context mContext) {
    this.mContext = mContext;
    mMediaPlayer = new MediaPlayer();
  }

  public void startRing(String filePath) {
    mRingFilePath = filePath;
    startHandlerThread();
    mHandler.post(mPlayRunnable);
  }

  public void stopRing() {
    mRingFilePath = "";
    stopHandlerThread();
  }

  private void startHandlerThread() {
    if (null != mHandler) {
      return;
    }
    mHandlerThread = new HandlerThread("CallingBell");
    mHandlerThread.start();
    mHandler = new Handler(mHandlerThread.getLooper());
    mPlayRunnable =
        new Runnable() {
          @Override
          public void run() {
            if (mMediaPlayer.isPlaying()) {
              mMediaPlayer.stop();
            }
            mMediaPlayer.reset();
            mMediaPlayer.setAudioStreamType(AudioManager.STREAM_RING);

            try {
              mMediaPlayer.setDataSource(mRingFilePath);
              mMediaPlayer.setLooping(true);
              mMediaPlayer.prepare();
              mMediaPlayer.start();

            } catch (Exception e) {
              e.printStackTrace();
            }
          }
        };
  }

  private void stopHandlerThread() {
    if (null == mHandler) {
      return;
    }
    if (mMediaPlayer.isPlaying()) {
      mMediaPlayer.stop();
    }
    if (mHandler != null) {
      mHandler.removeCallbacks(mPlayRunnable);
      mHandler = null;
    }
    mPlayRunnable = null;
    if (mHandlerThread != null) {
      mHandlerThread.quitSafely();
      mHandlerThread = null;
    }
  }
}
