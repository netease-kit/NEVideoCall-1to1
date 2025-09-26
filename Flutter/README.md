# 网易云信音视频通话

本文主要介绍云信的呼叫组件，帮助您快速实现一对一音视频通话功能。您可以直接基于我们的Demo修改适配，也可以使用我们提供的CallKit组件，实现自定义UI。

## 产品特性

<p align="center">
  <img src="https://yx-web-nosdn.netease.im/common/afb33761ed9791af7d81b2d12d436c35/call_ui_sample.png"/>
</p>

- **完善的 UI 交互**：我们提供含 UI 的开源组件 NECallKit，可以节省您 90% 开发时间，您只需要花20分钟就可以拥有一款类似微信、FaceTime 的视频通话应用。
- **多平台互联互通**：我们支持Web、Android、iOS等各个平台，同时也支持类似uni-app等跨平台框架，您可以使用不同平台的 NECallKit 组件支持相互呼叫、接听、挂断等。
- **移动端离线推送**：我们支持Android、iOS 的离线唤醒，当您的应用处于离线状态时，也可以及时收到来电提醒，目前已经支持Google FCM、Apple、小米、华为、OPPO、VIVO、魅族等多个推送服务
- **多设备登录**：我们也支持您可以在不同平台上登录多台设备，您可以同时在您的Pad、手机登录，更大屏幕，体验更好跟更灵活。

## 开始使用

这里以 含 UI 的集成（即NECallKit）为例，这也是我们推荐的集成方式，关键步骤如下：

- **Step1**：登录[网易云控制台](https://app.yunxin.163.com/index?clueFrom=nim&from=nim#/)，点击【应用】>【创建】创建自己的App，在【功能管理】中申请开通【信令】和【音视频通话2.0】功能。
- **Step2**：接入 NECallKit 到您的项目中，各平台/框架详细的接入流程：[Flutter](https://doc.yunxin.163.com/nertccallkit/guide/DYyMDk4OTY?platform=flutter) 
- **Step3**：拨打您的第一个视频通话！

## 联系我们

- 如果想要了解该场景的更多信息，请参见[音视频呼叫文档](https://doc.yunxin.163.com/nertccallkit/guide/DYyMDk4OTY?platform=flutter)
- 完整的API文档请参见[API参考](https://doc.yunxin.163.com/nertccallkit/client-apis?platform=client)
- 如果您遇到的问题，可以先查阅[知识库](https://faq.yunxin.163.com/kb/main/#/)
- 如果需要售后技术支持，请[提交工单](https://app.yunxin.163.com/index#/issue/submit)


## 更多场景方案

网易云信针对1V1娱乐社交、语聊房、PK连麦、在线教育等业务场景，推出了一体式、可扩展、功能业务融合的全链路解决方案，帮助客户快速接入、业务及时上线，提高营收增长。

- [1对1 娱乐社交](https://github.com/netease-kit/1V1)
- [语聊房](https://github.com/netease-kit/NEChatroom)
- [PK连麦](https://github.com/netease-kit/OnlinePK)
- [在线教育](https://github.com/netease-kit/WisdomEducation)
- [多人视频通话](https://github.com/netease-kit/NEGroupCall)
- [一起听](https://github.com/netease-kit/NEListenTogether)
- [在线K歌](https://github.com/netease-kit/NEKaraoke)
- [云信娱乐社交服务端 Nemo](https://github.com/netease-kit/nemo)