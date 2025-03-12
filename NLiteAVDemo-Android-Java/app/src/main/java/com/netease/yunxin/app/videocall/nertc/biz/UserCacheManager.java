// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.biz;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.netease.yunxin.app.videocall.login.model.ProfileManager;
import com.netease.yunxin.app.videocall.login.model.UserModel;
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

    private List<UserModel> lastSearchUser;

    private final Map<String, UserModel> userModelMap = new HashMap<>();

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

    public void addUser(final UserModel userModel) {
        if (userModel != null) {
            userModelMap.put(userModel.imAccid, userModel);
        }
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        executorService.submit(
            () -> {
                if (lastSearchUser == null || lastSearchUser.size() == 0) {
                    loadUsers();
                }
                if (lastSearchUser != null) {
                    if (!lastSearchUser.contains(userModel)) {
                        if (lastSearchUser.size() >= MAX_SIZE) {
                            lastSearchUser.remove(lastSearchUser.get(0));
                        }
                        lastSearchUser.add(userModel);
                    }
                } else {
                    lastSearchUser = new LinkedList<>();
                    lastSearchUser.add(userModel);
                }
                uploadUsers();
            });
    }

    public UserModel getUserModelFromAccId(String accId) {
        return userModelMap.get(accId);
    }

    private void loadUsers() {
        UserModel currentUser = ProfileManager.getInstance().getUserModel();
        String userStr =
            SPUtils.getInstance(LAST_SEARCH_USER + currentUser.mobile).getString(USER_LIST);
        Type type = TypeToken.getParameterized(List.class, UserModel.class).getType();
        lastSearchUser = new Gson().fromJson(userStr, type);
    }

    private void uploadUsers() {
        UserModel currentUser = ProfileManager.getInstance().getUserModel();
        String userStr = GsonUtils.toJson(lastSearchUser);
        SPUtils.getInstance(LAST_SEARCH_USER + currentUser.mobile).put(USER_LIST, userStr);
    }

    public interface GetUserCallBack {
        void getUser(List<UserModel> users);
    }
}
