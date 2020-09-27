## 云信一对一视频通话（iOS）

本文主要展示如何集成云信的NIMSDK以及NERtcSDK，快速实现一对一视频通话功能。您可以直接基于我们的Demo修改适配，也可以使用我们提供的NERtcVideoCall组件，实现自定义UI。

### 功能介绍

- 视频呼叫/接听
- 开启/关闭麦克风
- 开启/关闭摄像头
- 切换前后摄像头
- 视频拒绝/挂断

### 环境准备

1. 登录[网易云控制台](https://app.yunxin.163.com/index?clueFrom=nim&from=nim#/)，点击【应用】>【创建】创建自己的App，在【功能管理】中申请开通【信令】和【音视频通话】功能。
2. 在控制台中【App Key管理】获取App Key。
3. 下载[场景Demo]()，将AppDelegate.m中的App Key更换为自己的App Key。

### 运行示例项目

**注意：在运行前，请联系商务经理开通非安全模式（因Demo中RTCSDK中的token传空）。**

1. 下载完成场景Demo后，终端进入Podfile所在文件夹，执行`pod install`命令。如未安装Cocoapods，请参考[安装说明](https://guides.cocoapods.org/using/getting-started.html#getting-started)。
2. 执行 `pod install` 完成安装后，双击 `NLiteAVDemo.xcworkspace` 通过 Xcode 打开工程。然后打开 `AppDelegate.h` 文件，填入您的AppKey，`APNSCerName`和`VoIPCerName`可以需要时再填写。随后运行工程即可。

### 功能实现

源码Demo的NERtcVideoCall模块主要包含`Model`、`UI`、`Task`三个文件夹，其中Model文件夹包含了可重用的开源组件NERtcVideoCall，您可以在`NERtcVideoCall.h`中查看适用于一对一视频通话的接口。

1. NERtcVideoCall组件：

   ![](https://github.com/netease-im/NEVideoCall-1to1/blob/feature/feature_iOS/NLiteAVDemo-iOS-ObjC/Images/image-20200902204955182.png)

#### 修改Demo源代码：

Demo跑通之后，可以修改NERtcVideoCall/UI文件夹下的类文件，复用**联系人搜索页**以及**视频通话页**。

|         文件/文件夹         |                   功能                   |
| :-------------------------: | :--------------------------------------: |
|          AppKey.h           |   配置AppKey、推送证书名称、服务器域名   |
|    NEMenuViewController     |               功能列表首页               |
| NERtcContactsViewController |             **联系人搜索页**             |
|    NECallViewController     |              **视频通话页**              |
|           Login/            |            登录&注册功能模块             |
|          Service/           |             网络请求功能模块             |
|           Utils/            | 通用功能：UI父类、分类、宏定义、账户信息 |

#### 基于NERtcVideoCall实现自定义UI：

仅需拷贝NERtcVideoCall/Model文件夹到自己的工程，导入`NERtcVideoCall.h`头文件，创建自定义UI界面，即可实现视频通话功能。具体步骤如下：


#### 复用UI：

Demo跑通之后，可以修改NERtcVideoCall/UI文件夹下的类文件，复用**联系人搜索页**以及**视频通话页**UI。

#### 自定义UI：

仅需拷贝NERtcVideoCall/Model文件夹到自己的工程，导入`NERtcVideoCall.h`头文件，创建自定义UI界面，即可实现视频通话功能。具体步骤如下：


##### 步骤1:集成SDK

1. 使用Xcode创建工程，进入/iOS/NLiteAVDemo目录，执行`pod init`，创建Podfile文件。

2. 编辑Podfile文件并执行`pod install`：

   ```objc
   pod 'NERtcSDK', '~> 3.5.1'
   pod 'NIMSDK_LITE', '~> 7.8.4'
   ```

   

3. 拷贝/iOS/NLiteAVDemo/NERtcVideoCall/Model文件夹下所有类文件到项目，在自定义UI页面导入头文件：

   ```objc
   #import "NERtcVideoCall.h"
   ```

##### 步骤2:添加权限

1. 在`Info.plist`文件中添加相机、麦克风访问权限：

   ```
   Privacy - Camera Usage Description
   Privacy - Microphone Usage Description
   ```

2. 在工程的`Signing&Capabilities`添加`Push Notifications`能力。

3. 在工程的`Signing&Capabilities`添加`Background Modes`，并勾选`Audio、Airplay、and Picture in Picture`。

##### 步骤3:初始化NERtcVideoCall组件并登录：

```objc
// 初始化 参数为云信控制台注册的App Key
[[NERtcVideoCall shared] setupAppKey:@""];

// 登录 所有功能要在登录之后调用
NEUser *user = [[NEUser alloc] init];
user.imAccid = @"";
user.imToken = @"";
user.avatar = @"";
user.mobile = @"";
[[NERtcVideoCall shared] login:user success:^{

} failed:^(NSError * _Nonnull error) {

}];
```

##### 步骤4:发起呼叫

```objc
NEUser *userB = [[NEUser alloc] init];
userB.imAccid = @"";
userB.imToken = @"";
[[NERtcVideoCall shared] call:userB completion:^(NSError * _Nullable error) {

}];
```

##### 步骤5:接听呼叫

```
[[NERtcVideoCall shared] acceptCompletion:^(NSError * _Nullable error) {

}];
```

##### NERtcVideoCall API

**NERtcVideoCall**组件的 API 接口列表如下：

| setupAppKey      | 初始化，所有功能需要先初始化             |
| ---------------- | ---------------------------------------- |
| login            | 登录IM，所有功能需要先进行登录后才能使用 |
| logout           | 登出IM                                   |
| call             | 开始呼叫                                 |
| cancel           | 取消呼叫                                 |
| acceptCompletion | 接受呼叫                                 |
| reject           | 拒绝呼叫                                 |
| hangup           | 挂断                                     |
| setupLocalView   | 设置自己画面                             |
| setupRemoteView  | 设置其他用户画面                         |
| enableCamera     | 开启/关闭摄像头                          |
| setMicMute       | 开启/关闭麦克风                          |
| switchCamera     | 切换摄像头                               |
| addDelegate      | 添加代理，接收回调                       |

**NERtcVideoCall**组件的**回调接口**列表如下：

| onInvitedByUser   | 收到对方邀请    |
| ----------------- | --------------- |
| onUserEnter       | 对方接受呼叫    |
| onRejectByUserId  | 对方拒绝邀请    |
| onCancelByUserId  | 对方取消邀请    |
| onUserBusy        | 对方忙线        |
| timeOut           | 邀请超时        |
| onCameraAvailable | 开启/关闭相机   |
| onAudioAvailable  | 开启/关闭麦克风 |
| onUserHangup      | 对方挂断        |





