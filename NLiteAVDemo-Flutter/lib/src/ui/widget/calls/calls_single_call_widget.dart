// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/call_define.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/ui/widget/calls/calls_user_widget_data.dart';
import 'package:netease_callkit_ui/src/impl/call_manager.dart';
import 'package:netease_callkit_ui/src/impl/call_state.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/data/user.dart';
import 'package:netease_callkit_ui/src/utils/string_stream.dart';

class CallsIndividualUserWidget extends StatefulWidget {
  final Function close;

  const CallsIndividualUserWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CallsIndividualUserWidgetState();
}

class _CallsIndividualUserWidgetState extends State<CallsIndividualUserWidget>
    with SingleTickerProviderStateMixin {
  static const String _tag = "CallsIndividualUserWidget";
  NEEventCallback? setSateCallBack;
  // 为大画面和小画面创建独立的Key，避免GlobalKey冲突
  final Key _localBigKey = GlobalKey(debugLabel: "local_big");
  final Key _remoteBigKey = GlobalKey(debugLabel: "remote_big");
  final Key _localSmallKey = GlobalKey(debugLabel: "local_small");
  final Key _remoteSmallKey = GlobalKey(debugLabel: "remote_small");

  // 添加动画控制器和状态管理
  late AnimationController _animationController;

  // 用于防止视频切换时的闪烁
  bool _isTransitioning = false;

  // 创建大画面专用的视频view
  Widget _createBigVideoView(bool isLocal) {
    return NECallkitVideoView(
        key: isLocal ? _localBigKey : _remoteBigKey,
        onPlatformViewCreated: (viewId) {
          if (isLocal) {
            CallState.instance.selfUser.viewID = viewId;
            CallManager.instance.setupLocalView(viewId);
            if (CallState.instance.isCameraOpen) {
              CallManager.instance
                  .openCamera(CallState.instance.camera, viewId);
            }
          } else {
            if (CallState.instance.remoteUserList.isNotEmpty) {
              CallState.instance.remoteUserList[0].viewID = viewId;
              CallManager.instance.setupRemoteView(
                  CallState.instance.remoteUserList[0].id, viewId);
            }
          }
        });
  }

  // 创建小画面专用的视频view
  Widget _createSmallVideoView(bool isLocal) {
    return NECallkitVideoView(
        key: isLocal ? _localSmallKey : _remoteSmallKey,
        onPlatformViewCreated: (viewId) {
          if (isLocal) {
            CallState.instance.selfUser.viewID = viewId;
            CallManager.instance.setupLocalView(viewId);
            if (CallState.instance.isCameraOpen) {
              CallManager.instance
                  .openCamera(CallState.instance.camera, viewId);
            }
          } else {
            if (CallState.instance.remoteUserList.isNotEmpty) {
              CallState.instance.remoteUserList[0].viewID = viewId;
              CallManager.instance.setupRemoteView(
                  CallState.instance.remoteUserList[0].id, viewId);
            }
          }
        });
  }

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.forward();

    setSateCallBack = (arg) {
      if (mounted) {
        setState(() {});
      }
    };
    NEEventNotify().register(setStateEvent, setSateCallBack);
  }

  @override
  dispose() {
    // Dispose animation and unregister listeners before super.dispose()
    _animationController.dispose();
    NEEventNotify().unregister(setStateEvent, setSateCallBack);
    // 清理所有视频view
    CallManager.instance.setupLocalView(-1);
    if (CallState.instance.remoteUserList.isNotEmpty) {
      CallManager.instance
          .setupRemoteView(CallState.instance.remoteUserList[0].id, -1);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _getBackgroundColor(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            _buildBigVideoWidget(),
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildSmallVideoWidget(),
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildUserInfoWidget(),
          ],
        ),
      ),
    );
  }

  _buildBackground() {
    var avatar = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      avatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Image(
          height: double.infinity,
          image: NetworkImage(avatar),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stackTrace) => Image.asset(
            'assets/images/user_icon.png',
            package: 'netease_callkit_ui',
          ),
        ),
        Opacity(
            opacity: 1,
            child: Container(
              color: const Color.fromRGBO(45, 45, 45, 0.9),
            ))
      ],
    );
  }

  _buildUserInfoWidget() {
    var showName = '';
    var avatar = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      showName = User.getUserDisplayName(CallState.instance.remoteUserList[0]);
      avatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
    }
    CallKitUILog.i(_tag, "_buildUserInfoWidget avatar = $avatar");

    final userInfoWidget = Positioned(
        top: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 110,
              width: 110,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Image(
                image: NetworkImage(avatar),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stackTrace) => Image.asset(
                  'assets/images/user_icon.png',
                  package: 'netease_callkit_ui',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              showName,
              textScaleFactor: 1.0,
              style: TextStyle(
                fontSize: 24,
                color: _getTextColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));

    if (CallState.instance.mediaType == NECallType.video &&
        CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      return const SizedBox();
    }
    return userInfoWidget;
  }

  Widget _buildBigVideoWidget() {
    var remoteAvatar = '';
    var remoteVideoAvailable = false;
    if (CallState.instance.remoteUserList.isNotEmpty) {
      remoteAvatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
      remoteVideoAvailable =
          CallState.instance.remoteUserList[0].videoAvailable;
    }
    var selfAvatar = StringStream.makeNull(
        CallState.instance.selfUser.avatar, Constants.defaultAvatar);
    var isCameraOpen = CallState.instance.isCameraOpen;

    if (CallState.instance.mediaType == NECallType.audio) {
      return const SizedBox();
    }

    bool isLocalViewBig = true;
    if (CallState.instance.selfUser.callStatus == NECallStatus.waiting) {
      isLocalViewBig = true;
    } else {
      if (CallState.instance.isChangedBigSmallVideo) {
        isLocalViewBig = false;
      } else {
        isLocalViewBig = true;
      }
    }

    return CallState.instance.mediaType == NECallType.video
        ? InkWell(
            onTap: () {
              CallsIndividualUserWidgetData.isOnlyShowBigVideoView =
                  !CallsIndividualUserWidgetData.isOnlyShowBigVideoView;
              NEEventNotify().notify(setStateEventGroupCallUserWidgetRefresh);
            },
            child: Container(
              color: Colors.black54,
              child: Stack(
                children: [
                  CallState.instance.selfUser.callStatus == NECallStatus.accept
                      ? AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: (isLocalViewBig
                                  ? !isCameraOpen
                                  : !remoteVideoAvailable)
                              ? 1.0
                              : 0.0,
                          child: Center(
                              child: Container(
                            height: 80,
                            width: 80,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Image(
                              image: NetworkImage(
                                  isLocalViewBig ? selfAvatar : remoteAvatar),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stackTrace) =>
                                  Image.asset(
                                'assets/images/user_icon.png',
                                package: 'netease_callkit_ui',
                              ),
                            ),
                          )),
                        )
                      : Container(),
                  // 大画面视频 - 使用独立的视频view避免GlobalKey冲突
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 120),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(
                                parent: animation, curve: Curves.easeOut)),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key:
                          ValueKey(isLocalViewBig ? 'local_big' : 'remote_big'),
                      width: double.infinity,
                      height: double.infinity,
                      child: Opacity(
                          opacity: isLocalViewBig
                              ? _getOpacityByVis(isCameraOpen)
                              : _getOpacityByVis(remoteVideoAvailable),
                          child: _createBigVideoView(isLocalViewBig)),
                    ),
                  )
                ],
              ),
            ))
        : Container();
  }

  Widget _buildSmallVideoWidget() {
    if (CallState.instance.mediaType == NECallType.audio) {
      return const SizedBox();
    }

    // 获取视频状态信息
    var remoteAvatar = '';
    var remoteVideoAvailable = false;
    var remoteAudioAvailable = false;

    if (CallState.instance.remoteUserList.isNotEmpty) {
      remoteAvatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
      remoteVideoAvailable =
          CallState.instance.remoteUserList[0].videoAvailable;
      remoteAudioAvailable =
          CallState.instance.remoteUserList[0].audioAvailable;
    }
    var selfAvatar = StringStream.makeNull(
        CallState.instance.selfUser.avatar, Constants.defaultAvatar);
    var isCameraOpen = CallState.instance.isCameraOpen;

    // 判断当前应该显示哪个视频
    bool isRemoteViewSmall = true;
    if (CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      if (CallState.instance.isChangedBigSmallVideo) {
        isRemoteViewSmall = false;
      } else {
        isRemoteViewSmall = true;
      }
    }

    return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        top: CallsIndividualUserWidgetData.smallViewTop - 40,
        right: CallsIndividualUserWidgetData.smallViewRight,
        child: GestureDetector(
          onTap: () {
            _changeVideoView();
          },
          onPanUpdate: (DragUpdateDetails e) {
            if (CallState.instance.mediaType == NECallType.video &&
                !_isTransitioning) {
              CallsIndividualUserWidgetData.smallViewRight -= e.delta.dx;
              CallsIndividualUserWidgetData.smallViewTop += e.delta.dy;
              if (CallsIndividualUserWidgetData.smallViewTop < 100) {
                CallsIndividualUserWidgetData.smallViewTop = 100;
              }
              if (CallsIndividualUserWidgetData.smallViewTop >
                  MediaQuery.of(context).size.height - 216) {
                CallsIndividualUserWidgetData.smallViewTop =
                    MediaQuery.of(context).size.height - 216;
              }
              if (CallsIndividualUserWidgetData.smallViewRight < 0) {
                CallsIndividualUserWidgetData.smallViewRight = 0;
              }
              if (CallsIndividualUserWidgetData.smallViewRight >
                  MediaQuery.of(context).size.width - 110) {
                CallsIndividualUserWidgetData.smallViewRight =
                    MediaQuery.of(context).size.width - 110;
              }
              setState(() {});
            }
          },
          child: CallState.instance.selfUser.callStatus == NECallStatus.accept
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 216,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      // 小画面视频 - 使用独立的视频view和优化的动画
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 120),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.8, end: 1.0)
                                    .animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut)),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              key: ValueKey(isRemoteViewSmall
                                  ? 'remote_small'
                                  : 'local_small'),
                              width: 110,
                              height: 216,
                              color: Colors.transparent, // 移除背景色，避免黑边
                              child: Opacity(
                                  opacity: isRemoteViewSmall
                                      ? _getOpacityByVis(remoteVideoAvailable)
                                      : _getOpacityByVis(isCameraOpen),
                                  child: _createSmallVideoView(
                                      !isRemoteViewSmall)),
                            ),
                          ),
                        ),
                      ),
                      // 远程用户头像 - 当远程视频不可用时显示
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        opacity: (isRemoteViewSmall && !remoteVideoAvailable)
                            ? 1.0
                            : 0.0,
                        child: Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Image(
                              image: NetworkImage(remoteAvatar),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stackTrace) =>
                                  Image.asset(
                                'assets/images/user_icon.png',
                                package: 'netease_callkit_ui',
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 本地用户头像 - 当本地视频不可用时显示
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        opacity:
                            (!isRemoteViewSmall && !isCameraOpen) ? 1.0 : 0.0,
                        child: Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Image(
                              image: NetworkImage(selfAvatar),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stackTrace) =>
                                  Image.asset(
                                'assets/images/user_icon.png',
                                package: 'netease_callkit_ui',
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 音频不可用图标
                      Positioned(
                        left: 5,
                        bottom: 5,
                        width: 20,
                        height: 20,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: (isRemoteViewSmall && !remoteAudioAvailable)
                              ? 1.0
                              : 0.0,
                          child: Image.asset(
                            'assets/images/audio_unavailable_grey.png',
                            package: 'netease_callkit_ui',
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
        ));
  }

  _changeVideoView() {
    if (CallState.instance.mediaType == NECallType.audio ||
        CallState.instance.selfUser.callStatus == NECallStatus.waiting ||
        _isTransitioning) {
      return;
    }

    // 设置过渡状态，防止在动画期间进行拖拽或重复触发
    _isTransitioning = true;

    // 直接切换状态，让AnimatedSwitcher处理动画
    CallState.instance.isChangedBigSmallVideo =
        !CallState.instance.isChangedBigSmallVideo;

    if (mounted) {
      setState(() {});

      // 120ms后重置过渡状态（与AnimatedSwitcher动画时长一致）
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) {
          _isTransitioning = false;
        }
      });
    }
  }

  double _getOpacityByVis(bool vis) {
    return vis ? 1.0 : 0;
  }

  _getBackgroundColor() {
    return CallState.instance.mediaType == NECallType.audio
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF444444);
  }

  _getTextColor() {
    return Colors.white;
  }
}
