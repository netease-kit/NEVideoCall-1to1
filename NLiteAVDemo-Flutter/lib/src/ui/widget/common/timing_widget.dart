// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/impl/call_state.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';

class TimingWidget extends StatefulWidget {
  const TimingWidget({Key? key}) : super(key: key);

  @override
  State<TimingWidget> createState() => _TimingWidgetState();
}

class _TimingWidgetState extends State<TimingWidget> {
  NEEventCallback? refreshTimingCallBack;

  @override
  void initState() {
    super.initState();
    refreshTimingCallBack = (arg) {
      setState(() {});
    };
    NEEventNotify().register(setStateEventRefreshTiming, refreshTimingCallBack);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatCallTime(),
      textScaleFactor: 1.0,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    );
  }

  @override
  void dispose() {
    super.dispose();
    NEEventNotify()
        .unregister(setStateEventRefreshTiming, refreshTimingCallBack);
  }

  String _formatCallTime() {
    int hour = CallState.instance.timeCount ~/ 3600;
    String hourShow = hour <= 9 ? "0$hour" : "$hour";
    int minute = (CallState.instance.timeCount % 3600) ~/ 60;
    String minuteShow = minute <= 9 ? "0$minute" : "$minute";
    int second = CallState.instance.timeCount % 60;
    String secondShow = second <= 9 ? "0$second" : "$second";
    return hour > 0
        ? "$hourShow:$minuteShow:$secondShow"
        : "$minuteShow:$secondShow";
  }
}
