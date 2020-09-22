package com.netease.yunxin.nertc.baselib;

public class NativeConfig {
    static {
        System.loadLibrary("config");
    }

    public static native String getAppKey();

    public static native String getBaseURL();
}
