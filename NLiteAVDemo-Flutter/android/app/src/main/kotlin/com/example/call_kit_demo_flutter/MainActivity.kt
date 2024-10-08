package com.example.call_kit_demo_flutter

import android.content.Context
import android.content.SharedPreferences
import android.media.AudioManager
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.widget.Toast
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.SDKOptions
import com.netease.nimlib.sdk.StatusCode
import com.netease.nimlib.sdk.auth.AuthService
import com.netease.nimlib.sdk.auth.AuthServiceObserver
import com.netease.nimlib.sdk.auth.LoginInfo
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.kit.call.p2p.model.NERecordCallStatus
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.CallKitUIOptions
import com.netease.yunxin.nertc.ui.base.AVChatSoundPlayer
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.SoundHelper
import com.netease.yunxin.nertc.ui.service.DefaultIncomingCallEx
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val logTag = "MainActivity"

    // 配置应用的 appKey
    private val appKey = "your appkey"

    // channel 名称
    private val channelNameCall = "com.example.call_kit_demo_flutter/channel/call"

    // 发起呼叫方法
    private val callMethodName = "startCall"

    // 是否可以使用呼叫组件方法
    private val callkitCanBeUsedMethodName = "callKitCanBeUsed"

    // 呼叫参数被叫方的 accId
    private val callParamAccId = "accId"

    // 用户昵称 map
    private val callParamNameMap = "userInfoNameMap"

    // 用户头像 map
    private val callParamAvatarMap = "userInfoAvatarMap"

    // 登录 IM 方法
    private val imLoginMethodName = "imLogin"

    private val imLoginParamAccId = "accId"

    private val imLoginParamToken = "token"

    // 登出 IM 方法
    private val imLogoutMethodName = "imLogout"

    // 通知外部呼叫组件状态方法
    private val notifyCallKitStateMethodName = "notifyCallKitState"

    // 当前登录的 IM 账号
    private val notifyCallKitStateParamAccId = "accId"

    // 当前登录的 呼叫组件的状态，true 可用，false 不可用
    private val notifyCallKitStateParamState = "state"

    private val spLoginFileName = "sp_callKit_login_Info"
    private val spKeyLoginAccId = "sp_key_login_accId"
    private val spKeyLoginToken = "sp_key_login_token"

    private lateinit var sharedPreferences: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 自动登录，从本地获取账号和 token
        sharedPreferences = getSharedPreferences(spLoginFileName, Context.MODE_PRIVATE)
        val accId = sharedPreferences.getString(spKeyLoginAccId, null).apply {
            ALog.e(logTag, "onCreate accId: $this")
        }
        val token = sharedPreferences.getString(spKeyLoginToken, null).apply {
            ALog.e(logTag, "onCreate token: $this")
        }

        // 初始化 IM sdk
        NIMClient.init(this, LoginInfo(accId, token), SDKOptions().apply {
            appKey = this@MainActivity.appKey
        })

        flutterEngine?.dartExecutor?.binaryMessenger?.run {
            val methodChannel = MethodChannel(this, channelNameCall)

            // 监听云信 IM 登录状态
            NIMClient.getService(AuthServiceObserver::class.java).observeOnlineStatus({ status ->
                Log.d(logTag, "onCreate status: $status")
                if (status == StatusCode.LOGINED && !TextUtils.equals(
                        CallKitUI.currentUserAccId, NIMClient.getCurrentAccount()
                    )
                ) {
                    // 登录成功初始化呼叫组件
                    initCallKit(context)
                    // 通知外部登录成功用于以及登录的账号，外部收到此通知说明已经完成呼叫组件登录可以发起呼叫
                    methodChannel.invokeMethod(
                        notifyCallKitStateMethodName,
                        mapOf(
                            notifyCallKitStateParamAccId to CallKitUI.currentUserAccId,
                            notifyCallKitStateParamState to CallKitUI.init
                        )
                    )
                }
            }, true)

            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    // 发起呼叫
                    callMethodName -> {
                        startCall(call.arguments() as? Map<String, Any>, result, this@MainActivity)
                    }

                    // IM账号的登录（同时初始化呼叫组件）
                    imLoginMethodName -> {
                        imLogin(call.arguments() as? Map<String, Any>, result)
                    }

                    // IM账号的登出（同时销毁呼叫组件）
                    imLogoutMethodName -> {
                        methodChannel.invokeMethod(
                            notifyCallKitStateMethodName,
                            mapOf(
                                notifyCallKitStateParamAccId to CallKitUI.currentUserAccId,
                                notifyCallKitStateParamState to false
                            )
                        )
                        imLogout(result)
                    }
                    callkitCanBeUsedMethodName->{
                        getCallKitState(result)
                    }

                }
            }
        }
    }

    /**
     * IM 登录
     */
    private fun imLogin(
        arguments: Map<String, Any>?,
        result: MethodChannel.Result,
    ) {
        val accId = arguments?.get(imLoginParamAccId) as? String
        val token = arguments?.get(imLoginParamToken) as? String
        if (TextUtils.isEmpty(accId) || TextUtils.isEmpty(token)) {
            Log.e(logTag, "登录失败")
            return
        }

        NIMClient.getService(AuthService::class.java).login(LoginInfo(accId, token))
            .setCallback(object : RequestCallback<LoginInfo> {
                override fun onSuccess(param: LoginInfo?) {
                    Log.d(logTag, "登录成功")
                    // 记录本地用于自动登录
                    sharedPreferences.edit().apply {
                        putString(spKeyLoginAccId, accId)
                        putString(spKeyLoginToken, token)
                        apply()
                    }
                    sharedPreferences.getString(spKeyLoginAccId, null).apply {
                        ALog.e(logTag, "accId: $this")
                    }
                    sharedPreferences.getString(spKeyLoginToken, null).apply {
                        ALog.e(logTag, "token: $this")
                    }

                    result.success(mapOf("result" to mapOf("code" to 200, "msg" to "登录成功")))
                }

                override fun onFailed(code: Int) {
                    Log.d(logTag, "登录失败")
                    result.success(mapOf("result" to mapOf("code" to code, "msg" to "登录失败")))
                }

                override fun onException(exception: Throwable?) {
                    Log.d(logTag, "登录异常")
                    result.success(
                        mapOf(
                            "result" to mapOf(
                                "code" to -1, "msg" to "登录异常:${exception?.message}"
                            )
                        )
                    )
                }

            })
    }

    /**
     * 初始化呼叫组件
     */
    @Suppress("UNCHECKED_CAST")
    private fun initCallKit(context: Context) {
        // 组件初始化参数构建
        val options = CallKitUIOptions.Builder().rtcAppKey(appKey)
            // 设置当前登录云信的 IM 账号
            .currentUserAccId(NIMClient.getCurrentAccount())
            // 被叫用户收到呼叫后处理主叫传递的参数
            .incomingCallEx(object : DefaultIncomingCallEx() {
                override fun onIncomingCall(invitedInfo: NEInviteInfo): Boolean {
                    // 解析外部传过来的参数更新被叫头像和名称数据
                    invitedInfo.extraInfo?.run {
                        val arguments = Gson().fromJson<Map<String, Any>>(
                            this, (object : TypeToken<Map<String, Any>>() {}).type
                        )
                        val avatars = arguments?.get(callParamAvatarMap) as? Map<String, String>
                        UserInfoCenter.updateAvatars(avatars)
                        val names = arguments?.get(callParamNameMap) as? Map<String, String>
                        UserInfoCenter.updateNames(names)
                    }
                    // 用户被叫页面弹起等相关逻辑
                    return super.onIncomingCall(invitedInfo)
                }
            })
            // 设置自定义的用户页面
            .p2pAudioActivity(SelfCustomCallActivity::class.java)
            .p2pVideoActivity(SelfCustomCallActivity::class.java)
            // 设置响铃相关设置
            .soundHelper(object : SoundHelper() {
                override fun soundOptions(type: AVChatSoundPlayer.RingerTypeEnum): SoundPlayOptions {
                    return when (type) {
                        AVChatSoundPlayer.RingerTypeEnum.NO_RESPONSE,
                        AVChatSoundPlayer.RingerTypeEnum.PEER_BUSY,
                        AVChatSoundPlayer.RingerTypeEnum.PEER_REJECT,
                        AVChatSoundPlayer.RingerTypeEnum.CONNECTING,
                        -> SoundPlayOptions(
                            loop = false, streamType = AudioManager.STREAM_MUSIC
                        )

                        AVChatSoundPlayer.RingerTypeEnum.RING -> SoundPlayOptions(
                            loop = true, streamType = AudioManager.STREAM_RING
                        )
                    }
                }
            }).build()
        // 自定义发送通话话单
        NECallEngine.sharedInstance().setCallRecordProvider {
            when (it.callState) {
                NERecordCallStatus.TIMEOUT -> {
                    Log.d(logTag, "发送超时话单")
                }

                NERecordCallStatus.BUSY -> {
                    Log.d(logTag, "发送占线话单")
                }

                NERecordCallStatus.CANCELED -> {
                    Log.d(logTag, "发送取消话单")
                }

                NERecordCallStatus.REJECTED -> {
                    Log.d(logTag, "发送拒绝话单")
                }
            }
        }
        // 组件初始化
        CallKitUI.init(context.applicationContext, options)
    }

    /**
     * 发起呼叫
     */
    @Suppress("UNCHECKED_CAST")
    private fun startCall(
        arguments: Map<String, Any>?,
        result: MethodChannel.Result,
        context: Context,
    ) {
        // accId 为必要参数，若无则呼叫失败
        val accId = arguments?.get(callParamAccId) as? String
        if (TextUtils.isEmpty(accId)) {
            Toast.makeText(context, "呼叫失败", Toast.LENGTH_SHORT).show()
            Log.d(logTag, "呼叫失败")
            return
        }
        // 解析外部传过来的图像 map
        val avatars = arguments?.get(callParamAvatarMap) as? Map<String, String>
        UserInfoCenter.updateAvatars(avatars)
        // 解析外部传过来的名称 map
        val names = arguments?.get(callParamNameMap) as? Map<String, String>
        UserInfoCenter.updateNames(names)

        // 生成 json 用于通知被叫用户使用的头像和名称
        val json = arguments?.run {
            Gson().toJson(this)
        } ?: ""
        val param = CallParam.Builder()
            // 被叫用户Id
            .calledAccId(accId!!)
            // 呼叫类型,VIDEO 为视频， AUDIO 为音频呼叫
            .callType(NECallType.VIDEO)
            // 通知被叫用户的额外参数
            .callExtraInfo(json)
            .build()

        CallKitUI.startSingleCall(context, param)
        result.success(mapOf("result" to mapOf("code" to 200, "msg" to "呼叫成功")))
    }

    /**
     * 查询呼叫组件状态
     */
    private fun getCallKitState(result: MethodChannel.Result){
        result.success(mapOf("result" to mapOf("code" to 200, "msg" to "查询成功", "data" to CallKitUI.init)))
    }

    /**
     * IM 登出
     */
    private fun imLogout(result: MethodChannel.Result) {
        // 清除自动登录内容
        sharedPreferences.edit().apply {
            remove(spKeyLoginAccId)
            remove(spKeyLoginToken)
            apply()
        }
        // 销毁呼叫组件
        CallKitUI.destroy()
        // 登出当前账号
        NIMClient.getService(AuthService::class.java).logout()
        result.success(mapOf("result" to mapOf("code" to 200, "msg" to "登出成功")))
    }
}
