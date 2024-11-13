/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.group

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.bumptech.glide.Glide
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.group.NEGroupConstants
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.utils.dip2Px
import com.netease.yunxin.nertc.ui.utils.image.RoundedCornersCenterCrop

class GroupMemberPageView(context: Context) : FrameLayout(context) {

    private val viewList = mutableListOf<ItemView>()

    init {
        initUI()
    }

    private fun initUI() {
        LayoutInflater.from(context)
            .inflate(R.layout.view_group_member_page, this, false)
            .run {
                addView(this, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
            }

        viewList.add(ItemView(findViewById(R.id.item1)))
        viewList.add(ItemView(findViewById(R.id.item2)))
        viewList.add(ItemView(findViewById(R.id.item3)))
        viewList.add(ItemView(findViewById(R.id.item4)))
    }

    fun refreshData(
        userList: List<GroupMemberInfo>,
        videoViewPool: GroupVideoViewPool,
        isShowing: Boolean
    ) {
        viewList.forEach {
            it.itemView.visibility = View.GONE
        }
        for (index in userList.indices) {
            val data = userList[index]
            val holder = viewList[index]
            if (!isShowing) {
                videoViewPool.recycleRtcVideo(data.uid)
                continue
            }
            ALog.d("GroupMemberPageView", "current item position is $index, data is $data.")
            if (data.state == NEGroupConstants.UserState.LEAVING) {
                continue
            }

            ALog.d("GroupMemberPageView", "onBindViewHolder - $data position is $index")
            holder.itemView.visibility = View.VISIBLE
            Glide.with(context).asBitmap().load(data.avatarUrl)
                .transform(RoundedCornersCenterCrop(4.dip2Px(context))).into(holder.ivUserAvatar)

            holder.tvUserName.text = data.name
            holder.tipToAccept.visibility = View.GONE
            holder.focusFlag.visibility = if (data.focus) View.VISIBLE else View.GONE
            if (data.accId == CallKitUI.currentUserAccId) {
                if (data.enableVideo) {
                    holder.userVideoViewGroup.visibility = View.VISIBLE
                    videoViewPool.obtainRtcVideo(data.uid, true).run {
                        holder.userVideoViewGroup.addView(this)
                    }
                    holder.ivUserAvatar.visibility = View.GONE
                } else {
                    holder.userVideoViewGroup.visibility = View.GONE
                    holder.ivUserAvatar.visibility = View.VISIBLE
                    videoViewPool.recycleRtcVideo(data.uid)
                }
            } else {
                if (data.state == NEGroupConstants.UserState.WAITING) {
                    holder.tipToAccept.visibility = View.VISIBLE
                    continue
                }
                if (data.enableVideo && data.uid > 0) {
                    holder.userVideoViewGroup.visibility = View.VISIBLE
                    videoViewPool.obtainRtcVideo(data.uid, false).run {
                        holder.userVideoViewGroup.addView(this)
                    }
                    holder.ivUserAvatar.visibility = View.GONE
                } else {
                    holder.userVideoViewGroup.visibility = View.GONE
                    holder.ivUserAvatar.visibility = View.VISIBLE
                    videoViewPool.recycleRtcVideo(data.uid)
                }
            }
        }
    }

    private class ItemView(val itemView: View) {
        var ivUserAvatar: ImageView = itemView.findViewById(R.id.ivUserAvatar)
        var userVideoViewGroup: ViewGroup = itemView.findViewById(R.id.userVideoView)
        var tvUserName: TextView = itemView.findViewById(R.id.tvUserName)
        var focusFlag: View = itemView.findViewById(R.id.focusFlag)
        var tipToAccept: View = itemView.findViewById(R.id.tvTipToAccept)
    }
}
