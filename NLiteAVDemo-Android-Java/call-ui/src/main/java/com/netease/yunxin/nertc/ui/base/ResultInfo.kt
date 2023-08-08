/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

/**
 * 统一结果信息
 */
class ResultInfo<T> @JvmOverloads constructor(
    val value: T? = null, // 结果具体值
    val success: Boolean = true, // 执行结果是否成功
    val msg: ErrorMsg? = null // 存在的错误信息
) {
    override fun toString(): String {
        return "ResultInfo(value=$value, success=$success, msg=$msg)"
    }
}

/**
 * 统一的错误信息
 */
class ErrorMsg @JvmOverloads constructor(
    val type: Int = -1, // 错误类型
    val code: Int, // 错误码
    val message: String = "", // 错误信息
    val exception: Throwable? = null // 执行产生的 exception
) {
    override fun toString(): String {
        return "ErrorMsg(type=$type, code=$code, message='$message', exception=$exception)"
    }
}

/**
 * 用于处理回调结果
 */
interface ResultObserver<T> {

    /**
     * 当执行结束后，此回调输出执行结果
     *
     * @param result 此操作的执行结果，以及相关原因
     */
    fun onResult(result: ResultInfo<T>)
}
