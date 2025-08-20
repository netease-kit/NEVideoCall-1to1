// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERtcCallKit
import SDWebImage

class NESingleCallFloatWindowView: NEFloatWindowView {
  let selfCallStatusObserver = NEObserver()
  let remoteUserObserver = NEObserver()

  // 添加定时器相关属性
  private var timer: Timer?
  private var callDuration: Int = 0 // 通话时长（秒）

  lazy var containerView: UIView = {
    let containerView = UIView()
    containerView.backgroundColor = UIColor.white
    containerView.isUserInteractionEnabled = false
    return containerView
  }()

  // Video Call
  lazy var localPreView: UIView = {
    let view = UIView(frame: CGRect.zero)
    return view
  }()

  lazy var remotePreView: UIView = {
    let view = UIView(frame: CGRect.zero)
    return view
  }()

  lazy var avatarImageView: UIImageView = {
    let avatarImageView = UIImageView()
    avatarImageView.contentMode = .scaleAspectFit
    avatarImageView.clipsToBounds = true
    avatarImageView.isUserInteractionEnabled = false
    return avatarImageView
  }()

  lazy var videoDescribeLabel: UILabel = {
    let describeLabel = UILabel()
    describeLabel.font = UIFont.systemFont(ofSize: 12.0)
    describeLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    describeLabel.textAlignment = .center
    describeLabel.isUserInteractionEnabled = false
    return describeLabel
  }()

  lazy var dialingImageView: UIImageView = {
    let imageView = UIImageView()
    if let image = NEBundleUtils.getBundleImage(name: "icon_float_dialing") {
      imageView.image = image
    }

    imageView.isUserInteractionEnabled = false
    return imageView
  }()

  lazy var audioDescribeAndTimerLabel: UILabel = {
    let describeLabel = UILabel()
    describeLabel.font = UIFont.systemFont(ofSize: 12.0)
    describeLabel.textColor = UIColor(red: 28 / 255, green: 176 / 255, blue: 86 / 255, alpha: 1)
    describeLabel.textAlignment = .center
    describeLabel.isUserInteractionEnabled = false
    return describeLabel
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    registerObserveState()
    startTimer()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    clean() // 调用clean方法确保资源清理
  }

  // MARK: timer

  private func startTimer() {
    stopTimer() // 先停止现有定时器
    callDuration = Int(Date().timeIntervalSince1970) - NECallState.instance.startTime
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      callDuration += 1
      self.updateUI()
    }
  }

  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  // MARK: - Clean up resources

  func clean() {
    // 停止定时器
    stopTimer()

    // 清理观察者
    NECallState.instance.selfUser.removeObserver(selfCallStatusObserver)
    NECallState.instance.remoteUser.removeObserver(remoteUserObserver)
    isViewReady = false
  }

  private func getCallTimeString() -> String {
    secondToHMSString(callDuration)
  }

  private func secondToHMSString(_ seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60

    if hours > 0 {
      return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    } else {
      return String(format: "%02d:%02d", minutes, secs)
    }
  }

  private var isViewReady: Bool = false
  override func didMoveToWindow() {
    super.didMoveToWindow()
    if isViewReady { return }
    constructViewHierarchy()
    activateConstraints()
    bindInteraction()
    isViewReady = true

    updateUI()
  }

  func constructViewHierarchy() {
    addSubview(containerView)
    if NECallState.instance.mediaType.value == .audio {
      containerView.addSubview(dialingImageView)
      containerView.addSubview(audioDescribeAndTimerLabel)
      return
    }
    containerView.addSubview(localPreView)
    containerView.addSubview(remotePreView)
    containerView.addSubview(avatarImageView)
    containerView.addSubview(videoDescribeLabel)
  }

  func activateConstraints() {
    containerView.snp.makeConstraints { make in
      make.center.equalTo(self)
      make.size.equalToSuperview()
    }

    if NECallState.instance.mediaType.value == .audio {
      dialingImageView.snp.makeConstraints { make in
        make.top.equalTo(self.containerView).offset(12.neScaleWidth())
        make.centerX.equalToSuperview()
        make.width.height.equalTo(36.neScaleWidth())
      }

      audioDescribeAndTimerLabel.snp.makeConstraints { make in
        make.centerX.width.equalTo(self.containerView)
        make.top.equalToSuperview().offset(48.neScaleWidth())
        make.height.equalTo(16.neScaleWidth())
      }
      return
    }

    localPreView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    remotePreView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    avatarImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(45.neScaleWidth())
    }

    videoDescribeLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().offset(-20.neScaleWidth())
    }
  }

  func bindInteraction() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(tapGesture:)))
    let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(panGesture:)))
    addGestureRecognizer(tap)
    pan.require(toFail: tap)
    addGestureRecognizer(pan)
  }

  @objc func tapGestureAction(tapGesture: UITapGestureRecognizer) {
    if delegate != nil, (delegate?.responds(to: Selector(("tapGestureAction")))) != nil {
      delegate?.tapGestureAction(tapGesture: tapGesture)
    }
  }

  @objc func panGestureAction(panGesture: UIPanGestureRecognizer) {
    if delegate != nil, (delegate?.responds(to: Selector(("panGestureAction")))) != nil {
      delegate?.panGestureAction(panGesture: panGesture)
    }
  }

  func registerObserveState() {
    // 监听通话状态变化
    NECallState.instance.selfUser.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
      guard let self = self else { return }
      // 根据通话状态控制定时器
      switch newValue.callStatus {
      case .none:
        self.stopTimer() // 通话结束时停止定时器

      default:
        break
      }

      self.updateUI()
    })

    NECallState.instance.remoteUser.addObserver(remoteUserObserver, closure: { [weak self] newValue, _ in

      guard let self = self else { return }
      self.updateUI()
    })
  }

  func updateUI() {
    if !isViewReady { return }

    if NECallState.instance.mediaType.value == .audio {
      setAudioAcceptUI()
      return
    }
    if NECallState.instance.remoteUser.value.videoAvailable == false {
      setNoVideoAccept()
    } else {
      setVideoAcceptUI()
    }
  }

  func setAudioAcceptUI() {
    audioDescribeAndTimerLabel.text = getCallTimeString()
  }

  func setVideoAcceptUI() {
    videoDescribeLabel.isHidden = true
    avatarImageView.isHidden = true
    remotePreView.isHidden = false

    NECallEngine.sharedInstance().setupRemoteView(remotePreView)
  }

  // 视频通话 但是对方没有开视频
  func setNoVideoAccept() {
    videoDescribeLabel.isHidden = true
    localPreView.isHidden = true
    remotePreView.isHidden = true
    avatarImageView.isHidden = false
    containerView.backgroundColor = UIColor.gray
    let remoteUserAvatar = NECallState.instance.remoteUser.value.avatar
    avatarImageView.sd_setImage(with: URL(string: remoteUserAvatar), placeholderImage: NEBundleUtils.getBundleImage(name: "icon_default_user"))
  }
}
