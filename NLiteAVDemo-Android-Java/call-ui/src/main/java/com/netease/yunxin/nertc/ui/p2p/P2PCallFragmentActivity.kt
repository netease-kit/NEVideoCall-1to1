/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

import android.app.AlertDialog
import android.content.DialogInterface
import android.os.Bundle
import android.view.View
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NEHangupReasonCode
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState.STATE_CALL_OUT
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState.STATE_DIALOG
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState.STATE_IDLE
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState.STATE_INVITED
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.CommonCallActivity
import com.netease.yunxin.nertc.ui.p2p.fragment.BaseP2pCallFragment
import com.netease.yunxin.nertc.ui.p2p.fragment.FragmentActionBridge
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PCallFragmentType.AUDIO_CALLEE
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PCallFragmentType.AUDIO_CALLER
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PCallFragmentType.AUDIO_ON_THE_CALL
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PCallFragmentType.VIDEO_CALLEE
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PCallFragmentType.VIDEO_CALLER
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PCallFragmentType.VIDEO_ON_THE_CALL
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.CHANGE_CALL_TYPE
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.FROM_FLOATING_WINDOW
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.INIT
import com.netease.yunxin.nertc.ui.p2p.fragment.callee.AudioCalleeFragment
import com.netease.yunxin.nertc.ui.p2p.fragment.callee.VideoCalleeFragment
import com.netease.yunxin.nertc.ui.p2p.fragment.caller.AudioCallerFragment
import com.netease.yunxin.nertc.ui.p2p.fragment.caller.VideoCallerFragment
import com.netease.yunxin.nertc.ui.p2p.fragment.onthecall.AudioOnTheCallFragment
import com.netease.yunxin.nertc.ui.p2p.fragment.onthecall.VideoOnTheCallFragment
import com.netease.yunxin.nertc.ui.utils.toastShort

open class P2PCallFragmentActivity : CommonCallActivity() {
    private val tag = "P2PCallFragmentActivity"

    private val bridge: FragmentActionBridge = object : FragmentActionBridge {
        override val callParam: CallParam
            get() = this@P2PCallFragmentActivity.callParam
        override val uiConfig: P2PUIConfig?
            get() = this@P2PCallFragmentActivity.uiConfig
        override val callEngine: NECallEngine
            get() = this@P2PCallFragmentActivity.callEngine
        override val isLocalMuteAudio: Boolean
            get() = this@P2PCallFragmentActivity.isLocalMuteAudio
        override val isRemoteMuteVideo: Boolean
            get() = this@P2PCallFragmentActivity.isRemoteMuteVideo
        override val isLocalMuteVideo: Boolean
            get() = this@P2PCallFragmentActivity.isLocalMuteVideo
        override val isLocalMuteSpeaker: Boolean
            get() = this@P2PCallFragmentActivity.isLocalMuteSpeaker
        override val isLocalSmallVideo: Boolean
            get() = this@P2PCallFragmentActivity.isLocalSmallVideo
        override val isVirtualBlur: Boolean
            get() = this@P2PCallFragmentActivity.isVirtualBlur

        override fun isSpeakerOn(): Boolean = this@P2PCallFragmentActivity.isSpeakerOn()

        override fun doConfigSpeaker(on: Boolean) = this@P2PCallFragmentActivity.doConfigSpeaker(on)

        override fun doMuteAudio(mute: Boolean) = this@P2PCallFragmentActivity.doMuteAudio(mute)

        override fun doMuteVideo(mute: Boolean) = this@P2PCallFragmentActivity.doMuteVideo(mute)

        override fun doVirtualBlur(enable: Boolean) =
            this@P2PCallFragmentActivity.doVirtualBlur(enable)

        override fun doSwitchCamera() = this@P2PCallFragmentActivity.doSwitchCamera()

        override fun configTimeTick(config: CallUIOperationsMgr.TimeTickConfig?) =
            this@P2PCallFragmentActivity.configTimeTick(config)

        override fun doCall(observer: NEResultObserver<CommonResult<NECallInfo>>?) =
            this@P2PCallFragmentActivity.doCall(observer)

        override fun doAccept(observer: NEResultObserver<CommonResult<NECallInfo>>?) =
            this@P2PCallFragmentActivity.doAccept(observer)

        override fun doHangup(
            observer: NEResultObserver<CommonResult<Void>>?,
            channelId: String?,
            extraInfo: String?
        ) {
            this@P2PCallFragmentActivity.doHangup(observer, channelId, extraInfo)
            finish()
        }

        override fun doSwitchCallType(
            callType: Int, switchCallState: Int, observer: NEResultObserver<CommonResult<Void>>?
        ) = this@P2PCallFragmentActivity.doSwitchCallType(callType, switchCallState, observer)

        override fun setupLocalView(view: NERtcVideoView?, action: ((NERtcVideoView?) -> Unit)?) {
            this@P2PCallFragmentActivity.setupLocalView(view, action)
        }

        override fun setupRemoteView(view: NERtcVideoView?, action: ((NERtcVideoView?) -> Unit)?) {
            this@P2PCallFragmentActivity.setupRemoteView(view, action)
        }

        override fun currentCallState(): Int = this@P2PCallFragmentActivity.currentCallState()

        override fun showPermissionDialog(clickListener: View.OnClickListener) =
            this@P2PCallFragmentActivity.showPermissionDialog(clickListener)

        override fun showFloatingWindow() = this@P2PCallFragmentActivity.doShowFloatingWindow()

        override fun startVideoPreview() = this@P2PCallFragmentActivity.startVideoPreview()

        override fun stopVideoPreview() = this@P2PCallFragmentActivity.stopVideoPreview()
    }

    private var currentFragment: BaseP2pCallFragment? = null

    private val videoCallerFragment = VideoCallerFragment()
    private val videoCalleeFragment = VideoCalleeFragment()
    private val videoOnTheCallFragment = VideoOnTheCallFragment()

    private val audioCallerFragment = AudioCallerFragment()
    private val audioCalleeFragment = AudioCalleeFragment()
    private val audioOnTheCallFragment = AudioOnTheCallFragment()

    override fun onCallEnd(info: NECallEndInfo) {
        when (info.reasonCode) {
            NEHangupReasonCode.CALLER_REJECTED -> if (!isFinishing && !callParam.isCalled) {
                getString(R.string.tip_reject_by_other).toastShort(this@P2PCallFragmentActivity)
            }

            NEHangupReasonCode.BUSY -> if (!isFinishing && !callParam.isCalled) {
                getString(R.string.tip_busy_by_other).toastShort(this@P2PCallFragmentActivity)
            }

            NEHangupReasonCode.CALLEE_CANCELED -> if (!isFinishing && callParam.isCalled) {
                getString(R.string.tip_cancel_by_other).toastShort(this@P2PCallFragmentActivity)
            }

            NEHangupReasonCode.TIME_OUT ->
                if (!callParam.isCalled) {
                    getString(R.string.tip_timeout_by_other).toastShort(
                        this@P2PCallFragmentActivity
                    )
                }

            NEHangupReasonCode.OTHER_REJECTED -> getString(R.string.tip_other_client_other_reject).toastShort(
                this@P2PCallFragmentActivity
            )

            NEHangupReasonCode.OTHER_ACCEPTED -> getString(R.string.tip_other_client_other_accept).toastShort(
                this@P2PCallFragmentActivity
            )
        }
        currentFragment?.onCallEnd(info)
        releaseAndFinish(false)
    }

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {
        if (isFinishing) {
            return
        }
        when (info.state) {
            SwitchCallState.ACCEPT -> {
                val tempFragment = currentFragment
                changeCurrentFragment()
                if (tempFragment != currentFragment) {
                    currentFragment?.toUpdateUIState(CHANGE_CALL_TYPE)
                }
            }

            SwitchCallState.INVITE -> {
                showSwitchCallTypeConfirmDialog(info.callType)
            }

            SwitchCallState.REJECT -> {
                getString(R.string.ui_switch_call_type_reject_tip).toastShort(
                    this@P2PCallFragmentActivity
                )
            }
        }
        currentFragment?.onCallTypeChange(info)
    }

    override fun onCallConnected(info: NECallInfo) {
        if (isFinishing) {
            return
        }
        changeCurrentFragment()
        currentFragment?.onCallConnected(info)
    }

    override fun onVideoAvailable(userId: String?, available: Boolean) {
        if (isFinishing) {
            return
        }
        currentFragment?.onVideoAvailable(userId, available)
    }

    override fun onVideoMuted(userId: String?, mute: Boolean) {
        if (isFinishing) {
            return
        }
        currentFragment?.onVideoMuted(userId, mute)
    }

    override fun onAudioMuted(userId: String?, mute: Boolean) {
        if (isFinishing) {
            return
        }
        currentFragment?.onAudioMuted(userId, mute)
    }

    override fun provideLayoutId(): Int = R.layout.activity_p2p_call_fragment

    override fun doOnCreate(savedInstanceState: Bundle?) {
        super.doOnCreate(savedInstanceState)
        changeCurrentFragment()
    }

    override fun onBackPressed() {
        showExitDialog()
    }

    private fun showExitDialog() {
        val confirmDialog = AlertDialog.Builder(this)
        confirmDialog.setTitle(R.string.tip_dialog_finish_call_title)
        confirmDialog.setMessage(R.string.tip_dialog_finish_call_content)
        confirmDialog.setPositiveButton(
            R.string.tip_dialog_finish_call_positive
        ) { _: DialogInterface?, _: Int ->
            releaseAndFinish(true)
        }
        confirmDialog.setNegativeButton(
            R.string.tip_dialog_finish_call_negative
        ) { _: DialogInterface?, _: Int -> }
        confirmDialog.show()
    }

    protected open fun changeCurrentFragment(
        callState: Int = currentCallState(),
        callType: Int = callParam.callType
    ) {
        val fragment = getFragment(callState, callType)
        if (fragment == null) {
            ALog.e(tag, "currentFragment is null, callState is $callState, callType is $callType.")
            finish()
            return
        }
        fragment.configData(
            bridge,
            if (isFromFloatingWindow) {
                FROM_FLOATING_WINDOW
            } else {
                INIT
            }
        )
        if (fragment != currentFragment) {
            val tag = "${getFragmentKey(callState, callType)}"
            val transaction = supportFragmentManager.beginTransaction()
            if (supportFragmentManager.findFragmentByTag(tag) == fragment) {
                transaction.show(fragment)
            } else {
                transaction.add(R.id.clRoot, fragment, tag)
            }
            currentFragment?.run {
                transaction.hide(this)
            }
            transaction.commitAllowingStateLoss()
        }
        currentFragment = fragment
    }

    protected open fun getFragment(callState: Int, callType: Int): BaseP2pCallFragment? {
        val key = getFragmentKey(callState, callType) ?: return null
        return uiConfig?.customCallFragmentMap?.get(key) ?: when (key) {
            VIDEO_CALLEE -> videoCalleeFragment
            VIDEO_CALLER -> videoCallerFragment
            VIDEO_ON_THE_CALL -> videoOnTheCallFragment
            AUDIO_CALLEE -> audioCalleeFragment
            AUDIO_CALLER -> audioCallerFragment
            AUDIO_ON_THE_CALL -> audioOnTheCallFragment
            else -> null
        }
    }

    protected open fun getFragmentKey(callState: Int, callType: Int): Int? {
        return when (callState) {
            STATE_CALL_OUT, STATE_IDLE -> if (callType == NECallType.VIDEO) VIDEO_CALLER else AUDIO_CALLER
            STATE_INVITED -> if (callType == NECallType.VIDEO) VIDEO_CALLEE else AUDIO_CALLEE
            STATE_DIALOG -> if (callType == NECallType.VIDEO) VIDEO_ON_THE_CALL else AUDIO_ON_THE_CALL
            else -> null
        }
    }
}
