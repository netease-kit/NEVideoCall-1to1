// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

protocol NEBackToFlutterWidgetDelegate: NSObject {
  func backCallingPageFromFloatWindow()
}

class NEWindowManager: NSObject, NEFloatWindowViewDelegate {
  static let instance = NEWindowManager()

  let selfCallStatus: NEObservable<NECallStatus> = NEObservable(.none)

  var floatWindowBeganPoint: CGPoint?
  var floatWindowBeganOrigin: CGPoint?

  weak var backToFlutterWidgetDelegate: NEBackToFlutterWidgetDelegate?

  var floatWindow = UIWindow()

  override init() {
    super.init()
    registerObserveState()
  }

  func showFloatWindow() {
    let floatViewController = NEFloatWindowViewController()
    floatViewController.delegate = self
    initFloatWindowFrame()
    floatWindow.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    floatWindow.layer.shadowColor = UIColor.black.cgColor
    floatWindow.layer.shadowOffset = CGSizeMake(10.0, 10.0)
    floatWindow.layer.shadowOpacity = 1.0
    floatWindow.layer.shadowRadius = 1.0
    floatWindow.layer.cornerRadius = 10.0
    floatWindow.layer.masksToBounds = true
    floatWindow.rootViewController = floatViewController
    floatWindow.isHidden = false
    floatWindow.neMakeKeyAndVisible()
  }

  func closeFloatWindow() {
    // 获取当前的悬浮窗视图控制器
    if let floatViewController = floatWindow.rootViewController as? NEFloatWindowViewController {
      // 获取悬浮窗视图
      if let floatView = floatViewController.floatView as? NESingleCallFloatWindowView {
        // 调用clean方法清理资源
        floatView.clean()
      }
    }

    // 关闭悬浮窗
    floatWindow = UIWindow()
  }

  func registerObserveState() {
    // 监听 selfUser 的变化
    NECallState.instance.selfUser.addObserver(self, options: [.new]) { [weak self] newUser, _ in
      guard let self = self else { return }

      // 检查通话状态变化
      if self.selfCallStatus.value == newUser.callStatus { return }
      self.selfCallStatus.value = newUser.callStatus
      self.updateFloatWindowFrame()

      if self.selfCallStatus.value == NECallStatus.none {
        NEWindowManager.instance.closeFloatWindow()
      }
    }
  }

  func initFloatWindowFrame() {
    if NECallState.instance.mediaType.value == .audio {
      floatWindow.frame = CGRect(x: NEScreen_Width - kNESingleCallMicroAudioViewWidth - kNEMicroLeftRightEdge, y: kNEMicroTopEdge,
                                 width: kNESingleCallMicroAudioViewWidth, height: kNESingleCallMicroAudioViewHeight)
    } else {
      floatWindow.frame = CGRect(x: NEScreen_Width - kNESingleCallMicroVideoViewWidth - kNEMicroLeftRightEdge, y: kNEMicroTopEdge,
                                 width: kNESingleCallMicroVideoViewWidth, height: kNESingleCallMicroVideoViewHeight)
    }
  }

  func updateFloatWindowFrame() {
    let originY = floatWindow.frame.origin.y
    if NECallState.instance.mediaType.value == .audio {
      let dstX = floatWindow.frame.origin.x < NEScreen_Width / 2.0 ? kNEMicroLeftRightEdge : NEScreen_Width - kNESingleCallMicroAudioViewWidth - kNEMicroLeftRightEdge
      floatWindow.frame = CGRect(x: dstX, y: originY, width: kNESingleCallMicroAudioViewWidth, height: kNESingleCallMicroAudioViewHeight)
    } else {
      let dstX = floatWindow.frame.origin.x < NEScreen_Width / 2.0 ? kNEMicroLeftRightEdge : NEScreen_Width - kNESingleCallMicroVideoViewWidth - kNEMicroLeftRightEdge
      floatWindow.frame = CGRect(x: dstX, y: originY, width: kNESingleCallMicroVideoViewWidth, height: kNESingleCallMicroVideoViewHeight)
    }
  }

  // MARK: NEFloatingWindowViewDelegate

  func tapGestureAction(tapGesture: UITapGestureRecognizer) {
    closeFloatWindow()
    if backToFlutterWidgetDelegate != nil,
       (backToFlutterWidgetDelegate?.responds(to: Selector(("backToFlutterWidgetDelegate")))) != nil,
       NECallState.instance.selfUser.value.callStatus != .none {
      backToFlutterWidgetDelegate?.backCallingPageFromFloatWindow()
    }
  }

  func panGestureAction(panGesture: UIPanGestureRecognizer) {
    switch panGesture.state {
    case .began:
      floatWindowBeganPoint = floatWindow.frame.origin
      floatWindowBeganOrigin = floatWindow.frame.origin
    case .changed:
      let point = panGesture.translation(in: floatWindow)
      var dstX = (floatWindowBeganPoint?.x ?? 0) + CGFloat(point.x)
      var dstY = (floatWindowBeganOrigin?.y ?? 0) + CGFloat(point.y)

      if dstX < 0 {
        dstX = 0
      } else if dstX > (NEScreen_Width - floatWindow.frame.size.width) {
        dstX = NEScreen_Width - floatWindow.frame.size.width
      }

      if dstY < 0 {
        dstY = 0
      } else if dstY > (NEScreen_Height - floatWindow.frame.size.height) {
        dstY = NEScreen_Height - floatWindow.frame.size.height
      }

      floatWindow.frame = CGRect(x: dstX,
                                 y: dstY,
                                 width: floatWindow.frame.size.width,
                                 height: floatWindow.frame.size.height)
    case .cancelled:
      break
    case .ended:
      var dstX: CGFloat = 0
      if (floatWindow.frame.origin.x + floatWindow.frame.size.width / 2) < NEScreen_Width / 2 {
        dstX = kNEMicroLeftRightEdge
      } else if (floatWindow.frame.origin.x + floatWindow.frame.size.width / 2) > NEScreen_Width / 2 {
        dstX = CGFloat(NEScreen_Width - floatWindow.frame.size.width - kNEMicroLeftRightEdge)
      }
      floatWindow.frame = CGRect(x: dstX,
                                 y: floatWindow.frame.origin.y,
                                 width: floatWindow.frame.size.width,
                                 height: floatWindow.frame.size.height)
    default:
      break
    }
  }
}

extension UIWindow {
  func neMakeKeyAndVisible() {
    if #available(iOS 13.0, *) {
      for windowScene in UIApplication.shared.connectedScenes {
        if windowScene.activationState == UIScene.ActivationState.foregroundActive ||
          windowScene.activationState == UIScene.ActivationState.background {
          self.windowScene = windowScene as? UIWindowScene
          break
        }
      }
    }
    makeKeyAndVisible()
  }
}
