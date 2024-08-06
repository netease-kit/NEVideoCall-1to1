/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.floating

import android.animation.Animator
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.util.DisplayMetrics
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import androidx.core.content.ContextCompat
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.nertc.ui.R
import kotlin.math.max

/**
 * 实现类似微信浮窗效果，支持拖动以及吸附效果
 */
class DefaultFloatingTouchEventStrategy(
    private val context: Context,
    private val bgColor: Int = ContextCompat.getColor(
        context,
        R.color.transparent
    ),
    radius: Float = 0f
) : FloatingTouchEventStrategy {
    private val logTag = "DefaultFloatingTouchEventStrategy"

    private var widthPixel = -1
    private var density = 1f

    private var currentX = 0
    private var currentY = 0
    private val radiusPixel = radius.dpToPixel().toFloat()
    private var animator = BgAndXPosAnimator()

    private var gravity: Int = 0

    private val leftBg = GradientDrawable().apply {
        setColor(bgColor)
        cornerRadii =
            floatArrayOf(0f, 0f, radiusPixel, radiusPixel, radiusPixel, radiusPixel, 0f, 0f)
    }

    private val movingBg = GradientDrawable().apply {
        setColor(bgColor)
        cornerRadius = radiusPixel
    }

    private val rightBg = GradientDrawable().apply {
        setColor(bgColor)
        cornerRadii =
            floatArrayOf(radiusPixel, radiusPixel, 0f, 0f, 0f, 0f, radiusPixel, radiusPixel)
    }

    init {
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
        wm?.run {
            val outMetrics = DisplayMetrics()
            wm.defaultDisplay.getMetrics(outMetrics)
            widthPixel = outMetrics.widthPixels
            density = outMetrics.density
        }
    }

    override fun initForWrapper(wrapper: FloatingWindowWrapper) {
        wrapper.setBgRes(leftBg)
        this.gravity = wrapper.config.windowParams.gravity
    }

    override fun handScrollEvent(event: MotionEvent, windowWrapper: FloatingWindowWrapper) {
        if (animator.isRunning()) {
            return
        }
        ALog.i(
            logTag,
            "x is ${event.x} , y is ${event.y} , rawX is ${event.rawX}, rawY is ${event.rawY}. detail is $event"
        )
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                currentX = event.rawX.toInt()
                currentY = event.rawY.toInt()
            }

            MotionEvent.ACTION_MOVE -> {
                val nowX = event.rawX.toInt()
                val nowY = event.rawY.toInt()
                val movedX = nowX - currentX
                val movedY = nowY - currentY
                currentX = nowX
                currentY = nowY
                windowWrapper.updateWindowParamsPos(
                    max(
                        windowWrapper.fetchWindowParamsX() + if (gravity.and(Gravity.END) == Gravity.END) -movedX else movedX,
                        0
                    ),
                    max(
                        windowWrapper.fetchWindowParamsY() + if (gravity.and(Gravity.TOP) == Gravity.TOP) movedY else -movedY,
                        0
                    )
                )
                windowWrapper.setBgRes(movingBg)
            }

            MotionEvent.ACTION_UP -> {
                if (widthPixel < 0) {
                    return
                }
                toAdsorbEdge(event.rawX.toInt(), windowWrapper)
            }
        }
    }

    override fun toUpdateViewUI(wrapper: FloatingWindowWrapper) {
        if (gravity.and(Gravity.END) == 0) {
            toAdsorbEdge(wrapper.fetchWindowParamsX(), wrapper)
        }
    }

    /**
     * 吸附至边缘
     */
    private fun toAdsorbEdge(x: Int, windowWrapper: FloatingWindowWrapper) {
        windowWrapper.post {
            if (x > widthPixel / 2) {
                animator.start(
                    windowWrapper.fetchWindowParamsX(),
                    if (gravity.and(Gravity.END) == Gravity.END) 0 else widthPixel - windowWrapper.measuredWidth,
                    rightBg,
                    windowWrapper
                )
            } else {
                animator.start(
                    windowWrapper.fetchWindowParamsX(),
                    if (gravity.and(Gravity.END) == Gravity.END) widthPixel - windowWrapper.measuredWidth else 0,
                    leftBg,
                    windowWrapper
                )
            }
        }
    }

    private var currentBgRes: Drawable? = null

    /**
     * 设置页面背景
     */
    private fun View.setBgRes(bg: Drawable) {
        if (currentBgRes == bg) {
            return
        }
        background = bg
        currentBgRes = bg
    }

    /**
     * dp 转换至 pixel
     */
    private fun Float.dpToPixel(): Int = (this * density + 0.5f).toInt()

    /**
     * 背景和 x坐标点的动画控制
     */
    private inner class BgAndXPosAnimator {
        private var endXPos: Int? = null
        private var finishedBg: Drawable? = null
        private var windowWrapper: FloatingWindowWrapper? = null

        /**
         * 属性动画更新监听
         */
        private val updateListener = object : ValueAnimator.AnimatorUpdateListener {
            override fun onAnimationUpdate(animation: ValueAnimator) {
                animation ?: return
                (animation.animatedValue as? Int)?.run {
                    windowWrapper?.updateWindowParamsPos(xPos = this)
                }
            }
        }

        /**
         * 动画状态监听
         */
        private val animatorListener = object : Animator.AnimatorListener {
            override fun onAnimationStart(animation: Animator) {
            }

            override fun onAnimationEnd(animation: Animator) {
                ALog.d(logTag, "onAnimationEnd")
                finish()
            }

            override fun onAnimationCancel(animation: Animator) {
                ALog.d(logTag, "onAnimationCancel")
                finish()
            }

            override fun onAnimationRepeat(animation: Animator) {
            }
        }

        private val animator = ValueAnimator.ofInt(0, 1).setDuration(100)
            .apply {
                interpolator = AccelerateDecelerateInterpolator()
            }

        /**
         * 动画开始
         */
        fun start(
            startPos: Int,
            endPos: Int,
            finishedBg: Drawable,
            windowWrapper: FloatingWindowWrapper
        ) {
            if (isRunning()) {
                ALog.d(logTag, "running")
                return
            }
            if (endPos == windowWrapper.fetchWindowParamsX()) {
                windowWrapper.setBgRes(finishedBg)
                return
            }
            ALog.d(logTag, "start $startPos, $endPos")

            this.endXPos = endPos
            this.finishedBg = finishedBg
            this.windowWrapper = windowWrapper

            animator.run {
                addListener(animatorListener)
                addUpdateListener(updateListener)
                setIntValues(startPos, endPos)
                start()
            }
        }

        fun isRunning() = animator.isRunning

        fun cancel() {
            this.windowWrapper = null
            this.finishedBg = null
            this.endXPos = null
            animator.removeAllUpdateListeners()
            animator.removeAllListeners()

            if (isRunning()) {
                animator.cancel()
            }
        }

        private fun finish() {
            animator.removeAllUpdateListeners()
            animator.removeAllListeners()
            windowWrapper?.also { wrapper ->
                finishedBg?.also { bg ->
                    wrapper.setBgRes(bg)
                }
                endXPos?.run {
                    wrapper.updateWindowParamsPos(this)
                }
            }
        }
    }
}
