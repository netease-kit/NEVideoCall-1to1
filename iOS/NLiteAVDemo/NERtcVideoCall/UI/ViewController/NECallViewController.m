//
//  NECallViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NECallViewController.h"
#import "NERtcVideoCall.h"
#import "NECustomButton.h"
#import "NEVideoOperationView.h"
#import "NEVideoView.h"

@interface NECallViewController ()
@property(strong,nonatomic)NEVideoView *smallVideoView;
@property(strong,nonatomic)NEVideoView *bigVideoView;
@property(strong,nonatomic)UIImageView *remoteAvatorView;
@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UILabel *subTitleLabel;
//@property(strong,nonatomic)UIButton *closeBtn;
@property(strong,nonatomic)UIButton *switchCameraBtn;
/// 取消呼叫
@property(strong,nonatomic)NECustomButton *cancelBtn;
/// 拒绝接听
@property(strong,nonatomic)NECustomButton *rejectBtn;
/// 接听
@property(strong,nonatomic)NECustomButton *acceptBtn;
@property(strong,nonatomic)NEVideoOperationView *operationView;
@property(assign,nonatomic)BOOL showMyBigView;

@end

@implementation NECallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupSDK];
    [self updateUIonStatus:self.status];
}
#pragma mark - SDK
- (void)setupSDK {
    [[NERtcVideoCall shared] addDelegate:self];
    [NERtcVideoCall shared].timeOutSeconds = 1.0 * 60;
    if (self.status == NECallStatusCall) {
        [[NERtcVideoCall shared] call:self.remoteUser completion:^(NSError * _Nullable error) {
            [[NERtcVideoCall shared] setupLocalView:self.bigVideoView.videoView];
            self.bigVideoView.userID = self.localUser.imAccid;
            if (error) {
                /// 对方离线时 通过APNS推送 UI不弹框提示
                if (error.code != 10202) {
                    [self.view makeToast:error.localizedDescription];
                }
            }
        }];
    }
}
#pragma mark - UI
- (void)setupUI {
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
    
    [self.view addSubview:self.smallVideoView];
    [self.smallVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(statusHeight + 20);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(90, 160));
    }];
    [self.view addSubview:self.remoteAvatorView];
    [self.remoteAvatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.smallVideoView.mas_top);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.remoteAvatorView.mas_top).offset(5);
        make.right.mas_equalTo(self.remoteAvatorView.mas_left).offset(-8);
        make.left.mas_equalTo(60);
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
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    /// 接听和拒接按钮
    [self.view addSubview:self.rejectBtn];
    [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(- self.view.frame.size.width/4.0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    [self.view addSubview:self.acceptBtn];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.frame.size.width/4.0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    [self.view addSubview:self.operationView];
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(224, 60));
        make.bottom.mas_equalTo(-50);
    }];
}
- (void)updateUIonStatus:(NECallStatus)status {
    switch (status) {
        case NECallStatusCall:
        {
            self.titleLabel.text = [NSString stringWithFormat:@"正在呼叫 %@",self.remoteUser.mobile];
            self.subTitleLabel.text = @"等待对方接听……";
            self.remoteAvatorView.hidden = NO;
            [self.remoteAvatorView sd_setImageWithURL:[NSURL URLWithString:self.remoteUser.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
            self.smallVideoView.hidden = YES;
            self.cancelBtn.hidden = NO;
            self.rejectBtn.hidden = YES;
            self.acceptBtn.hidden = YES;
            self.switchCameraBtn.hidden = YES;
            self.operationView.hidden = YES;
        }
            break;
        case NECallStatusCalled:
        {
            self.titleLabel.text = [NSString stringWithFormat:@"%@",self.remoteUser.mobile];
            self.remoteAvatorView.hidden = NO;
            [self.remoteAvatorView sd_setImageWithURL:[NSURL URLWithString:self.remoteUser.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
            self.subTitleLabel.text = @"邀请您视频通话";
            self.smallVideoView.hidden = YES;
            self.cancelBtn.hidden = YES;
            self.rejectBtn.hidden = NO;
            self.acceptBtn.hidden = NO;
            self.switchCameraBtn.hidden = YES;
            self.operationView.hidden = YES;
        }
            break;
        case NECallStatusCalling:
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
        }
            break;
        default:
            break;
    }
}
#pragma mark - event
- (void)closeEvent:(NECustomButton *)button {
    [[NERtcVideoCall shared] hangup];
}
- (void)cancelEvent:(NECustomButton *)button {
    [[NERtcVideoCall shared] cancel:^(NSError * _Nullable error) {
        [self destroy];
    }];
}
- (void)rejectEvent:(NECustomButton *)button {
    [[NERtcVideoCall shared] reject:^(NSError * _Nullable error) {
        [self destroy];
    }];
}
- (void)acceptEvent:(NECustomButton *)button {
    [[NERtcVideoCall shared] accept:^(NSError * _Nullable error) {
        if (error) {
            [self.view makeToast:error.localizedDescription];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self destroy];
            });
        }else {
            [[NERtcVideoCall shared] setupLocalView:self.smallVideoView.videoView];
            self.smallVideoView.userID = self.localUser.imAccid;
            [[NERtcVideoCall shared] setupRemoteView:self.bigVideoView.videoView userID:[self.remoteUser.imAccid longLongValue]];
            self.bigVideoView.userID = self.remoteUser.imAccid;
            [self updateUIonStatus:NECallStatusCalling];
        }
    }];
}
- (void)switchCameraBtn:(UIButton *)button {
    [[NERtcVideoCall shared] switchCamera];
}
- (void)microPhoneClick:(UIButton *)button {
    button.selected = !button.selected;
    [[NERtcVideoCall shared] setMicMute:button.selected];
}
- (void)cameraBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    [[NERtcVideoCall shared] enableCamera:!button.selected];
    [self cameraAvailble:!button.selected userId:self.localUser.imAccid];
}
- (void)hangupBtnClick:(UIButton *)button {
    [[NERtcVideoCall shared] hangup];
    [self destroy];
}
- (void)switchVideoView:(UITapGestureRecognizer *)tap {
    self.showMyBigView = !self.showMyBigView;
    if (self.showMyBigView) {
        [[NERtcVideoCall shared] setupLocalView:self.bigVideoView.videoView];
        [[NERtcVideoCall shared] setupRemoteView:self.smallVideoView.videoView userID:[self.remoteUser.imAccid longLongValue]];
        self.bigVideoView.userID = self.localUser.imAccid;
        self.smallVideoView.userID = self.remoteUser.imAccid;
    }else {
        [[NERtcVideoCall shared] setupLocalView:self.smallVideoView.videoView];
        [[NERtcVideoCall shared] setupRemoteView:self.bigVideoView.videoView userID:[self.remoteUser.imAccid longLongValue]];
        self.bigVideoView.userID = self.remoteUser.imAccid;
        self.smallVideoView.userID = self.localUser.imAccid;
    }
}
#pragma mark - NERtcVideoCallDelegate
- (void)onUserEnter:(NEUser *)user {
    [[NERtcVideoCall shared] setupLocalView:self.smallVideoView.videoView];
    self.smallVideoView.userID = self.localUser.imAccid;
    [[NERtcVideoCall shared] setupRemoteView:self.bigVideoView.videoView userID:[user.imAccid longLongValue]];
    self.bigVideoView.userID = user.imAccid;
    [self updateUIonStatus:NECallStatusCalling];
}
- (void)onCancelByUserId:(NSString *)userId {
    [[NERtcVideoCall shared] hangup];
    [self destroy];
}

- (void)onCameraAvailable:(BOOL)available userId:(NSString *)userId {
    [self cameraAvailble:available userId:userId];
}

- (void)timeOut {
    [self.view makeToast:@"对方无响应"];
    [[NERtcVideoCall shared] cancel:^(NSError * _Nullable error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self destroy];
        });
    }];
}

- (void)onUserBusy:(NSString *)userId {
    [self.view makeToast:@"对方正在通话中"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self destroy];
    });
}
- (void)onUserHangup:(NSString *)userId {
    [self destroy];
}
- (void)onRejectByUserId:(NSString *)userId {
    [self.view makeToast:@"对方拒绝了您的邀请"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self destroy];
    });
}

#pragma mark - private mothed
- (void)cameraAvailble:(BOOL)available userId:(NSString *)userId {
    NSString *tips = [self.localUser.imAccid isEqualToString:userId]?@"你关闭了摄像头":@"对方关闭了摄像头";
    if ([self.bigVideoView.userID isEqualToString:userId]) {
        self.bigVideoView.titleLabel.hidden = available;
        self.bigVideoView.titleLabel.text = tips;
    }
    if ([self.smallVideoView.userID isEqualToString:userId]) {
        self.smallVideoView.titleLabel.hidden = available;
        self.smallVideoView.titleLabel.text = tips;
    }
}
#pragma mark - destroy
- (void)destroy {
    [[NERtcVideoCall shared] removeDelegate:self];
    [self dismissViewControllerAnimated:YES completion:nil];
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
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _titleLabel;
}
- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
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
    }
    return _operationView;
}

- (void)dealloc {
    NSLog(@"%@ dealloc",[self class]);
}
@end
