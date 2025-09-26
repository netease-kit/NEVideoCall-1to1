// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

let kNEMicroTopEdge = 75.neScaleWidth()
let kNEMicroLeftRightEdge = 6.neScaleWidth()
let kNEMicroWindowCornerRatio = 15.neScaleWidth()

let kNESingleCallMicroAudioViewWidth = 72.neScaleWidth()
let kNESingleCallMicroAudioViewHeight = 72.neScaleWidth()

let kNESingleCallMicroVideoViewWidth = 110.neScaleWidth()
let kNESingleCallMicroVideoViewHeight = 196.neScaleWidth()

let kNEGroupCallMicroViewWidth = 72.neScaleWidth()
let kNEGroupCallMicroViewHeight = 90.neScaleWidth()

let NEScreenSize = UIScreen.main.bounds.size
let NEScreen_Width = UIScreen.main.bounds.size.width
let NEScreen_Height = UIScreen.main.bounds.size.height
let NEStatusBar_Height: CGFloat = {
  var statusBarHeight: CGFloat = 0
  if #available(iOS 13.0, *) {
    statusBarHeight = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
  } else {
    statusBarHeight = UIApplication.shared.statusBarFrame.height
  }
  return statusBarHeight
}()

let NEBottom_SafeHeight = { var bottomSafeHeight: CGFloat = 0
  if #available(iOS 11.0, *) {
    let window = UIApplication.shared.windows.first
    bottomSafeHeight = window?.safeAreaInsets.bottom ?? 0
  }
  return bottomSafeHeight
}()
