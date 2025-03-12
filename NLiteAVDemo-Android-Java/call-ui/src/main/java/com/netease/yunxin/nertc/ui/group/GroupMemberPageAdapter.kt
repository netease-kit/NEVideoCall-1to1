/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.group

import android.content.Context
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import com.netease.yunxin.kit.alog.ALog
import kotlin.math.ceil
import kotlin.math.min

class GroupMemberPageAdapter(private val context: Context) :
    RecyclerView.Adapter<GroupMemberPageAdapter.ViewHolder>() {

    private val tag = "GroupMemberPageAdapter"

    /**
     * 最大页数
     */
    private val maxPageSize = 4

    /**
     * 每页数据大小
     */
    private val pageLimit = 4

    private val userList = mutableListOf<GroupMemberInfo>()

    private val videoViewPool = GroupVideoViewPool()

    private var viewPager: ViewPager2? = null

    private var lastPageIndex = 0

    private var currentPageIndex = 0

    private val viewList = mutableListOf<GroupMemberPageView>()

    private val selectorOnPage = object : ViewPager2.OnPageChangeCallback() {
        override fun onPageSelected(position: Int) {
            currentPageIndex = position
            if (position == lastPageIndex) {
                return
            }
            getItemList(lastPageIndex)?.forEach {
                videoViewPool.recycleRtcVideo(it.uid, true)
            }
            lastPageIndex = position
            notifyItemChanged(position)
        }
    }

    init {
        videoViewPool.init(context)
    }

    fun setData(itemList: List<GroupMemberInfo>, onActionForData: (() -> Unit)? = null) {
        if (itemList.isEmpty()) {
            return
        }
        val oldData = userList.getClone()
        onActionForData?.invoke()
        val diffResult = DiffUtil.calculateDiff(DiffUtilCallback(oldData, itemList))

        userList.clear()
        userList.addAll(itemList)
        diffResult.dispatchUpdatesTo(this)
    }
    private fun List<GroupMemberInfo>.getClone(): List<GroupMemberInfo> {
        val result = mutableListOf<GroupMemberInfo>()
        for (item in this) {
            result.add(item.clone())
        }
        return result
    }

    private fun List<GroupMemberInfo>.update(
        index: Int? = null,
        item: GroupHelperMemberInfo?
    ): Int {
        item ?: return -1
        return if (index == null || index < 0 || index >= size) {
            val result = find {
                (it.uid == item.uid || it.accId == item.accId)
            } ?: return -1

            result.uid = item.uid
            item.enableAudio?.run {
                result.enableAudio = this
            }
            item.enableVideo?.run {
                result.enableVideo = this
            }
            item.focus?.run {
                result.focus = this
            }
            indexOf(result)
        } else {
            this[index].run {
                uid = item.uid
                item.enableAudio?.run {
                    enableAudio = this
                }
                item.enableVideo?.run {
                    enableVideo = this
                }
                item.focus?.run {
                    focus = this
                }
            }
            index
        }
    }

    fun updateState(
        uid: Long,
        focus: Boolean? = null,
        enableVideo: Boolean? = null
    ) {
        val index = findPosition(uid)
        if (index < 0) {
            return
        }

        getItemList(index)?.update(
            item = GroupHelperMemberInfo(
                uid = uid,
                focus = focus,
                enableVideo = enableVideo
            )
        )
        notifyItemChanged(index)
    }

    fun updateCallerUid(
        accId: String,
        uid: Long
    ) {
        val index = findPosition(accId)
        if (index < 0) {
            return
        }
        getItemList(index)?.update(
            item = GroupHelperMemberInfo(
                uid = uid,
                accId = accId

            )
        )
        notifyItemChanged(index)
    }

    fun wrapViewpager(viewPager: ViewPager2) {
        this.viewPager = viewPager
        viewPager.adapter = this
        viewPager.registerOnPageChangeCallback(selectorOnPage)
    }

    fun release() {
        videoViewPool.release()
        viewPager?.unregisterOnPageChangeCallback(selectorOnPage)
    }

    override fun getItemViewType(position: Int): Int {
        return position
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val contentView = GroupMemberPageView(context)
        contentView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        viewList.add(contentView)
        return ViewHolder(contentView)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val pageData = getItemList(position) ?: return
        ALog.d(tag, "page data is $pageData.")
        holder.pageView.refreshData(pageData, videoViewPool, position == currentPageIndex)
    }

    override fun getItemCount(): Int = userList.itemCount()

    private fun getItemList(position: Int): List<GroupMemberInfo>? =
        userList.itemListByPosition(position)

    private fun List<GroupMemberInfo>.itemCount(): Int {
        return min(maxPageSize, ceil(this.size.toDouble() / pageLimit).toInt())
    }

    private fun List<GroupMemberInfo>.itemListByPosition(position: Int): List<GroupMemberInfo>? {
        if (position < 0 || position >= maxPageSize) {
            return null
        }
        return subList(
            position * pageLimit,
            min((position + 1) * pageLimit, size)
        )
    }

    private fun findPosition(accId: String): Int {
        var result = -1
        for (position in 0 until itemCount) {
            val item = getItemList(position)?.find {
                it.accId == accId
            }
            if (item != null) {
                result = position
                break
            }
        }
        return result
    }

    private fun findPosition(uid: Long): Int {
        var result = -1
        for (position in 0 until itemCount) {
            val item = getItemList(position)?.find {
                it.uid == uid
            }
            if (item != null) {
                result = position
                break
            }
        }
        return result
    }

    private inner class DiffUtilCallback(
        val oldList: List<GroupMemberInfo>?,
        val newList: List<GroupMemberInfo>?
    ) :
        DiffUtil.Callback() {
        override fun getOldListSize(): Int = oldList?.itemCount() ?: 0

        override fun getNewListSize(): Int = newList?.itemCount() ?: 0

        override fun areItemsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean =
            oldList?.itemListByPosition(oldItemPosition) == newList?.itemListByPosition(
                newItemPosition
            )

        override fun areContentsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
            val oldItem = oldList?.itemListByPosition(oldItemPosition)
            val newItem = newList?.itemListByPosition(newItemPosition)
            if (oldItem != newItem) {
                return false
            }
            if (oldItem == null || newItem == null) {
                return true
            }
            var result = true
            for (position in oldItem.indices) {
                val oldSubItem = oldItem[position]
                val newSubItem = newItem[position]
                result =
                    (newSubItem == oldSubItem) &&
                    (newSubItem.uid == oldSubItem.uid) &&
                    (newSubItem.enableVideo == oldSubItem.enableVideo) &&
                    (newSubItem.state == oldSubItem.state) &&
                    !newSubItem.enableVideo
                if (!result) {
                    break
                }
            }
            return result
        }
    }

    // 创建ViewHolder
    class ViewHolder(val pageView: GroupMemberPageView) : RecyclerView.ViewHolder(pageView)
}
