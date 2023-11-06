/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

object Constants {

    /**
     * intent-key，呼叫传递参数
     */
    const val PARAM_KEY_CALL = "call_param"

    /**
     * intent-key，群组呼叫传递参数
     */
    const val PARAM_KEY_GROUP_CALL = "group_call_param"

    /**
     * intent-key，群组呼叫信息
     */
    const val PARAM_KEY_GROUP_CALL_INFO = "group_call_info"

    /**
     * intent-key，群组呼叫通话 id
     */
    const val PARAM_KEY_GROUP_CALL_ID = "group_call_id"

    /**
     * ui 层关闭本地摄像头数据发布
     */
    const val CLOSE_TYPE_MUTE = 1

    /**
     * ui 层关闭本地摄像头数据采集及发布
     */
    const val CLOSE_TYPE_DISABLE = 2

    /**
     * ui 层关闭本地摄像头处理兼容[CLOSE_TYPE_MUTE]和[CLOSE_TYPE_DISABLE]
     */
    const val CLOSE_TYPE_COMPAT = 3

    /**
     * 是否来自浮窗
     */
    const val PARAM_KEY_FLAG_IS_FROM_FLOATING_WINDOW = "is_from_floating_window"

    // path for single callkit
    const val PATH_CALL_SINGLE_PAGE = "imkit://call/single.page"

    // path for current is idle state.
    const val PATH_IS_CALL_IDLE = "imkit://call/state/isIdle"

    const val KEY_CALLER_ACC_ID = "caller_accid"

    const val KEY_CALLED_ACC_ID = "called_accid"

    const val KEY_CALL_TYPE = "call_type"

    const val KEY_CALL_EXTRA_INFO = "call_callExtraInfo"

    const val KEY_CALL_GLOBAL_EXTRA_COPY = "call_globalExtraCopy"

    const val KEY_CALL_RTC_CHANNEL_NAME = "call_rtcChannelName"

    const val KEY_CALL_PUSH_CONFIG = "call_pushConfig"

    const val KEY_CALL_PAGE_EXTRAS = "call_extras"
}
