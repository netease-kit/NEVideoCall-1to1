// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.biz;

import android.util.Log;
import androidx.lifecycle.MutableLiveData;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.RequestCallbackWrapper;
import com.netease.nimlib.sdk.ResponseCode;
import com.netease.nimlib.sdk.msg.MsgServiceObserve;
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment;
import com.netease.nimlib.sdk.msg.attachment.NetCallAttachment;
import com.netease.nimlib.sdk.msg.constant.MsgDirectionEnum;
import com.netease.nimlib.sdk.msg.model.IMMessage;
import com.netease.nimlib.sdk.uinfo.UserService;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;
import com.netease.yunxin.app.videocall.login.model.ProfileManager;
import com.netease.yunxin.app.videocall.login.model.UserModel;
import com.netease.yunxin.app.videocall.nertc.model.CallOrder;
import com.netease.yunxin.app.videocall.nertc.utils.SPUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.nertcvideocall.utils.GsonUtils;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.locks.ReentrantReadWriteLock;

public class CallOrderManager {

    private CallOrderManager() {}

    public static final int MAX_ORDER = 3;

    private static final String RECENTLY_CALL_ORDERS = "recently_call_orders";

    private static final String ORDER_LIST = "call_orders";

    MutableLiveData<List<CallOrder>> ordersLiveData = new MutableLiveData<>();

    List<CallOrder> orders = new ArrayList<>();

    public static CallOrderManager getInstance() {
        return ManagerHolder.manager;
    }

    private static final class ManagerHolder {
        public static final CallOrderManager manager = new CallOrderManager();
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
                    UserModel currentUser = ProfileManager.getInstance().getUserModel();
                    ALog.i("GeorgeTest", "loadOrders currentUser mobile:" + currentUser.mobile);
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

    Observer<List<IMMessage>> incomingMessageObserver =
        messages -> {
            for (IMMessage msg : messages) {
                MsgAttachment attachment = msg.getAttachment();
                if (attachment instanceof NetCallAttachment) {
                    handleNetCallAttachment(msg, (NetCallAttachment) attachment);
                }
            }
        };

    Observer<IMMessage> statusMessage =
        message -> {
            if (message.getDirect() == MsgDirectionEnum.Out) {
                MsgAttachment attachment = message.getAttachment();
                if (attachment instanceof NetCallAttachment) {
                    handleNetCallAttachment(message, (NetCallAttachment) attachment);
                }
            }
        };

    private void handleNetCallAttachment(IMMessage message, NetCallAttachment attachment) {
        if (message == null) {
            Log.e("CallOrderManager", "handleNetCallAttachment message is null");
            return;
        }
        String id = message.getSessionId();
        NimUserInfo userInfo = NIMClient.getService(UserService.class).getUserInfo(id);
        if (userInfo != null) {
            CallOrder callOrder =
                new CallOrder(
                    message.getSessionId(),
                    message.getTime(),
                    message.getDirect(),
                    attachment,
                    userInfo.getMobile());
            addOrder(callOrder);
            return;
        }
        NIMClient.getService(UserService.class)
            .fetchUserInfo(Collections.singletonList(id))
            .setCallback(
                new RequestCallbackWrapper<List<NimUserInfo>>() {
                    @Override
                    public void onResult(int code, List<NimUserInfo> result, Throwable exception) {
                        if (code == ResponseCode.RES_SUCCESS) {
                            if (result == null || result.isEmpty()) {
                                Log.e("CallOrderManager", "fetchUserInfo success but list is empty. ");
                                return;
                            }
                            NimUserInfo userInfoRemote = result.get(0);
                            CallOrder callOrder =
                                new CallOrder(
                                    message.getSessionId(),
                                    message.getTime(),
                                    message.getDirect(),
                                    attachment,
                                    userInfoRemote.getMobile());
                            addOrder(callOrder);
                        } else {
                            Log.e(
                                "CallOrderManager",
                                "fetchUserInfo failed code is " + code + ", exception is " + exception);
                        }
                    }
                });
    }

    private void addOrder(CallOrder order) {
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
        UserModel currentUser = ProfileManager.getInstance().getUserModel();
        ALog.i("GeorgeTest", "uploadOrder currentUser mobile:" + currentUser.mobile);
        SPUtils.getInstance(RECENTLY_CALL_ORDERS + currentUser.mobile).put(ORDER_LIST, orderStr);
    }

    private void register(boolean register) {
        NIMClient.getService(MsgServiceObserve.class)
            .observeReceiveMessage(incomingMessageObserver, register);
        NIMClient.getService(MsgServiceObserve.class).observeMsgStatus(statusMessage, register);
    }
}
