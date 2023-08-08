/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import android.content.Context
import android.content.Intent
import android.text.TextUtils
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.nertc.nertcvideocall.utils.CallParams
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.service.UIServiceManager

fun CallParam.currentUserIsCaller(): Boolean {
    return !TextUtils.isEmpty(callerAccId) && TextUtils.equals(callerAccId, currentAccId)
}

fun CallParam.getChannelId(): String? {
    return extras?.run {
        this[CallParams.INVENT_CHANNEL_ID] as? String
    }
}

fun CallParam.channelId(channelId: String?) {
    if (extras == null) {
        extras = HashMap()
    }
    extras?.run {
        this[CallParams.INVENT_CHANNEL_ID] = channelId
    }
}

fun NEInviteInfo.toCallParam(): CallParam {
    return CallParam(
        true,
        callType,
        callerAccId,
        CallKitUI.currentUserAccId,
        callExtraInfo = extraInfo,
        globalExtraCopy = NECallEngine.sharedInstance().callInfo.signalInfo.globalExtraCopy,
        rtcChannelName = NECallEngine.sharedInstance().callInfo.rtcInfo.channelName,
        extras = mutableMapOf(
            CallParams.INVENT_CHANNEL_ID to channelId
        )
    )
}

fun NEInviteInfo.toCallIntent(context: Context): Intent {
    return Intent().apply {
        when (callType) {
            NECallType.AUDIO -> setClass(
                context,
                UIServiceManager.getInstance().uiService!!.getOneToOneAudioChat()!!
            )

            else -> setClass(
                context,
                UIServiceManager.getInstance().uiService!!.getOneToOneVideoChat()!!
            )
        }
    }.apply {
        putExtra(Constants.PARAM_KEY_CALL, toCallParam())
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
    }
}

fun NEGroupCallInfo.toCallIntent(context: Context): Intent {
    return Intent().apply {
        setClass(context, UIServiceManager.getInstance().uiService!!.getGroupChat()!!)
    }.apply {
        putExtra(Constants.PARAM_KEY_GROUP_CALL_INFO, this@toCallIntent)
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
    }
}
