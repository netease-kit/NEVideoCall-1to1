// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

public extension CGFloat {
  /// - Returns: Final result scaling result
  func neScaleWidth(_ exceptPad: Bool = true) -> CGFloat {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return exceptPad ? self * 1.5 : self * (NEScreen_Width / 375.00)
    }
    return self * (NEScreen_Width / 375.00)
  }

  func neScaleHeight(_ exceptPad: Bool = true) -> CGFloat {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return exceptPad ? self * 1.5 : self * (NEScreen_Height / 812.00)
    }
    return self * (NEScreen_Height / 812.00)
  }
}

public extension Int {
  /// - Returns: Final result scaling result
  func neScaleWidth(_ exceptPad: Bool = true) -> CGFloat {
    CGFloat(self).neScaleWidth()
  }

  func neScaleHeight(_ exceptPad: Bool = true) -> CGFloat {
    CGFloat(self).neScaleHeight()
  }
}
