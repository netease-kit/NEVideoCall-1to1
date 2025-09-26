/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.group

import android.content.Context
import android.view.ViewGroup
import com.netease.yunxin.nertc.ui.utils.CallUILog
import com.netease.yunxin.nertc.ui.view.GroupCallGridLayout

class GroupMemberGridAdapter(private val context: Context) {

    companion object {
        const val TAG = "GroupMemberGridAdapter"
    }

    private val userList = mutableListOf<GroupMemberInfo>()
    private val videoViewPool = GroupVideoViewPool()
    private val itemViews = mutableListOf<GroupMemberItemView>()
    private var gridLayout: GroupCallGridLayout? = null
    private var isLayoutAnimating = false

    init {
        videoViewPool.init(context)
    }

    fun setGridLayout(gridLayout: GroupCallGridLayout) {
        this.gridLayout = gridLayout
    }

    fun setLayoutAnimating(animating: Boolean) {
        isLayoutAnimating = animating
        itemViews.forEach { itemView ->
            itemView.setLayoutAnimating(animating)
        }
    }

    fun setData(itemList: List<GroupMemberInfo>, onActionForData: (() -> Unit)? = null) {
        if (itemList.isEmpty()) {
            return
        }
        CallUILog.i(TAG, "setData newData is $itemList")
        onActionForData?.invoke()

        // 清除旧的视图
        clearViews()

        // 更新数据
        userList.clear()
        userList.addAll(itemList)

        // 创建新的视图
        createViews()
    }

    private fun clearViews() {
        itemViews.forEach { view ->
            gridLayout?.removeView(view)
        }
        itemViews.clear()
    }

    private fun createViews() {
        userList.forEach { data ->
            val itemView = GroupMemberItemView(context)
            itemView.layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            itemView.refreshData(data, videoViewPool)
            itemViews.add(itemView)
            gridLayout?.addView(itemView)
        }
    }

    fun updateState(uid: Long, enableVideo: Boolean? = null, enableAudio: Boolean? = null) {
        val index = findPosition(uid)
        if (index < 0) {
            return
        }
        val item = userList[index]
        enableVideo?.let { item.enableVideo = it }
        enableAudio?.let { item.enableAudio = it }
        if (index < itemViews.size) {
            // 立即更新，延迟逻辑在GroupMemberItemView中处理
            itemViews[index].refreshData(item, videoViewPool)
        }
    }

    fun updateCallerUid(accId: String, uid: Long) {
        val index = findPosition(accId)
        if (index < 0) {
            return
        }
        userList[index].uid = uid
        if (index < itemViews.size) {
            itemViews[index].refreshData(userList[index], videoViewPool)
        }
    }

    fun release() {
        clearViews()
        videoViewPool.release()
    }

    private fun findPosition(accId: String): Int {
        var result = -1
        for (index in userList.indices) {
            if (userList[index].accId == accId) {
                result = index
                break
            }
        }
        return result
    }

    private fun findPosition(uid: Long): Int {
        var result = -1
        for (index in userList.indices) {
            if (userList[index].uid == uid) {
                result = index
                break
            }
        }
        return result
    }
}
