// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.event;

import android.text.TextUtils;
import android.util.Pair;
import com.netease.yunxin.kit.alog.ALog;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

public class EventManager {
  private static final String TAG = EventManager.class.getSimpleName();
  private final Map<Pair<String, String>, List<INotifyEvent>> eventMap;

  public static EventManager getInstance() {
    return EventManager.EventManagerHolder.eventManager;
  }

  private EventManager() {
    this.eventMap = new ConcurrentHashMap();
  }

  public void registerEvent(String key, String subKey, INotifyEvent notification) {
    ALog.i(
        TAG,
        "registerEvent : key : "
            + key
            + ", subKey : "
            + subKey
            + ", notification : "
            + notification);
    if (!TextUtils.isEmpty(key) && !TextUtils.isEmpty(subKey) && notification != null) {
      Pair<String, String> keyPair = new Pair(key, subKey);
      List<INotifyEvent> list = (List) this.eventMap.get(keyPair);
      if (list == null) {
        list = new CopyOnWriteArrayList();
        this.eventMap.put(keyPair, list);
      }

      if (!((List) list).contains(notification)) {
        ((List) list).add(notification);
      }
    }
  }

  public void unRegisterEvent(String key, String subKey, INotifyEvent notification) {
    ALog.i(
        TAG,
        "removeEvent : key : " + key + ", subKey : " + subKey + " notification : " + notification);
    if (!TextUtils.isEmpty(key) && !TextUtils.isEmpty(subKey) && notification != null) {
      Pair<String, String> keyPair = new Pair(key, subKey);
      List<INotifyEvent> list = (List) this.eventMap.get(keyPair);
      if (list != null) {
        list.remove(notification);
      }
    }
  }

  public void unRegisterEvent(INotifyEvent notification) {
    ALog.i(TAG, "removeEvent : notification : " + notification);
    if (notification != null) {
      Iterator var2 = this.eventMap.keySet().iterator();

      while (true) {
        while (true) {
          List value;
          do {
            if (!var2.hasNext()) {
              return;
            }

            Pair<String, String> key = (Pair) var2.next();
            value = (List) this.eventMap.get(key);
          } while (value == null);

          Iterator var5 = value.iterator();

          while (var5.hasNext()) {
            INotifyEvent item = (INotifyEvent) var5.next();
            if (item == notification) {
              value.remove(item);
              break;
            }
          }
        }
      }
    }
  }

  public void notifyEvent(String key, String subKey, Map<String, Object> param) {
    ALog.d(TAG, "notifyEvent : key : " + key + ", subKey : " + subKey);
    if (!TextUtils.isEmpty(key) && !TextUtils.isEmpty(subKey)) {
      Pair<String, String> keyPair = new Pair(key, subKey);
      List<INotifyEvent> notificationList = (List) this.eventMap.get(keyPair);
      if (notificationList != null) {
        Iterator var6 = notificationList.iterator();

        while (var6.hasNext()) {
          INotifyEvent notification = (INotifyEvent) var6.next();
          notification.onNotifyEvent(key, subKey, param);
        }
      }
    }
  }

  private static class EventManagerHolder {
    private static final EventManager eventManager = new EventManager();

    private EventManagerHolder() {}
  }

  public interface INotifyEvent {
    void onNotifyEvent(String key, String subKey, Map<String, Object> param);
  }
}
