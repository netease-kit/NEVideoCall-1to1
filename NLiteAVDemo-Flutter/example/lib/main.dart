// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:callkit_example/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'config/app_config.dart';
import 'base/device_manager.dart';
import 'auth/auth_manager.dart';
import 'utils/nav_register.dart';
import 'constants/router_name.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 初始化应用配置
    await AppConfig().init();

    // await CallKitLog.init();

    // 初始化设备管理器
    await DeviceManager().init();

    // 初始化认证管理器
    await AuthManager().init();

    // 初始化 CallKit
    await initCallKit();

    runApp(const MyApp());
  }, (Object error, StackTrace stack) {
    print('crash exception: $error \ncrash stack: $stack');
  });
}

/// 初始化 CallKit
Future<void> initCallKit() async {
  try {
    final callkit = NECallKitUI.instance;

    // 调用 CallKit 初始化接口
    // final result = await callkit.setup(NESetupConfig(
    //   appKey: AppConfig().appKey,
    //   enableJoinRtcWhenCall: true,
    //   // initRtcMode: NECallInitRtcMode.global,
    // ));

    // if (result.code == 0) {
    //   print('CallKit 初始化成功');
    // } else {
    //   print('CallKit 初始化失败: ${result.msg}');
    // }
  } catch (e) {
    print('CallKit 初始化异常: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('MyApp build: navigatorObserver = ${NECallKitUI.navigatorObserver}');
    return MaterialApp(
      navigatorKey: CallKitUIL10n.navigatorKey,
      localizationsDelegates: [
        S.delegate,
        CallKitUIL10n.delegate,
        ...AppLocalizations.localizationsDelegates
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [NECallKitUI.navigatorObserver],
      color: Colors.black,
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      themeMode: ThemeMode.light,
      home: const WelcomePage(),
      onGenerateRoute: (settings) {
        WidgetBuilder builder =
            RoutesRegister.routes(settings)[settings.name] as WidgetBuilder;
        return MaterialPageRoute(
          builder: (ctx) => builder(ctx),
          settings: RouteSettings(name: settings.name),
        );
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    loadLoginInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black);
  }

  void loadLoginInfo() {
    AuthManager().autoLogin().then((value) {
      if (value) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouterName.homePage,
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouterName.loginPage,
          (route) => false,
        );
      }
    });
  }
}
