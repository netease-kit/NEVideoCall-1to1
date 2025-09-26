import { secondToDate } from '../utils/index'
const app = getApp()

Component({
  properties: {
    userAccId: String,
  },
  data: {
    callStatus: 0, // 状态 0：闲置 1：正在呼叫 2：正在被呼叫 3：通话中
    callType: '1', // 通话类型 1：语音通话 2：视频通话
    durationText: '00:00', // 通话时长
    userInfo: {},
    microphoneImg: {
      open: '../assets/microphone-open.png',
      close: '../assets/microphone-close.png',
    },
    videoImg: {
      open: '../assets/video-open.png',
      close: '../assets/video-close.png',
    },
    acceptImg: {
      audio: '../assets/audio-accept.png',
      video: '../assets/video-accept.png',
    },
    switchImg: {
      audio: '../assets/switch-audio.png',
      video: '../assets/switch-video.png',
    },
    hangupImg: '../assets/hangup.png',
    cameraRevertImg: '../assets/camera-revert.png',
    pusher: {
      mode: 'RTC',
      autopush: true,
      enableCamera: true,
      enableMic: true,
      pictureInPictureMode: ['push', 'pop'],
      waitingImage:
        'https://yx-web-nosdn.netease.im/quickhtml%2Fassets%2Fyunxin%2Fdefault%2Fgroupcall%2FLark20210401-161321.jpeg',
    },
    player: {
      mode: 'RTC',
      autoplay: true,
      enableCamera: true,
      enableMic: true,
      objectFit: 'fillCrop',
      videoMute: false,
      pictureInPictureMode: ['push', 'pop'],
    },
  },
  lifetimes: {
    attached() {
      const neCall = app.globalData.neCall
      const nim = app.globalData.nim
      if (!neCall || !nim) {
        throw new Error(
          '需要在全局实例化 neCall 和 nim，绑定到 app.globalData 上'
        )
      }
      const callStatus = neCall.signalController.callStatus
      let userAccId =
        callStatus === 1
          ? neCall.signalController._channelInfo.calleeId
          : neCall.signalController._channelInfo.callerId
      nim.getUser({
        account: userAccId,
        done: (error, user) => {
          if (!error && user) {
            this.setData({
              userInfo: user,
            })
          }
        },
      })
      this.setData({
        callStatus: neCall.signalController.callStatus,
        callType: neCall._callType,
      })
      let durationTimer
      let duration = 0
      neCall.on('onCallConnected', () => {
        this.setData({
          callStatus: 3,
        })
        durationTimer = setInterval(() => {
          duration += 1
          this.setData({
            durationText: secondToDate(duration),
          })
        }, 1000)
      })
      neCall.on('onSwtichCallType', (value) => {
        const callType = value.callType
        if (value.state === 1) {
          const content =
            callType === '1'
              ? '对方请求将视频转为音频，将直接关闭您的摄像头'
              : '对方请求将转音频为视频，需要打开您的摄像头'
          wx.showModal({
            title: '权限请求',
            content,
            cancelText: '拒绝',
            confirmText: '同意',
            success(res) {
              if (res.confirm) {
                neCall.switchCallType({ callType, state: 2 })
              } else if (res.cancel) {
                neCall.switchCallType({ callType, state: 3 })
              }
            },
          })
        }
        if (value.state === 2) {
          this.setData({
            callType: value.callType,
            pusher: {
              ...this.data.pusher,
              enableCamera: value.callType === '2',
            },
            pusher: { ...this.data.pusher, enableMic: true },
          })
        }
        if (value.state === 3) {
        }
      })
      neCall.on('onVideoMuteOrUnmute', (mute) => {
        this.setData({
          player: { ...this.data.player, videoMute: mute },
        })
      })
      neCall.on('onStreamPublish', (url) => {
        this.setData({
          pusher: { ...this.data.pusher, url },
        })
      })
      neCall.on('onStreamSubscribed', (url) => {
        this.setData({
          player: { ...this.data.player, url },
        })
      })
      neCall.on('onCallEnd', () => {
        duration = 0
        durationTimer && clearInterval(durationTimer)
        this.setData({
          player: { ...this.data.player, pictureInPictureMode: [] },
          pusher: { ...this.data.pusher, pictureInPictureMode: [] },
        })
        setTimeout(() => {
          wx.navigateBack()
        }, 500)
      })
    },
    detached() {
      const neCall = app.globalData.neCall
      neCall.off('onCallConnected')
      neCall.off('onSwtichCallType')
      neCall.off('onStreamPublish')
      neCall.off('onStreamSubscribed')
      neCall.off('onCallEnd')
    },
  },
  methods: {
    onHangup() {
      const neCall = app.globalData.neCall
      neCall.hangup()
    },
    onAccept() {
      const neCall = app.globalData.neCall
      neCall.accept()
    },
    handleEnableLocalAudio() {
      const neCall = app.globalData.neCall
      const enable = this.data.pusher.enableMic
      neCall.enableLocalAudio(!enable)
      this.setData({
        pusher: { ...this.data.pusher, enableMic: !enable },
      })
    },
    handleEnableLocalVideo() {
      const neCall = app.globalData.neCall
      const enable = this.data.pusher.enableCamera
      neCall.enableLocalVideo(!enable)
      this.setData({
        pusher: { ...this.data.pusher, enableCamera: !enable },
      })
    },
    handleSwitchCallType() {
      const neCall = app.globalData.neCall
      const callType = this.data.callType === '1' ? '2' : '1'
      neCall.switchCallType({ callType, state: 1 })
    },
    handleCameraRevert() {
      const livePusherContext = wx.createLivePusherContext()
      livePusherContext.switchCamera()
    },
  },
})
