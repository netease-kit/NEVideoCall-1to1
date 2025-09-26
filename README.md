为了方便开发者接入音视频通话 2.0 的呼叫功能，网易云信将信令和 NERTC 的音视频能力相结合，简化呼叫的复杂流程，将呼叫功能以组件的形式提供给客户，提高接入效率、降低使用成本。呼叫组件（NECallKit）内部提供音视频类型通话的呼叫、接通、拒接，以及通话中音频和视频的开关控制，同时提供配套 UI，您可以使用呼叫组件实现类似通用即时通讯应用中的音视频通话功能。

## 架构简介
呼叫组件（NECallKit）是基于云信信令、音视频通话 2.0 和 IM 即时通讯产品封装的融合性场景组件，通过 NIM SDK 和 NERTC SDK 提供信令、通信和音视频能力，开发者可以直接使用呼叫组件（NECallKit）实现通话呼叫业务。


## 功能特性
| <div style="width: 200px">功能</div> | 描述 |
|---|---|
| 自定义 UI | 开发者可以自行设计通话和呼叫页面 UI。 |
| 音视频呼叫 | App 通过此功能通知被叫用户呼叫请求，呼叫请求类型包括音频和视频呼叫。 |
| 音视频通话 | 接通后可依照呼叫类型进行实时通话。 |
| 音视频控制 | 通话过程中可以控制本端音频或视频的开关，以及摄像头方向等。 |
| 话单 | 每次通话结束后都会收到对应的话单消息，标记本次通话是否接通以及通话时间、类型等数据。 |

## 平台支持

* Android
* iOS
* Web
* Flutter
* Uniapp

## 联系我们

- 如果想要了解该场景的更多信息，请参见[1 对 1 娱乐社交场景方案文档](https://doc.yunxin.163.com/1v1-social/docs/jk2OTI0NTM?platform=android)
- 如果您遇到问题，可以先查阅[知识库](https://faq.yunxin.163.com/kb/main/#/)
- 如果需要售后技术支持，请[提交工单](https://app.yunxin.163.com/index#/issue/submit)  

## 更多场景方案
网易云信针对1 对 1 娱乐社交、语聊房、PK连麦、在线教育等业务场景，推出了一体式、可扩展、功能业务融合的全链路解决方案，帮助客户快速接入、业务及时上线，提高营收增长。
- [云信娱乐社交服务端 Nemo](https://github.com/netease-kit/nemo)
- [语聊房](https://github.com/netease-kit/NEChatroom)
- [一起听](https://github.com/netease-kit/NEListenTogether)
- [在线K歌](https://github.com/netease-kit/NEKaraoke)
- [PK连麦](https://github.com/netease-kit/OnlinePK)
- [在线教育](https://github.com/netease-kit/WisdomEducation)
- [多人视频通话](https://github.com/netease-kit/NEGroupCall)
