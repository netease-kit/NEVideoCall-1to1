// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AudioToolbox

class CallingVibrator {
  private static var isVibrating = false

  static func startVibration() {
    isVibrating = true
    DispatchQueue.global().async {
      while isVibrating {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        Thread.sleep(forTimeInterval: 1)
      }
    }
  }

  static func stopVirbration() {
    isVibrating = false
  }
}
