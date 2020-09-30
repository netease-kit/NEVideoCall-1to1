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
3. 下载[场景Demo](https://github.com/netease-im/NEVideoCall-1to1/tree/develop/NLiteAVDemo-Android-Java)，将config.cpp中的appkey更换为自己的appkey。为了安全我们建议将appkey放在cpp文件中
4. 替换config.cpp中的baseURL 为自己的业务baseURL，实现验证码等登陆功能。

### <span id="运行示例项目">运行示例项目</span>
**注意：在运行前，请联系商务经理开通非安全模式（因Demo中RTCSDK中的token传空）。**


### <span id="功能实现">功能实现</span>
源码Demo的nertcvideocalldemo模块主要包含`model`、`ui`、`biz`三个个文件夹，其中Model文件夹包含了可重用的开源组件NERtcVideoCall，ui文件夹是业务UI，biz是业务相关内容，建议您自己实现。您可以在`NERtcVideoCall.java`中查看适用于一对一视频通话的接口。

NERtcVideoCall组件：

   ![](https://yx-web-nosdn.netease.im/quickhtml%2Fassets%2Fyunxin%2Fdefault%2FIOS%E5%9C%BA%E6%99%AF%E5%AE%9E%E8%B7%B5%20%E9%99%84%E5%9B%BE.png)

#### 修改Demo源代码：

Demo跑通之后，可以修改nertcvideocalldemo/ui文件夹下的Activity，复用**联系人搜索页**以及**视频通话页**。

|         文件/文件夹         |                   功能                   |
| :------------------------- | :-------------------------------------- |
| NERTCSelectCallUserActivity |             **联系人搜索页**             |
|    NERTCVideoCallActivity   |              **视频通话页**              |

#### 基于NERtcVideoCall实现自定义UI：

仅需拷贝nertcvideocalldemo/model文件夹到自己的工程，创建自定义UI界面，即可实现视频通话功能。具体步骤如下：

##### 步骤1:集成SDK

1. 使用Android Studio创建工程。

2. 通过 Gradle 集成信令SDK：具体可参考[云信信令SDK集成](https://dev.yunxin.163.com/docs/product/%E4%BF%A1%E4%BB%A4/SDK%E5%BC%80%E5%8F%91%E9%9B%86%E6%88%90/Android%E5%BC%80%E5%8F%91%E9%9B%86%E6%88%90/%E9%9B%86%E6%88%90%E6%96%B9%E5%BC%8F)

 ```
   dependencies {
    compile fileTree(dir: 'libs', include: '*.jar')
    // 添加依赖。注意，版本号必须一致。
    // 基础功能 (必需)
    compile 'com.netease.nimlib:basesdk:6.5.0'
    // 信令服务需要
    compile 'com.netease.nimlib:avsignalling:6.5.0'
   }
```

3. 集成SDK：

   ```
   api 'com.netease.yunxin:nertc:3.6.0'
   ```

4. 防止代码混淆，在 proguard-rules.pro 文件中，为 nertc sdk 添加 -keep 类的配置，这样可以防止混淆 nertc sdk 公共类名称:

   ```
   -keep class com.netease.lava.** {*;}
   -keep class com.netease.yunxin.** {*;}
   ```

##### 步骤2:添加权限

1. 打开 app/src/main/AndroidManifest.xml 文件，添加必要的设备权限。例如：

```
<uses-permission android:name="android.permission.INTERNET"/>
 <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
 <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
 <uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>
 <uses-permission android:name="android.permission.WAKE_LOCK"/>
 <uses-permission android:name="android.permission.CAMERA"/>
 <uses-permission android:name="android.permission.RECORD_AUDIO"/>
 <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
 <uses-permission android:name="android.permission.BLUETOOTH"/>
 <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
 <uses-permission android:name="android.permission.BROADCAST_STICKY"/>
 <uses-permission android:name="android.permission.READ_PHONE_STATE"/>
 <uses-feature android:name="android.hardware.camera"/>
 <uses-feature android:name="android.hardware.camera.autofocus"/>
```
2. 点击 Sync Project With Gradle Files , 重新同步 Android 项目文件。

##### 步骤3:初始化NERtcVideoCall组件并登录：

```
  public static NERTCVideoCall sharedInstance(Context context) {
        return NERTCVideoCallImpl.sharedInstance(context);
    }
```

##### 步骤4:发起呼叫

```
public abstract void call(String userId, ChannelType type);
```

##### 步骤5:接听呼叫

```
public abstract void accept(InviteParamBuilder invitedParam);
```

### NERtcVideoCall API

####**NERtcVideoCall**组件的 **API接口**列表如下：

| **接口名**      | **接口描述**             |
| :---------------- | :---------------------------------------- |
| **setupAppKey**      | **初始化，所有功能需要先初始化**           |
| call             | 开始呼叫                                 |
| cancel           | 取消呼叫                                 |
| accept           | 接受呼叫                                 |
| reject           | 拒绝呼叫                                 |
| hangup           | 挂断                                     |
| setupLocalView   | 设置自己画面                             |
| setupRemoteView  | 设置其他用户画面                         |
| enableCamera     | 开启/关闭摄像头                          |
| setMicMute       | 开启/关闭麦克风                          |
| switchCamera     | 切换摄像头                               |
| addDelegate      | 添加代理，接收回调                       |

####**NERtcVideoCall**组件的**回调接口(NERTCCallingDelegate)**列表如下：

| **接口名**      | **接口描述**             |
| :----------------- | :--------------- |
| onInvitedByUser   | 收到对方邀请    |
| onUserEnter       | 对方接受呼叫    |
| onRejectByUserId  | 对方拒绝邀请    |
| onCancelByUserId  | 对方取消邀请    |
| onUserBusy        | 对方忙线        |
| timeOut           | 邀请超时        |
| onCameraAvailable | 开启/关闭相机   |
| onAudioAvailable  | 开启/关闭麦克风 |
| onUserHangup      | 对方挂断        |