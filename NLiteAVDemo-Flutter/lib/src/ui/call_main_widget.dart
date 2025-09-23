// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/call_define.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/impl/call_manager.dart';
import 'package:netease_callkit_ui/src/impl/call_state.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/ui/widget/calls/calls_widget.dart';

class NECallKitWidget extends StatefulWidget {
  final Function close;

  const NECallKitWidget({Key? key, required this.close}) : super(key: key);

  @override
  State<NECallKitWidget> createState() => _NECallKitWidgetState();
}

class _NECallKitWidgetState extends State<NECallKitWidget> {
  static const String _tag = "NECallKitWidget";
  NEEventCallback? onCallEndCallBack;

  @override
  void initState() {
    super.initState();
    CallKitUILog.i(_tag, 'NECallKitWidget initState');
    if (CallState.instance.selfUser.callStatus == NECallStatus.none) {
      Future.microtask(() {
        widget.close();
      });
    }
    onCallEndCallBack = (arg) {
      if (mounted) {
        widget.close();
      }
    };
    NEEventNotify().register(setStateEventOnCallEnd, onCallEndCallBack);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: CallsWidget(close: widget.close),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    CallKitUILog.i(_tag, 'NECallKitWidget dispose');
    NEEventNotify().unregister(setStateEventOnCallEnd, onCallEndCallBack);
    CallManager.instance.enableWakeLock(false);
  }
}
