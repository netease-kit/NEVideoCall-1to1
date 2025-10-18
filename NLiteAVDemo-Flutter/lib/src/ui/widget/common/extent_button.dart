// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ExtendButton extends StatelessWidget {
  const ExtendButton(
      {required this.imgUrl,
      this.tips = "",
      this.onTap,
      this.imgHeight = 0,
      this.imgOffsetX = 0,
      this.imgOffsetY = 0,
      this.imgColor,
      this.textColor,
      this.duration = const Duration(milliseconds: 200),
      this.userAnimation = false,
      this.fallbackNetworkUrl,
      Key? key})
      : super(key: key);
  final String imgUrl;
  final double imgHeight;
  final Color? imgColor;
  final double imgOffsetX;
  final double imgOffsetY;
  final String tips;
  final GestureTapCallback? onTap;
  final Color? textColor;
  final bool? userAnimation;
  final Duration duration;
  final String? fallbackNetworkUrl;

  Widget _buildImageView() {
    Widget imageWidget = Image.asset(
      imgUrl,
      package: 'netease_callkit_ui',
      color: imgColor,
      errorBuilder: (context, error, stackTrace) {
        // 如果本地图片加载失败且有备用网络URL，则使用网络图片
        if (fallbackNetworkUrl != null && fallbackNetworkUrl!.isNotEmpty) {
          return Image.network(
            fallbackNetworkUrl!,
            color: imgColor,
            errorBuilder: (context, error, stackTrace) {
              // 如果网络图片也加载失败，返回一个默认的占位图标
              return Icon(
                Icons.error_outline,
                size: imgHeight > 0 ? imgHeight : 52.0,
                color: imgColor ?? Colors.grey,
              );
            },
          );
        } else {
          // 如果没有备用网络URL，返回默认图标
          return Icon(
            Icons.error_outline,
            size: imgHeight > 0 ? imgHeight : 52.0,
            color: imgColor ?? Colors.grey,
          );
        }
      },
    );

    return userAnimation!
        ? AnimatedContainer(
            duration: duration,
            height: imgHeight > 0 ? imgHeight : 52.0,
            width: imgHeight > 0 ? imgHeight : 52.0,
            child: imageWidget,
          )
        : SizedBox(
            height: imgHeight > 0 ? imgHeight : 52.0,
            width: imgHeight > 0 ? imgHeight : 52.0,
            child: imageWidget,
          );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap!();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(imgOffsetX, imgOffsetY),
            child: _buildImageView(),
          ),
          Container(
            width: 100,
            height: 15,
            margin: const EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: Text(
              tips,
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 12, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
