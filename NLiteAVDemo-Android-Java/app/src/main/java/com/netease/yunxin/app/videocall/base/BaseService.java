package com.netease.yunxin.app.videocall.base;

import android.text.TextUtils;
import android.util.Log;


import com.netease.yunxin.app.videocall.BuildConfig;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class BaseService {

    private final Retrofit mRetrofit;

    public static final int ERROR_CODE_UNKNOWN = -1;

    private static final String BASE_URL = BuildConfig.BASE_URL;

    public static BaseService getInstance() {
        return RetrofitHolder.retrofit;
    }

    static class RetrofitHolder {
        static BaseService retrofit = new BaseService();
    }

    private BaseService() {
        HttpLoggingInterceptor interceptor =  new HttpLoggingInterceptor(message -> Log.d("======>>>", message));
        interceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
        OkHttpClient.Builder builder = new OkHttpClient.Builder()
                .addInterceptor(interceptor)
                .addInterceptor(chain -> {
                    Request original = chain.request();
                    // Request customization: add request headers
                    Request.Builder requestBuilder = original.newBuilder();
                    if (!TextUtils.isEmpty(CommonDataManager.getInstance().getAccessToken())) {
                        requestBuilder.header("accessToken", CommonDataManager.getInstance().getAccessToken());
                    }

                    requestBuilder.addHeader("appkey", BuildConfig.APP_KEY);
                    Request request = requestBuilder.build();
                    return chain.proceed(request);
                });
        mRetrofit = new Retrofit.Builder()
                .baseUrl(BASE_URL)
                .client(builder.build())
                .addConverterFactory(GsonConverterFactory.create())
                .build();
    }

    public Retrofit getRetrofit() {
        return mRetrofit;
    }

    public static class ResponseEntity<T> {
        public int code;
        public T data;
    }

    public interface ResponseCallBack<T> {
        void onSuccess(T response);

        void onFail(int code);
    }
}
