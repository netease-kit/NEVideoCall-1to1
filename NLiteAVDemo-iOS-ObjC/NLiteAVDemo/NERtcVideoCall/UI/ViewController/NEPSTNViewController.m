// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEPSTNViewController.h"

#import "NERtcCallKit+Demo.h"
#import "SettingManager.h"

@interface NEPSTNViewController () <NERtcLinkEngineDelegate, NECallKitPstnDelegate>
@property(strong, nonatomic) NEVideoView *smallVideoView;
@property(strong, nonatomic) NEVideoView *bigVideoView;
@property(strong, nonatomic) UIImageView *remoteAvatorView;
@property(strong, nonatomic) UIImageView *remoteBigAvatorView;
@property(strong, nonatomic) UILabel *titleLabel;
@property(strong, nonatomic) UILabel *centerTitleLabel;
@property(strong, nonatomic) UILabel *subTitleLabel;
@property(strong, nonatomic) UILabel *centerSubtitleLabel;
@property(strong, nonatomic) UILabel *timerLabel;
@property(strong, nonatomic) NSTimer *timer;

@property(strong, nonatomic) UIButton *switchCameraBtn;
/// 取消呼叫
@property(strong, nonatomic) NECustomButton *cancelBtn;
/// 拒绝接听
@property(strong, nonatomic) NECustomButton *rejectBtn;
/// 接听
@property(strong, nonatomic) NECustomButton *acceptBtn;
/// 音视频转换
@property(strong, nonatomic) NECustomButton *mediaSwitchBtn;
/// 麦克风
@property(strong, nonatomic) NECustomButton *microphoneBtn;
/// 扬声器
@property(strong, nonatomic) NECustomButton *speakerBtn;

@property(strong, nonatomic) NEVideoOperationView *operationView;
@property(assign, nonatomic) BOOL showMyBigView;

@property(strong, nonatomic) UIImageView *blurImage;

@property(strong, nonatomic) UIToolbar *toolBar;

@property(assign, nonatomic) CGFloat radius;
@property(assign, nonatomic) CGFloat titleFontSize;
@property(assign, nonatomic) CGFloat subTitleFontSize;
@property(assign, nonatomic) CGFloat factor;

@property(assign, nonatomic) int timerCount;

@property(nonatomic, strong) NECallStatusRecordModel *statusModel;

@property(nonatomic, assign) BOOL isPstn;  // 当前呼叫是否已进入pstn流程，默认 NO

@property(nonatomic, strong) UIView *bannerView;

@property(nonatomic, weak) UIAlertController *alert;

@property(nonatomic, strong) UILabel *cnameLabel;

@property(nonatomic, assign) BOOL isRemoteMute;

@end

@implementation NEPSTNViewController

- (instancetype)init {
  self = [super init];
  if (self) {
    self.factor = 1;
    self.radius = 4.0;
    self.titleFontSize = 20.0;
    self.subTitleFontSize = 14.0;
    self.timerCount = 0;
    //    self.videoConfirm = YES;
    //    self.audioConfirm = YES;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[NERtcEngine sharedEngine] setParameters:@{kNERtcKeyVideoStartWithBackCamera : @NO}];
  [self setupUI];
  [self setupCenterRemoteAvator];
  [self setupSDK];
  [self updateUIonStatus:self.status];
  self.statusModel.startTime = [NSDate date];
  if (self.callKitType == PSTN) {
    [self setupPSTNUI];
  }
  if (self.isCaller == NO && [NERtcCallKit sharedInstance].callStatus == NERtcCallStatusIdle) {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf onCallEnd];
    });
  }

  [self.view addSubview:self.bannerView];
  [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view).offset(80);
    make.left.equalTo(self.view).offset(20);
    make.right.equalTo(self.view).offset(-20);
    make.height.mas_equalTo(40);
  }];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  //  if (self.switchCameraBtn.selected == YES) {
  //      NSLog(@"viewDidDisappear switchCamera");
  //    [[NERtcCallKit sharedInstance] switchCamera];
  //  }
  [[NERtcCallKit sharedInstance] setupLocalView:nil];
  [[NECallKitPstn sharedInstance] removeDelegate];
}
#pragma mark - SDK
- (void)setupSDK {
  if (self.callKitType == CALLKIT || self.isCaller == NO) {
    [[NERtcCallKit sharedInstance] addDelegate:self];
  } else if (self.callKitType == PSTN) {
    [[NECallKitPstn sharedInstance] addDelegate:self];
    [[NECallKitPstn sharedInstance] addPstnDelegate:self];
    [[NECallKitPstn sharedInstance] setCallee:self.remoteUser.mobile];
    NSLog(@"pstn mobile : %@", self.remoteUser.mobile);
  }
  NSLog(@"called time out %ld", (long)[[SettingManager shareInstance] timeout]);
  //[NERtcCallKit sharedInstance].timeOutSeconds = [[SettingManager shareInstance] timeout];
  [[NERtcCallKit sharedInstance] enableLocalVideo:YES];
  [[NERtcEngine sharedEngine] adjustRecordingSignalVolume:200];
  [[NERtcEngine sharedEngine] adjustPlaybackSignalVolume:400];

  __weak typeof(self) weakSelf = self;
  if (self.status == NERtcCallStatusCalling) {
    NSString *token = [[SettingManager shareInstance] customToken];
    NSString *extra = [[SettingManager shareInstance] globalExtra];
    NSString *channeName = [[SettingManager shareInstance] customChannelName];

    [[NERtcCallKit sharedInstance]
               call:self.remoteUser.imAccid
               type:self.callType ? self.callType : NERtcCallTypeVideo
         attachment:nil
        globalExtra:extra
          withToken:token
        channelName:channeName
         completion:^(NSError *_Nullable error) {
           NSLog(@"call error code : %@", error);

           if ([[SettingManager shareInstance] isGlobalInit] == YES) {
             dispatch_async(dispatch_get_main_queue(), ^{
               [[NERtcCallKit sharedInstance] setupLocalView:self.bigVideoView.videoView];
             });
           }

           self.bigVideoView.userID = self.localUser.imAccid;
           if (error) {
             /// 对方离线时 通过APNS推送 UI不弹框提示
             if (error.code == 10202 || error.code == 10201) {
               return;
             }

             if (error.code == 21000 || error.code == 21001) {
               if (self.callKitType == PSTN && error.code == 21000) {
                 [weakSelf onCallEnd];
               }
             } else {
               [weakSelf onCallEnd];
             }
             [UIApplication.sharedApplication.keyWindow ne_makeToast:error.localizedDescription];
           }
         }];
    /*
     [[NERtcCallKit sharedInstance] call:self.remoteUser.imAccid type:self.callType ? self.callType
     : NERtcCallTypeVideo attachment:nil globalExtra:@"iOS extra test" completion:^(NSError *
     _Nullable error) { NSLog(@"call error code : %@", error);

     if (self.callType == NERtcCallTypeVideo) {
     dispatch_async(dispatch_get_main_queue(), ^{
     [[NERtcCallKit sharedInstance] setupLocalView:self.bigVideoView.videoView];
     });
     }
     self.bigVideoView.userID = self.localUser.imAccid;
     if (error) {
     /// 对方离线时 通过APNS推送 UI不弹框提示
     if (error.code == 10202 || error.code == 10201) {
     return;
     }

     if (error.code == 21000 || error.code == 21001) {
     if (self.callKitType == PSTN  && error.code == 21000) {
     [weakSelf onCallEnd];
     }
     }else {
     [weakSelf onCallEnd];
     }
     [UIApplication.sharedApplication.keyWindow ne_makeToast:error.localizedDescription];
     }
     }];*/
  }
}

- (void)setCallType:(NERtcCallType)callType {
  NSLog(@"set current call type : %lu", (unsigned long)callType);
  _callType = callType;
  if (_callType == NERtcCallTypeVideo) {
    self.statusModel.isVideoCall = YES;
  }
}

#pragma mark - UI
- (void)setupUI {
  __weak typeof(self) weakSelf = self;

  if (self.view.frame.size.height < 600) {
    self.factor = 0.5;
  }

  CGSize buttonSize = CGSizeMake(75, 103);

  [self.view addSubview:self.bigVideoView];
  CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
  [self.bigVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];
  [self.view addSubview:self.switchCameraBtn];
  [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(statusHeight + 20);
    make.left.mas_equalTo(20);
    make.size.mas_equalTo(CGSizeMake(30, 30));
  }];

  self.blurImage = [[UIImageView alloc] init];
  [self.view addSubview:self.blurImage];
  [self.blurImage mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
  }];
  self.blurImage.hidden = YES;

  self.toolBar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
  self.toolBar.barStyle = UIBarStyleBlackOpaque;
  [self.blurImage addSubview:self.toolBar];

  [self.view addSubview:self.smallVideoView];
  [self.smallVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(statusHeight + 20);
    make.right.mas_equalTo(self.view.mas_right).offset(-20);
    make.size.mas_equalTo(CGSizeMake(90, 160));
  }];
  self.smallVideoView.clipsToBounds = YES;
  self.smallVideoView.layer.cornerRadius = self.radius;

  [self.view addSubview:self.remoteAvatorView];
  [self.remoteAvatorView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(self.smallVideoView.mas_top);
    make.right.mas_equalTo(self.view.mas_right).offset(-20);
    make.size.mas_equalTo(CGSizeMake(60, 60));
  }];
  self.remoteAvatorView.clipsToBounds = YES;
  self.remoteAvatorView.layer.cornerRadius = self.radius;

  [self.view addSubview:self.titleLabel];
  [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(self.remoteAvatorView.mas_top).offset(5);
    make.right.mas_equalTo(self.remoteAvatorView.mas_left).offset(-8);
    make.left.mas_equalTo(20);
    make.height.mas_equalTo(25);
  }];
  [self.view addSubview:self.subTitleLabel];
  [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(self.titleLabel.mas_bottom);
    make.right.mas_equalTo(self.titleLabel.mas_right);
    make.left.mas_equalTo(self.titleLabel.mas_left);
    make.height.mas_equalTo(20);
  }];

  /// 取消按钮
  [self.view addSubview:self.cancelBtn];
  [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.view.mas_centerX);
    make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80 * self.factor);
    make.size.mas_equalTo(buttonSize);
  }];

  /// 接听和拒接按钮
  [self.view addSubview:self.rejectBtn];
  [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(-self.view.frame.size.width / 4.0);
    make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80 * self.factor);
    make.size.mas_equalTo(buttonSize);
  }];
  [self.view addSubview:self.acceptBtn];
  [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.view.frame.size.width / 4.0);
    make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80 * self.factor);
    make.size.mas_equalTo(buttonSize);
  }];
  [self.view addSubview:self.operationView];
  [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.view.mas_centerX);
    // make.size.mas_equalTo(CGSizeMake(224, 60));
    make.height.mas_equalTo(60);
    make.width.equalTo(self.view).multipliedBy(0.8);
    make.bottom.mas_equalTo(-50 * self.factor);
  }];

  /// 未接通状态下的音视频切换按钮
  self.mediaSwitchBtn = [[NECustomButton alloc] init];
  self.mediaSwitchBtn.maskBtn.accessibilityIdentifier = @"inCallSwitch";

  [self.view addSubview:self.mediaSwitchBtn];
  [self.mediaSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(weakSelf.operationView.mas_centerX);
    make.bottom.equalTo(weakSelf.operationView.mas_top).offset(-150 * self.factor);
    make.size.mas_equalTo(buttonSize);
  }];

  CGFloat space_width = 20;

  [self.view addSubview:self.microphoneBtn];
  [self.microphoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(weakSelf.cancelBtn);
    make.centerX.mas_equalTo(-self.view.frame.size.width / 4.0 - 20);
    make.size.mas_equalTo(buttonSize);
  }];
  [self.microphoneBtn setHidden:YES];

  [self.view addSubview:self.speakerBtn];
  [self.speakerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.view.frame.size.width / 4.0 + 20);
    make.centerY.equalTo(weakSelf.cancelBtn);
    make.left.equalTo(weakSelf.cancelBtn.mas_right).offset(space_width);
    make.size.mas_equalTo(buttonSize);
  }];
  [self.speakerBtn setHidden:YES];

  [self.mediaSwitchBtn.maskBtn addTarget:self
                                  action:@selector(mediaSwitchClick)
                        forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:self.timerLabel];
  [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.switchCameraBtn);
    make.centerX.equalTo(self.view);
  }];

  self.mediaSwitchBtn.hidden = ![[SettingManager shareInstance] supportAutoJoinWhenCalled];
}

- (void)mediaSwitchClick {
  if ([[NetManager shareInstance] isClose] == YES) {
    [self.view ne_makeToast:@"网络连接异常，请稍后再试"];
    return;
  }
  self.mediaSwitchBtn.maskBtn.enabled = NO;
  NERtcCallType type =
      self.callType == NERtcCallTypeVideo ? NERtcCallTypeAudio : NERtcCallTypeVideo;
  __weak typeof(self) weakSelf = self;

  [[NERtcCallKit sharedInstance]
      switchCallType:type
           withState:NERtcSwitchStateInvite
          completion:^(NSError *_Nullable error) {
            weakSelf.mediaSwitchBtn.maskBtn.enabled = YES;
            if (error == nil) {
              NSLog(@"切换成功 : %lu", type);
              if (type == NERtcCallTypeVideo && [SettingManager.shareInstance isVideoConfirm]) {
                [weakSelf showBannerView];
              } else if (type == NERtcCallTypeAudio &&
                         [SettingManager.shareInstance isAudioConfirm]) {
                [weakSelf showBannerView];
              }
            } else {
              [weakSelf.view ne_makeToast:[NSString stringWithFormat:@"切换失败:%@", error]];
            }
          }];
}

- (void)setupPSTNUI {
  self.mediaSwitchBtn.hidden = YES;
  self.remoteAvatorView.hidden = YES;
  self.mediaSwitchBtn.hidden = YES;
  [self.operationView hideMediaSwitch];
}

- (void)setupCenterRemoteAvator {
  [self.view addSubview:self.centerSubtitleLabel];

  [self.centerSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.view);
    make.bottom.equalTo(self.mediaSwitchBtn.mas_top).offset(-33 * self.factor);
  }];

  [self.view addSubview:self.centerTitleLabel];

  [self.centerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.centerSubtitleLabel.mas_top).offset(-10 * self.factor);
    make.right.left.equalTo(self.view);
  }];

  [self.view addSubview:self.remoteBigAvatorView];

  [self.remoteBigAvatorView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(90, 90));
    make.bottom.equalTo(self.centerTitleLabel.mas_top).offset(-10 * self.factor);
    make.centerX.equalTo(self.view);
  }];

  [self.centerTitleLabel setHidden:YES];
  [self.centerSubtitleLabel setHidden:YES];

  if (self.callType == NERtcCallTypeVideo) {
    [self setSwitchAudioStyle];
  } else {
    [self setSwitchVideoStyle];
  }
}

- (void)setSwitchAudioStyle {
  self.mediaSwitchBtn.imageView.image = [UIImage imageNamed:@"switch_audio"];
  self.mediaSwitchBtn.titleLabel.text = @"切换到语音通话";
  self.mediaSwitchBtn.tag = NERtcCallTypeAudio;
  [self showVideoView];
  [self setUrl:self.remoteUser.avatar withPlaceholder:@"avator"];
  if (self.status == NERtcCallStatusCalled) {
    self.subTitleLabel.text = [self getInviteText];
    self.centerSubtitleLabel.text = [self getInviteText];
  } else {
    [self.blurImage setHidden:YES];
    [self.microphoneBtn setHidden:YES];
    [self.speakerBtn setHidden:YES];
    [self.centerTitleLabel setHidden:YES];
    [self.centerSubtitleLabel setHidden:YES];
    [self.remoteBigAvatorView setHidden:YES];

    [self.titleLabel setHidden:NO];
    [self.subTitleLabel setHidden:NO];
    [self.remoteAvatorView setHidden:NO];
  }
}

- (void)setSwitchVideoStyle {
  self.mediaSwitchBtn.imageView.image = [UIImage imageNamed:@"switch_video"];
  self.mediaSwitchBtn.titleLabel.text = @"切换到视频通话";
  self.mediaSwitchBtn.tag = NERtcCallTypeVideo;
  [self hideVideoView];
  [self setUrl:self.remoteUser.avatar withPlaceholder:@"avator"];
  if (self.status == NERtcCallStatusCalled) {
    self.subTitleLabel.text = [self getInviteText];
    self.centerSubtitleLabel.text = [self getInviteText];
  } else {
    [self.microphoneBtn setHidden:NO];
    [self.speakerBtn setHidden:NO];
    [self.centerTitleLabel setHidden:NO];
    [self.centerSubtitleLabel setHidden:NO];
    [self.remoteBigAvatorView setHidden:NO];

    [self.titleLabel setHidden:YES];
    [self.subTitleLabel setHidden:YES];
    [self.remoteAvatorView setHidden:YES];
  }
}

- (void)updateUIonStatus:(NERtcCallStatus)status {
  switch (status) {
    case NERtcCallStatusCalling: {
      self.titleLabel.text = [NSString stringWithFormat:@"正在呼叫 %@", self.remoteUser.mobile];
      self.centerTitleLabel.text = self.titleLabel.text;
      self.subTitleLabel.text = @"等待对方接听……";
      self.centerSubtitleLabel.text = self.subTitleLabel.text;
      self.remoteAvatorView.hidden = NO;
      [self.remoteAvatorView sd_setImageWithURL:[NSURL URLWithString:self.remoteUser.avatar]
                               placeholderImage:[UIImage imageNamed:@"avator"]];
      [self.remoteBigAvatorView sd_setImageWithURL:[NSURL URLWithString:self.remoteUser.avatar]
                                  placeholderImage:[UIImage imageNamed:@"avator"]];
      self.smallVideoView.hidden = YES;
      self.cancelBtn.hidden = NO;
      self.rejectBtn.hidden = YES;
      self.acceptBtn.hidden = YES;
      self.switchCameraBtn.hidden = YES;
      self.operationView.hidden = YES;
    } break;
    case NERtcCallStatusCalled: {
      self.titleLabel.text = [NSString stringWithFormat:@"%@", self.remoteUser.mobile];
      self.centerTitleLabel.text = self.titleLabel.text;
      self.remoteAvatorView.hidden = NO;
      [self setUrl:self.remoteUser.avatar withPlaceholder:@"avator"];
      [self.remoteBigAvatorView sd_setImageWithURL:[NSURL URLWithString:self.remoteUser.avatar]
                                  placeholderImage:[UIImage imageNamed:@"avator"]];
      self.remoteBigAvatorView.hidden = NO;
      self.centerSubtitleLabel.hidden = NO;
      self.centerTitleLabel.hidden = NO;

      self.remoteAvatorView.hidden = YES;
      self.titleLabel.hidden = YES;
      self.subTitleLabel.hidden = YES;
      self.subTitleLabel.text = [self getInviteText];
      self.centerSubtitleLabel.text = [self getInviteText];
      self.smallVideoView.hidden = YES;
      self.cancelBtn.hidden = YES;
      self.rejectBtn.hidden = NO;
      self.acceptBtn.hidden = NO;
      self.switchCameraBtn.hidden = YES;
      self.operationView.hidden = YES;
    } break;
    case NERtcCallStatusInCall: {
      self.smallVideoView.hidden = NO;
      self.titleLabel.hidden = YES;
      self.subTitleLabel.hidden = YES;
      self.remoteAvatorView.hidden = YES;
      self.cancelBtn.hidden = YES;
      self.rejectBtn.hidden = YES;
      self.acceptBtn.hidden = YES;
      self.switchCameraBtn.hidden = NO;
      self.operationView.hidden = NO;

      self.mediaSwitchBtn.hidden = YES;
      self.microphoneBtn.hidden = YES;
      self.speakerBtn.hidden = YES;
      self.centerSubtitleLabel.hidden = YES;

      if (self.callType == NERtcCallTypeVideo) {
        self.centerTitleLabel.hidden = YES;
        self.remoteBigAvatorView.hidden = YES;
        self.blurImage.hidden = YES;
      } else {
        self.centerTitleLabel.hidden = NO;
        self.remoteBigAvatorView.hidden = NO;
        self.blurImage.hidden = NO;
        self.smallVideoView.hidden = YES;
      }

      self.titleLabel.text = self.remoteUser.mobile;
      self.centerTitleLabel.text = self.remoteUser.mobile;
    } break;
    default:
      break;
  }
  self.status = status;
}

- (void)showVideoView {
  if (self.status == NERtcCallStatusCalling) {
    [[NERtcCallKit sharedInstance] setupLocalView:self.bigVideoView.videoView];
  }
  if (self.status == NERtcCallStatusInCall) {
    [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
    NSLog(@"self.status == NERtcCallStatusInCall enableLocalVideo:YES");
    [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView
                                           forUser:self.remoteUser.imAccid];
    self.smallVideoView.hidden = NO;
  }

  //    if (self.switchCameraBtn.selected == YES) {
  //        [[NERtcCallKit sharedInstance] switchCamera];
  //    }

  [[NERtcCallKit sharedInstance] muteLocalAudio:NO];
  [[NERtcCallKit sharedInstance] muteLocalVideo:NO];
  self.operationView.microPhone.selected = NO;
  self.bigVideoView.videoView.hidden = NO;
  self.smallVideoView.videoView.hidden = NO;
  self.smallVideoView.coverView.hidden = YES;
  self.bigVideoView.imageView.hidden = YES;
  self.smallVideoView.imageView.hidden = YES;
  self.bigVideoView.coverView.hidden = YES;
  self.callType = NERtcCallTypeVideo;
  self.operationView.cameraBtn.selected = NO;
  if (self.status != NERtcCallStatusCalled) {
    self.centerTitleLabel.hidden = YES;
    self.remoteBigAvatorView.hidden = YES;
    self.blurImage.hidden = YES;
  }

  self.speakerBtn.imageView.highlighted = YES;
  self.microphoneBtn.imageView.highlighted = NO;
  self.operationView.speakerBtn.selected = NO;
  self.operationView.microPhone.selected = NO;
  NSError *error;
  [[NERtcCallKit sharedInstance] setLoudSpeakerMode:YES error:&error];
  [[NERtcEngine sharedEngine] muteLocalAudio:NO];
}

- (void)hideVideoView {
  [[NERtcCallKit sharedInstance] setupLocalView:nil];
  [[NERtcCallKit sharedInstance] setupRemoteView:nil forUser:nil];
  self.bigVideoView.videoView.hidden = YES;
  self.smallVideoView.videoView.hidden = YES;
  self.smallVideoView.hidden = YES;
  self.callType = NERtcCallTypeAudio;
  self.centerTitleLabel.hidden = NO;
  self.remoteBigAvatorView.hidden = NO;
  self.blurImage.hidden = NO;

  self.speakerBtn.imageView.highlighted = NO;
  self.microphoneBtn.imageView.highlighted = NO;
  self.operationView.speakerBtn.selected = YES;
  self.operationView.microPhone.selected = NO;
  NSError *error;
  [[NERtcCallKit sharedInstance] setLoudSpeakerMode:NO error:&error];
  [[NERtcEngine sharedEngine] muteLocalAudio:NO];
}

#pragma mark - event
- (void)closeEvent:(UIButton *)button {
  if (self.isPstn == YES) {
    [[NECallKitPstn sharedInstance] hangupWithCompletion:^(NSError *_Nullable error){

    }];
    return;
  }

  [[NERtcCallKit sharedInstance] hangup:^(NSError *_Nullable error){

  }];
}

- (void)cancelEvent:(UIButton *)button {
  __weak typeof(self) weakSelf = self;
  button.enabled = NO;

  if ([[NetManager shareInstance] isClose] == YES) {
    if (self.isPstn == YES) {
      [[NERtcCallKit sharedInstance] changeStatusIdle];
    }
    [self onCallEnd];
    return;
  }

  if (self.isPstn == YES) {
    NSLog(@"cancel pstn");
    [[NECallKitPstn sharedInstance] hangupWithCompletion:^(NSError *_Nullable error) {
      button.enabled = YES;
      if (error) {
        [UIApplication.sharedApplication.keyWindow ne_makeToast:error.localizedDescription];
      } else {
        weakSelf.statusModel.status = NIMRtcCallStatusCanceled;
        [weakSelf destroy];
      }
    }];
    return;
  }
  NSLog(@"cancel rtc");
  [[NERtcCallKit sharedInstance] cancel:^(NSError *_Nullable error) {
    NSLog(@"cancel error %@", error);
    button.enabled = YES;
    if (error.code == 20016) {
      // 邀请已接受 取消失败 不销毁VC
      NSLog(@"邀请已接受 取消失败 不销毁VC");
    } else {
      weakSelf.statusModel.status = NIMRtcCallStatusCanceled;
      [weakSelf destroy];
    }
  }];
}
- (void)rejectEvent:(UIButton *)button {
  self.acceptBtn.userInteractionEnabled = NO;

  if ([[SettingManager shareInstance] rejectBusyCode] == YES) {
    [[NERtcCallKit sharedInstance] rejectWithReason:TerminalCodeBusy
                                     withCompletion:^(NSError *_Nullable error) {
                                       self.acceptBtn.userInteractionEnabled = YES;
                                       [self destroy];
                                     }];
  } else {
    [[NERtcCallKit sharedInstance] reject:^(NSError *_Nullable error) {
      self.acceptBtn.userInteractionEnabled = YES;
      [self destroy];
    }];
  }
}
- (void)acceptEvent:(UIButton *)button {
  __weak typeof(self) weakSelf = self;
  self.rejectBtn.userInteractionEnabled = NO;
  self.acceptBtn.userInteractionEnabled = NO;

  [[NERtcCallKit sharedInstance]
      acceptWithToken:[[SettingManager shareInstance] customToken]
       withCompletion:^(NSError *_Nullable error) {
         self.rejectBtn.userInteractionEnabled = YES;
         self.acceptBtn.userInteractionEnabled = YES;
         if (error) {
           //           NSLog(@"accept error : %@", error);
           [UIApplication.sharedApplication.keyWindow
               ne_makeToast:[NSString stringWithFormat:@"接听失败%@", error.localizedDescription]];
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                          dispatch_get_main_queue(), ^{
                            weakSelf.statusModel.status = NIMRtcCallStatusTimeout;
                            [weakSelf destroy];
                          });
         } else {
           [[NERtcCallKit sharedInstance] memberOfAccid:@""
                                             completion:^(NIMSignalingMemberInfo *_Nullable info){

                                             }];
           [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
           weakSelf.smallVideoView.userID = self.localUser.imAccid;
           [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView
                                                  forUser:self.remoteUser.imAccid];
           weakSelf.bigVideoView.userID = self.remoteUser.imAccid;
           [weakSelf updateUIonStatus:NERtcCallStatusInCall];
           [weakSelf startTimer];
         }
       }];

  /*
   [[NERtcCallKit sharedInstance] accept:^(NSError * _Nullable error) {
   self.rejectBtn.userInteractionEnabled = YES;
   self.acceptBtn.userInteractionEnabled = YES;
   if (error) {
   NSLog(@"accept error : %@", error);
   if (error.code == 21000 || error.code == 21001) {
   [UIApplication.sharedApplication.keyWindow ne_makeToast:[NSString
   stringWithFormat:@"接听失败%@", error.localizedDescription]]; }else {
   [UIApplication.sharedApplication.keyWindow ne_makeToast:@"接听失败"];
   }
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
   dispatch_get_main_queue(), ^{ weakSelf.statusModel.status = NIMRtcCallStatusTimeout; [weakSelf
   destroy];
   });
   }else {
   [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
   weakSelf.smallVideoView.userID = self.localUser.imAccid;
   [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView
   forUser:self.remoteUser.imAccid]; weakSelf.bigVideoView.userID = self.remoteUser.imAccid;
   [weakSelf updateUIonStatus:NERtcCallStatusInCall];
   [weakSelf startTimer];
   }
   }]; */
}
- (void)switchCameraBtn:(UIButton *)button {
  [[NERtcCallKit sharedInstance] switchCamera];
  button.selected = !button.selected;
  if (button.isSelected == YES) {
    [[NERtcEngine sharedEngine] setParameters:@{kNERtcKeyVideoStartWithBackCamera : @YES}];
  }
}
- (void)microPhoneClick:(UIButton *)button {
  button.selected = !button.selected;
  [[NERtcCallKit sharedInstance] muteLocalAudio:button.selected];
}
- (void)cameraBtnClick:(UIButton *)button {
  button.selected = !button.selected;
  NSLog(@"mute video select : %d", button.selected);
  if ([[SettingManager shareInstance] useEnableLocalMute] == YES) {
    NSLog(@"enableLocalVideo: %d", !button.selected);
    [[NERtcCallKit sharedInstance] enableLocalVideo:!button.selected];
  } else {
    [[NERtcCallKit sharedInstance] muteLocalVideo:button.selected];
  }
  [self changeDefaultImage:button.selected];
  [self cameraAvailble:!button.selected userId:self.localUser.imAccid];
}
- (void)hangupBtnClick:(UIButton *)button {
  self.statusModel.status = NIMRtcCallStatusComplete;
  if (self.isPstn) {
    [[NECallKitPstn sharedInstance] hangupWithCompletion:^(NSError *_Nullable error){

    }];
  } else {
    [[NERtcCallKit sharedInstance] hangup:^(NSError *_Nullable error){
    }];
  }
  [self destroy];
}
- (void)microphoneBtnClick:(UIButton *)button {
  NSLog(@"micro phone btn click : %d", button.imageView.highlighted);
  self.microphoneBtn.imageView.highlighted = !self.microphoneBtn.imageView.highlighted;
  button.selected = self.microphoneBtn.imageView.highlighted;
  [[NERtcCallKit sharedInstance] muteLocalAudio:button.imageView.highlighted];
  _operationView.microPhone.selected = self.microphoneBtn.imageView.highlighted;
}
- (void)speakerBtnClick:(UIButton *)button {
  NSLog(@"speaker btn click : %d", button.imageView.highlighted);
  NSError *error = nil;
  [[NERtcCallKit sharedInstance] setLoudSpeakerMode:!button.imageView.highlighted error:&error];
  if (error == nil) {
    self.speakerBtn.imageView.highlighted = !self.speakerBtn.imageView.highlighted;
    button.selected = self.speakerBtn.imageView.highlighted;
    _operationView.speakerBtn.selected = !self.speakerBtn.imageView.highlighted;
  } else {
    [self.view ne_makeToast:error.description];
  }
}
- (void)switchVideoView:(UITapGestureRecognizer *)tap {
  self.showMyBigView = !self.showMyBigView;
  if (self.showMyBigView) {
    [[NERtcCallKit sharedInstance] setupLocalView:self.bigVideoView.videoView];
    [[NERtcCallKit sharedInstance] setupRemoteView:self.smallVideoView.videoView
                                           forUser:self.remoteUser.imAccid];
    NSLog(@"show my big view");
    self.smallVideoView.coverView.hidden = YES;
    self.bigVideoView.coverView.hidden = !self.operationView.cameraBtn.selected;
    self.bigVideoView.userID = self.localUser.imAccid;
    self.smallVideoView.userID = self.remoteUser.imAccid;
  } else {
    [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
    [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView
                                           forUser:self.remoteUser.imAccid];
    NSLog(@"show my small view");
    self.bigVideoView.coverView.hidden = YES;
    self.smallVideoView.coverView.hidden = !self.operationView.cameraBtn.selected;
    self.bigVideoView.userID = self.remoteUser.imAccid;
    self.smallVideoView.userID = self.localUser.imAccid;
  }

  [self changeDefaultImage:self.operationView.cameraBtn.selected];
}

- (void)operationSwitchClick:(UIButton *)btn {
  if ([[NetManager shareInstance] isClose] == YES) {
    [self.view ne_makeToast:@"网络连接异常，请稍后再试"];
    return;
  }
  __weak typeof(self) weakSelf = self;
  btn.enabled = NO;
  NERtcCallType type =
      self.callType == NERtcCallTypeVideo ? NERtcCallTypeAudio : NERtcCallTypeVideo;
  [[NERtcCallKit sharedInstance]
      switchCallType:type
           withState:NERtcSwitchStateInvite
          completion:^(NSError *_Nullable error) {
            // weakSelf.mediaSwitchBtn.enabled = YES;
            btn.enabled = YES;
            if (error == nil) {
              NSLog(@"切换成功 : %lu", type);
              NSLog(@"switch : %d", btn.selected);
              if (type == NERtcCallTypeVideo && [SettingManager.shareInstance isVideoConfirm]) {
                [weakSelf showBannerView];
              } else if (type == NERtcCallTypeAudio &&
                         [SettingManager.shareInstance isAudioConfirm]) {
                [weakSelf showBannerView];
              }
            } else {
              [weakSelf.view ne_makeToast:[NSString stringWithFormat:@"切换失败:%@", error]];
            }
          }];
}
- (void)operationSpeakerClick:(UIButton *)btn {
  NSError *error = nil;
  BOOL use;
  [[NERtcEngine sharedEngine] getLoudspeakerMode:&use];
  NSLog(@"get loud speaker %d", use);
  [[NERtcCallKit sharedInstance] setLoudSpeakerMode:btn.selected error:&error];
  if (error == nil) {
    btn.selected = !btn.selected;
  } else {
    [self.view ne_makeToast:error.description];
  }
}

#pragma mark - pstn delegate

- (void)pstnWillStart {
  self.isPstn = YES;
  [[UIApplication sharedApplication].keyWindow ne_makeToast:@"超时未响应"];
  //    self.cancelBtn.enabled = NO;
}

- (void)pstnOnError:(NSError *)error {
  NSLog(@"pstnOnError on error : %@", error);
  [[UIApplication sharedApplication].keyWindow ne_makeToast:error.localizedDescription];
}

- (void)pstnDidStart {
  NSLog(@"pstnDidStart");
}

- (void)directCallStartCallFinish {
  NSLog(@"directCallStartCallFinish");
  //    self.cancelBtn.enabled = YES;
}

- (void)onDirectCallRing {
}

- (void)onDirectCallAccept {
  [self updateUIonStatus:NERtcCallStatusInCall];
  [self startTimer];
}

- (void)onDirectCallDisconnectWithError:(NSError *)error {
}

- (void)onDirectCallHangupWithReason:(int)reason
                               error:(NSError *)error
                   isCallEstablished:(BOOL)isCallEstablished {
  if (reason == 102) {
    [[UIApplication sharedApplication].keyWindow ne_makeToast:@"超时未响应"];
  }
}

#pragma mark - NERtcVideoCallDelegate

- (void)onDisconnect:(NSError *)reason {
  self.statusModel.status = NIMRtcCallStatusTimeout;
  [self destroy];
}

- (void)onUserAccept:(NSString *)userID {
  NSLog(@"call viewcontroller accept");
}

// 能看到对方首首帧画面
- (void)onFirstVideoFrameDecoded:(NSString *)userID width:(uint32_t)width height:(uint32_t)height {
  //    [self.piPeibgView removeFromSuperview];
  //    self.piPeibgView = nil;
  NSLog(@"onFirstVideoFrameDecoded start");
}

- (void)onUserEnter:(NSString *)userID {
  NSLog(@"onUserEnter");
  [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
  self.smallVideoView.userID = self.localUser.imAccid;
  [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView forUser:userID];
  self.bigVideoView.userID = userID;
  [self updateUIonStatus:NERtcCallStatusInCall];
  [self startTimer];
  if ([[SettingManager shareInstance] incallShowCName] == YES &&
      [self.cnameLabel superview] == nil) {
    [self.view addSubview:self.cnameLabel];
    self.cnameLabel.text =
        [NSString stringWithFormat:@"cname: %@", [[SettingManager shareInstance] getRtcCName]];
    [self.cnameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.center.equalTo(self.view);
    }];
  }
}
- (void)onUserCancel:(NSString *)userID {
  self.statusModel.status = NIMRtcCallStatusCanceled;
  [[NERtcCallKit sharedInstance] hangup:^(NSError *_Nullable error){
  }];
  [UIApplication.sharedApplication.keyWindow ne_makeToast:@"对方取消"];
  [self destroy];
}
- (void)onCameraAvailable:(BOOL)available userID:(NSString *)userID {
  self.isRemoteMute = !available;
  [self cameraAvailble:available userId:userID];
}
- (void)onVideoMuted:(BOOL)muted userID:(NSString *)userID {
  self.isRemoteMute = muted;
  [self cameraAvailble:!muted userId:userID];
}
- (void)onUserLeave:(NSString *)userID {
  NSLog(@"onUserLeave");
  self.statusModel.status = NIMRtcCallStatusComplete;
  //    [self destroy];
}
- (void)onUserDisconnect:(NSString *)userID {
  NSLog(@"onUserDiconnect");
  self.statusModel.status = NIMRtcCallStatusComplete;
  [self destroy];
}
- (void)onCallingTimeOut {
  if ([[NetManager shareInstance] isClose] == YES) {
    [self destroy];
    return;
  }
  [UIApplication.sharedApplication.keyWindow ne_makeToast:@"对方超时未响应"];
  self.statusModel.status = NIMRtcCallStatusTimeout;
  [self destroy];
  //    [[NERtcCallKit sharedInstance] cancel:^(NSError * _Nullable error) {
  //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
  //        dispatch_get_main_queue(), ^{
  //            [self destroy];
  //        });
  //    }];
}
- (void)onUserBusy:(NSString *)userID {
  [UIApplication.sharedApplication.keyWindow ne_makeToast:@"对方占线"];
  self.statusModel.status = NIMRtcCallStatusBusy;
  [self destroy];
}
- (void)onCallEnd {
  self.statusModel.status = NIMRtcCallStatusComplete;
  [self destroy];
}
- (void)onUserReject:(NSString *)userID {
  [UIApplication.sharedApplication.keyWindow ne_makeToast:@"对方已经拒绝"];
  self.statusModel.status = NIMRtcCallStatusRejected;
  [self destroy];
}

- (void)onOtherClientAccept {
  [UIApplication.sharedApplication.keyWindow ne_makeToast:@"已被其他端接受"];
  self.statusModel.status = NIMRtcCallStatusComplete;
  [self destroy];
}

- (void)onOtherClientReject {
  [UIApplication.sharedApplication.keyWindow ne_makeToast:@"已被其他端拒绝"];
  self.statusModel.status = NIMRtcCallStatusRejected;
  [self destroy];
}

- (void)onCallTypeChange:(NERtcCallType)callType withState:(NERtcSwitchState)state {
  NSLog(@"onCallTypeChange:withState:");
  switch (state) {
    case NERtcSwitchStateAgree:
      [self hideBannerView];
      [self onCallTypeChange:callType];
      break;
    case NERtcSwitchStateInvite: {
      if (self.alert != nil) {
        NSLog(@"alert is showing");
        return;
      }
      UIAlertController *alert = [UIAlertController
          alertControllerWithTitle:NSLocalizedString(@"permission", nil)
                           message:callType == NERtcCallTypeVideo
                                       ? NSLocalizedString(@"audio_to_video", nil)
                                       : NSLocalizedString(@"video_to_audio", nil)
                    preferredStyle:UIAlertControllerStyleAlert];
      self.alert = alert;
      UIAlertAction *rejectAction =
          [UIAlertAction actionWithTitle:NSLocalizedString(@"reject", nil)
                                   style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *_Nonnull action) {
                                   [[NERtcCallKit sharedInstance]
                                       switchCallType:callType
                                            withState:NERtcSwitchStateReject
                                           completion:^(NSError *_Nullable error) {
                                             if (error) {
                                               [UIApplication.sharedApplication.keyWindow
                                                   ne_makeToast:error.localizedDescription];
                                             }
                                           }];
                                 }];
      __weak typeof(self) weakSelf = self;
      UIAlertAction *agreeAction =
          [UIAlertAction actionWithTitle:NSLocalizedString(@"agree", nil)
                                   style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *_Nonnull action) {
                                   [[NERtcCallKit sharedInstance]
                                       switchCallType:callType
                                            withState:NERtcSwitchStateAgree
                                           completion:^(NSError *_Nullable error) {
                                             [weakSelf onCallTypeChange:callType];
                                             if (error) {
                                               [UIApplication.sharedApplication.keyWindow
                                                   ne_makeToast:error.localizedDescription];
                                             }
                                           }];
                                 }];

      [alert addAction:rejectAction];
      [alert addAction:agreeAction];
      [self presentViewController:alert animated:YES completion:nil];

      NSLog(@"NERtcSwitchStateInvite : %ld", callType);

    }

    break;
    case NERtcSwitchStateReject:
      [self hideBannerView];
      [UIApplication.sharedApplication.keyWindow
          ne_makeToast:NSLocalizedString(@"reject_tip", nil)];
      break;
    default:
      break;
  }
  NSLog(@"onCallTypeChange : %lu  with state : %lu", callType, state);
}

- (void)onCallTypeChange:(NERtcCallType)callType {
  NSLog(@"onCallTypeChange:");
  if (self.callKitType == PSTN) {
    NSLog(@"pstn not support audio video convert");
    return;
  }
  if (self.callType == callType) {
    return;
  }
  self.callType = callType;

  if (self.status == NERtcCallStatusInCall) {
    switch (callType) {
      case NERtcCallTypeAudio:
        NSLog(@"NERtcCallTypeAudio");
        [self.operationView changeAudioStyle];
        [self hideVideoView];
        break;
      case NERtcCallTypeVideo:
        NSLog(@"NERtcCallTypeVideo");
        [self.operationView changeVideoStyle];
        [self showVideoView];
        break;
      default:
        break;
    }
    return;
  }

  switch (callType) {
    case NERtcCallTypeAudio:
      [self.operationView changeAudioStyle];
      [self setSwitchVideoStyle];
      break;
    case NERtcCallTypeVideo:
      [self.operationView changeVideoStyle];
      [self setSwitchAudioStyle];
      break;
    default:
      break;
  }
}

- (void)onError:(NSError *)error {
  NSLog(@"call kit on error : %@", error);
}

- (void)onAudioAvailable:(BOOL)available userID:(NSString *)userID {
  NSLog(@"onAudioAvailable");
}

#pragma mark - private mothed
- (void)cameraAvailble:(BOOL)available userId:(NSString *)userId {
  //    NSString *tips = [self.localUser.imAccid
  //    isEqualToString:userId]?@"关闭了摄像头":@"对方关闭了摄像头";
  if ([self.bigVideoView.userID isEqualToString:userId]) {
    self.bigVideoView.coverView.hidden = available;
  }
  if ([self.smallVideoView.userID isEqualToString:userId]) {
    self.smallVideoView.coverView.hidden = available;
  }
  if (self.showMyBigView) {
    [self changeRemoteMute:self.isRemoteMute videoView:self.smallVideoView];
  } else {
    [self changeRemoteMute:self.isRemoteMute videoView:self.bigVideoView];
  }
}

- (void)setUrl:(NSString *)url withPlaceholder:(NSString *)holder {
  __weak typeof(self) weakSelf = self;
  [self.remoteAvatorView
      sd_setImageWithURL:[NSURL URLWithString:url]
               completed:^(UIImage *_Nullable image, NSError *_Nullable error,
                           SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                 if (image == nil) {
                   image = [UIImage imageNamed:holder];
                 }
                 if (weakSelf.isCaller == false && weakSelf.callType == NERtcCallTypeVideo) {
                   [weakSelf.blurImage setHidden:NO];
                 }
                 weakSelf.blurImage.image = image;
               }];
}

- (void)startTimer {
  if (self.timer != nil) {
    return;
  }
  if (self.timerLabel.hidden == YES) {
    self.timerLabel.hidden = NO;
  }
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(figureTimer)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)figureTimer {
  self.timerCount++;
  self.timerLabel.text = [self timeFormatted:self.timerCount];
}

- (NSString *)timeFormatted:(int)totalSeconds {
  if (totalSeconds < 3600) {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
  }
  int seconds = totalSeconds % 60;
  int minutes = (totalSeconds / 60) % 60;
  int hours = totalSeconds / 3600;
  return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

- (NSString *)getInviteText {
  return (self.callType == NERtcCallTypeAudio ? @"邀请您音频通话" : @"邀请您视频通话");
}

- (void)hideBannerView {
  self.bannerView.hidden = YES;
}

- (void)showBannerView {
  self.bannerView.hidden = NO;
}

#pragma mark - destroy
- (void)destroy {
  //  NSLog(@"destroy callStackSymbols : %@", [NSThread callStackSymbols]);
  if (self.alert != nil) {
    [self.alert dismissViewControllerAnimated:NO completion:nil];
  }

  if (self && [self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
  [[NERtcCallKit sharedInstance] removeDelegate:self];
  if (self.callKitType == PSTN) {
    [[NECallKitPstn sharedInstance] removePstnDelegate];
  }

  if (self.timer != nil) {
    [self.timer invalidate];
    self.timer = nil;
  }
}
#pragma mark - property

- (UILabel *)cnameLabel {
  if (_cnameLabel == nil) {
    _cnameLabel = [[UILabel alloc] init];
    _cnameLabel.textColor = [UIColor redColor];
    _cnameLabel.font = [UIFont systemFontOfSize:14];
  }
  return _cnameLabel;
}

- (UIView *)bannerView {
  if (!_bannerView) {
    _bannerView = [[UIView alloc] init];
    _bannerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    _bannerView.clipsToBounds = YES;
    _bannerView.layer.cornerRadius = self.radius;
    _bannerView.hidden = YES;

    NEExpandButton *closeBtn = [NEExpandButton buttonWithType:UIButtonTypeCustom];
    [_bannerView addSubview:closeBtn];
    closeBtn.backgroundColor = [UIColor clearColor];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];

    [closeBtn addTarget:self
                  action:@selector(closeEvent)
        forControlEvents:UIControlEventTouchUpInside];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.bottom.right.equalTo(_bannerView);
      make.width.mas_equalTo(40);
    }];

    UILabel *label = [[UILabel alloc] init];
    [_bannerView addSubview:label];
    label.textColor = [UIColor whiteColor];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(_bannerView).offset(10);
      make.top.bottom.equalTo(_bannerView);
      make.right.equalTo(closeBtn.mas_left).offset(-10);
    }];
    label.adjustsFontSizeToFitWidth = YES;
    label.text = @"正在等待对方响应...";
  }
  return _bannerView;
}

- (void)closeEvent {
  [self hideBannerView];
}

- (NEVideoView *)bigVideoView {
  if (!_bigVideoView) {
    _bigVideoView = [[NEVideoView alloc] init];
    _bigVideoView.backgroundColor = [UIColor darkGrayColor];
  }
  return _bigVideoView;
}
- (NEVideoView *)smallVideoView {
  if (!_smallVideoView) {
    _smallVideoView = [[NEVideoView alloc] init];
    _smallVideoView.backgroundColor = [UIColor darkGrayColor];
    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchVideoView:)];
    [_smallVideoView addGestureRecognizer:tap];
  }
  return _smallVideoView;
}
- (UIImageView *)remoteAvatorView {
  if (!_remoteAvatorView) {
    _remoteAvatorView = [[UIImageView alloc] init];
    _remoteAvatorView.image = [UIImage imageNamed:@"avator"];
  }
  return _remoteAvatorView;
}
- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:self.titleFontSize];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentRight;
  }
  return _titleLabel;
}
- (UILabel *)subTitleLabel {
  if (!_subTitleLabel) {
    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.font = [UIFont boldSystemFontOfSize:self.subTitleFontSize];
    _subTitleLabel.textColor = [UIColor whiteColor];
    _subTitleLabel.text = @"等待对方接听……";
    _subTitleLabel.textAlignment = NSTextAlignmentRight;
  }
  return _subTitleLabel;
}
- (NECustomButton *)cancelBtn {
  if (!_cancelBtn) {
    _cancelBtn = [[NECustomButton alloc] init];
    _cancelBtn.titleLabel.text = @"取消";
    _cancelBtn.imageView.image = [UIImage imageNamed:@"call_cancel"];
    _cancelBtn.maskBtn.accessibilityIdentifier = @"cancel_btn";
    [_cancelBtn.maskBtn addTarget:self
                           action:@selector(cancelEvent:)
                 forControlEvents:UIControlEventTouchUpInside];
  }
  return _cancelBtn;
}
- (NECustomButton *)rejectBtn {
  if (!_rejectBtn) {
    _rejectBtn = [[NECustomButton alloc] init];
    _rejectBtn.titleLabel.text = @"拒绝";
    _rejectBtn.imageView.image = [UIImage imageNamed:@"call_cancel"];
    _rejectBtn.maskBtn.accessibilityIdentifier = @"reject_btn";
    [_rejectBtn.maskBtn addTarget:self
                           action:@selector(rejectEvent:)
                 forControlEvents:UIControlEventTouchUpInside];
  }
  return _rejectBtn;
}
- (NECustomButton *)acceptBtn {
  if (!_acceptBtn) {
    _acceptBtn = [[NECustomButton alloc] init];
    _acceptBtn.titleLabel.text = @"接听";
    _acceptBtn.imageView.image = [UIImage imageNamed:@"call_accept"];
    _acceptBtn.imageView.contentMode = UIViewContentModeCenter;
    _acceptBtn.maskBtn.accessibilityIdentifier = @"accept_btn";
    [_acceptBtn.maskBtn addTarget:self
                           action:@selector(acceptEvent:)
                 forControlEvents:UIControlEventTouchUpInside];
  }
  return _acceptBtn;
}
- (NECustomButton *)microphoneBtn {
  if (nil == _microphoneBtn) {
    _microphoneBtn = [[NECustomButton alloc] init];
    _microphoneBtn.titleLabel.text = @"麦克风";
    _microphoneBtn.imageView.image = [UIImage imageNamed:@"micro_phone"];
    _microphoneBtn.imageView.highlightedImage = [UIImage imageNamed:@"micro_phone_mute"];
    _microphoneBtn.imageView.contentMode = UIViewContentModeCenter;
    _microphoneBtn.maskBtn.accessibilityIdentifier = @"micro_phone";
    [_microphoneBtn.maskBtn addTarget:self
                               action:@selector(microphoneBtnClick:)
                     forControlEvents:UIControlEventTouchUpInside];
  }
  return _microphoneBtn;
}
- (NECustomButton *)speakerBtn {
  if (nil == _speakerBtn) {
    _speakerBtn = [[NECustomButton alloc] init];
    _speakerBtn.titleLabel.text = @"扬声器";
    _speakerBtn.imageView.image = [UIImage imageNamed:@"speaker_off"];
    _speakerBtn.imageView.highlightedImage = [UIImage imageNamed:@"speaker_on"];
    _speakerBtn.imageView.contentMode = UIViewContentModeCenter;
    _speakerBtn.maskBtn.accessibilityIdentifier = @"speaker";
    [_speakerBtn.maskBtn addTarget:self
                            action:@selector(speakerBtnClick:)
                  forControlEvents:UIControlEventTouchUpInside];
  }
  return _speakerBtn;
}
- (UIButton *)switchCameraBtn {
  if (!_switchCameraBtn) {
    _switchCameraBtn = [[UIButton alloc] init];
    [_switchCameraBtn setImage:[UIImage imageNamed:@"call_switch_camera"]
                      forState:UIControlStateNormal];
    [_switchCameraBtn addTarget:self
                         action:@selector(switchCameraBtn:)
               forControlEvents:UIControlEventTouchUpInside];
  }
  return _switchCameraBtn;
}
- (NEVideoOperationView *)operationView {
  if (!_operationView) {
    _operationView = [[NEVideoOperationView alloc] init];
    _operationView.layer.cornerRadius = 30;
    [_operationView.microPhone addTarget:self
                                  action:@selector(microPhoneClick:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_operationView.cameraBtn addTarget:self
                                 action:@selector(cameraBtnClick:)
                       forControlEvents:UIControlEventTouchUpInside];
    [_operationView.hangupBtn addTarget:self
                                 action:@selector(hangupBtnClick:)
                       forControlEvents:UIControlEventTouchUpInside];
    [_operationView.mediaBtn addTarget:self
                                action:@selector(operationSwitchClick:)
                      forControlEvents:UIControlEventTouchUpInside];
    [_operationView.speakerBtn addTarget:self
                                  action:@selector(operationSpeakerClick:)
                        forControlEvents:UIControlEventTouchUpInside];
  }
  return _operationView;
}
- (UILabel *)centerSubtitleLabel {
  if (nil == _centerSubtitleLabel) {
    _centerSubtitleLabel = [[UILabel alloc] init];
    _centerSubtitleLabel.textColor = [UIColor whiteColor];
    _centerSubtitleLabel.font = [UIFont systemFontOfSize:self.subTitleFontSize];
    _centerSubtitleLabel.text = @"等待对方接听……";
    _centerSubtitleLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _centerSubtitleLabel;
}
- (UILabel *)centerTitleLabel {
  if (nil == _centerTitleLabel) {
    _centerTitleLabel = [[UILabel alloc] init];
    _centerTitleLabel.textColor = [UIColor whiteColor];
    _centerTitleLabel.font = [UIFont systemFontOfSize:self.titleFontSize];
    _centerTitleLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _centerTitleLabel;
}
- (UIImageView *)remoteBigAvatorView {
  if (nil == _remoteBigAvatorView) {
    _remoteBigAvatorView = [[UIImageView alloc] init];
    _remoteBigAvatorView.image = [UIImage imageNamed:@"avator"];
    _remoteBigAvatorView.clipsToBounds = YES;
    _remoteBigAvatorView.layer.cornerRadius = self.radius;
  }
  return _remoteBigAvatorView;
}
- (UILabel *)timerLabel {
  if (nil == _timerLabel) {
    _timerLabel = [[UILabel alloc] init];
    _timerLabel.textColor = [UIColor whiteColor];
    _timerLabel.font = [UIFont systemFontOfSize:14.0];
    _timerLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _timerLabel;
}
- (NECallStatusRecordModel *)statusModel {
  if (nil == _statusModel) {
    _statusModel = [[NECallStatusRecordModel alloc] init];
  }
  return _statusModel;
}

- (void)dealloc {
  if (self.callType == CALLKIT) {
    [[NERtcCallKit sharedInstance] removeDelegate:self];
  } else if (self.callType == PSTN) {
    [[NECallKitPstn sharedInstance] removeDelegate];
  }
}

- (void)hideViews:(NSArray<UIView *> *)views {
  for (UIView *view in views) {
    [view setHidden:YES];
  }
}

- (void)showViews:(NSArray<UIView *> *)views {
  for (UIView *view in views) {
    [view setHidden:NO];
  }
}

- (void)changeDefaultImage:(BOOL)mute {
  UIImage *image = [[SettingManager shareInstance] muteDefaultImage];
  if (image != nil) {
    if (mute == YES) {
      if (self.showMyBigView) {
        self.bigVideoView.imageView.image = image;
        self.bigVideoView.imageView.hidden = NO;
        [self changeRemoteMute:self.isRemoteMute videoView:self.smallVideoView];
      } else {
        self.smallVideoView.imageView.image = image;
        self.smallVideoView.imageView.hidden = NO;
        [self changeRemoteMute:self.isRemoteMute videoView:self.bigVideoView];
      }
    } else {
      if (self.showMyBigView) {
        self.bigVideoView.imageView.image = nil;
        self.bigVideoView.imageView.hidden = YES;
        self.smallVideoView.imageView.hidden = YES;
        [self changeRemoteMute:self.isRemoteMute videoView:self.smallVideoView];
      } else {
        self.smallVideoView.imageView.image = nil;
        self.smallVideoView.imageView.hidden = YES;
        [self changeRemoteMute:self.isRemoteMute videoView:self.bigVideoView];
      }
    }
  }
}

- (void)changeRemoteMute:(BOOL)mute videoView:(NEVideoView *)remoteVideo {
  UIImage *defaultImage = [[SettingManager shareInstance] remoteDefaultImage];
  if (mute == true && defaultImage != nil) {
    remoteVideo.imageView.hidden = NO;
    remoteVideo.imageView.image = defaultImage;
  } else {
    remoteVideo.imageView.hidden = YES;
  }
}

@end
