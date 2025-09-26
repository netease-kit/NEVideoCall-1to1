// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:callkit_example/settings/settings_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';

enum SettingWidgetType {
  avatar,
  extendInfo,
  offlinePush,
}

class SettingsDetailWidget extends StatefulWidget {
  final SettingWidgetType widgetType;

  const SettingsDetailWidget({Key? key, required this.widgetType})
      : super(key: key);

  @override
  State<SettingsDetailWidget> createState() => _SettingsDetailWidgetState();
}

class _SettingsDetailWidgetState extends State<SettingsDetailWidget> {
  String _data = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_getTitle()),
          leading: IconButton(
              onPressed: _goBack,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.control_point_sharp),
              tooltip: 'Search',
              onPressed: () => _setData(),
            ),
          ],
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: TextField(
              autofocus: true,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.please_enter,
                border: InputBorder.none,
              ),
              onChanged: (value) => _data = value),
        ));
  }

  _getTitle() {
    switch (widget.widgetType) {
      case SettingWidgetType.avatar:
        return AppLocalizations.of(context)!.avatar_settings;
      case SettingWidgetType.extendInfo:
        return AppLocalizations.of(context)!.extended_info_settings;
      case SettingWidgetType.offlinePush:
        return AppLocalizations.of(context)!.offline_push_info_settings;
    }
  }

  _setData() {
    switch (widget.widgetType) {
      case SettingWidgetType.avatar:
        SettingsConfig.avatar = _data;
        NECallKitUI.instance
            .setSelfInfo(SettingsConfig.nickname, SettingsConfig.avatar);
        break;
      case SettingWidgetType.extendInfo:
        SettingsConfig.extendInfo = _data;
        break;
    }
  }

  _goBack() {
    Navigator.of(context).pop();
  }
}
