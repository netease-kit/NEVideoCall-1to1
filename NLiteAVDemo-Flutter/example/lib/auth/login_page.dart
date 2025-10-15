// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:callkit_example/auth/login_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                    try {
                      final uri = Uri.parse(
                          'https://doc.yunxin.163.com/messaging2/guide/jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7');
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } catch (e) {
                      print('Failed to launch URL: $e');
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.how_to_get_account_token,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 20,
                  child: Text(AppLocalizations.of(context)!.sample_login_desc),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 30, top: 50, right: 30),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: _accountIdController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enter_account,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enter_token,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                      ToastUtils.showToast(context,
                          AppLocalizations.of(context)!.please_enter_account);
                      return;
                    }
                    final token = _tokenController.text.trim();
                    if (token.isEmpty) {
                      ToastUtils.showToast(context,
                          AppLocalizations.of(context)!.please_enter_token);
                      return;
                    }
                    login(accountId, token);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.start_exploring,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
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
        ToastUtils.showToast(
            context, AppLocalizations.of(context)!.login_success);
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(RouterName.homePage);
      } else {
        ToastUtils.showToast(context,
            "${AppLocalizations.of(context)!.login_failed} code = ${result.code}, msg = ${result.message}");
      }
    });
  }
}
