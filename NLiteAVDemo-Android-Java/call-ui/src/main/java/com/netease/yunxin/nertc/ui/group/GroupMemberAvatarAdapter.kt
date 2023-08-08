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
import android.widget.ImageView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.utils.dip2Px
import com.netease.yunxin.nertc.ui.utils.image.RoundedCornersCenterCrop

class GroupMemberAvatarAdapter(private val context: Context) :
    RecyclerView.Adapter<GroupMemberAvatarAdapter.ViewHolder>() {
    private val userModelList: MutableList<GroupMemberInfo?> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            LayoutInflater.from(
                context
            ).inflate(layoutId, parent, false)
        )
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val model: GroupMemberInfo = getItem(position) ?: return
        Glide.with(context).load(model.avatarUrl).apply(
            RequestOptions.bitmapTransform(
                RoundedCornersCenterCrop(
                    4.dip2Px(
                        context
                    )
                )
            )
        ).into(holder.ivUser)
    }

    fun addAll(dataList: List<GroupMemberInfo?>?) {
        if (dataList == null || dataList.isEmpty()) {
            return
        }
        userModelList.addAll(dataList)
        notifyItemRangeChanged(0, userModelList.size)
    }

    private fun getItem(position: Int): GroupMemberInfo? {
        return if (position >= userModelList.size || position < 0) {
            null
        } else {
            userModelList[position]
        }
    }

    override fun getItemCount(): Int {
        return userModelList.size
    }

    // 创建ViewHolder
    class ViewHolder(v: View) : RecyclerView.ViewHolder(v) {
        var ivUser: ImageView = v.findViewById(R.id.iv_user)
    }

    private val layoutId: Int = R.layout.view_item_group_member_avatart_layout
}
