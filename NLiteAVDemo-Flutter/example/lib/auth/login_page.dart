// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:callkit_example/auth/client/http_code.dart';
import 'package:callkit_example/auth/login_info.dart';
import 'package:flutter/material.dart';
import '../../constants/strings.dart';
import 'auth_manager.dart';
import 'service/app_service.dart';
import '../../utils/loading.dart';
import '../../utils/toast_utils.dart';
import '../../constants/router_name.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginRoute> {
  static const _tag = 'SampleLoginState';

  final TextEditingController _accountController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 241, 244, 1),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 200,
                child: Icon(
                  Icons.phone_android,
                  size: 100,
                  color: Colors.blue,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 20,
                child: Text(Strings.sampleLoginDesc),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 30, top: 50, right: 30),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: TextField(
                  controller: _accountController,
                  decoration: const InputDecoration(
                    hintText: '请输入账号',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.only(left: 30, top: 250, right: 30),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.blue.withOpacity(0.5);
                    }
                    return Colors.blue;
                  }),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 13),
                  ),
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue, width: 0),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                  ),
                ),
                onPressed: () {
                  final accountId = _accountController.text.trim();
                  if (accountId.isEmpty) {
                    ToastUtils.showToast(context, '请输入云信账号');
                    return;
                  }
                  createAccountThenLogin(accountId);
                },
                child: const Text(
                  Strings.startExploring,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createAccountThenLogin(String accountId) async {
    // 创建账号并登录
    print("createAccountThenLogin");
    LoadingUtil.showLoading();
    AppService().loginByNemo(accountId).then((result) {
      print("createAccountThenLogin result:$result");
      if (result.code == HttpCode.success && result.data != null) {
        LoginInfo loginInfo = LoginInfo(
          accountId: result.data!.userUuid ?? "",
          accountToken: result.data!.userToken ?? "",
          nickname: result.data!.userName,
          avatar: result.data!.icon,
        );

        AuthManager().loginCallKitWithToken(loginInfo).then((result) {
          print('loginCallKitWithToken result = ${result.code}');
          LoadingUtil.hideLoading();
          if (result.code == 0) {
            ToastUtils.showToast(context, Strings.loginSuccess);
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(RouterName.homePage);
          } else {
            ToastUtils.showToast(context,
                "${Strings.loginFailed} code = ${result.code}, msg = ${result.msg}");
          }
        });
      } else {
        LoadingUtil.hideLoading();
        ToastUtils.showToast(context,
            "create nemo account failed,code:${result.code},msg:${result.msg}");
      }
    });
  }
}
