/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import android.os.Parcel
import android.os.Parcelable
import com.netease.yunxin.kit.call.p2p.model.NECallPushConfig
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.ui.CallKitUI

/**
 * 呼叫参数，用户群组呼叫/P2P 呼叫
 */
class CallParam @JvmOverloads constructor(
    val isCalled: Boolean,
    var callType: Int = NECallType.AUDIO,
    val callerAccId: String? = null,
    val calledAccId: String? = null,
    val callExtraInfo: String? = null,
    val globalExtraCopy: String? = null,
    val rtcChannelName: String? = null,
    val pushConfig: NECallPushConfig? = null,
    var extras: MutableMap<String?, Any?>? = null
) : Parcelable {

    val currentAccId: String? = CallKitUI.currentUserAccId

    val otherAccId: String?
        get() = if (isCalled) callerAccId else calledAccId

    constructor(
        callType: Int,
        callerAccId: String? = null,
        calledAccId: String? = null,
        callExtraInfo: String? = null,
        globalExtraCopy: String? = null,
        rtcChannelName: String? = null,
        pushConfig: NECallPushConfig? = null,
        extras: MutableMap<String?, Any?>?
    ) : this(
        false,
        callType,
        callerAccId,
        calledAccId,
        callExtraInfo = callExtraInfo,
        globalExtraCopy = globalExtraCopy,
        rtcChannelName = rtcChannelName,
        pushConfig = pushConfig,
        extras = extras
    )

    constructor(parcel: Parcel) : this(
        parcel.readByte() != 0.toByte(),
        parcel.readInt(),
        parcel.readString(),
        parcel.readString(),
        parcel.readString(),
        parcel.readString(),
        parcel.readString(),
        parcel.readParcelable(NECallPushConfig::class.java.classLoader),
        HashMap<String?, Any?>().apply {
            parcel.readMap(this, javaClass.classLoader)
        }
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeByte(if (isCalled) 1 else 0)
        parcel.writeInt(callType)
        parcel.writeString(callerAccId)
        parcel.writeString(calledAccId)
        parcel.writeString(callExtraInfo)
        parcel.writeString(globalExtraCopy)
        parcel.writeString(rtcChannelName)
        parcel.writeParcelable(pushConfig, 0)
        parcel.writeMap(extras)
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun toString(): String {
        return "CallParam(isCalled=$isCalled, callType=$callType, callerAccId=$callerAccId, calledAccId=$calledAccId, callExtraInfo=$callExtraInfo, globalExtraCopy=$globalExtraCopy, rtcChannelName=$rtcChannelName, pushConfig=$pushConfig, extras=$extras, currentAccId=$currentAccId, otherAccId=$otherAccId)"
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as CallParam

        if (isCalled != other.isCalled) return false
        if (callType != other.callType) return false
        if (callerAccId != other.callerAccId) return false
        if (calledAccId != other.calledAccId) return false
        if (callExtraInfo != other.callExtraInfo) return false
        if (globalExtraCopy != other.globalExtraCopy) return false
        if (rtcChannelName != other.rtcChannelName) return false
        if (pushConfig != other.pushConfig) return false
        if (extras != other.extras) return false

        return true
    }

    override fun hashCode(): Int {
        var result = isCalled.hashCode()
        result = 31 * result + callType
        result = 31 * result + (callerAccId?.hashCode() ?: 0)
        result = 31 * result + (calledAccId?.hashCode() ?: 0)
        result = 31 * result + (callExtraInfo?.hashCode() ?: 0)
        result = 31 * result + (globalExtraCopy?.hashCode() ?: 0)
        result = 31 * result + (rtcChannelName?.hashCode() ?: 0)
        result = 31 * result + (pushConfig?.hashCode() ?: 0)
        result = 31 * result + (extras?.hashCode() ?: 0)
        return result
    }

    companion object CREATOR : Parcelable.Creator<CallParam> {
        override fun createFromParcel(parcel: Parcel): CallParam {
            return CallParam(parcel)
        }

        override fun newArray(size: Int): Array<CallParam?> {
            return arrayOfNulls(size)
        }
    }

    class Builder {
        private var callType: Int = NECallType.AUDIO
        private var isCalled: Boolean = false
        private var callerAccId: String? = CallKitUI.currentUserAccId
        private var calledAccId: String? = null
        private var callExtraInfo: String? = null
        private var globalExtraCopy: String? = null
        private var rtcChannelName: String? = null
        private var pushConfig: NECallPushConfig? = null
        private val extras: MutableMap<String?, Any?> = mutableMapOf()

        fun callType(type: Int) = apply { this.callType = type }

        fun isCalled(called: Boolean) = apply { this.isCalled = called }

        fun callerAccId(accId: String) = apply { this.callerAccId = accId }

        fun calledAccId(accId: String) = apply { this.calledAccId = accId }

        fun callExtraInfo(extraInfo: String) = apply { this.callExtraInfo = extraInfo }

        fun globalExtraCopy(globalExtraCopy: String) =
            apply { this.globalExtraCopy = globalExtraCopy }

        fun rtcChannelName(channelName: String) = apply { this.rtcChannelName = channelName }

        fun pushConfig(config: NECallPushConfig) = apply { this.pushConfig = config }

        fun replaceAllExtras(extras: Map<String?, Any?>) = apply {
            this.extras.let {
                it.clear()
                it.putAll(extras)
            }
        }

        fun addExtras(key: String, value: Any?) = apply {
            extras[key] = value
        }

        fun build(): CallParam {
            return CallParam(
                isCalled,
                callType,
                callerAccId,
                calledAccId,
                callExtraInfo,
                globalExtraCopy,
                rtcChannelName,
                pushConfig,
                extras
            )
        }
    }
}
