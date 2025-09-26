// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.biz;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.netease.yunxin.app.videocall.login.model.AuthManager;
import com.netease.yunxin.app.videocall.login.model.LoginModel;
import com.netease.yunxin.app.videocall.nertc.utils.SPUtils;
import com.netease.yunxin.nertc.nertcvideocall.utils.GsonUtils;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class UserCacheManager {

    private List<LoginModel> lastSearchUser;

    private final Map<String, LoginModel> userModelMap = new HashMap<>();

    private static final String LAST_SEARCH_USER = "last_search_users";

    private static final String USER_LIST = "user_list";

    private static final int MAX_SIZE = 15;

    public static UserCacheManager getInstance() {
        return new UserCacheManager();
    }

    private UserCacheManager() {}

    public void getLastSearchUser(final GetUserCallBack callBack) {
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        executorService.submit(
            () -> {
                if (lastSearchUser == null || lastSearchUser.size() == 0) {
                    loadUsers();
                }
                callBack.getUser(lastSearchUser);
            });
    }

    public void addUser(final LoginModel loginModel) {
        if (loginModel != null) {
            userModelMap.put(loginModel.imAccid, loginModel);
        }
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        executorService.submit(
            () -> {
                if (lastSearchUser == null || lastSearchUser.size() == 0) {
                    loadUsers();
                }
                if (lastSearchUser != null) {
                    if (!lastSearchUser.contains(loginModel)) {
                        if (lastSearchUser.size() >= MAX_SIZE) {
                            lastSearchUser.remove(lastSearchUser.get(0));
                        }
                        lastSearchUser.add(loginModel);
                    }
                } else {
                    lastSearchUser = new LinkedList<>();
                    lastSearchUser.add(loginModel);
                }
                uploadUsers();
            });
    }

    public LoginModel getUserModelFromAccId(String accId) {
        return userModelMap.get(accId);
    }

    private void loadUsers() {
        LoginModel currentUser = AuthManager.getInstance().getUserModel();
        String userStr =
            SPUtils.getInstance(LAST_SEARCH_USER + currentUser.mobile).getString(USER_LIST);
        Type type = TypeToken.getParameterized(List.class, LoginModel.class).getType();
        lastSearchUser = new Gson().fromJson(userStr, type);
    }

    private void uploadUsers() {
        LoginModel currentUser = AuthManager.getInstance().getUserModel();
        String userStr = GsonUtils.toJson(lastSearchUser);
        SPUtils.getInstance(LAST_SEARCH_USER + currentUser.mobile).put(USER_LIST, userStr);
    }

    public interface GetUserCallBack {
        void getUser(List<LoginModel> users);
    }
}
