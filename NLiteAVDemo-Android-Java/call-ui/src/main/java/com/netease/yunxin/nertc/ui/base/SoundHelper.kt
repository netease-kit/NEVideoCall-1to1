/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R

open class SoundHelper {
    private val logTag = "SoundHelper"
    private var player: MediaPlayer = MediaPlayer()
    private var ringerTypeEnum: AVChatSoundPlayer.RingerTypeEnum? = null
    private var isAudioFocus = false

    protected open fun soundOptions(type: AVChatSoundPlayer.RingerTypeEnum): SoundPlayOptions? {
        return when (type) {
            AVChatSoundPlayer.RingerTypeEnum.NO_RESPONSE,
            AVChatSoundPlayer.RingerTypeEnum.PEER_BUSY,
            AVChatSoundPlayer.RingerTypeEnum.PEER_REJECT ->
                SoundPlayOptions(loop = false, streamType = AudioManager.STREAM_MUSIC)

            AVChatSoundPlayer.RingerTypeEnum.CONNECTING ->
                SoundPlayOptions(
                    loop = true,
                    streamType = AudioManager.STREAM_VOICE_CALL
                )

            AVChatSoundPlayer.RingerTypeEnum.RING ->
                SoundPlayOptions(loop = true, streamType = AudioManager.STREAM_RING)
        }
    }

    protected open fun soundResources(type: AVChatSoundPlayer.RingerTypeEnum): Int? {
        return when (type) {
            AVChatSoundPlayer.RingerTypeEnum.NO_RESPONSE ->
                R.raw.avchat_no_response

            AVChatSoundPlayer.RingerTypeEnum.PEER_BUSY ->
                R.raw.avchat_peer_busy

            AVChatSoundPlayer.RingerTypeEnum.PEER_REJECT ->
                R.raw.avchat_peer_reject

            AVChatSoundPlayer.RingerTypeEnum.CONNECTING ->
                R.raw.avchat_connecting

            AVChatSoundPlayer.RingerTypeEnum.RING ->
                R.raw.avchat_ring
        }
    }

    open fun play(context: Context, type: AVChatSoundPlayer.RingerTypeEnum) {
        ALog.d(logTag, "play type is ${type.name}")
        ringerTypeEnum = type
        innerPlay(context, type)
    }

    @JvmOverloads
    open fun stop(context: Context? = null, type: AVChatSoundPlayer.RingerTypeEnum? = null) {
        ALog.d(logTag, "stop, type is ${type?.name}")
        if (type != null && type != ringerTypeEnum) {
            return
        }
        ringerTypeEnum = null
        innerStop()
        context?.run {
            abandonAudioFocus(this)
        }
    }

    private fun innerPlay(
        context: Context,
        type: AVChatSoundPlayer.RingerTypeEnum
    ) {
        ALog.d(logTag, "play ring type is $type.")
        val ringId = soundResources(type)
        if (ringId == null || ringId == 0) {
            return
        }
        val options = soundOptions(type) ?: SoundPlayOptions()
        player.run {
            if (isPlaying) {
                stop()
            }
            reset()
            release()
        }
        player = MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder().setLegacyStreamType(options.streamType)
                    .build()
            )
            val afd = context.resources.openRawResourceFd(ringId)
            if (afd == null) {
                ALog.e(logTag, "can't open resources by ringId$ringId, type is $type.")
                return@apply
            }
            try {
                requestAudioFocus(context, type)
                setOnCompletionListener {
                    abandonAudioFocus(context)
                }
                setDataSource(
                    afd.fileDescriptor,
                    afd.startOffset,
                    afd.length
                )
                isLooping = options.loop
                prepare()
                start()
            } catch (e: Exception) {
                ALog.e(logTag, "innerPlay error.", e)
            }
        }
    }

    private fun innerStop() {
        ALog.d(logTag, "stop")
        player.run {
            if (isPlaying) {
                stop()
            }
        }
    }

    private fun requestAudioFocus(context: Context, type: AVChatSoundPlayer.RingerTypeEnum) {
        if (CallKitUI.options?.joinRtcWhenCall == true && type == AVChatSoundPlayer.RingerTypeEnum.CONNECTING) {
            return
        }
        (context.getSystemService(Context.AUDIO_SERVICE) as AudioManager).run {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                requestAudioFocus(
                    AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                        .build()
                )
            } else {
                @Suppress("DEPRECATION")
                requestAudioFocus(
                    null,
                    soundOptions(type)?.streamType ?: AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
                )
            }

            isAudioFocus = true
            ALog.d(logTag, "requestAudioFocus")
        }
    }

    private fun abandonAudioFocus(context: Context) {
        if (!isAudioFocus) {
            return
        }
        (context.getSystemService(Context.AUDIO_SERVICE) as AudioManager).run {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                abandonAudioFocusRequest(
                    AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT).build()
                )
            } else {
                @Suppress("DEPRECATION")
                abandonAudioFocus(null)
            }
            isAudioFocus = false
            ALog.d(logTag, "abandonAudioFocus")
        }
    }

    class SoundPlayOptions(
        internal val loop: Boolean = true,
        internal val streamType: Int = AudioManager.STREAM_MUSIC
    ) {
        override fun toString(): String {
            return "SoundPlayOptions(loop=$loop, streamType=$streamType)"
        }
    }
}
