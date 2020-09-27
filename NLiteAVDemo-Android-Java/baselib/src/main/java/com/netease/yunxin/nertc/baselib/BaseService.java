package com.netease.yunxin.nertc.baselib;

import android.text.TextUtils;

import java.io.IOException;

import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class BaseService {

    private final Retrofit mRetrofit;

    public static final int ERROR_CODE_UNKNOWN = -1;

    private static final String BASE_URL = NativeConfig.getBaseURL();

    public static BaseService getInstance() {
        return RetrofitHolder.retrofit;
    }

    static class RetrofitHolder {
        static BaseService retrofit = new BaseService();
    }

    private BaseService() {
        OkHttpClient.Builder builder = new OkHttpClient.Builder()
                .addInterceptor(new Interceptor() {
                    @Override
                    public okhttp3.Response intercept(Chain chain) throws IOException {
                        Request original = chain.request();

                        // Request customization: add request headers

                        Request.Builder requestBuilder = original.newBuilder();
                        if (!TextUtils.isEmpty(CommonDataManager.getInstance().getAccessToken())) {
                            requestBuilder.header("accessToken", CommonDataManager.getInstance().getAccessToken());
                        }


                        Request request = requestBuilder.build();
                        return chain.proceed(request);
                    }
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
        public void onSuccess(T response);

        public void onFail(int code);
    }
}
