//
// Created by Wenchao Ding on 2020-09-03.
//

#include <jni.h>
#include <string>

extern "C"
JNIEXPORT jstring
JNICALL
Java_com_netease_yunxin_nertc_baselib_NativeConfig_getAppKey__(JNIEnv *env, jclass) {
    std::string appKey = "请输入您的AppKey";
    return env->NewStringUTF(appKey.c_str());
}

extern "C"
JNIEXPORT jstring
JNICALL
Java_com_netease_yunxin_nertc_baselib_NativeConfig_getBaseURL__(JNIEnv *env, jclass) {
    std::string baseURL = "请填写您的BASE地址";
    return env->NewStringUTF(baseURL.c_str());
}