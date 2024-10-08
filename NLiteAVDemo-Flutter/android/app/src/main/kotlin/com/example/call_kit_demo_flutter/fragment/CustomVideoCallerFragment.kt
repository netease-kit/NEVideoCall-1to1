package com.example.call_kit_demo_flutter.fragment

import android.widget.ImageView
import android.widget.TextView
import com.bumptech.glide.Glide
import com.example.call_kit_demo_flutter.UserInfoCenter
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.caller.VideoCallerFragment
import com.netease.yunxin.nertc.ui.utils.dip2Px
import com.netease.yunxin.nertc.ui.utils.image.RoundedCornersCenterCrop

// 视频主叫界面
class CustomVideoCallerFragment : VideoCallerFragment() {
    private var userName: TextView? = null
    private var userAvatar: ImageView? = null

    override fun toBindView() {
        super.toBindView()
        // 获取父类的view控件
        userName = getView<TextView>(viewKeyTextUserName)
        userAvatar = getView<ImageView>(viewKeyImageUserInnerAvatar)
        // 解除父类对内部控件的引用避免重复渲染
        removeView(viewKeyTextUserName)
        removeView(viewKeyImageUserInnerAvatar)

    }

    override fun toRenderView(callParam: CallParam, uiConfig: P2PUIConfig?) {
        super.toRenderView(callParam, uiConfig)

        userName?.let { textView ->
            callParam.otherAccId?.let { accId ->
                UserInfoCenter.getName(accId)?.let { name ->
                    textView.text = name
                }
            }
        }

        userAvatar?.let { imageView ->
            callParam.otherAccId?.let { accId ->
                UserInfoCenter.getAvatar(accId)?.let { avatar ->
                    Glide.with(imageView.context.applicationContext).load(avatar)
                        .transform(RoundedCornersCenterCrop(4.dip2Px(imageView.context.applicationContext)))
                        .into(imageView)
                }
            }
        }
    }
}