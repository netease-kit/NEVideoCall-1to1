// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.biz;

import android.util.Log;

import androidx.lifecycle.MutableLiveData;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.netease.nimlib.sdk.v2.message.V2NIMClearHistoryNotification;
import com.netease.nimlib.sdk.v2.message.V2NIMMessage;
import com.netease.nimlib.sdk.v2.message.V2NIMMessageDeletedNotification;
import com.netease.nimlib.sdk.v2.message.V2NIMMessageListener;
import com.netease.nimlib.sdk.v2.message.V2NIMMessagePinNotification;
import com.netease.nimlib.sdk.v2.message.V2NIMMessageQuickCommentNotification;
import com.netease.nimlib.sdk.v2.message.V2NIMMessageRevokeNotification;
import com.netease.nimlib.sdk.v2.message.V2NIMP2PMessageReadReceipt;
import com.netease.nimlib.sdk.v2.message.V2NIMTeamMessageReadReceipt;
import com.netease.nimlib.sdk.v2.message.attachment.V2NIMMessageAttachment;
import com.netease.nimlib.sdk.v2.message.attachment.V2NIMMessageCallAttachment;
import com.netease.nimlib.sdk.v2.message.enums.V2NIMMessageSendingState;
import com.netease.nimlib.sdk.v2.message.model.V2NIMMessageCallDuration;
import com.netease.nimlib.sdk.v2.utils.V2NIMConversationIdUtil;
import com.netease.yunxin.app.videocall.login.model.AuthManager;
import com.netease.yunxin.app.videocall.login.model.LoginModel;
import com.netease.yunxin.app.videocall.nertc.model.CallOrder;
import com.netease.yunxin.app.videocall.nertc.utils.SPUtils;
import com.netease.yunxin.app.videocall.user.UserManager;
import com.netease.yunxin.app.videocall.user.UserModel;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.call.common.NimMessageWrapper;
import com.netease.yunxin.kit.call.common.callback.Callback2;
import com.netease.yunxin.nertc.nertcvideocall.utils.GsonUtils;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.locks.ReentrantReadWriteLock;

public class CallOrderManager {
  private final String TAG = "CallOrderManager";
  public static final int MAX_ORDER = 3;

  private static final String RECENTLY_CALL_ORDERS = "recently_call_orders";

  private static final String ORDER_LIST = "call_orders";

  MutableLiveData<List<CallOrder>> ordersLiveData = new MutableLiveData<>();

  List<CallOrder> orders = new ArrayList<>();

  private static volatile CallOrderManager mInstance;

  private CallOrderManager() {}

  public static CallOrderManager getInstance() {
    if (null == mInstance) {
      synchronized (CallOrderManager.class) {
        if (mInstance == null) {
          mInstance = new CallOrderManager();
        }
      }
    }
    return mInstance;
  }

  public void init() {
    register(true);
    orders.clear();
    readWriteLock = new ReentrantReadWriteLock();
    loadOrders();
  }

  private ReentrantReadWriteLock readWriteLock;

  public List<CallOrder> getOrders() {
    return orders;
  }

  private void loadOrders() {
    ExecutorService executorService = Executors.newSingleThreadExecutor();
    executorService.submit(
        () -> {
          try {
            readWriteLock.writeLock().lock();
            LoginModel currentUser = AuthManager.getInstance().getUserModel();
            ALog.i("CallOrderManager", "loadOrders currentUser mobile:" + currentUser.mobile);
            String orderStr =
                SPUtils.getInstance(RECENTLY_CALL_ORDERS + currentUser.mobile)
                    .getString(ORDER_LIST);
            Type type = TypeToken.getParameterized(List.class, CallOrder.class).getType();
            List<CallOrder> orderList = new Gson().fromJson(orderStr, type);
            if (orderList != null && !orderList.isEmpty()) {
              int len = orderList.size() - orders.size();
              orders.addAll(orderList.subList(0, len));
              ordersLiveData.postValue(orders);
            }
          } catch (Exception exception) {
            ALog.e("CallOrderManager", "loadOrders", exception);
          } finally {
            readWriteLock.writeLock().unlock();
          }
        });
  }

  public MutableLiveData<List<CallOrder>> getOrdersLiveData() {
    return ordersLiveData;
  }

  V2NIMMessageListener messageListener =
      new V2NIMMessageListener() {
        @Override
        public void onReceiveMessages(List<V2NIMMessage> messages) {
          if (messages != null) {
            for (V2NIMMessage msg : messages) {
              ALog.i(TAG, "onReceiveMessages message = " + msg);
              V2NIMMessageAttachment attachment = msg.getAttachment();
              if (attachment instanceof V2NIMMessageCallAttachment) {
                handleNetCallAttachment(msg, (V2NIMMessageCallAttachment) attachment);
              }
            }
          }
        }

        @Override
        public void onReceiveP2PMessageReadReceipts(
            List<V2NIMP2PMessageReadReceipt> readReceipts) {}

        @Override
        public void onReceiveTeamMessageReadReceipts(
            List<V2NIMTeamMessageReadReceipt> readReceipts) {}

        @Override
        public void onMessageRevokeNotifications(
            List<V2NIMMessageRevokeNotification> revokeNotifications) {}

        @Override
        public void onMessagePinNotification(V2NIMMessagePinNotification pinNotification) {}

        @Override
        public void onMessageQuickCommentNotification(
            V2NIMMessageQuickCommentNotification quickCommentNotification) {}

        @Override
        public void onMessageDeletedNotifications(
            List<V2NIMMessageDeletedNotification> messageDeletedNotifications) {}

        @Override
        public void onClearHistoryNotifications(
            List<V2NIMClearHistoryNotification> clearHistoryNotifications) {}

        @Override
        public void onSendMessage(V2NIMMessage message) {
          ALog.i(TAG, "onSendMessage message = " + message);

          if (message.getSendingState()
              == V2NIMMessageSendingState.V2NIM_MESSAGE_SENDING_STATE_SUCCEEDED) {
            V2NIMMessageAttachment attachment = message.getAttachment();
            if (attachment instanceof V2NIMMessageCallAttachment) {
              handleNetCallAttachment(message, (V2NIMMessageCallAttachment) attachment);
            }
          }
        }

        @Override
        public void onReceiveMessagesModified(List<V2NIMMessage> messages) {
          ALog.i(TAG, "onReceiveMessagesModified messages = " + messages);
        }
      };

  private void handleNetCallAttachment(
      V2NIMMessage message, V2NIMMessageCallAttachment attachment) {
    ALog.i(TAG, "handleNetCallAttachment attachment = " + attachment);
    if (message == null) {
      ALog.e(TAG, "handleNetCallAttachment message is null");
      return;
    }

    if (attachment == null) {
      ALog.e(TAG, "handleNetCallAttachment attachment is null");
      return;
    }

    String targetId = V2NIMConversationIdUtil.conversationTargetId(message.getConversationId());

    UserManager.getInstance()
        .getUserList(
            Collections.singletonList(targetId),
            new Callback2<List<UserModel>>() {
              @Override
              public void onSuccess(List<UserModel> userModels) {
                if (userModels == null || userModels.isEmpty()) {
                  Log.e(TAG, "fetchUserInfo success but list is empty. ");
                  return;
                }
                UserModel userModel = userModels.get(0);

                List<CallOrder.CallDuration> callDurationList = new ArrayList<>();
                for (V2NIMMessageCallDuration duration : attachment.getDurations()) {
                  if (duration != null) {
                    CallOrder.CallDuration callDuration =
                        new CallOrder.CallDuration(duration.getAccountId(), duration.getDuration());
                    callDurationList.add(callDuration);
                  }
                }

                CallOrder callOrder =
                    new CallOrder(
                        targetId,
                        message.getCreateTime(),
                        message.isSelf(),
                        userModel.getMobile(),
                        attachment.getType(),
                        attachment.getChannelId(),
                        attachment.getStatus(),
                        callDurationList);
                addOrder(callOrder);
              }

              @Override
              public void onFailure(int code, String msg) {
                ALog.e(TAG, "fetchUserInfo failed code is " + code + ", msg is " + msg);
              }
            });
  }

  private void addOrder(CallOrder order) {
    ALog.i(TAG, "addOrder order:" + order);
    try {
      readWriteLock.writeLock().lock();
      if (orders.size() >= MAX_ORDER) {
        orders.remove(0);
      }
      orders.add(order);
      ordersLiveData.postValue(orders);
    } catch (Exception exception) {
      ALog.e("CallOrderManager", "addOrder", exception);
    } finally {
      readWriteLock.writeLock().unlock();
    }
    uploadOrder();
  }

  private void uploadOrder() {
    String orderStr = GsonUtils.toJson(orders);
    LoginModel currentUser = AuthManager.getInstance().getUserModel();
    ALog.i("CallOrderManager", "uploadOrder currentUser mobile:" + currentUser.mobile);
    SPUtils.getInstance(RECENTLY_CALL_ORDERS + currentUser.mobile).put(ORDER_LIST, orderStr);
  }

  private void register(boolean register) {
    if (register) {
      NimMessageWrapper.addMessageListener(messageListener);
    } else {
      NimMessageWrapper.removeMessageListener(messageListener);
    }
  }
}
