/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils.image

import android.graphics.Bitmap
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation
import com.bumptech.glide.load.resource.bitmap.TransformationUtils
import com.bumptech.glide.util.Preconditions
import com.bumptech.glide.util.Util
import java.nio.ByteBuffer
import java.security.MessageDigest

/**
 * Created by luc on 2020/12/2.
 *
 *
 * 合并圆角以及中心裁切效果。
 */
class RoundedCornersCenterCrop(roundingRadius: Int) : BitmapTransformation() {
    private val roundingRadius: Int
    override fun transform(
        pool: BitmapPool,
        toTransform: Bitmap,
        outWidth: Int,
        outHeight: Int
    ): Bitmap {
        val bitmap = TransformationUtils.centerCrop(pool, toTransform, outWidth, outHeight)
        return TransformationUtils.roundedCorners(pool, bitmap, roundingRadius)
    }

    override fun equals(other: Any?): Boolean {
        if (other is RoundedCornersCenterCrop) {
            return roundingRadius == other.roundingRadius
        }
        return false
    }

    override fun hashCode(): Int {
        return Util.hashCode(ID.hashCode(), Util.hashCode(roundingRadius))
    }

    override fun updateDiskCacheKey(messageDigest: MessageDigest) {
        messageDigest.update(ID_BYTES)
        val radiusData = ByteBuffer.allocate(4).putInt(roundingRadius).array()
        messageDigest.update(radiusData)
    }

    companion object {
        private const val ID = "com.netease.yunxin.android.lib.picture.RoundedCornersCenterCrop"
        private val ID_BYTES = ID.toByteArray(CHARSET)
    }

    /**
     * @param roundingRadius the corner radius (in device-specific pixels).
     * @throws IllegalArgumentException if rounding radius is 0 or less.
     */
    init {
        Preconditions.checkArgument(roundingRadius > 0, "roundingRadius must be greater than 0.")
        this.roundingRadius = roundingRadius
    }
}
