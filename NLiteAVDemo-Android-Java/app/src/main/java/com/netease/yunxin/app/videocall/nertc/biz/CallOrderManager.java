package com.netease.yunxin.app.videocall.nertc.biz;

import androidx.lifecycle.MutableLiveData;

import com.blankj.utilcode.util.GsonUtils;
import com.blankj.utilcode.util.SPUtils;
import com.blankj.utilcode.util.TimeUtils;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.msg.MsgServiceObserve;
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment;
import com.netease.nimlib.sdk.msg.attachment.NetCallAttachment;
import com.netease.nimlib.sdk.msg.constant.MsgDirectionEnum;
import com.netease.nimlib.sdk.msg.model.IMMessage;
import com.netease.nimlib.sdk.uinfo.UserService;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;
import com.netease.yunxin.app.videocall.login.model.ProfileManager;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.app.videocall.login.model.UserModel;
import com.netease.yunxin.app.videocall.nertc.model.CallOrder;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.locks.ReentrantReadWriteLock;

public class CallOrderManager {

    private CallOrderManager() {
    }

    public static final int MAX_ORDER = 3;

    public static final String TIME_FORMAT = "HH:mm:ss";

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
        executorService.submit(() -> {
            readWriteLock.writeLock().lock();
            UserModel currentUser = ProfileManager.getInstance().getUserModel();
            ALog.i("GeorgeTest", "loadOrders currentUser mobile:" + currentUser.mobile);
            String orderStr = SPUtils.getInstance(RECENTLY_CALL_ORDERS + currentUser.mobile).getString(ORDER_LIST);
            Type type = GsonUtils.getListType(CallOrder.class);
            List<CallOrder> orderList = GsonUtils.fromJson(orderStr, type);
            if (orderList != null && !orderList.isEmpty()) {
                int len = orderList.size() - orders.size();
                orders.addAll(orderList.subList(0, len));
                ordersLiveData.postValue(orders);
            }
            readWriteLock.writeLock().unlock();
        });
    }


    public MutableLiveData<List<CallOrder>> getOrdersLiveData() {
        return ordersLiveData;
    }

    Observer<List<IMMessage>> incomingMessageObserver =
            (Observer<List<IMMessage>>) messages -> {
                for (IMMessage msg : messages) {
                    MsgAttachment attachment = msg.getAttachment();
                    if (attachment instanceof NetCallAttachment) {
                        NimUserInfo user = NIMClient.getService(UserService.class).getUserInfo(msg.getSessionId());
                        if (user != null) {
                            CallOrder callOrder = new CallOrder(msg.getSessionId(), TimeUtils.millis2String(msg.getTime(), TIME_FORMAT), msg.getDirect(), (NetCallAttachment) attachment, user.getMobile());
                            addOrder(callOrder);
                        }
                    }
                }
            };

    Observer<IMMessage> statusMessage =
            (Observer<IMMessage>) message -> {
                if (message.getDirect() == MsgDirectionEnum.Out) {
                    MsgAttachment attachment = message.getAttachment();
                    if (attachment instanceof NetCallAttachment) {
                        NimUserInfo user = NIMClient.getService(UserService.class).getUserInfo(message.getSessionId());
                        CallOrder order = new CallOrder(message.getSessionId(), TimeUtils.millis2String(message.getTime(), TIME_FORMAT), message.getDirect(), (NetCallAttachment) attachment, user.getMobile());
                        addOrder(order);
                    }
                }
            };

    private void addOrder(CallOrder order) {
        readWriteLock.writeLock().lock();
        if (orders.size() >= MAX_ORDER) {
            orders.remove(0);
        }
        orders.add(order);
        ordersLiveData.postValue(orders);
        readWriteLock.writeLock().unlock();
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
        NIMClient.getService(MsgServiceObserve.class)
                .observeMsgStatus(statusMessage, register);
    }
}
