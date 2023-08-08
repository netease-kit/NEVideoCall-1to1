/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

import com.netease.nimlib.sdk.avsignalling.constant.ChannelType
import com.netease.nimlib.sdk.util.Entry
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.nertc.nertcvideocall.bean.InvitedInfo
import com.netease.yunxin.nertc.nertcvideocall.model.AbsNERtcCallingDelegate

open class NERtcCallDelegateForP2P : AbsNERtcCallingDelegate() {

    private val tag = "NERtcCallDelegateForGroup"

    override fun onError(errorCode: Int, errorMsg: String?, needFinish: Boolean) {
        ALog.e(
            tag,
            "NERtcCallDelegateForGroup onError->$errorCode, errorMsg:$errorMsg, needFinish:$needFinish"
        )
        if (needFinish) {
            onCallFinished(code = errorCode, msg = "onError, message is $errorMsg.")
        }
    }

    override fun onInvited(invitedInfo: InvitedInfo?) {
    }

    override fun onUserEnter(userId: String?) {
    }

    override fun onCallEnd(userId: String?) {
        onCallFinished(msg = "onCallEnd, user is $userId.")
    }

    override fun onUserLeave(userId: String?) {
        onCallFinished(msg = "onUserLeave, user is $userId.")
    }

    override fun onUserDisconnect(userId: String?) {
        onCallFinished(msg = "onUserDisconnect, user is $userId.")
    }

    override fun onRejectByUserId(userId: String?) {
        onCallFinished(msg = "onRejectByUserId, user is $userId.")
    }

    override fun onUserBusy(userId: String?) {
        onCallFinished(msg = "onUserBusy, user is $userId.")
    }

    override fun onCancelByUserId(userId: String?) {
        onCallFinished(msg = "onCancelByUserId, user is $userId.")
    }

    override fun onCameraAvailable(userId: String?, isVideoAvailable: Boolean) {
    }

    override fun onVideoMuted(userId: String?, isMuted: Boolean) {
    }

    override fun onAudioMuted(userId: String?, isMuted: Boolean) {
    }

    override fun onJoinChannel(
        accId: String?,
        uid: Long,
        channelName: String?,
        rtcChannelId: Long
    ) {
    }

    override fun onAudioAvailable(userId: String?, isAudioAvailable: Boolean) {
    }

    override fun onDisconnect(res: Int) {
        onCallFinished(code = res, msg = "onDisconnect, local user disconnect rtc channel.")
    }

    override fun onUserNetworkQuality(stats: Array<out Entry<String, Int>>?) {
    }

    override fun onCallTypeChange(type: ChannelType?, switchCallState: Int) {
    }

    override fun timeOut() {
        onCallFinished(msg = "timeOut")
    }

    override fun onFirstVideoFrameDecoded(userId: String?, width: Int, height: Int) {
    }

    open fun onCallFinished(code: Int? = null, msg: String? = null) {
    }
}
