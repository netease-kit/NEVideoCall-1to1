# README.md
Demo 中演示了如何将自定义的名称和头像传入到组件中，初始化以及发起呼叫的能力。

[TOC]

## Demo 运行配置

**需要配置应用的 appKey 和 用户的 accId 和 token，需要准被两个账号，用于呼叫别人和接通；**

原生呼叫组件的使用文档请参考 

Android： https://doc.yunxin.163.com/nertccallkit/docs/home-page?platform=android 

iOS：https://doc.yunxin.163.com/nertccallkit/docs/home-page?platform=iOS



### 1. Flutter

在 flutter 的 main.dart 文件中找到 `accound1` 、`account2`、 `token1`、 `token2`变量并赋值；

### 2. Android

在 Android 的 MainActivity.kt 文件中找到 `appKey`  变量并填写对应的数据；

### 3. iOS
在 AppDelegate 替换 `appkey`

在  GeneratedPluginRegistrant 类中 registerWithRegistry 方法中添加  [NECallKitPlugin registerWithRegistrar:[registry registrarForPlugin:@"callkit"]];

示例
```objc
+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
    [NECallKitPlugin registerWithRegistrar:[registry registrarForPlugin:@"callkit"]];
}
```



直接运行即可，运行在两台不同的移动设备中，一台设备登录账号1，一台设备登录账号2，可以在登录账号1的设备呼叫账号2，或在登录账号2的设备呼叫账号1。



## 代码说明

Flutter 和原生应用在demo中的通信通过 MethodChannel 机制完成。

Demo 对 MethodChannel 使用到的参数中定义如下：

1. MethodChannel构建名称 Flutter 和原生必须一致，可以按照自己的需求修改，保证多端一致即可：**`com.example.call_kit_demo_flutter/channel/call`** 

2. 通信方法参数/及返回格式说明：

   1. 方法入参数：格式都是 `Map<String, Object>` ，String 定义参数名称， Object 定义具体参数值；

   2. 方法返回结果：返回的 `result` 都是成功，失败通过具体参数体现如形式为 

      `Map<String,Map<String, Object>>` 其中外层 Map 通过 `result` 参数解析，内层 Map 定义如下 

      code 对应方法结果 200 为成功，其余为失败；msg 对应方法信息说明。这两个字段固定，其余字段按照需求添加

      ```kotlin
      result.success(mapOf("result" to mapOf("code" to code, "msg" to "登录失败")))
      ```

3. IM 登录方法：

   1. 方法定义：`imLogin`

   2. 入参定义：

      ```json
      {
        "accId": "当前登录用户 accid",
        "token": "当前登录用户 token"
      }
      ```

   3. 返回定义：

      ```json
      {
        "result":{
          "code":200,
          "msg":"登录成功"
        }
      }
      ```

4. IM 登出方法：

   1. 方法定义：`imLogout`
   2. 入参定义：无
   3. 返回定义：

      ```json
      {
        "result":{
          "code":200,
          "msg":"登出成功"
        }
      }
      ```

5. 发起呼叫方法：

   1. 方法定义：`startCall`

   2. 入参定义：

      ```json
      {
        "accId": "被叫用户 accid",
        "userInfoNameMap": {
          "用户accId":"对应用户自定义名称",
          "用户accId1":"对应用户1自定义名称",
        },
        "userInfoAvatarMap":{
          "用户accId":"对应用户头像链接地址",
          "用户accId1":"对应用户1头像链接地址"
        }
      }
      ```

   3. 返回定义：

      ```json
      {
        "result":{
          "code":200,
          "msg":"呼叫成功"
        }
      }
      ```

6. 查询呼叫组件是否可用方法：

   1. 方法定义：`callKitCanBeUsed`

   2. 入参定义：无

   3. 返回定义：

      ```json
      {
        "result":{
          "code":200,
          "msg":"查询成功",
          "data":true // 呼叫组件状态，true 可用，false 不可用
        }
      }
      ```

7. 主动通知Flutter呼叫组件是否可用方法：

   1. 方法定义：`notifyCallKitState`

   2. 参数定义：

      ```json
      {
        "accId":"当前登录IM 的账号",
        "state": true，// 呼叫组件状态，true 可用，false 不可用
      }
      ```

      


### 1. Flutter 

Flutter 代码不需要复制，可以参考方法调用，主要还是原生层代码。

### 2. Android 

Demo 中已经实现了呼叫组件自定义ui实现，外部设置用户的昵称和头像，

`UserInfoCenter` 用于记录 accId 对应的头像和昵称，内部通过 map 实现。

`MainActivity` 中的代码可以参考复制，主要为 `imLogin`、`initCallKit`、 `startCall`、`getCallKitState`、`imLogout` 方法可以直接复制使用，参考 onCreate 方法中 云信 IM sdk 的初始化以及监听登录成功后自动初始化呼叫组件。

`SelfCustomCallActivity`以及 fragment 文件夹下的文件可以直接复制使用，主要为自定义ui相关内容设置了自定义的头像和昵称。

不要忘记 AndroidManifest 文件中 `SelfCustomCallActivity` 的注册。

### 3. iOS



## 其他注意点

### 1. 登录

#### 登录失败：

在调用登录成功接口时可以得到异步返回值了解是否登录成功，若云信登录IM 失败可以根据返回值确定，若登录失败则无法使用呼叫组件功能，若尝试后仍无法登录成功，可以在ui上给用户提示音视频通话功能不可用。

```dart
final result = 
  await methodChannel
  .invokeMethod(imLoginMethodName,{imLoginParamAccId:account1, imLoginParamToken:token1}
               );
print("登录结果 $result");
```



#### 自动/手动登录：

Android如下：

Demo 内部在登录成功的回调处通过 Android 的 sharedPreferences 工具记录了登录的IM 账号及其token在本地

```kotlin
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
    result.success(mapOf("result" to mapOf("code" to 200, "msg" to "登录成功")))
  }
  override fun onFailed(code: Int) {
    Log.d(logTag, "登录失败")
    result.success(mapOf("result" to mapOf("code" to code, "msg" to "登录失败")))
  }
  override fun onException(exception: Throwable?) {
    Log.d(logTag, "登录异常")
    result.success(
      mapOf("result" to mapOf( "code" to -1, "msg" to "登录异常:${exception?.message}" ))
    )              
  }
})
```

在账号登出的接口出清理本地记录的账号和token

```kotlin
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
```

在 IM 账号登录成功且未登出状态下在初始化 IM sdk 的接口处传入需要登录的账号和 token 完成自动登录

```kotlin
 // 自动登录，从本地获取账号和 token
val sharedPreferences = getSharedPreferences(spLoginFileName, Context.MODE_PRIVATE)
val accId = sharedPreferences.getString(spKeyLoginAccId, null).apply {
  Log.e(logTag, "onCreate accId: $this")
}
val token = sharedPreferences.getString(spKeyLoginToken, null).apply {
  Log.e(logTag, "onCreate token: $this")
}
// 初始化 IM sdk
NIMClient.init(this, LoginInfo(accId, token), SDKOptions().apply {
  appKey = "具体的appKey"
})
```

自动登录成功也会触发如下回调，所以可以通过如下方式来通知 flutter 层是否可以使用呼叫能力，需要注意调用如下代码必须要保证已经调用了 IM sdk 的初始化功能

```kotlin
// 监听云信 IM 登录状态
NIMClient.getService(AuthServiceObserver::class.java)
.observeOnlineStatus({
  status ->
  Log.d(logTag, "onCreate status: $status")
  // 此处判断是因为 IM 在网络断开重连是会触发此回调，回调状态为 LOGINED，避免重复初始化呼叫组件
  if (status == StatusCode.LOGINED && !TextUtils.equals(
    CallKitUI.currentUserAccId, NIMClient.getCurrentAccount()
  )) {
    // 登录成功初始化呼叫组件
    initCallKit(context)
    // 通知外部登录成功用于以及登录的账号，外部收到此通知说明已经完成呼叫组件登录可以发起呼叫
    methodChannel.invokeMethod(notifyLoginMethodName, NIMClient.getCurrentAccount())
  }
}, true)
```





iOS 如下：







