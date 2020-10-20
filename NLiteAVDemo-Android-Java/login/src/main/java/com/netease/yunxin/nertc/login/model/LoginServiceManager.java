package com.netease.yunxin.nertc.login.model;

import android.text.TextUtils;

import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.yunxin.nertc.baselib.BaseService;
import com.netease.yunxin.nertc.baselib.CommonDataManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import okhttp3.MediaType;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.http.Body;
import retrofit2.http.FieldMap;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.Headers;
import retrofit2.http.POST;

import static com.netease.yunxin.nertc.baselib.BaseService.ERROR_CODE_UNKNOWN;

/**
 * 登录服务管理
 */
public class LoginServiceManager {

    private static final LoginServiceManager mOurInstance = new LoginServiceManager();

    private final Api mApi;

    private Call<BaseService.ResponseEntity<Void>> sendMessageCall;
    private Call<BaseService.ResponseEntity<UserModel>> msmLoginCall;
    private Call<BaseService.ResponseEntity<UserModel>> tokenLoginCall;
    private Call<BaseService.ResponseEntity<Void>> logoutCall;

    public static LoginServiceManager getInstance() {
        return mOurInstance;
    }

    private LoginServiceManager() {
        mApi = BaseService.getInstance().getRetrofit().create(Api.class);
    }

    /**
     * 网络访问接口
     */
    private interface Api {
        @POST("/auth/sendLoginSmsCode")
        @Headers("Content-Type: application/json")
        Call<BaseService.ResponseEntity<Void>> sendLoginSmsCode(@Body RequestBody body);


        @POST("/auth/loginBySmsCode")
        @Headers("Content-Type: application/json")
        Call<BaseService.ResponseEntity<UserModel>> loginBySmsCode(@Body RequestBody body);

        @POST("/auth/loginByToken")
        @Headers("Content-Type: application/json")
        Call<BaseService.ResponseEntity<UserModel>> loginByToken();

        @POST("/auth/logout")
        @Headers("Content-Type: application/json")
        Call<BaseService.ResponseEntity<Void>> logout();

    }


    /**
     * 发送验证码短信
     *
     * @param phoneNumber
     * @param callBack
     */
    public void sendMessage(String phoneNumber, BaseService.ResponseCallBack<Void> callBack) {
        if (sendMessageCall != null && sendMessageCall.isExecuted()) {
            sendMessageCall.cancel();
        }
        JSONObject result = new JSONObject();
        try {
            result.put("mobile", phoneNumber);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        RequestBody body = RequestBody.create(MediaType.parse("application/json"), result.toString());
        sendMessageCall = mApi.sendLoginSmsCode(body);
        sendMessageCall.enqueue(new Callback<BaseService.ResponseEntity<Void>>() {
            @Override
            public void onResponse(Call<BaseService.ResponseEntity<Void>> call, Response<BaseService.ResponseEntity<Void>> response) {
                if (callBack != null) {
                    BaseService.ResponseEntity<Void> responseEntity = response.body();
                    if (responseEntity != null) {
                        if (responseEntity.code == 200) {
                            callBack.onSuccess(null);
                        } else {
                            callBack.onFail(responseEntity.code);
                        }
                    } else {
                        callBack.onFail(response.code());
                    }
                }
            }

            @Override
            public void onFailure(Call<BaseService.ResponseEntity<Void>> call, Throwable t) {
                if (callBack != null) {
                    callBack.onFail(ERROR_CODE_UNKNOWN);
                }
            }
        });
    }

    /**
     * 短信验证码登录
     *
     * @param phoneNumber
     * @param smsCode
     * @param callBack
     */
    public void loginWithSms(String phoneNumber, String smsCode, BaseService.ResponseCallBack<Void> callBack) {
        if (msmLoginCall != null && msmLoginCall.isExecuted()) {
            msmLoginCall.cancel();
        }
        JSONObject result = new JSONObject();
        try {
            result.put("mobile", phoneNumber);
            result.put("smsCode", smsCode);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        RequestBody body = RequestBody.create(MediaType.parse("application/json"), result.toString());
        msmLoginCall = mApi.loginBySmsCode(body);
        msmLoginCall.enqueue(new Callback<BaseService.ResponseEntity<UserModel>>() {
            @Override
            public void onResponse(Call<BaseService.ResponseEntity<UserModel>> call, Response<BaseService.ResponseEntity<UserModel>> response) {
                if (callBack != null) {
                    BaseService.ResponseEntity<UserModel> responseEntity = response.body();
                    if (responseEntity.code == 200) {
                        saveUserModel(responseEntity.data);
                        UserModel userModel = responseEntity.data;
                        loginNim(userModel, callBack);
                    } else {
                        callBack.onFail(responseEntity.code);
                    }
                }
            }

            @Override
            public void onFailure(Call<BaseService.ResponseEntity<UserModel>> call, Throwable t) {
                if (callBack != null) {
                    callBack.onFail(ERROR_CODE_UNKNOWN);
                }
            }
        });
    }

    /**
     * 业务token登录接口，IM在初始化的时候设置已有userInfo 可以自动登录
     *
     * @param callBack
     */
    public void loginWithToken(BaseService.ResponseCallBack<Void> callBack) {
        if (tokenLoginCall != null && tokenLoginCall.isExecuted()) {
            tokenLoginCall.cancel();
        }
        tokenLoginCall = mApi.loginByToken();
        tokenLoginCall.enqueue(new Callback<BaseService.ResponseEntity<UserModel>>() {
            @Override
            public void onResponse(Call<BaseService.ResponseEntity<UserModel>> call, Response<BaseService.ResponseEntity<UserModel>> response) {
                if (callBack != null) {
                    BaseService.ResponseEntity<UserModel> responseEntity = response.body();
                    if (responseEntity.code == 200) {
                        saveUserModel(responseEntity.data);
                        UserModel userModel = responseEntity.data;
                        loginNim(userModel, callBack);
                    } else {
                        callBack.onFail(responseEntity.code);
                    }
                }
            }

            @Override
            public void onFailure(Call<BaseService.ResponseEntity<UserModel>> call, Throwable t) {
                if (callBack != null) {
                    callBack.onFail(ERROR_CODE_UNKNOWN);
                }
            }
        });
    }

    /**
     * 退出登录
     *
     * @param callBack
     */
    public void logout(BaseService.ResponseCallBack<Void> callBack) {
        if (logoutCall != null && logoutCall.isExecuted()) {
            logoutCall.cancel();
        }
        logoutCall = mApi.logout();
        logoutCall.enqueue(new Callback<BaseService.ResponseEntity<Void>>() {
            @Override
            public void onResponse(Call<BaseService.ResponseEntity<Void>> call, Response<BaseService.ResponseEntity<Void>> response) {
                if (callBack != null) {
                    BaseService.ResponseEntity<Void> responseEntity = response.body();
                    if (responseEntity.code == 200) {
                        clearLoginInfo();
                        ProfileManager.getInstance().logout();
                        callBack.onSuccess(null);
                    } else {
                        callBack.onFail(responseEntity.code);
                    }
                }
            }

            @Override
            public void onFailure(Call<BaseService.ResponseEntity<Void>> call, Throwable t) {
                if (callBack != null) {
                    callBack.onFail(ERROR_CODE_UNKNOWN);
                }
            }
        });
    }

    /**
     * 登录IM
     *
     * @param userModel
     * @param callBack
     */
    private void loginNim(UserModel userModel, BaseService.ResponseCallBack<Void> callBack) {
        LoginInfo loginInfo = new LoginInfo(String.valueOf(userModel.imAccid), userModel.imToken);
        ProfileManager.getInstance().login(loginInfo, new RequestCallback<LoginInfo>() {
            @Override
            public void onSuccess(LoginInfo param) {
                callBack.onSuccess(null);
                ProfileManager.getInstance().setLogin(true);//登录IM成功
                ProfileManager.getInstance().updateUserInfo(userModel);
            }

            @Override
            public void onFailed(int code) {
                callBack.onFail(code);
            }

            @Override
            public void onException(Throwable exception) {
                callBack.onFail(-1);
            }
        });
    }

    private void saveUserModel(UserModel userModel) {
        if (userModel != null) {
            ProfileManager.getInstance().setUserModel(userModel);
            if (!TextUtils.isEmpty(userModel.accessToken)) {
                ProfileManager.getInstance().setAccessToken(userModel.accessToken);
            }
            if (!TextUtils.isEmpty(userModel.imToken)) {
                CommonDataManager.getInstance().setIMToken(userModel.imToken);
            }
        }
    }

    private void clearLoginInfo() {
        ProfileManager.getInstance().setLogin(false);
        ProfileManager.getInstance().setUserModel(null);
        ProfileManager.getInstance().setAccessToken(null);
        CommonDataManager.getInstance().setIMToken(null);
    }

}
