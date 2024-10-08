import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// methodChannel 名称
const channelNameCall = "com.example.call_kit_demo_flutter/channel/call";

// 账号一 accId
const account1 = "";

// 账号二 accId
const account2 = "";

// 账号一 token
const token1 = "";

// 账号二 token
const token2 = "";

// 发起呼叫
const callMethodName = "startCall";

const callParamAccId = "accId";

const callParamNameMap = "userInfoNameMap";

const callParamAvatarMap = "userInfoAvatarMap";

// IM 登录
const imLoginMethodName = "imLogin";

const imLoginParamAccId = "accId";

const imLoginParamToken = "token";

// IM 登出
const imLogoutMethodName = "imLogout";

// 通知 Flutter 呼叫组件状态方法
const notifyCallKitStateMethodName = "notifyCallKitState";
const notifyCallKitStateParamAccId = "accId";
const notifyCallKitStateParamState = "state";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String info = "组件不可用";
  String accountFlag = "";
  var methodChannel = const MethodChannel(channelNameCall);

  @override
  void initState() {
    super.initState();
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == notifyCallKitStateMethodName) {
        final params = call.arguments as Map?;
        if (params == null || params[notifyCallKitStateParamState] != true) {
          info = "组件不可用";
        } else if (params[notifyCallKitStateParamAccId] == account1) {
          accountFlag = "账号1";
          info = "IM 登录$accountFlag成功, 完成初始化 呼叫组件";
        } else if (params[notifyCallKitStateParamAccId] == account2) {
          accountFlag = "账号2";
          info = "IM 登录$accountFlag成功, 完成初始化 呼叫组件";
        }
        setState(() {});
        return "notifyCallKitStateMethodName";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(info),
            ElevatedButton(
                onPressed: () async {
                  accountFlag = "账号1";
                  final result = await methodChannel.invokeMethod(
                      imLoginMethodName,
                      {imLoginParamAccId: account1, imLoginParamToken: token1});

                  print("登录账号1结果：$result");
                },
                child: const Text("登录账号1")),
            ElevatedButton(
                onPressed: () {
                  methodChannel.invokeMethod(callMethodName, {
                    callParamAccId: account2,
                    // 自定义头像和昵称
                    callParamNameMap: {account1: "账号1", account2: "账号2"},
                    callParamAvatarMap: {
                      account1:
                          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201803%2F14%2F20180314140551_idj2m.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1696043526&t=d5fe1bc8a1fa8ae62a86f187a6a8f29a",
                      account2:
                          "https://img2.baidu.com/it/u=3557531149,769851715&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=1000"
                    }
                  });
                },
                child: const Text("呼叫账号2")),
            ElevatedButton(
                onPressed: () async {
                  final result = await methodChannel.invokeMethod(
                      imLoginMethodName,
                      {imLoginParamAccId: account2, imLoginParamToken: token2});
                  accountFlag = "账号2";
                  print("登录账号2结果$result");
                },
                child: const Text("登录账号2")),
            ElevatedButton(
                onPressed: () async {
                  methodChannel.invokeMethod(callMethodName, {
                    callParamAccId: account1,
                    // 自定义头像和昵称
                    callParamNameMap: {account1: "账号1", account2: "账号2"},
                    callParamAvatarMap: {
                      account1:
                          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201803%2F14%2F20180314140551_idj2m.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1696043526&t=d5fe1bc8a1fa8ae62a86f187a6a8f29a",
                      account2:
                          "https://img2.baidu.com/it/u=3557531149,769851715&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=1000"
                    }
                  });
                },
                child: const Text("呼叫账号1")),
            ElevatedButton(
                onPressed: () {
                  methodChannel.invokeMethod(imLogoutMethodName);
                  info = "组件不可用";
                  accountFlag = "";
                  setState(() {});
                },
                child: const Text("登出")),
          ],
        ),
      ),
    );
  }
}
