//
//  NECallViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NECallViewController.h"
#import "NECustomButton.h"
#import "NEVideoOperationView.h"
#import "NEVideoView.h"
#import <NERtcSDK/NERtcSDK.h>
#import "NetManager.h"

@interface NECallViewController ()
@property(strong,nonatomic) NEVideoView *smallVideoView;
@property(strong,nonatomic) NEVideoView *bigVideoView;
@property(strong,nonatomic) UIImageView *remoteAvatorView;
@property(strong,nonatomic) UIImageView *remoteBigAvatorView;
@property(strong,nonatomic) UILabel *titleLabel;
@property(strong,nonatomic) UILabel *centerTitleLabel;
@property(strong,nonatomic) UILabel *subTitleLabel;
@property(strong,nonatomic) UILabel *centerSubtitleLabel;
@property(strong,nonatomic) UILabel *timerLabel;
@property(strong,nonatomic) NSTimer *timer;

@property(strong,nonatomic) UIButton *switchCameraBtn;
/// 取消呼叫
@property(strong,nonatomic) NECustomButton *cancelBtn;
/// 拒绝接听
@property(strong,nonatomic) NECustomButton *rejectBtn;
/// 接听
@property(strong,nonatomic) NECustomButton *acceptBtn;
/// 音视频转换
@property(strong,nonatomic) NECustomButton *mediaSwitchBtn;
/// 麦克风
@property(strong,nonatomic) NECustomButton *microphoneBtn;
/// 扬声器
@property(strong,nonatomic) NECustomButton *speakerBtn;

@property(strong,nonatomic) NEVideoOperationView *operationView;
@property(assign,nonatomic) BOOL showMyBigView;

@property(strong,nonatomic) UIImageView *blurImage;

@property(strong,nonatomic) UIToolbar *toolBar;

@property(assign,nonatomic) CGFloat radius;
@property(assign,nonatomic) CGFloat titleFontSize;
@property(assign,nonatomic) CGFloat subTitleFontSize;
@property(assign,nonatomic) CGFloat factor;

@property(assign,nonatomic) int timerCount;

@property(nonatomic, strong) NECallStatusRecordModel *statusModel;

@end

@implementation NECallViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.factor = 1;
        self.radius = 4.0;
        self.titleFontSize = 20.0;
        self.subTitleFontSize = 14.0;
        self.timerCount = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupCenterRemoteAvator];
    [self setupSDK];
    [self updateUIonStatus:self.status];
    self.statusModel.startTime = [NSDate date];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NERtcCallKit sharedInstance] setupLocalView:nil];
}
#pragma mark - SDK
- (void)setupSDK {
    [[NERtcCallKit sharedInstance] addDelegate:self];
    [NERtcCallKit sharedInstance].timeOutSeconds = 30;
    NSError *error;
    [[NERtcCallKit sharedInstance] setLoudSpeakerMode:YES error:&error];
    [[NERtcCallKit sharedInstance] enableLocalVideo:YES];
    [[NERtcEngine sharedEngine] adjustRecordingSignalVolume:200];
    [[NERtcEngine sharedEngine] adjustPlaybackSignalVolume:200];
    if (self.status == NERtcCallStatusCalling) {
        [[NERtcCallKit sharedInstance] call:self.remoteUser.imAccid type:self.callType ? self.callType : NERtcCallTypeVideo completion:^(NSError * _Nullable error) {
            NSLog(@"call error code : %@", error);

            if (self.callType == NERtcCallTypeVideo) {
                [[NERtcCallKit sharedInstance] setupLocalView:self.bigVideoView.videoView];
            }
            self.bigVideoView.userID = self.localUser.imAccid;
            if (error) {
                /// 对方离线时 通过APNS推送 UI不弹框提示
                if (error.code == 10202 || error.code == 10201) {
                    return;
                }
                
                if (error.code == 21000 || error.code == 21001) {
                    //[UIApplication.sharedApplication.keyWindow makeToast:error.localizedDescription];
                    [self performSelector:@selector(destroy) withObject:nil afterDelay:3.5];
                }
                [self.view makeToast:error.localizedDescription];
            }
        }];
    }
}

- (void)setCallType:(NERtcCallType)callType {
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
        make.centerX.mas_equalTo(- self.view.frame.size.width/4.0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80 * self.factor);
        make.size.mas_equalTo(buttonSize);
    }];
    [self.view addSubview:self.acceptBtn];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.frame.size.width/4.0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80 * self.factor);
        make.size.mas_equalTo(buttonSize);
    }];
    [self.view addSubview:self.operationView];
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        //make.size.mas_equalTo(CGSizeMake(224, 60));
        make.height.mas_equalTo(60);
        make.width.equalTo(self.view).multipliedBy(0.8);
        make.bottom.mas_equalTo(-50 * self.factor);
    }];
    
    /// 未接通状态下的音视频切换按钮
    self.mediaSwitchBtn = [[NECustomButton alloc] init];
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
        make.centerX.mas_equalTo(-self.view.frame.size.width/4.0 - 20);
        make.size.mas_equalTo(buttonSize);
    }];
    [self.microphoneBtn setHidden:YES];
    
    [self.view addSubview:self.speakerBtn];
    [self.speakerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.frame.size.width/4.0 + 20);
        make.centerY.equalTo(weakSelf.cancelBtn);
        make.left.equalTo(weakSelf.cancelBtn.mas_right).offset(space_width);
        make.size.mas_equalTo(buttonSize);
    }];
    [self.speakerBtn setHidden:YES];
    
    if (self.callType == NERtcCallTypeVideo) {
        [self setSwitchAudioStyle];
    }else {
        [self setSwitchVideoStyle];
    }
    
    [[self.mediaSwitchBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if ([[NetManager shareInstance] isClose] == YES) {
            [weakSelf.view makeToast:@"网络连接异常，请稍后再试"];
            return;
        }
        weakSelf.mediaSwitchBtn.enabled = NO;
        NERtcCallType type =  weakSelf.callType == NERtcCallTypeVideo ? NERtcCallTypeAudio : NERtcCallTypeVideo;
        [[NERtcCallKit sharedInstance] switchCallType: type  completion:^(NSError * _Nullable error) {
            weakSelf.mediaSwitchBtn.enabled = YES;
            if (error == nil) {
                NSLog(@"切换成功 : %lu", type);
                if (weakSelf.mediaSwitchBtn.tag == NERtcCallTypeVideo) {
                    [weakSelf setSwitchAudioStyle];
                    [weakSelf.operationView changeVideoStyle];
                }else {
                    [weakSelf setSwitchVideoStyle];
                    [weakSelf.operationView changeAudioStyle];
                }
            }else {
                [weakSelf.view makeToast:[NSString stringWithFormat:@"切换失败:%@", error]];
            }
        }];
    }];
    
    [self.view addSubview:self.timerLabel];
    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.switchCameraBtn);
        make.centerX.equalTo(self.view);
    }];
    
    
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
}

- (void)setSwitchAudioStyle {
    
    self.mediaSwitchBtn.imageView.image = [UIImage imageNamed:@"switch_audio"];
    self.mediaSwitchBtn.titleLabel.text = @"切换到语音通话";
    self.mediaSwitchBtn.tag = NERtcCallTypeAudio;
    [self showVideoView];
    [self setUrl:self.remoteUser.avatar withPlaceholder:@"avator"];
    if (self.status == NERtcCallStatusCalled) {
        self.subTitleLabel.text = @"邀请您语音通话";
        self.centerSubtitleLabel.text = @"邀请您语音通话";
    }else {
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
        self.subTitleLabel.text = @"邀请您视频通话";
        self.centerSubtitleLabel.text = @"邀请您视频通话";
    }else {
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
        case NERtcCallStatusCalling:
        {
            self.titleLabel.text = [NSString stringWithFormat:@"正在呼叫 %@",self.remoteUser.mobile];
            self.centerTitleLabel.text = self.titleLabel.text;
            self.subTitleLabel.text = @"等待对方接听……";
            self.remoteAvatorView.hidden = NO;
            [self.remoteAvatorView sd_setImageWithURL:[NSURL URLWithString:self.remoteUser.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
            [self.remoteBigAvatorView sd_setImageWithURL:[NSURL URLWithString:self.remoteUser.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
            self.smallVideoView.hidden = YES;
            self.cancelBtn.hidden = NO;
            self.rejectBtn.hidden = YES;
            self.acceptBtn.hidden = YES;
            self.switchCameraBtn.hidden = YES;
            self.operationView.hidden = YES;
        }
            break;
        case NERtcCallStatusCalled:
        {
            self.titleLabel.text = [NSString stringWithFormat:@"%@",self.remoteUser.mobile];
            self.centerTitleLabel.text = self.titleLabel.text;
            self.remoteAvatorView.hidden = NO;
            [self setUrl:self.remoteUser.avatar withPlaceholder:@"avator"];
            [self.remoteBigAvatorView sd_setImageWithURL:[NSURL URLWithString:self.remoteUser.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
            self.remoteBigAvatorView.hidden = NO;
            self.centerSubtitleLabel.hidden = NO;
            self.centerTitleLabel.hidden = NO;
            
            self.remoteAvatorView.hidden = YES;
            self.titleLabel.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.subTitleLabel.text = @"邀请您视频通话";
            self.centerSubtitleLabel.text = @"邀请您视频通话";
            self.smallVideoView.hidden = YES;
            self.cancelBtn.hidden = YES;
            self.rejectBtn.hidden = NO;
            self.acceptBtn.hidden = NO;
            self.switchCameraBtn.hidden = YES;
            self.operationView.hidden = YES;
        }
            break;
        case NERtcCallStatusInCall:
        {
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
            }else {
                self.centerTitleLabel.hidden = NO;
                self.remoteBigAvatorView.hidden = NO;
                self.blurImage.hidden = NO;
                self.smallVideoView.hidden = YES;
            }
            
            self.titleLabel.text = self.remoteUser.mobile;
            self.centerTitleLabel.text = self.remoteUser.mobile;
        }
            break;
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
        [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView forUser:self.remoteUser.imAccid];
        self.smallVideoView.hidden = NO;
    }
    
//    if (self.switchCameraBtn.selected == YES) {
//        [[NERtcCallKit sharedInstance] switchCamera];
//    }
    
    [[NERtcCallKit sharedInstance] muteLocalAudio:NO];
    self.operationView.microPhone.selected = NO;
    self.bigVideoView.videoView.hidden = NO;
    self.smallVideoView.videoView.hidden = NO;
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
- (void)closeEvent:(NECustomButton *)button {
    [[NERtcCallKit sharedInstance] hangup:^(NSError * _Nullable error) {
        
    }];
}
- (void)cancelEvent:(NECustomButton *)button {
    __weak typeof(self) weakSelf = self;
    button.enabled = NO;
    [[NERtcCallKit sharedInstance] cancel:^(NSError * _Nullable error) {
        NSLog(@"cancel error %@",error);
        if (error.code == 20016) {
            // 邀请已接受 取消失败 不销毁VC
            NSLog(@"邀请已接受 取消失败 不销毁VC");
        }else {
            weakSelf.statusModel.status = NIMRtcCallStatusCanceled;
            [weakSelf destroy];
        }
    }];
}
- (void)rejectEvent:(NECustomButton *)button {
    self.acceptBtn.userInteractionEnabled = NO;
    [[NERtcCallKit sharedInstance] reject:^(NSError * _Nullable error) {
        self.acceptBtn.userInteractionEnabled = YES;
        [self destroy];
    }];
}
- (void)acceptEvent:(NECustomButton *)button {
    __weak typeof(self) weakSelf = self;
    self.rejectBtn.userInteractionEnabled = NO;
    self.acceptBtn.userInteractionEnabled = NO;
    [[NERtcCallKit sharedInstance] accept:^(NSError * _Nullable error) {
        self.rejectBtn.userInteractionEnabled = YES;
        self.acceptBtn.userInteractionEnabled = YES;
        if (error) {
            NSLog(@"accept error : %@", error);
            if (error.code == 21000 || error.code == 21001) {
                [UIApplication.sharedApplication.keyWindow makeToast:[NSString stringWithFormat:@"接听失败%@", error.localizedDescription]];
            }else {
                [UIApplication.sharedApplication.keyWindow makeToast:@"接听失败"];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.statusModel.status = NIMRtcCallStatusTimeout;
                [weakSelf destroy];
            });
        }else {
            [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
            weakSelf.smallVideoView.userID = self.localUser.imAccid;
            [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView forUser:self.remoteUser.imAccid];
            weakSelf.bigVideoView.userID = self.remoteUser.imAccid;
            [weakSelf updateUIonStatus:NERtcCallStatusInCall];
            [weakSelf startTimer];
        }
    }];
}
- (void)switchCameraBtn:(UIButton *)button {
    [[NERtcCallKit sharedInstance] switchCamera];
    button.selected = !button.selected;
}
- (void)microPhoneClick:(UIButton *)button {
    button.selected = !button.selected;
    [[NERtcCallKit sharedInstance] muteLocalAudio:button.selected];
}
- (void)cameraBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    [[NERtcCallKit sharedInstance] enableLocalVideo:!button.selected];
    [self cameraAvailble:!button.selected userId:self.localUser.imAccid];
}
- (void)hangupBtnClick:(UIButton *)button {
    self.statusModel.status = NIMRtcCallStatusComplete;
    [[NERtcCallKit sharedInstance] hangup:^(NSError * _Nullable error) {
    }];
    [self destroy];
}
- (void)microphoneBtnClick:(NECustomButton *)button {
    NSLog(@"micro phone btn click : %d", button.imageView.highlighted);
    button.imageView.highlighted = !button.imageView.highlighted;
    [[NERtcCallKit sharedInstance] muteLocalAudio:button.imageView.highlighted];
    _operationView.microPhone.selected = button.imageView.highlighted;
}
- (void)speakerBtnClick:(NECustomButton *)button {
    NSLog(@"speaker btn click : %d", button.imageView.highlighted);
    NSError *error = nil;
    [[NERtcCallKit sharedInstance] setLoudSpeakerMode:!button.imageView.highlighted error:&error];
    if (error == nil) {
        button.imageView.highlighted = !button.imageView.highlighted;
        _operationView.speakerBtn.selected = !button.imageView.highlighted;
    }else {
        [self.view makeToast:error.description];
    }
}
- (void)switchVideoView:(UITapGestureRecognizer *)tap {
    self.showMyBigView = !self.showMyBigView;
    if (self.showMyBigView) {
        [[NERtcCallKit sharedInstance] setupLocalView:self.bigVideoView.videoView];
        [[NERtcCallKit sharedInstance] setupRemoteView:self.smallVideoView.videoView forUser:self.remoteUser.imAccid];
        self.bigVideoView.userID = self.localUser.imAccid;
        self.smallVideoView.userID = self.remoteUser.imAccid;
    }else {
        [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
        [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView forUser:self.remoteUser.imAccid];
        self.bigVideoView.userID = self.remoteUser.imAccid;
        self.smallVideoView.userID = self.localUser.imAccid;
    }
}
- (void)operationSwitchClick:(UIButton *)btn {
    
    if ([[NetManager shareInstance] isClose] == YES) {
        [self.view makeToast:@"网络连接异常，请稍后再试"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    btn.enabled = NO;
    NERtcCallType type =  self.callType == NERtcCallTypeVideo ? NERtcCallTypeAudio : NERtcCallTypeVideo;
    [[NERtcCallKit sharedInstance] switchCallType: type  completion:^(NSError * _Nullable error) {
        //weakSelf.mediaSwitchBtn.enabled = YES;
        btn.enabled = YES;
        if (error == nil) {
            NSLog(@"切换成功 : %lu", type);
            NSLog(@"switch : %d", btn.selected);
            if (btn.selected == YES) {
                [weakSelf.operationView changeVideoStyle];
                [weakSelf showVideoView];
            }else {
                [weakSelf.operationView changeAudioStyle];
                [weakSelf hideVideoView];
            }
        }else {
            [weakSelf.view makeToast:[NSString stringWithFormat:@"切换失败:%@", error]];
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
    }else {
        [self.view makeToast:error.description];
    }
}
#pragma mark - NERtcVideoCallDelegate

- (void)onDisconnect:(NSError *)reason {
    self.statusModel.status = NIMRtcCallStatusTimeout;
    [self destroy];
}
- (void)onUserEnter:(NSString *)userID {
    [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
    self.smallVideoView.userID = self.localUser.imAccid;
    [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView forUser:userID];
    self.bigVideoView.userID = userID;
    [self updateUIonStatus:NERtcCallStatusInCall];
    [self startTimer];
}
- (void)onUserCancel:(NSString *)userID {
    self.statusModel.status = NIMRtcCallStatusCanceled;
    [[NERtcCallKit sharedInstance] hangup:^(NSError * _Nullable error) {
    }];
    [self destroy];
}
- (void)onCameraAvailable:(BOOL)available userID:(NSString *)userID {
    [self cameraAvailble:available userId:userID];
}
- (void)onUserLeave:(NSString *)userID {
    NSLog(@"onUserLeave");
    self.statusModel.status = NIMRtcCallStatusComplete;
    [self destroy];
}
- (void)onUserDisconnect:(NSString *)userID {
    NSLog(@"onUserDiconnect");
    self.statusModel.status = NIMRtcCallStatusComplete;
    [self destroy];
}
- (void)onCallingTimeOut {
    if ([[NetManager shareInstance] isClose] == YES) {
        //[self.view makeToast:@"网络连接异常，请稍后再试"];
        [self destroy];
        return;
    }
    [self.view makeToast:@"对方无响应"];
    self.statusModel.status = NIMRtcCallStatusTimeout;
    [[NERtcCallKit sharedInstance] cancel:^(NSError * _Nullable error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self destroy];
        });
    }];
}
- (void)onUserBusy:(NSString *)userID {
    [UIApplication.sharedApplication.keyWindow makeToast:@"对方占线"];
    self.statusModel.status = NIMRtcCallStatusBusy;
    [self destroy];
}
- (void)onCallEnd {
    self.statusModel.status = NIMRtcCallStatusComplete;
    [self destroy];
}
- (void)onUserReject:(NSString *)userID {
    [UIApplication.sharedApplication.keyWindow makeToast:@"对方已经拒绝"];
    self.statusModel.status = NIMRtcCallStatusRejected;
    [self destroy];
}

- (void)onOtherClientAccept {
    self.statusModel.status = NIMRtcCallStatusComplete;
    [self destroy];
}

- (void)onOtherClientReject {
    self.statusModel.status = NIMRtcCallStatusRejected;
    [self destroy];
}

- (void)onCallTypeChange:(NERtcCallType)callType {
    
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
    NSLog(@"call kit on error : %@",error);
}

#pragma mark - private mothed
- (void)cameraAvailble:(BOOL)available userId:(NSString *)userId {
    if ([self.bigVideoView.userID isEqualToString:userId]) {
        self.bigVideoView.maskView.hidden = available;
    }
    if ([self.smallVideoView.userID isEqualToString:userId]) {
        self.smallVideoView.maskView.hidden = available;
    }
}

- (void)setUrl:(NSString*)url withPlaceholder:(NSString*)holder {
    
    __weak typeof(self) weakSelf = self;
    
    [self.remoteAvatorView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image == nil) {
            image = [UIImage imageNamed:holder];
        }
        [weakSelf.blurImage setHidden:NO];
        weakSelf.blurImage.image = image;
    }];
}

- (void)startTimer {
    
    if (self.timer != nil ) {
        return;
    }
    if (self.timerLabel.hidden == YES) {
        self.timerLabel.hidden = NO;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(figureTimer) userInfo:nil repeats:YES];
}

- (void)figureTimer {
    self.timerCount++;
    self.timerLabel.text = [self timeFormatted:self.timerCount];
}

- (NSString *)timeFormatted:(int)totalSeconds{
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

#pragma mark - destroy
- (void)destroy {
    if (self && [self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [[NERtcCallKit sharedInstance] removeDelegate:self];
    
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (self.isCaller == YES && [self.delegate respondsToSelector:@selector(didEndCallWithStatusModel:)]) {
        self.statusModel.isCaller = YES;
        self.statusModel.duration = self.timerCount;
        self.statusModel.imAccid = self.remoteUser.imAccid;
        self.statusModel.mobile = self.remoteUser.mobile;
        self.statusModel.isVideoCall = self.callType == NERtcCallTypeVideo ? YES : NO;
        self.statusModel.avatar = self.remoteUser.avatar;
        [self.delegate didEndCallWithStatusModel:self.statusModel];
    }
}
#pragma mark - property
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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchVideoView:)];
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
        [_cancelBtn addTarget:self action:@selector(cancelEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
- (NECustomButton *)rejectBtn {
    if (!_rejectBtn) {
        _rejectBtn = [[NECustomButton alloc] init];
        _rejectBtn.titleLabel.text = @"拒绝";
        _rejectBtn.imageView.image = [UIImage imageNamed:@"call_cancel"];
        [_rejectBtn addTarget:self action:@selector(rejectEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rejectBtn;
}
- (NECustomButton *)acceptBtn {
    if (!_acceptBtn) {
        _acceptBtn = [[NECustomButton alloc] init];
        _acceptBtn.titleLabel.text = @"接听";
        _acceptBtn.imageView.image = [UIImage imageNamed:@"call_accept"];
        _acceptBtn.imageView.contentMode = UIViewContentModeCenter;
        [_acceptBtn addTarget:self action:@selector(acceptEvent:) forControlEvents:UIControlEventTouchUpInside];
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
        [_microphoneBtn addTarget:self action:@selector(microphoneBtnClick:) forControlEvents:UIControlEventTouchUpInside];
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
        [_speakerBtn addTarget:self action:@selector(speakerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speakerBtn;
}
- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [[UIButton alloc] init];
        [_switchCameraBtn setImage:[UIImage imageNamed:@"call_switch_camera"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}
- (NEVideoOperationView *)operationView {
    if (!_operationView) {
        _operationView = [[NEVideoOperationView alloc] init];
        _operationView.layer.cornerRadius = 30;
        [_operationView.microPhone addTarget:self action:@selector(microPhoneClick:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.hangupBtn addTarget:self action:@selector(hangupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.mediaBtn addTarget:self action:@selector(operationSwitchClick:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.speakerBtn addTarget:self action:@selector(operationSpeakerClick:) forControlEvents:UIControlEventTouchUpInside];
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
    NSLog(@"%@ dealloc%@",[self class],self);
}

- (void)hideViews:(NSArray<UIView *> *)views {
    for (UIView *view in views) {
        [view setHidden:YES];
    }
}

-(void)showViews:(NSArray<UIView *> *)views {
    for (UIView *view in views) {
        [view setHidden:NO];
    }
}
@end
