// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:callkit_example/auth/login_page.dart';
import 'package:callkit_example/pages/single_call_page.dart';
import 'package:callkit_example/service/call_record_service.dart';
import 'package:callkit_example/service/call_record_service_impl.dart';
import 'package:callkit_example/settings/settings_config.dart';
import 'package:netease_callkit_ui/src/utils/callkit_ui_log.dart';
import 'package:callkit_example/utils/record_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nim_core_v2/nim_core.dart';
import '../auth/auth_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePageRoute extends StatefulWidget {
  const HomePageRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageRouteState();
  }
}

class _HomePageRouteState extends State<HomePageRoute> {
  static const _tag = "_HomePageRouteState";

  String _version = 'Unknown';
  final _callkitPlugin = NECallEngine.instance;
  late StreamSubscription _messageSubscription;
  final CallRecordServiceImpl _callRecordService = CallRecordServiceImpl();

  @override
  void initState() {
    super.initState();
    _messageSubscription = NimCore.instance.messageService.onReceiveMessages
        .listen((messages) async {
      for (var message in messages) {
        CallRecord? record = await RecordUtils.parseForCallRecord(message);
        if (record != null) {
          _addCallRecord(record);
        }
      }
    });
    getVersion();
    _requestNotificationPermissions();
  }

  void _requestNotificationPermissions() async {
    [
      Permission.notification,
    ].request();
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
  }

  Future<void> getVersion() async {
    String version;
    try {
      version = await _callkitPlugin.getVersion();
    } catch (e) {
      version = 'Failed to get version: $e';
    }

    if (!mounted) return;

    setState(() {
      _version = version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [_getUserInfo(), _getAppInfo(), _getBtnWidget()],
          ),
        ));
  }

  _getUserInfo() {
    return Positioned(
        left: 10,
        top: 50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Text(
                "${AppLocalizations.of(context)!.login_info}：",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Row(
              children: [
                Container(
                    width: 55,
                    height: 55,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(27.5)),
                    ),
                    child: InkWell(
                      child: Image(
                        image: NetworkImage(SettingsConfig.avatar.isNotEmpty
                            ? SettingsConfig.avatar
                            : SettingsConfig.defaultAvatar),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stackTrace) =>
                            Image.asset('images/people.webp'),
                      ),
                      onTap: () => _showDialog(),
                    )),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    AuthManager().nickName ?? '',
                    style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.normal,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onDoubleTap: () {
                      final accountId = AuthManager().accountId;
                      if (accountId != null) {
                        Clipboard.setData(ClipboardData(text: accountId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account ID copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'accountId: ${AuthManager().accountId}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                  )
                ])
              ],
            )
          ],
        ));
  }

  _getAppInfo() {
    return Positioned(
        left: 10,
        top: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Text(
                "${AppLocalizations.of(context)!.app_info}:",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              child: Text("Version:$_version"),
            )
          ],
        ));
  }

  _getBtnWidget() {
    return Positioned(
        left: 0,
        bottom: 84,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 52,
              width: MediaQuery.of(context).size.width * 5 / 6,
              child: ElevatedButton(
                  onPressed: () => _goSingleCallWidget(),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xff056DF6)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_outline_outlined),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.single_call,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  )),
            ),
            const SizedBox(height: 20),
          ],
        ));
  }

  _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.logout),
            actions: [
              CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop()),
              CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.confirm),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _logout();
                  })
            ],
          );
        });
  }

  _logout() {
    AuthManager().logout();
    NECallKitUI.navigatorObserver.navigator?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (widget) {
      return const LoginRoute();
    }), (route) => false);
  }

  _goSingleCallWidget() async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const SingleCallWidget();
      },
    ));
  }

  // 添加通话记录并保存
  Future<void> _addCallRecord(CallRecord record) async {
    CallKitUILog.i(_tag, "_addCallRecord: $record");
    await _callRecordService.addRecordToCurrentAccount(record);
  }
}
