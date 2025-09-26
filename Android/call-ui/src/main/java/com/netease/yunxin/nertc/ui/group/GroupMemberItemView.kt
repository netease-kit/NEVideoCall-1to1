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
import com.netease.nimlib.sdk.NIMClient
import com.netease.yunxin.kit.call.group.NEGroupConstants
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.utils.CallUILog
import com.netease.yunxin.nertc.ui.utils.dip2Px
import com.netease.yunxin.nertc.ui.utils.image.RoundedCornersCenterCrop

class GroupMemberItemView(context: Context) : FrameLayout(context) {
    companion object {
        const val TAG = "GroupMemberItemView"
    }

    private lateinit var ivUserAvatar: ImageView
    private lateinit var userVideoViewGroup: ViewGroup
    private lateinit var tvUserName: TextView
    private lateinit var focusFlag: View
    private lateinit var tipToAccept: View
    private var isLayoutAnimating = false

    init {
        initUI()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        // 强制保持正方形
        val size = minOf(
            View.MeasureSpec.getSize(widthMeasureSpec),
            View.MeasureSpec.getSize(heightMeasureSpec)
        )
        val squareMeasureSpec = View.MeasureSpec.makeMeasureSpec(size, View.MeasureSpec.EXACTLY)

        // 测量所有子View
        for (i in 0 until childCount) {
            val child = getChildAt(i)
            child.measure(squareMeasureSpec, squareMeasureSpec)
        }

        setMeasuredDimension(size, size)
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        val size = minOf(right - left, bottom - top)

        // 布局所有子View为正方形
        for (i in 0 until childCount) {
            val child = getChildAt(i)
            child.layout(0, 0, size, size)
        }

        // 动态设置头像大小为父容器的一半且为正方形
        updateAvatarSize(size)
    }

    private fun updateAvatarSize(containerSize: Int) {
        // 设置头像大小为父容器的一半且为正方形
        val avatarSize = containerSize / 2
        val layoutParams = ivUserAvatar.layoutParams as androidx.constraintlayout.widget.ConstraintLayout.LayoutParams
        layoutParams.width = avatarSize
        layoutParams.height = avatarSize
        ivUserAvatar.layoutParams = layoutParams
    }

    private fun initUI() {
        LayoutInflater.from(context)
            .inflate(R.layout.view_group_member_item, this, false)
            .run {
                addView(this, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
            }

        ivUserAvatar = findViewById(R.id.ivUserAvatar)
        userVideoViewGroup = findViewById(R.id.userVideoView)
        tvUserName = findViewById(R.id.tvUserName)
        focusFlag = findViewById(R.id.focusFlag)
        tipToAccept = findViewById(R.id.tvTipToAccept)
    }

    fun refreshData(data: GroupMemberInfo, videoViewPool: GroupVideoViewPool) {
        CallUILog.i(TAG, "refreshData - $data")

        if (data.state == NEGroupConstants.UserState.LEAVING) {
            visibility = View.GONE
            return
        }

        visibility = View.VISIBLE

        Glide.with(context)
            .asBitmap()
            .load(data.avatarUrl)
            .error(R.drawable.t_avchat_avatar_default) // 加载失败时显示的图片
            .transform(RoundedCornersCenterCrop(4.dip2Px(context)))
            .into(ivUserAvatar)
        tvUserName.text = data.name
        tipToAccept.visibility = View.GONE
        focusFlag.visibility = if (data.focus) View.VISIBLE else View.GONE

        // 根据布局动画状态决定是否延迟更新视频视图
        if (isLayoutAnimating) {
            // 如果正在布局动画中，延迟更新视频视图
            postDelayed({
                updateVideoView(data, videoViewPool)
            }, 600) // 延迟600ms，让布局动画进行更长时间
        } else {
            // 没有布局动画，立即更新
            updateVideoView(data, videoViewPool)
        }
    }

    fun setLayoutAnimating(animating: Boolean) {
        isLayoutAnimating = animating
    }

    private fun updateVideoView(data: GroupMemberInfo, videoViewPool: GroupVideoViewPool) {
        if (data.accId == NIMClient.getCurrentAccount()) {
            if (data.enableVideo) {
                // 先清理旧的视频视图
                userVideoViewGroup.removeAllViews()
                userVideoViewGroup.visibility = View.VISIBLE

                // 添加视频视图
                videoViewPool.obtainRtcVideo(data.uid, true).run {
                    // 确保视频视图也是正方形
                    layoutParams = ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                    userVideoViewGroup.addView(this)
                }
                ivUserAvatar.visibility = View.GONE
            } else {
                userVideoViewGroup.visibility = View.GONE
                userVideoViewGroup.removeAllViews()
                ivUserAvatar.visibility = View.VISIBLE
                videoViewPool.recycleRtcVideo(data.uid)
            }
        } else {
            if (data.state == NEGroupConstants.UserState.WAITING) {
                tipToAccept.visibility = View.VISIBLE
                return
            }
            if (data.enableVideo && data.uid > 0) {
                // 先清理旧的视频视图
                userVideoViewGroup.removeAllViews()
                userVideoViewGroup.visibility = View.VISIBLE

                // 添加视频视图
                videoViewPool.obtainRtcVideo(data.uid, false).run {
                    // 确保视频视图也是正方形
                    layoutParams = ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                    userVideoViewGroup.addView(this)
                }
                ivUserAvatar.visibility = View.GONE
            } else {
                userVideoViewGroup.visibility = View.GONE
                userVideoViewGroup.removeAllViews()
                ivUserAvatar.visibility = View.VISIBLE
                videoViewPool.recycleRtcVideo(data.uid)
            }
        }

        // 强制重新测量和布局，确保保持正方形
        requestLayout()
    }
}
