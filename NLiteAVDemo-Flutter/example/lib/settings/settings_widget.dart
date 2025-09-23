// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:callkit_example/settings/settings_config.dart';
import 'package:callkit_example/settings/settings_detail_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit/netease_callkit.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        leading: IconButton(
            onPressed: () => _goBack(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
        child: ListView(
          children: [
            _getBasicSettingsWidget(),
            _getCallParamsSettingsWidget(),
          ],
        ),
      ),
    );
  }

  _getBasicSettingsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: Text(
            AppLocalizations.of(context)!.settings,
            style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                color: Colors.black54),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.enable_floating,
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              Switch(
                  value: SettingsConfig.enableFloatWindow,
                  onChanged: (value) {
                    setState(() {
                      SettingsConfig.enableFloatWindow = value;
                      NECallKitUI.instance
                          .enableFloatWindow(SettingsConfig.enableFloatWindow);
                    });
                  })
            ],
          ),
        ),
        if (Platform.isAndroid)
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.show_incoming_banner,
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                Switch(
                    value: SettingsConfig.showIncomingBanner,
                    onChanged: (value) {
                      setState(() {
                        SettingsConfig.showIncomingBanner = value;
                        NECallKitUI.instance.enableIncomingBanner(
                            SettingsConfig.showIncomingBanner);
                      });
                    })
              ],
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  _getCallParamsSettingsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: Text(
            AppLocalizations.of(context)!.call_custom_setiings,
            style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                color: Colors.black54),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.timeout,
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextField(
                      autofocus: true,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: '${SettingsConfig.timeout}',
                        border: InputBorder.none,
                      ),
                      onChanged: ((value) async {
                        try {
                          final timeout = int.parse(value);
                          SettingsConfig.timeout = timeout;
                          // 当 timeout 值改变时，调用 setTimeout 接口
                          await NECallEngine.instance.setTimeout(timeout);
                        } catch (e) {
                          print('Failed to set timeout: $e');
                        }
                      })))
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.extended_info,
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              InkWell(
                  onTap: () => _goDetailSettings(SettingWidgetType.extendInfo),
                  child: Row(children: [
                    Text(
                      SettingsConfig.extendInfo.isEmpty
                          ? AppLocalizations.of(context)!.not_set
                          : SettingsConfig.extendInfo,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(width: 10),
                    const Text('>')
                  ]))
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  _goBack() {
    Navigator.of(context).pop();
  }

  _goDetailSettings(SettingWidgetType widgetType) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return SettingsDetailWidget(widgetType: widgetType);
      },
    ));
  }
}
