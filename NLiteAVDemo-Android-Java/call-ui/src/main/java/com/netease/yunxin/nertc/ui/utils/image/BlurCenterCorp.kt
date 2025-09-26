/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils.image

import android.content.Context
import android.graphics.Bitmap
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool
import com.bumptech.glide.load.resource.bitmap.TransformationUtils
import com.bumptech.glide.util.Util
import java.nio.ByteBuffer
import java.security.MessageDigest
import jp.wasabeef.glide.transformations.BlurTransformation

/**
 * Created by luc on 2020/12/2.
 *
 *
 * 合并高斯模糊以及中心裁切效果。
 */
class BlurCenterCorp(private val tempRadius: Int, private val tempSampling: Int) :
    BlurTransformation(
        tempRadius,
        tempSampling
    ) {
    override fun transform(
        context: Context,
        pool: BitmapPool,
        toTransform: Bitmap,
        outWidth: Int,
        outHeight: Int
    ): Bitmap {
        val bitmap = TransformationUtils.centerCrop(pool, toTransform, outWidth, outHeight)
        return super.transform(context, pool, bitmap, outWidth, outHeight)
    }

    override fun hashCode(): Int {
        val code = Util.hashCode(tempRadius, tempSampling)
        return Util.hashCode(ID.hashCode(), Util.hashCode(code))
    }

    override fun updateDiskCacheKey(messageDigest: MessageDigest) {
        messageDigest.update(ID_BYTES)
        val radiusData = ByteBuffer.allocate(8).putInt(tempRadius).putInt(tempSampling).array()
        messageDigest.update(radiusData)
    }

    companion object {
        private const val ID = "com.netease.yunxin.android.lib.picture.BlurCenterCorp"
        private val ID_BYTES = ID.toByteArray(CHARSET)
    }
}
