/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.view

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.content.Context
import android.content.res.Configuration
import android.transition.TransitionManager
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import android.view.animation.DecelerateInterpolator
import androidx.constraintlayout.widget.ConstraintLayout
import com.netease.yunxin.kit.common.utils.ScreenUtils

open class GroupCallGridLayout(context: Context, attrs: AttributeSet?) : ConstraintLayout(
    context,
    attrs
) {
    private var showLargeViewIndex = DEFAULT_INDEX
    private var measureWidth: Int = 0
    private var screenWidth: Int = 0
    private var screenHeight: Int = 0
    private val changeList = ArrayList<View>()
    private var startMargin: Int = 0
    private var onItemClickListener: ((Int) -> Unit)? = null
    private var currentAnimator: ValueAnimator? = null
    private var isAnimating = false
    private var pendingVideoUpdates = mutableMapOf<Int, Boolean>()
    private var onAnimationStateChangeListener: ((Boolean) -> Unit)? = null

    init {
        setViewWidth()
        setupClickListeners()
    }

    override fun onConfigurationChanged(newConfig: Configuration?) {
        super.onConfigurationChanged(newConfig)
        setViewWidth()
        requestLayout()
    }

    private fun setViewWidth() {
        screenWidth = ScreenUtils.getDisplayWidth()
        screenHeight = ScreenUtils.getDisplayHeight()
        measureWidth = screenWidth
        startMargin = 0

        val isLandScape = false

        if (isLandScape) {
            // Set grid's actual width to 0.6 times the minimum value of width and height in landscape mode
            measureWidth = (screenHeight * 0.6).toInt()
            startMargin = (screenWidth - measureWidth) / 2
        }
    }

    private fun setupClickListeners() {
        // 为每个子View设置点击监听器
        post {
            for (i in 0 until childCount) {
                val child = getChildAt(i)
                child.setOnClickListener {
                    onItemClickListener?.invoke(i)
                }
            }
        }
    }

    override fun addView(child: View?, index: Int, params: ViewGroup.LayoutParams?) {
        super.addView(child, index, params)
        // 为新添加的子View设置点击监听器
        child?.setOnClickListener {
            val childIndex = indexOfChild(child)
            onItemClickListener?.invoke(childIndex)
        }
    }

    override fun removeView(view: View?) {
        super.removeView(view)
        // 重新设置所有子View的点击监听器，因为索引可能发生变化
        setupClickListeners()
    }

    /**
     * 设置点击监听器
     */
    fun setOnItemClickListener(listener: ((Int) -> Unit)?) {
        this.onItemClickListener = listener
    }

    /**
     * 设置动画状态变化监听器
     */
    fun setOnAnimationStateChangeListener(listener: ((Boolean) -> Unit)?) {
        this.onAnimationStateChangeListener = listener
    }

    /**
     * 设置放大视图索引
     */
    fun setLargeViewIndex(index: Int, animated: Boolean = true) {
        if (index < 0 || index >= childCount) {
            return
        }

        val oldIndex = showLargeViewIndex
        showLargeViewIndex = index

        if (animated) {
            isAnimating = true
            animateLayoutChange()
        } else {
            isAnimating = false
            requestLayout()
        }
    }

    /**
     * 重置放大视图
     */
    fun resetLargeView(animated: Boolean = true) {
        val oldIndex = showLargeViewIndex
        showLargeViewIndex = DEFAULT_INDEX

        if (animated) {
            isAnimating = true
            animateLayoutChange()
        } else {
            isAnimating = false
            requestLayout()
        }
    }

    /**
     * 获取当前放大的视图索引
     */
    fun getLargeViewIndex(): Int = showLargeViewIndex

    /**
     * 设置视频更新状态
     */
    fun setVideoUpdatePending(index: Int, enableVideo: Boolean) {
        if (isAnimating) {
            pendingVideoUpdates[index] = enableVideo
        }
    }

    /**
     * 应用待处理的视频更新
     */
    fun applyPendingVideoUpdates() {
        if (pendingVideoUpdates.isNotEmpty()) {
            // 这里可以通知外部应用视频更新
            pendingVideoUpdates.clear()
        }
    }

    /**
     * 布局变化动画
     */
    private fun animateLayoutChange() {
        currentAnimator?.cancel()

        // 在动画开始前，先触发一次布局更新，确保视频视图准备就绪
        requestLayout()

        val animator = ValueAnimator.ofFloat(0f, 1f)
        animator.duration = 300
        animator.interpolator = DecelerateInterpolator()

        animator.addUpdateListener { animation ->
            // 强制重新测量和布局，确保保持正方形
            invalidate()
            requestLayout()
        }

        animator.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationStart(animation: Animator) {
                // 动画开始时，确保所有子View都已经准备好
                for (i in 0 until childCount) {
                    val child = getChildAt(i)
                    child.requestLayout()
                }
                // 通知动画开始
                onAnimationStateChangeListener?.invoke(true)
            }

            override fun onAnimationEnd(animation: Animator) {
                currentAnimator = null
                isAnimating = false
                // 通知动画结束
                onAnimationStateChangeListener?.invoke(false)
                // 动画结束后应用待处理的视频更新
                applyPendingVideoUpdates()
            }
        })

        currentAnimator = animator
        animator.start()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        currentAnimator?.cancel()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.makeMeasureSpec(screenWidth, MeasureSpec.EXACTLY)
        var height = MeasureSpec.makeMeasureSpec(
            measureWidth + measureWidth / 3,
            MeasureSpec.EXACTLY
        )

        if (showLargeViewIndex < 0) {
            height = if (childCount <= 2) {
                MeasureSpec.makeMeasureSpec(
                    measureWidth / 2 + getTopMargin(childCount),
                    MeasureSpec.EXACTLY
                )
            } else {
                MeasureSpec.makeMeasureSpec(measureWidth, MeasureSpec.EXACTLY)
            }
        }
        setMeasuredDimension(width, height)

        for (i in 0 until childCount) {
            val child: View = getChildAt(i)
            val childSize = getMeasureSize(i, childCount)
            // 确保子View始终是正方形
            val squareSize = MeasureSpec.makeMeasureSpec(childSize, MeasureSpec.EXACTLY)
            measureChild(child, squareSize, squareSize)
        }
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        // 只在动画时使用TransitionManager添加过渡动画
        if (isAnimating) {
            TransitionManager.beginDelayedTransition(this)
        }

        val params = getLocation(childCount)

        if (showLargeViewIndex > 0 && childCount <= 4) {
            for (i in 0 until childCount) {
                val child = getChildAt(i)
                if (i != showLargeViewIndex) {
                    changeList.add(child)
                } else {
                    changeList.add(0, child)
                }
            }

            for (i in 0 until changeList.size) {
                val view = changeList[i]
                val pos = params[i]
                // 强制使用正方形尺寸
                val size = minOf(pos.width, pos.height)
                // 确保子View的测量尺寸也是正方形
                val squareMeasureSpec = View.MeasureSpec.makeMeasureSpec(
                    size,
                    View.MeasureSpec.EXACTLY
                )
                view.measure(squareMeasureSpec, squareMeasureSpec)
                view.layout(pos.x, pos.y, pos.x + size, pos.y + size)
            }
            changeList.clear()
            return
        }

        val topMargin = getTopMargin(childCount)

        for (i in 0 until childCount) {
            val child = getChildAt(i)
            val pos = params[i]
            // 强制使用正方形尺寸
            val size = minOf(pos.width, pos.height)
            // 确保子View的测量尺寸也是正方形
            val squareMeasureSpec = View.MeasureSpec.makeMeasureSpec(size, View.MeasureSpec.EXACTLY)
            child.measure(squareMeasureSpec, squareMeasureSpec)
            child.layout(
                pos.x,
                pos.y + topMargin,
                pos.x + size,
                pos.y + topMargin + size
            )
        }
    }

    private fun getMeasureSize(index: Int, count: Int): Int {
        val size = when {
            count <= 4 && showLargeViewIndex == index -> measureWidth
            count <= 4 && showLargeViewIndex < 0 -> measureWidth / 2
            count > 4 && showLargeViewIndex == index -> measureWidth / 3 * 2
            else -> measureWidth / 3
        }
        // 确保返回的尺寸是正方形的基础尺寸
        return size
    }

    private fun getTopMargin(count: Int): Int {
        return if (count <= 2 && showLargeViewIndex < 0 && screenWidth < screenHeight) {
            measureWidth / 4
        } else {
            0
        }
    }

    private fun getLocation(count: Int): List<Position> {
        val baseSize = measureWidth / 3
        // 确保基础尺寸是正方形
        val size = minOf(baseSize, baseSize)

        var currentIndex = 0
        var lastFrame = 0
        var segment: SegmentStyle = getSegment(count, currentIndex)

        val list = ArrayList<Position>()
        while (currentIndex < count) {
            when (segment) {
                SegmentStyle.FULL_WIDTH -> {
                    list.add(fullWidth(startMargin, lastFrame, size, size))
                    lastFrame += size * 3
                    currentIndex += 1
                }
                SegmentStyle.FIFTY_FIFTY -> {
                    list.addAll(fiftyFifty(startMargin, lastFrame, size, size))
                    lastFrame += size * 3
                    currentIndex += 4
                }
                SegmentStyle.THREE_ONE_THIRDS -> {
                    list.addAll(threeOneThird(startMargin, lastFrame, size, size))
                    lastFrame += size
                    currentIndex += 3
                }
                SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER -> {
                    list.addAll(twoThirdsOneThirdCenter(startMargin, lastFrame, size, size))
                    lastFrame += size * 2
                    currentIndex += 3
                }
                SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT -> {
                    list.addAll(twoThirdsOneThirdRight(startMargin, lastFrame, size, size))
                    lastFrame += size * 2
                    currentIndex += 3
                }
                SegmentStyle.ONE_THIRD_TWO_THIRDS -> {
                    list.addAll(oneThirdTwoThirds(startMargin, lastFrame, size, size))
                    lastFrame += size * 2
                    currentIndex += 3
                }
                SegmentStyle.ONE_THIRD -> {
                    list.addAll(oneThird(startMargin, lastFrame, size, size))
                    lastFrame += size * 3
                    currentIndex += 3
                }
                else -> {}
            }
            segment = getSegment(count, currentIndex)
        }
        return list
    }

    private fun oneThirdTwoThirds(x: Int, y: Int, width: Int, height: Int): List<Position> {
        val list = ArrayList<Position>()
        val largeSize = width * 2
        val smallSize = width
        list.add(Position(x, y, largeSize, largeSize))
        list.add(Position(x + largeSize, y, smallSize, smallSize))
        list.add(Position(x + largeSize, y + smallSize, smallSize, smallSize))
        return list
    }

    private fun threeOneThird(x: Int, y: Int, width: Int, height: Int): List<Position> {
        val list = ArrayList<Position>()
        list.add(Position(x, y, width, width))
        list.add(Position(x + width, y, width, width))
        list.add(Position(x + width * 2, y, width, width))
        return list
    }

    private fun fullWidth(x: Int, y: Int, width: Int, height: Int): Position {
        val size = width * 3
        return Position(x, y, size, size)
    }

    private fun twoThirdsOneThirdCenter(x: Int, y: Int, width: Int, height: Int): List<Position> {
        val list = ArrayList<Position>()
        val smallSize = width
        val largeSize = width * 2
        list.add(Position(x, y, smallSize, smallSize))
        list.add(Position(x + smallSize, y, largeSize, largeSize))
        list.add(Position(x, y + smallSize, smallSize, smallSize))
        return list
    }

    private fun twoThirdsOneThirdRight(x: Int, y: Int, width: Int, height: Int): List<Position> {
        val list = ArrayList<Position>()
        val smallSize = width
        val largeSize = width * 2
        list.add(Position(x, y, smallSize, smallSize))
        list.add(Position(x, y + smallSize, smallSize, smallSize))
        list.add(Position(x + smallSize, y, largeSize, largeSize))
        return list
    }

    private fun fiftyFifty(x: Int, y: Int, childWidth: Int, childHeight: Int): List<Position> {
        val size = childWidth * 3 / 2

        val list = ArrayList<Position>()
        list.add(Position(x, y, size, size))
        list.add(Position(x + size, y, size, size))
        list.add(Position(x, y + size, size, size))
        list.add(Position(x + size, y + size, size, size))
        return list
    }

    private fun oneThird(x: Int, y: Int, childWidth: Int, childHeight: Int): List<Position> {
        val size = childWidth * 3 / 2

        val list = ArrayList<Position>()
        list.add(Position(x, y, size, size))
        list.add(Position(x + size, y, size, size))
        list.add(Position(x + size / 2, y + size, size, size))
        return list
    }

    private fun getSegment(count: Int, currentIndex: Int): SegmentStyle {
        var segment = SegmentStyle.THREE_ONE_THIRDS
        if (currentIndex == 0) {
            when {
                count == 1 -> segment = SegmentStyle.FULL_WIDTH
                count == 2 || count == 4 ->
                    segment =
                        if (showLargeViewIndex >= 0) SegmentStyle.FULL_WIDTH else SegmentStyle.FIFTY_FIFTY
                count == 3 ->
                    segment =
                        if (showLargeViewIndex >= 0) SegmentStyle.FULL_WIDTH else SegmentStyle.ONE_THIRD
                showLargeViewIndex == 0 -> segment = SegmentStyle.ONE_THIRD_TWO_THIRDS
                showLargeViewIndex == 1 -> segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER
                showLargeViewIndex == 2 -> segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT
            }
            return segment
        }
        when (count - currentIndex) {
            1 -> segment = when {
                count == 3 -> SegmentStyle.ONE_THIRD
                count > 4 && showLargeViewIndex == count - 1 -> SegmentStyle.ONE_THIRD_TWO_THIRDS
                count == 4 -> SegmentStyle.FIFTY_FIFTY
                count > 4 && showLargeViewIndex == currentIndex -> SegmentStyle.ONE_THIRD_TWO_THIRDS
                count > 4 && showLargeViewIndex == currentIndex + 1 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER
                count > 4 && showLargeViewIndex == currentIndex + 2 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT
                else -> SegmentStyle.THREE_ONE_THIRDS
            }
            2 -> segment = when {
                count == 4 -> SegmentStyle.FIFTY_FIFTY
                count > 4 && showLargeViewIndex == currentIndex -> SegmentStyle.ONE_THIRD_TWO_THIRDS
                count > 4 && showLargeViewIndex == currentIndex + 1 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER
                count > 4 && showLargeViewIndex == currentIndex + 2 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT
                else -> SegmentStyle.THREE_ONE_THIRDS
            }
            else ->
                segment =
                    when {
                        count > 4 && showLargeViewIndex == currentIndex -> SegmentStyle.ONE_THIRD_TWO_THIRDS
                        count > 4 && showLargeViewIndex == currentIndex + 1 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER
                        count > 4 && showLargeViewIndex == currentIndex + 2 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT
                        else -> SegmentStyle.THREE_ONE_THIRDS
                    }
        }
        return segment
    }

    class Position(xx: Int, yy: Int, wWidth: Int, hHeight: Int) {
        var x = 0
        var y = 0
        var width = 0
        var height = 0

        init {
            x = xx
            y = yy
            width = wWidth
            height = hHeight
        }
    }

    enum class SegmentStyle {
        FULL_WIDTH,
        ONE_THIRD,
        FIFTY_FIFTY,
        THREE_ONE_THIRDS,
        ONE_THIRD_TWO_THIRDS,
        TWO_THIRDS_ONE_THIRD_CENTER,
        TWO_THIRDS_ONE_THIRD_RIGHT
    }

    companion object {
        const val DEFAULT_INDEX: Int = -99
    }
}
