package com.netease.yunxin.app.videocall.base;


import com.netease.yunxin.app.videocall.nertc.utils.SPUtils;

public class CommonDataManager {

    private static final CommonDataManager instance = new CommonDataManager();

    public static CommonDataManager getInstance() {
        return instance;
    }

    public final static String PER_DATA = "per_profile_manager";
    private static final String PER_ACCESS_TOKEN = "per_access_token";
    private static final String PER_IM_TOKEN = "per_im_token";

    private String token;

    private CommonDataManager() {
    }

    public String getAccessToken() {
        if (token == null) {
            loadAccessToken();
        }
        return token;
    }

    public void setAccessToken(String token) {
        this.token = token;
        SPUtils.getInstance(PER_DATA).put(PER_ACCESS_TOKEN, this.token);
    }

    private void loadAccessToken() {
        token = SPUtils.getInstance(PER_DATA).getString(PER_ACCESS_TOKEN, "");
    }

    public void setIMToken(String imToken) {
        SPUtils.getInstance(PER_DATA).put(PER_IM_TOKEN, imToken);
    }
}
