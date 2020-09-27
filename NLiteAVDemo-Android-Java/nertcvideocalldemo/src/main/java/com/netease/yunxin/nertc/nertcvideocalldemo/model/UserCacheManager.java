package com.netease.yunxin.nertc.nertcvideocalldemo.model;

import com.blankj.utilcode.util.GsonUtils;
import com.blankj.utilcode.util.SPUtils;
import com.netease.yunxin.nertc.login.model.UserModel;

import java.lang.reflect.Type;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;


public class UserCacheManager {

    private List<UserModel> lastSearchUser;

    private static final String LAST_SEARCH_USER = "last_search_users";

    private static final String USER_LIST = "user_list";

    private static final int MAX_SIZE = 10;

    public static UserCacheManager getInstance() {
        return new UserCacheManager();
    }

    private UserCacheManager() {

    }

    public void getLastSearchUser(final GetUserCallBack callBack) {
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        executorService.submit(new Runnable() {
            @Override
            public void run() {
                if (lastSearchUser == null || lastSearchUser.size() == 0) {
                    loadUsers();
                }
                callBack.getUser(lastSearchUser);
            }
        });

    }

    public void addUser(final UserModel userModel) {
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        executorService.submit(new Runnable() {
            @Override
            public void run() {
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
            }
        });
    }

    private void loadUsers() {
        String userStr = SPUtils.getInstance(LAST_SEARCH_USER).getString(USER_LIST);
        Type type = GsonUtils.getListType(UserModel.class);
        lastSearchUser = GsonUtils.fromJson(userStr, type);
    }

    private void uploadUsers() {
        String userStr = GsonUtils.toJson(lastSearchUser);
        SPUtils.getInstance(LAST_SEARCH_USER).put(USER_LIST, userStr);
    }

    public interface GetUserCallBack {
        void getUser(List<UserModel> users);
    }
}
