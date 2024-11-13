/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.group

import android.Manifest
import android.content.DialogInterface
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.group.GroupCallMember
import com.netease.yunxin.kit.call.group.GroupHelperUtils
import com.netease.yunxin.kit.call.group.NEGroupCall
import com.netease.yunxin.kit.call.group.NEGroupConstants
import com.netease.yunxin.kit.call.group.param.GroupAcceptParam
import com.netease.yunxin.kit.call.group.param.GroupCallParam
import com.netease.yunxin.kit.call.group.param.GroupHangupParam
import com.netease.yunxin.kit.call.group.param.GroupInviteParam
import com.netease.yunxin.kit.call.group.param.GroupJoinParam
import com.netease.yunxin.kit.call.group.result.GroupCallResult
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CommonGroupCallActivity
import com.netease.yunxin.nertc.ui.service.UIServiceManager
import com.netease.yunxin.nertc.ui.utils.SecondsTimer
import com.netease.yunxin.nertc.ui.utils.dip2Px
import com.netease.yunxin.nertc.ui.utils.formatSecondTime
import com.netease.yunxin.nertc.ui.utils.image.BlurCenterCorp
import com.netease.yunxin.nertc.ui.utils.image.RoundedCornersCenterCrop
import com.netease.yunxin.nertc.ui.utils.requestPermission
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

open class GroupCallActivity : CommonGroupCallActivity() {
    private val tag = "GroupCallActivity"

    protected val timer = SecondsTimer()
    protected var tvCountDown: TextView? = null
    protected var isMuteAudio = false
    protected var isMuteVideo = true
    protected var enableVideo = false

    private val videoEnableList = mutableListOf<Long>()

    private val userInfoFetcher = GroupUserInfoFetcher()

    override fun onMemberChanged(callId: String, userList: MutableList<GroupCallMember>) {
        super.onMemberChanged(callId, userList)
        if (isFinishing) {
            return
        }
        if (userList.isEmpty()) {
            return
        }
        ALog.d(tag, "onMemberChanged, callId is $callId, userList is $userList.")
        userList.forEach {
            if (currentUserAccId == it.accId) {
                return@forEach
            }
            when (it.action) {
                NEGroupConstants.UserAction.REJECT -> {
                    Toast.makeText(
                        this@GroupCallActivity,
                        when (it.reason) {
                            NEGroupConstants.HangupReason.BUSY -> R.string.tip_busy_by_other
                            NEGroupConstants.HangupReason.TIMEOUT -> R.string.tip_timeout_by_other
                            else -> R.string.tip_reject_by_other
                        },
                        Toast.LENGTH_SHORT
                    ).show()
                }
                NEGroupConstants.UserAction.LEAVE -> {
                    Toast.makeText(
                        this@GroupCallActivity,
                        when (it.reason) {
                            NEGroupConstants.HangupReason.BUSY -> R.string.tip_busy_by_other
                            NEGroupConstants.HangupReason.TIMEOUT -> R.string.tip_timeout_by_other
                            else -> R.string.tip_hangup_by_other
                        },
                        Toast.LENGTH_SHORT
                    ).show()
                }
                NEGroupConstants.UserAction.ACCEPT -> {
                    Toast.makeText(
                        this@GroupCallActivity,
                        R.string.tip_accept_by_other,
                        Toast.LENGTH_SHORT
                    ).show()
                }
                NEGroupConstants.UserAction.JOIN -> {
                    Toast.makeText(
                        this@GroupCallActivity,
                        R.string.tip_join_by_other,
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }
        }
    }

    override fun onMemberChangedForAll(callId: String, userList: List<GroupCallMember>) {
        if (isFinishing) {
            return
        }
        if (callInfo?.callId != callId) {
            return
        }
        if (userList.isEmpty()) {
            return
        }
        val resultList = userList.filter {
            val result = it.state != NEGroupConstants.UserState.LEAVING
            if (!result) {
                userInfoFetcher.reset(it.accId)
            }
            result
        }
        callInfo?.memberList = resultList
        userInfoFetcher.getUserInfoList(
            resultList.map { it.accId },
            NEResultObserver getUserInfoList@{ result: List<GroupMemberInfo>? ->
                if (result == null || result.isEmpty()) {
                    return@getUserInfoList
                }
                pageAdapter?.setData(result) {
                    result.forEach {
                        val index = resultList.indexOf(GroupCallMember(it.accId))
                        if (index >= 0) {
                            it.uid = resultList[index].uid
                            it.state = resultList[index].state
                        }
                    }
                }
            }
        )
    }

    override fun onJoinChannel(result: Int, channelId: Long, time: Long, uid: Long) {
        if (isFinishing) {
            return
        }
        tvCountDown?.run {
            visibility = View.VISIBLE
            timer.start {
                runOnUiThread {
                    text = it.formatSecondTime()
                }
            }
        }
    }

    override fun onUserVideoStart(uid: Long, maxProfile: Int) {
        if (isFinishing) {
            return
        }
        videoEnableList.add(uid)
        CoroutineScope(Dispatchers.Main).launch {
            pageAdapter?.updateState(uid, enableVideo = true)
        }
    }

    override fun onUserVideoMute(uid: Long, mute: Boolean) {
        if (isFinishing) {
            return
        }
        pageAdapter?.updateState(uid, enableVideo = !mute)
    }

    override fun onVideoDeviceStageChange(deviceState: Int) {
        if (isFinishing) {
            return
        }
        when (deviceState) {
            NERtcConstants.VideoDeviceState.FREEZED, NERtcConstants.VideoDeviceState.DISCONNECTED -> {
                NERtcEx.getInstance().enableLocalVideo(false)
                if (!isMuteVideo) {
                    NERtcEx.getInstance().enableLocalVideo(true)
                } else {
                    enableVideo = false
                }
            }
        }
    }

    private var pageAdapter: GroupMemberPageAdapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        this.requestPermission(
            {},
            { _: List<String>?, _: List<String>? ->
                Toast.makeText(
                    applicationContext,
                    R.string.ui_dialog_permission_content,
                    Toast.LENGTH_SHORT
                ).show()
            },
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO
        )
    }

    override fun doOnCreate() {
        super.doOnCreate()
        // ui 初始化
        tvCountDown = findViewById(R.id.tvCountdown)
        if (callInfo != null) {
            initCalleeUI()
        } else if (callParam != null) { // 发起呼叫
            val list = mutableListOf<String>().apply {
                add(CallKitUI.currentUserAccId!!)
                callParam?.calleeList?.let {
                    addAll(it)
                }
            }
            callInfo = GroupHelperUtils.generateGroupCallInfo(
                CallKitUI.currentUserAccId,
                CallKitUI.currentUserRtcUid,
                callParam,
                null
            )
            initOnTheCallUI(list)
            doCall(callParam!!)
        } else if (!TextUtils.isEmpty(callId)) {
            NEGroupCall.instance()
                .groupJoin(
                    GroupJoinParam(callId)
                ) {
                    if (!it.isSuccessful || it.groupCallInfo == null) {
                        Toast.makeText(
                            applicationContext,
                            R.string.tip_join_failed,
                            Toast.LENGTH_SHORT
                        ).show()
                        ALog.w(tag, "result is error $it.")
                        finish()
                        return@groupJoin
                    }
                    callInfo = it.groupCallInfo
                    val list = mutableListOf<String>().apply {
                        callInfo?.memberList?.forEach { item ->
                            add(item.accId)
                        }
                    }
                    initOnTheCallUI(list)
                }
        }
    }

    override fun provideLayoutId(): Int = R.layout.activity_group_call_layout

    /**
     * 初始化通话中页面
     */
    private fun initOnTheCallUI(userList: List<String>) {
        val switchCamera = findViewById<View>(R.id.ivSwitchCamera)
        switchCamera.setOnClickListener {
            NERtcEx.getInstance().switchCamera()
        }
        val muteAudio = findViewById<ImageView>(R.id.ivMuteAudio)
        muteAudio.setImageResource(if (isMuteAudio) R.drawable.voice_off else R.drawable.voice_on)
        NERtcEx.getInstance().muteLocalAudioStream(isMuteAudio)

        muteAudio.setOnClickListener {
            isMuteAudio = !isMuteAudio
            muteAudio.setImageResource(
                if (isMuteAudio) R.drawable.voice_off else R.drawable.voice_on
            )
            NERtcEx.getInstance().muteLocalAudioStream(isMuteAudio)
        }
        NERtcEx.getInstance().enableLocalVideo(false)
        val muteVideo = findViewById<ImageView>(R.id.ivMuteVideo)
        muteVideo.setImageResource(if (isMuteVideo) R.drawable.cam_off else R.drawable.cam_on)
        NERtcEx.getInstance().muteLocalVideoStream(isMuteVideo)

        muteVideo.setOnClickListener {
            isMuteVideo = !isMuteVideo
            if (!enableVideo && !isMuteVideo) {
                enableVideo = true
                NERtcEx.getInstance().enableLocalVideo(true)
            }
            muteVideo.setImageResource(if (isMuteVideo) R.drawable.cam_off else R.drawable.cam_on)
            NERtcEx.getInstance().muteLocalVideoStream(isMuteVideo)
            pageAdapter?.updateState(
                callInfo?.getRtcUidByAccId(currentUserAccId) ?: 0,
                enableVideo = !isMuteVideo
            )
        }
        val hangup = findViewById<View>(R.id.ivHangUp)
        hangup.setOnClickListener {
            hangup.isEnabled = false
            callInfo?.run {
                NEGroupCall.instance().groupHangup(GroupHangupParam(callId), null)
            }
            callInfo = null
            finish()
        }
        val inviteUsers = findViewById<View>(R.id.ivInviteUsers)
        if (UIServiceManager.getInstance().uiService == null) {
            inviteUsers.visibility = View.GONE
        } else {
            inviteUsers.visibility = View.VISIBLE
            inviteUsers.setOnClickListener { _ ->
                UIServiceManager
                    .getInstance()
                    .uiService?.startContactSelector(
                    this,
                    callInfo!!.groupId,
                    callInfo!!.memberList?.map { it.accId }
                ) { it ->
                    it ?: return@startContactSelector
                    val inviteParam = GroupInviteParam(callInfo!!.callId, it)
                    NEGroupCall.instance().groupInvite(inviteParam) { result ->
                        ALog.d(tag, "invite result is $result.")
                    }
                }
            }
        }

        val vpMemberOnTheCall = findViewById<ViewPager2>(R.id.vpMemberList)
        pageAdapter = GroupMemberPageAdapter(this)
        pageAdapter?.wrapViewpager(vpMemberOnTheCall)
        // 数据获取并刷新 UI
        userInfoFetcher.getUserInfoList(
            userList,
            NEResultObserver getUserInfoList@{ result: List<GroupMemberInfo>? ->
                if (result == null || result.isEmpty()) {
                    return@getUserInfoList
                }
                val totalUserList = callInfo!!.memberList
                pageAdapter?.setData(result) {
                    result.map {
                        val index = totalUserList.indexOf(GroupCallMember(it.accId))
                        if (index >= 0) {
                            it.uid = totalUserList[index].uid
                            it.state = totalUserList[index].state
                        }
                    }
                }
            }
        )
    }

    /**
     * 初始化被叫页面
     */
    private fun initCalleeUI() {
        val calleeLayout = findViewById<View>(R.id.viewCalleeLayout)
        calleeLayout.visibility = View.VISIBLE
        val ivCallerAvatar = findViewById<ImageView>(R.id.ivUserAvatar)
        val ivCallerAvatarBlur = findViewById<ImageView>(R.id.ivUserAvatarBlur)
        val tvCallerName = findViewById<TextView>(R.id.tvUserName)
        userInfoFetcher.getUserInfo(
            callInfo!!.callerInfo.accId,
            NEResultObserver getUserInfo@{ result: GroupMemberInfo? ->
                if (result == null) {
                    return@getUserInfo
                }
                val thumbSize = resources.getDimension(R.dimen.avatar_max_size).toInt()
                tvCallerName.text = result.name
                Glide.with(applicationContext).asBitmap().load(result.avatarUrl)
                    .transform(RoundedCornersCenterCrop(4.dip2Px(applicationContext))).apply(
                        RequestOptions().placeholder(R.drawable.t_avchat_avatar_default)
                            .error(R.drawable.t_avchat_avatar_default)
                            .override(thumbSize, thumbSize)
                    ).into(ivCallerAvatar)
                Glide.with(applicationContext).asBitmap().load(result.avatarUrl)
                    .transform(BlurCenterCorp(51, 3))
                    .error(R.drawable.shape_group_caller_error_bg)
                    .into(ivCallerAvatarBlur)
            }
        )
        val tvMemberCount = findViewById<TextView>(R.id.tvOtherCount)
        val rvMemberAvatar = findViewById<RecyclerView>(R.id.rvUserAvatar)
        val calleeSize = callInfo!!.userListWithoutCaller.size - 1
        if (calleeSize <= 0) {
            tvMemberCount.visibility = View.GONE
            rvMemberAvatar.visibility = View.GONE
        } else {
            tvMemberCount.visibility = View.VISIBLE
            tvMemberCount.text =
                getString(R.string.user_join_group_call_with_user_count, calleeSize)
            rvMemberAvatar.visibility = View.VISIBLE
            val adapter = GroupMemberAvatarAdapter(this)
            rvMemberAvatar.adapter = adapter
            rvMemberAvatar.layoutManager = GridLayoutManager(
                applicationContext,
                7
            )
            val userAccIdList: MutableList<String> = ArrayList()
            if (callInfo!!.userListWithoutCaller != null) {
                for (item in callInfo!!.userListWithoutCaller) {
                    if (item == null) {
                        continue
                    }
                    if (TextUtils.equals(item.accId, currentUserAccId)) {
                        continue
                    }
                    userAccIdList.add(item.accId)
                }
            }
            userInfoFetcher.getUserInfoList(
                userAccIdList,
                NEResultObserver getUserInfoList@{ result: List<GroupMemberInfo?>? ->
                    if (result == null || result.isEmpty()) {
                        return@getUserInfoList
                    }
                    adapter.addAll(result)
                }
            )
        }
        val accept = findViewById<View>(R.id.ivAccept)
        val reject = findViewById<View>(R.id.ivReject)
        reject.setOnClickListener {
            reject.isEnabled = false
            accept.isEnabled = false
            callInfo?.run {
                NEGroupCall.instance().groupHangup(GroupHangupParam(callId), null)
            }
            callInfo = null
            finish()
        }

        accept.setOnClickListener {
            accept.isEnabled = false
            reject.isEnabled = false
            callInfo?.run {
                NEGroupCall.instance().groupAccept(
                    GroupAcceptParam(
                        callId
                    )
                ) {
                    if (!it.isSuccessful || it.groupCallInfo == null) {
                        ALog.w(tag, "result is error $it.")
                        Toast.makeText(
                            applicationContext,
                            R.string.tip_accept_failed,
                            Toast.LENGTH_SHORT
                        ).show()
                        finish()
                        return@groupAccept
                    }
                    update(it.groupCallInfo)
                    val list = mutableListOf<String>().apply {
                        memberList.forEach { item ->
                            add(item.accId)
                        }
                    }
                    initOnTheCallUI(list)
                    calleeLayout.visibility = View.GONE
                }
            } ?: run {
                ALog.e(tag, "callInfo is null. accept failed.")
            }
        }
    }

    private fun doCall(param: GroupCallParam) {
        val muteVideo = findViewById<ImageView>(R.id.ivMuteVideo)
        muteVideo.isEnabled = false
        NEGroupCall.instance().groupCall(param) { result: GroupCallResult ->
            if (!result.isSuccessful) {
                Toast.makeText(
                    applicationContext,
                    R.string.tip_start_call_failed,
                    Toast.LENGTH_SHORT
                ).show()
                finish()
                return@groupCall
            }
            callInfo = GroupHelperUtils.generateGroupCallInfo(
                CallKitUI.currentUserAccId,
                CallKitUI.currentUserRtcUid,
                param,
                result
            ).apply {
                pageAdapter?.updateCallerUid(callerAccId, result.callerUid)
                muteVideo.isEnabled = true
            }
        }
    }

    override fun onBackPressed() {
        showExitDialog()
    }

    override fun onPause() {
        super.onPause()
        if (isFinishing) {
            timer.cancel()
            for (item in videoEnableList) {
                NERtcEx.getInstance().setupRemoteVideoCanvas(null, item)
            }
            NERtcEx.getInstance().setupLocalVideoCanvas(null)
            videoEnableList.clear()
            pageAdapter?.release()
            pageAdapter = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        pageAdapter?.release()
    }

    private fun showExitDialog() {
        val confirmDialog = AlertDialog.Builder(this)
        confirmDialog.setTitle(R.string.tip_dialog_finish_call_title)
        confirmDialog.setMessage(R.string.tip_dialog_finish_call_content)
        confirmDialog.setPositiveButton(
            R.string.tip_dialog_finish_call_positive
        ) { _: DialogInterface?, _: Int ->
            finish()
        }
        confirmDialog.setNegativeButton(
            R.string.tip_dialog_finish_call_negative
        ) { _: DialogInterface?, _: Int -> }
        confirmDialog.show()
    }
}
