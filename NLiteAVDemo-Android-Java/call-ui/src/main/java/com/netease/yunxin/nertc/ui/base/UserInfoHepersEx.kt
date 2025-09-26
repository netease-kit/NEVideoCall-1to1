/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

@file:JvmName("OthersExtendKt")

package com.netease.yunxin.nertc.ui.base

import android.content.Context
import android.graphics.Bitmap
import android.text.TextUtils
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.request.target.Target
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallbackWrapper
import com.netease.nimlib.sdk.nos.NosService
import com.netease.nimlib.sdk.uinfo.UserService
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo
import com.netease.nimlib.sdk.uinfo.model.UserInfo
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.utils.dip2Px
import com.netease.yunxin.nertc.ui.utils.image.BlurCenterCorp
import com.netease.yunxin.nertc.ui.utils.image.RoundedCornersCenterCrop
import java.util.*
import kotlin.math.abs

private const val SIZE = 7

private val bgRes = intArrayOf(
    R.drawable.default_avatar_bg_0,
    R.drawable.default_avatar_bg_1,
    R.drawable.default_avatar_bg_2,
    R.drawable.default_avatar_bg_3,
    R.drawable.default_avatar_bg_4,
    R.drawable.default_avatar_bg_5,
    R.drawable.default_avatar_bg_6
)

/**
 * default avatar show sub-name length
 */
private const val AVATAR_NAME_LEN = 2

/**
 * 内部缓存用户昵称信息
 */
private val nameMap = mutableMapOf<String, String?>()

/**
 * 直接展示用户头像，如果用户只有短链会自动解析长链进行展示
 */
fun String.loadAvatarByAccId(
    context: Context,
    imageView: ImageView?,
    bgView: ImageView? = null,
    txtView: TextView? = null,
    enableTextDefaultAvatar: Boolean
) {
    val applicationContext = context.applicationContext
    val defaultResId = R.drawable.t_avchat_avatar_default

    val thumbSize = applicationContext.resources.getDimension(R.dimen.avatar_max_size).toInt()

    val loadAction: (String?, Int, String) -> Unit = { url, res, name ->
        val requestBuilder = Glide.with(applicationContext).asBitmap().load(url)
            .listener(object : RequestListener<Bitmap> {
                override fun onLoadFailed(
                    e: GlideException?,
                    model: Any?,
                    target: Target<Bitmap>?,
                    isFirstResource: Boolean
                ): Boolean {
                    if (enableTextDefaultAvatar) {
                        txtView?.run {
                            visibility = View.VISIBLE
                            loadTvAvatar(this, name, avatarColor(this@loadAvatarByAccId))
                        }
                        imageView?.visibility = View.GONE
                    } else {
                        txtView?.visibility = View.GONE
                        imageView?.visibility = View.VISIBLE
                    }
                    return false
                }

                override fun onResourceReady(
                    resource: Bitmap?,
                    model: Any?,
                    target: Target<Bitmap>?,
                    dataSource: DataSource?,
                    isFirstResource: Boolean
                ): Boolean = false
            }).transform(RoundedCornersCenterCrop(4.dip2Px(context))).apply(
                RequestOptions().placeholder(res).error(res)
                    .override(thumbSize, thumbSize)
            )
        imageView?.run {
            requestBuilder.into(this)
        }
    }

    val userInfo: UserInfo? = NIMClient.getService(UserService::class.java).getUserInfo(this)
    val getLongUrlAndLoad: (String?, String) -> Unit = { url, name ->
        if (url == null) {
            loadAction(null, defaultResId, name)
        } else {
            NIMClient.getService(NosService::class.java).getOriginUrlFromShortUrl(url)
                .setCallback(object : RequestCallbackWrapper<String>() {
                    override fun onResult(code: Int, result: String?, exception: Throwable?) {
                        loadAction(result, defaultResId, name)
                        bgView?.run {
                            Glide.with(applicationContext).asBitmap().load(result)
                                .transform(BlurCenterCorp(51, 3)).into(this)
                        }
                    }
                })
        }
    }
    // 用户自定义头像
    val extension = UserInfoExtensionHelper.userInfoHelper
    if (extension?.fetchAvatar(context, this) { url, res ->
            loadAction(
                url,
                res ?: defaultResId,
                nameMap[this] ?: this@loadAvatarByAccId
            )
            bgView?.run {
                Glide.with(applicationContext).asBitmap().load(url)
                    .error(res ?: defaultResId)
                    .placeholder(res ?: defaultResId)
                    .transform(BlurCenterCorp(51, 3)).into(this)
            }
        } == true
    ) {
        return
    }
    if (userInfo?.avatar != null) {
        getLongUrlAndLoad(userInfo.avatar, getNameFromInfo(userInfo.name, this@loadAvatarByAccId))
        return
    }
    NIMClient.getService(UserService::class.java).fetchUserInfo(Collections.singletonList(this))
        .setCallback(object : RequestCallbackWrapper<List<NimUserInfo?>>() {
            override fun onResult(code: Int, result: List<NimUserInfo?>?, exception: Throwable?) {
                if (result.isNullOrEmpty()) {
                    loadAction(null, defaultResId, this@loadAvatarByAccId)
                    return
                }
                getLongUrlAndLoad(
                    result[0]?.avatar,
                    getNameFromInfo(result[0]?.name, result[0]?.account)
                )
            }
        })
}

/**
 * 获取用户的 昵称信息，如果为空 则返回 accId
 */
fun String.fetchNickname(notify: ((String) -> Unit)) {
    val extension = UserInfoExtensionHelper.userInfoHelper
    if (extension?.fetchNickname(this) {
            nameMap[this] = it
            notify(it)
        } == true
    ) {
        return
    }
    val userInfo = NIMClient.getService(UserService::class.java).getUserInfo(this)
    if (userInfo?.name != null) {
        notify(getNameFromInfo(userInfo.name, this))
        return
    }
    NIMClient.getService(UserService::class.java).fetchUserInfo(Collections.singletonList(this))
        .setCallback(object : RequestCallbackWrapper<List<NimUserInfo?>>() {
            override fun onResult(code: Int, result: List<NimUserInfo?>?, exception: Throwable?) {
                if (result.isNullOrEmpty()) {
                    notify(this@fetchNickname)
                    return
                }
                notify(getNameFromInfo(result[0]?.name, this@fetchNickname))
            }
        })
}

private fun getNameFromInfo(name: String?, account: String?): String =
    if (TextUtils.isEmpty(name) && TextUtils.isEmpty(account)) {
        ""
    } else if (TextUtils.isEmpty(name)) {
        account!!
    } else {
        name!!
    }

private fun avatarColor(content: String): Int {
    return if (!TextUtils.isEmpty(content)) {
        content[content.length - 1].code
    } else {
        0
    }
}

private fun loadTvAvatar(tvView: TextView, name: String, hashCode: Int) {
    val pos = if (hashCode == 0) {
        val random = Random()
        random.nextInt(SIZE)
    } else {
        abs(hashCode) % SIZE
    }
    tvView.setBackgroundResource(bgRes[abs(pos)])
    if (name.length <= AVATAR_NAME_LEN) {
        tvView.text = name
    } else {
        tvView.text = name.substring(name.length - AVATAR_NAME_LEN)
    }
}
