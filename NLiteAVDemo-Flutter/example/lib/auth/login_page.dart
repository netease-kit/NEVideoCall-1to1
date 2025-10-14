// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:callkit_example/auth/login_info.dart';
import 'package:flutter/material.dart';
import '../../constants/strings.dart';
import 'auth_manager.dart';
import '../../utils/loading.dart';
import '../../utils/toast_utils.dart';
import '../../constants/router_name.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginRoute> {
  static const _tag = 'SampleLoginState';

  final TextEditingController _accountIdController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    _tokenController.dispose();
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
            const Align(
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
            // Link to open registration doc in external browser
            Container(
              margin: const EdgeInsets.only(left: 30, top: 12, right: 30),
              child: GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(
                      'https://doc.yunxin.163.com/messaging2/guide/jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7');
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: const Text(
                  '如何获取云信账号与Token',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
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
                  controller: _accountIdController,
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
              margin: const EdgeInsets.only(left: 30, top: 50, right: 30),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    hintText: '请输入Token',
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
                  final accountId = _accountIdController.text.trim();
                  if (accountId.isEmpty) {
                    ToastUtils.showToast(context, '请输入云信账号');
                    return;
                  }
                  final token = _tokenController.text.trim();
                  if (token.isEmpty) {
                    ToastUtils.showToast(context, '请输入账号对应的Token');
                    return;
                  }
                  login(accountId, token);
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

  void login(String accountId, String token) async {
    // 创建账号并登录
    print("createAccountThenLogin");
    LoadingUtil.showLoading();
    LoginInfo loginInfo = LoginInfo(
      accountId: accountId,
      accountToken: token,
      nickname: accountId,
      avatar: "",
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
            "${Strings.loginFailed} code = ${result.code}, msg = ${result.message}");
      }
    });
  }
}
