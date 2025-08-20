// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import SnapKit

protocol NEFloatWindowViewDelegate: NSObject {
  func tapGestureAction(tapGesture: UITapGestureRecognizer)
  func panGestureAction(panGesture: UIPanGestureRecognizer)
}

class NEFloatWindowView: UIView {
  weak var delegate: NEFloatWindowViewDelegate?
}

class NEFloatWindowViewController: UIViewController, NEFloatWindowViewDelegate {
  weak var delegate: NEFloatWindowViewDelegate?

  lazy var floatView: NEFloatWindowView = {
    let view = NESingleCallFloatWindowView(frame: CGRect.zero)
    view.delegate = self
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(floatView)
    floatView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  // MARK: NEFloatingWindowViewDelegate

  func tapGestureAction(tapGesture: UITapGestureRecognizer) {
    if delegate != nil, (delegate?.responds(to: Selector(("tapGestureAction")))) != nil {
      delegate?.tapGestureAction(tapGesture: tapGesture)
    }
  }

  func panGestureAction(panGesture: UIPanGestureRecognizer) {
    if delegate != nil, (delegate?.responds(to: Selector(("panGestureAction")))) != nil {
      delegate?.panGestureAction(panGesture: panGesture)
    }
  }
}
