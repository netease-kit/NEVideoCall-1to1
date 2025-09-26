// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:netease_callkit_ui/src/call_define.dart';
import 'package:netease_callkit_ui/src/impl/call_state.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/utils/preference.dart';

class CallingBellFeature {
  static const _tag = "CallingBellFeature";
  static FileSystem fileSystem = const LocalFileSystem();
  static String keyRingPath = "key_ring_path";
  static String package = "packages/";
  static String pluginName = "netease_callkit_ui/";
  static String assetsPrefix = "assets/audios/";
  static String callerRingName = "avchat_connecting.mp3";
  static String calledRingName = "avchat_ring.mp3";
  static bool cancelStartRing = false;

  static Future<void> startRing() async {
    CallKitUILog.i(_tag, 'CallingBellFeature startRing');
    cancelStartRing = false;
    String filePath =
        await PreferenceUtils.getInstance().getString(keyRingPath);
    if (filePath.isNotEmpty &&
        NECallRole.called == CallState.instance.selfUser.callRole) {
      NECallKitPlatform.instance.startRing(filePath);
      return;
    }

    final String tempDirectory = await getTempDirectory();
    filePath = "$tempDirectory/$callerRingName";
    String assetsName = callerRingName;
    if (NECallRole.called == CallState.instance.selfUser.callRole) {
      filePath = "$tempDirectory/$calledRingName";
      assetsName = calledRingName;
    }
    final file = fileSystem.file(filePath);
    if (!await file.exists()) {
      ByteData byteData =
          await loadAsset('$package$pluginName$assetsPrefix$assetsName');
      await file.create();
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
    if (!cancelStartRing) {
      NECallKitPlatform.instance.startRing(file.path);
    }
  }

  static Future<String> getAssetsFilePath(String assetName) async {
    if (assetName.isEmpty) {
      return "";
    }
    final String tempDirectory = await getTempDirectory();
    String filePath = "$tempDirectory/$assetName";
    final file = fileSystem.file(filePath);
    if (!await file.exists()) {
      ByteData byteData = await loadAsset(assetName);
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
    return file.path;
  }

  static Future<void> stopRing() async {
    CallKitUILog.i(_tag, 'CallingBellFeature stopRing');
    cancelStartRing = true;
    NECallKitPlatform.instance.stopRing();
  }

  //path: The format of the path parameter in the plugin is 'package$pluginName$assetsPrefix$assetsName'
  @visibleForTesting
  static Future<ByteData> loadAsset(String path) => rootBundle.load(path);

  @visibleForTesting
  static Future<String> getTempDirectory() async =>
      (await getTemporaryDirectory()).path;
}
