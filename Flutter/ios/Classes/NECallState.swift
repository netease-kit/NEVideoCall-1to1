// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERtcCallKit

// MARK: - NECallUser

class NECallUser: NSObject {
  var id: String = ""
  var avatar: String = ""
  var nickname: String = ""
  var callRole: NECallRole = .none
  var callStatus: NECallStatus = .none
  var audioAvailable: Bool = false
  var videoAvailable: Bool = false
  var playOutVolume: Int = 0
  var viewID: Int = 0
}

// MARK: - Enums

enum NECallRole: Int {
  case none = 0
  case caller = 1
  case called = 2
}

enum NECallStatus: Int {
  case none = 0
  case waiting = 1
  case accept = 2
}

class NECallState {
  static let instance = NECallState()

  // User 相关 - 使用 NEObservable 包装
  let selfUser: NEObservable<NECallUser> = NEObservable(NECallUser())
  let remoteUser: NEObservable<NECallUser> = NEObservable(NECallUser())

  // 通话状态 - 使用 NEObservable 包装
  let mediaType: NEObservable<NECallType> = NEObservable(.audio)
  let isCameraOpen: NEObservable<Bool> = NEObservable(false)
  let isMicrophoneMute: NEObservable<Bool> = NEObservable(false)

  // 通话开始时间
  var startTime = 0
}
