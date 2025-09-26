## 云信一对一视频通话（Android）

本文主要展示如何集成云信的NIM SDK以及NERTC SDK，快速实现一对一视频通话功能。您可以直接基于我们的Demo修改适配，也可以使用我们提供的NERtcVideoCall组件，实现自定义UI。

### <span id="功能介绍">功能介绍</span>

- 视频呼叫/接听
- 开启/关闭麦克风
- 开启/关闭摄像头
- 切换前后摄像头
- 视频拒绝/挂断

### <span id="环境准备">环境准备</span>

1. 登录[网易云控制台](https://app.yunxin.163.com/index?clueFrom=nim&from=nim#/)，点击【应用】>【创建】创建自己的App，在【功能管理】中申请开通【信令】和【音视频通话2.0】功能。

2. 在控制台中【appkey管理】获取appkey。

3. 下载[场景Demo](https://github.com/netease-im/NEVideoCall-1to1/tree/develop/NLiteAVDemo-Android-Java)，app module 下 build.gradle 的如下内容替换自己的appkey，并将 key 同步给对应的 so 人员在后台添加应用体验权限；

   ```groovy
   def appKey = "Here, please fill your appKey!!!"
   ```

   

### <span id="运行示例项目">运行示例项目</span>


### <span id="功能实现">功能实现</span>
可参考[NERtcCallKit-Android](https://github.com/netease-kit/documents/tree/main/业务组件/呼叫组件)。

NERtcVideoCall组件：

   ![](https://yx-web-nosdn.netease.im/quickhtml%2Fassets%2Fyunxin%2Fdefault%2FIOS%E5%9C%BA%E6%99%AF%E5%AE%9E%E8%B7%B5%20%E9%99%84%E5%9B%BE.png)

#### 修改Demo源代码：

Demo跑通之后，可以修改工程文件夹下的Activity，复用**联系人搜索页**。

| 文件/文件夹                 | 功能             |
| :-------------------------- | :--------------- |
| NERTCSelectCallUserActivity | **联系人搜索页** |
