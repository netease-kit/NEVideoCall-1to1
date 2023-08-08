/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.service

import android.content.Context
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo

abstract class IncomingCallEx {

    internal var uiService: UIService? = null

    internal var context: Context? = null

    protected fun currentContext(): Context? = context

    protected fun currentUIService(): UIService? = uiService

    abstract fun onIncomingCall(invitedInfo: NEGroupCallInfo): Boolean

    abstract fun onIncomingCallInvalid(invitedInfo: NEGroupCallInfo?)

    abstract fun onIncomingCall(invitedInfo: NEInviteInfo): Boolean

    abstract fun onIncomingCallInvalid(invitedInfo: NEInviteInfo?)

    open fun tryResumeInvitedUI(invitedInfo: NEInviteInfo): Boolean = false

    open fun tryResumeInvitedUI(invitedInfo: NEGroupCallInfo): Boolean = false
}
