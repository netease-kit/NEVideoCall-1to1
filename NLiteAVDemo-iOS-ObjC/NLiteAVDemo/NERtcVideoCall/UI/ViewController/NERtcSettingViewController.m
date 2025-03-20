// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NERtcSettingViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "AppKey.h"

@interface NERtcSettingViewController () <UINavigationControllerDelegate,
                                          UIImagePickerControllerDelegate>

@property(nonatomic, strong) UITextField *timeoutField;

@property(nonatomic, strong) UILabel *videoChangeLabel;

@property(nonatomic, strong) UISwitch *videoSwitchBtn;

@property(nonatomic, strong) UILabel *rejectLabel;

@property(nonatomic, strong) UITextField *uidField;

//@property(nonatomic, strong) UITextField *tokenField;

@property(nonatomic, strong) UITextField *channelNameField;

@property(nonatomic, strong) UITextField *globalField;

@property(nonatomic, strong) UIScrollView *contentScroll;

@property(nonatomic, strong) UILabel *audioConfirmLabel;

@property(nonatomic, strong) UILabel *videoConfirmLabel;

@property(nonatomic, strong) UISwitch *audioConfirmSwitch;

@property(nonatomic, strong) UISwitch *videoConfirmSwitch;

@property(nonatomic, strong) NEExpandButton *rtcLogBtn;

@property(nonatomic, strong) NEExpandButton *imLogBtn;

@property(nonatomic, strong) NEExpandButton *photoBtn;

@property(nonatomic, strong) NEExpandButton *remotePhotoSettingBtn;

@property(nonatomic, strong) UIImagePickerController *imagePickerController;

@property(nonatomic, assign) BOOL isPickLocalDefautImage;

@property(nonatomic, strong) UITextField *modeTextField;

@end

@implementation NERtcSettingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  //  self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
  [self setupUI];
  self.view.backgroundColor = [UIColor colorWithRed:36 / 255.0
                                              green:36 / 255.0
                                               blue:45 / 255.0
                                              alpha:1.0];
}

- (void)loadView {
  self.view = self.contentScroll;
}

- (void)setupUI {
  //  self.edgesForExtendedLayout = UIRectEdgeNone;

  UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(saveSetting)];
  [saveItem setTintColor:[UIColor whiteColor]];

  self.navigationItem.rightBarButtonItem = saveItem;

  self.title = @"设置";

  UIView *line = [[UIView alloc] init];
  line.backgroundColor = [UIColor clearColor];
  [self.view addSubview:line];
  [line mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.equalTo(self.view);
    make.height.mas_equalTo(1);
    make.width.mas_equalTo(UIApplication.sharedApplication.keyWindow.bounds.size.width);
  }];

  UILabel *joinRtcLabel = [self createLabelWithText:@"主叫是否提前加入Rtc房间"];
  [self.view addSubview:joinRtcLabel];
  [joinRtcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(20);
    make.top.mas_equalTo(20);
  }];

  UISwitch *joinRtcSwitch = [[UISwitch alloc] init];
  [self.view addSubview:joinRtcSwitch];
  [joinRtcSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(joinRtcLabel);
    make.right.mas_equalTo(-20);
  }];
  [joinRtcSwitch setOn:[[SettingManager shareInstance] isJoinRtcWhenCall]];
  [joinRtcSwitch addTarget:self
                    action:@selector(changeJoinRtc:)
          forControlEvents:UIControlEventValueChanged];

  UILabel *initRtcLabel = [self createLabelWithText:@"Rtc初始化模式"];
  [self.view addSubview:initRtcLabel];
  [initRtcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(joinRtcLabel);
    make.top.equalTo(joinRtcLabel.mas_bottom).offset(20);
  }];

  // Rtc 初始化模式 TextField
  UITextField *textField = [self createTextField];
  textField.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:textField];
  [textField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(initRtcLabel.mas_right).offset(20);
    make.centerY.equalTo(initRtcLabel);
    make.right.mas_equalTo(-20);
  }];
  self.modeTextField = textField;
  textField.text =
      [NSString stringWithFormat:@"%d", [[[NECallEngine sharedInstance]
                                            valueForKeyPath:@"context.initRtcMode"] intValue]];

  UILabel *timeoutLabel = [self createLabelWithText:@"超时时间:"];

  [self.view addSubview:timeoutLabel];
  [timeoutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(20);
    make.top.equalTo(initRtcLabel.mas_bottom).offset(20);
  }];

  self.timeoutField = [self createTextField];
  [self.view addSubview:self.timeoutField];
  [self.timeoutField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(timeoutLabel.mas_right).offset(10);
    make.centerY.equalTo(timeoutLabel);
    make.right.mas_equalTo(-20);
  }];

  self.timeoutField.text =
      [NSString stringWithFormat:@"%ld", (long)[[SettingManager shareInstance] timeout]];
  self.timeoutField.keyboardType = UIKeyboardTypeNumberPad;
  self.timeoutField.attributedPlaceholder = [self getPlaceholderWithFont:self.timeoutField.font
                                                                withText:@"输入超时时间，单位(秒)"];

  CGFloat space = 20.0;

  self.videoChangeLabel = [[UILabel alloc] init];
  [self.view addSubview:self.videoChangeLabel];
  [self.videoChangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(timeoutLabel);
    make.top.equalTo(timeoutLabel.mas_bottom).offset(space);
  }];
  self.videoChangeLabel.textColor = timeoutLabel.textColor;
  self.videoChangeLabel.font = timeoutLabel.font;
  self.videoChangeLabel.text = @"呼叫前音视频切换";

  self.videoSwitchBtn = [[UISwitch alloc] init];
  [self.view addSubview:self.videoSwitchBtn];
  [self.videoSwitchBtn setOn:[[SettingManager shareInstance] supportAutoJoinWhenCalled]];
  [self.videoSwitchBtn addTarget:self
                          action:@selector(valueChange:)
                forControlEvents:UIControlEventValueChanged];
  [self.videoSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.videoChangeLabel);
    make.right.equalTo(self.view).offset(-20);
  }];

  self.rejectLabel = [[UILabel alloc] init];
  [self.view addSubview:self.rejectLabel];
  [self.rejectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.videoChangeLabel.mas_bottom).offset(space);
    make.left.equalTo(timeoutLabel.mas_left);
  }];
  self.rejectLabel.textColor = timeoutLabel.textColor;
  self.rejectLabel.font = timeoutLabel.font;
  self.rejectLabel.text = @"开启拒接忙线";

  UISwitch *busySwitch = [[UISwitch alloc] init];
  [self.view addSubview:busySwitch];
  [busySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.view).offset(-20);
    make.centerY.equalTo(self.rejectLabel);
  }];
  [busySwitch addTarget:self
                 action:@selector(busySwitchChange:)
       forControlEvents:UIControlEventValueChanged];
  [busySwitch setOn:[[SettingManager shareInstance] rejectBusyCode]];

  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
  tap.numberOfTouchesRequired = 1;
  tap.numberOfTapsRequired = 1;
  [self.view addGestureRecognizer:tap];

  UILabel *copyLabel = [self createLabelWithText:@"全局抄送参数"];
  [self.view addSubview:copyLabel];
  [copyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.rejectLabel.mas_bottom).offset(space);
    make.left.equalTo(timeoutLabel.mas_left);
  }];

  self.globalField = [self createTextField];
  [self.view addSubview:self.globalField];
  [self.globalField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(copyLabel.mas_right).offset(10);
    make.centerY.equalTo(copyLabel);
    make.right.mas_equalTo(-20);
  }];

  if ([[SettingManager shareInstance] globalExtra].length > 0) {
    self.globalField.text = [[SettingManager shareInstance] globalExtra];
  }

  UILabel *channelName = [self createLabelWithText:@"自定义channelname"];
  [self.view addSubview:channelName];
  [channelName mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(copyLabel.mas_bottom).offset(space);
    make.left.equalTo(timeoutLabel.mas_left);
  }];

  self.channelNameField = [self createTextField];
  [self.view addSubview:self.channelNameField];
  [self.channelNameField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(channelName.mas_right).offset(10);
    make.centerY.equalTo(channelName);
    make.right.mas_equalTo(-20);
  }];

  if ([[SettingManager shareInstance] customChannelName].length > 0) {
    self.channelNameField.text = [[SettingManager shareInstance] customChannelName];
  }

  UILabel *rtcUid = [self createLabelWithText:@"自定义rtcUid"];
  [self.view addSubview:rtcUid];
  [rtcUid mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(channelName.mas_bottom).offset(space);
    make.left.equalTo(timeoutLabel.mas_left);
  }];

  self.uidField = [self createTextField];
  [self.view addSubview:self.uidField];
  [self.uidField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(rtcUid.mas_right).offset(10);
    make.centerY.equalTo(rtcUid);
    make.right.mas_equalTo(-20);
  }];
  self.uidField.keyboardType = UIKeyboardTypeNumberPad;

  if ([[SettingManager shareInstance] customUid] > 0) {
    self.uidField.text =
        [NSString stringWithFormat:@"%llu", [[SettingManager shareInstance] customUid]];
  }

  self.audioConfirmLabel =
      [self createLabelWithText:NSLocalizedString(@"setting_audio_confirm", nil)];
  [self.view addSubview:self.audioConfirmLabel];
  [self.audioConfirmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(rtcUid.mas_bottom).offset(20);
    make.left.equalTo(rtcUid);
  }];

  self.audioConfirmSwitch = [[UISwitch alloc] init];
  [self.view addSubview:self.audioConfirmSwitch];
  [self.audioConfirmSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.audioConfirmLabel);
    make.right.equalTo(self.view).offset(-20);
  }];
  self.audioConfirmSwitch.on = [[SettingManager shareInstance] isAudioConfirm];
  [self.audioConfirmSwitch addTarget:self
                              action:@selector(audioConfirmChange:)
                    forControlEvents:UIControlEventValueChanged];

  self.videoConfirmLabel =
      [self createLabelWithText:NSLocalizedString(@"setting_video_confirm", nil)];
  [self.view addSubview:self.videoConfirmLabel];
  [self.videoConfirmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.audioConfirmLabel.mas_bottom).offset(20);
    make.left.equalTo(self.audioConfirmLabel);
  }];

  self.videoConfirmSwitch = [[UISwitch alloc] init];
  [self.view addSubview:self.videoConfirmSwitch];
  [self.videoConfirmSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.videoConfirmLabel);
    make.right.equalTo(self.view).offset(-20);
  }];
  self.videoConfirmSwitch.on = [[SettingManager shareInstance] isVideoConfirm];
  [self.videoConfirmSwitch addTarget:self
                              action:@selector(videoConfirmChange:)
                    forControlEvents:UIControlEventValueChanged];

  [self.view addSubview:self.rtcLogBtn];
  [self.rtcLogBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).offset(20);
    make.top.equalTo(self.videoConfirmSwitch.mas_bottom).offset(10);
    make.right.equalTo(self.view).offset(-20);
    make.height.mas_equalTo(40);
  }];

  [self.view addSubview:self.imLogBtn];
  [self.imLogBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).offset(20);
    make.top.equalTo(self.rtcLogBtn.mas_bottom).offset(5.0);
    make.right.equalTo(self.view).offset(-20);
    make.height.mas_equalTo(40);
  }];

  UILabel *cnameLabel = [[UILabel alloc] init];
  [self.view addSubview:cnameLabel];
  [cnameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.imLogBtn);
    make.top.equalTo(self.imLogBtn.mas_bottom).offset(5.0);
  }];
  cnameLabel.textColor = timeoutLabel.textColor;
  cnameLabel.font = timeoutLabel.font;
  cnameLabel.text = @"通话中显示cname";

  UISwitch *cnameSwitch = [[UISwitch alloc] init];
  [self.view addSubview:cnameSwitch];
  [cnameSwitch setOn:[[SettingManager shareInstance] incallShowCName]];
  [cnameSwitch addTarget:self
                  action:@selector(cnameValueChange:)
        forControlEvents:UIControlEventValueChanged];
  [cnameSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(cnameLabel);
    make.right.equalTo(self.view).offset(-20);
  }];

  self.videoConfirmSwitch = [[UISwitch alloc] init];
  [self.view addSubview:self.videoConfirmSwitch];
  [self.videoConfirmSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.videoConfirmLabel);
    make.right.equalTo(self.view).offset(-20);
  }];
  self.videoConfirmSwitch.on = [[SettingManager shareInstance] isVideoConfirm];
  [self.videoConfirmSwitch addTarget:self
                              action:@selector(videoConfirmChange:)
                    forControlEvents:UIControlEventValueChanged];

  UILabel *localEnableLabel = [self createLabelWithText:@"是否使用enable video"];
  [self.view addSubview:localEnableLabel];
  [localEnableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(timeoutLabel);
    make.top.equalTo(cnameLabel.mas_bottom).offset(20);
  }];

  UISwitch *enableSwitch = [[UISwitch alloc] init];
  [self.view addSubview:enableSwitch];
  [enableSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(localEnableLabel);
    make.right.equalTo(self.view).offset(-20);
  }];
  if ([[SettingManager shareInstance] useEnableLocalMute] == YES) {
    [enableSwitch setOn:YES];
  }
  [enableSwitch addTarget:self
                   action:@selector(enableSwitchChange:)
         forControlEvents:UIControlEventValueChanged];

  [self.view addSubview:self.photoBtn];
  [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).offset(20);
    make.top.equalTo(enableSwitch.mas_bottom).offset(10);
    make.right.equalTo(self.view).offset(-20);
    make.height.mas_equalTo(40);
  }];

  [self.view addSubview:self.remotePhotoSettingBtn];
  [self.remotePhotoSettingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).offset(20);
    make.top.equalTo(self.photoBtn.mas_bottom).offset(20);
    make.right.equalTo(self.view).offset(-20);
    make.bottom.equalTo(self.view.mas_bottom).offset(-20);
    make.height.mas_equalTo(40);
  }];

  UILabel *audioCallLabel = [[UILabel alloc] init];
  [self.view addSubview:audioCallLabel];
  [audioCallLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).offset(20);
    make.top.equalTo(self.remotePhotoSettingBtn.mas_bottom).offset(20);
  }];
  audioCallLabel.textColor = timeoutLabel.textColor;
  audioCallLabel.font = timeoutLabel.font;
  audioCallLabel.text = @"是否为音频呼叫";

  UISwitch *audioCall = [[UISwitch alloc] init];
  audioCall.on = [self isAudioCall];
  [self.view addSubview:audioCall];
  [audioCall addTarget:self
                action:@selector(audioSwitch:)
      forControlEvents:UIControlEventValueChanged];

  [audioCall mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(audioCallLabel);
    make.right.equalTo(self.view).offset(-20);
  }];
}

- (void)audioSwitch:(UISwitch *)on {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:[NSNumber numberWithBool:on.isOn] forKey:@"audio_call"];
  [defaults synchronize];
}

- (BOOL)isAudioCall {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSNumber *number = [defaults objectForKey:@"audio_call"];
  return number.boolValue;
}

- (void)saveSetting {
  NSString *initMode = self.modeTextField.text;
  NSInteger initModeInt = [initMode integerValue];
  if (initModeInt < 1 || initModeInt > 3) {
    [UIApplication.sharedApplication.keyWindow ne_makeToast:@"初始化模式值为1-3区间整数"];
    return;
  }

  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithInteger:initModeInt]
                               forKeyPath:@"context.initRtcMode"];

  NSString *time = self.timeoutField.text;
  if (time.length <= 0) {
    [self.timeoutField resignFirstResponder];
    [self.view ne_makeToast:@"请输入超时时间"];
    return;
  }
  NSInteger timeInt = [time integerValue];
  if (timeInt > 120) {
    [self.timeoutField resignFirstResponder];
    [self.view ne_makeToast:@"超时时间不能超过120秒"];
    return;
  }
  [[SettingManager shareInstance] setTimeoutWithSecond:[time integerValue]];

  if (self.channelNameField.text.length > 0) {
    [[SettingManager shareInstance] setCustomChannelName:self.channelNameField.text];
  } else {
    [[SettingManager shareInstance] setCustomChannelName:@""];
  }

  //  if (self.tokenField.text.length > 0) {
  //    [[SettingManager shareInstance] setCustomToken:self.tokenField.text];
  //  } else {
  //    [[SettingManager shareInstance] setCustomToken:@""];
  //  }

  if (self.uidField.text.length > 0 && [self.uidField.text isEqualToString:@"0"] == NO) {
    NSScanner *scanner = [NSScanner scannerWithString:self.uidField.text];
    unsigned long long convertedValue = 0;
    [scanner scanUnsignedLongLong:&convertedValue];
    [[SettingManager shareInstance] setCustomUid:convertedValue];
    [[SettingManager shareInstance] setCallKitUid:convertedValue];
  } else {
    [[SettingManager shareInstance] setCustomUid:0];
    [[SettingManager shareInstance] setCallKitUid:0];
  }

  if (self.globalField.text.length > 0) {
    [[SettingManager shareInstance] setGlobalExtra:self.globalField.text];
  } else {
    [[SettingManager shareInstance] setGlobalExtra:@""];
  }

  [self.navigationController popViewControllerAnimated:YES];
  [[UIApplication sharedApplication].keyWindow ne_makeToast:@"保存成功"];
}

- (void)hideKeyboard {
  [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (NSAttributedString *)getPlaceholderWithFont:(UIFont *)font withText:(NSString *)text {
  NSAttributedString *attrString =
      [[NSAttributedString alloc] initWithString:text
                                      attributes:@{
                                        NSForegroundColorAttributeName : [UIColor grayColor],
                                        NSFontAttributeName : font
                                      }];
  return attrString;
}

- (UILabel *)createLabelWithText:(NSString *)text {
  UILabel *label = [[UILabel alloc] init];
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont systemFontOfSize:16.0];
  label.textAlignment = NSTextAlignmentLeft;
  label.text = text;
  [label setContentHuggingPriority:UILayoutPriorityRequired
                           forAxis:UILayoutConstraintAxisHorizontal];
  return label;
}

- (UITextField *)createTextField {
  UITextField *field = [[UITextField alloc] init];
  field.borderStyle = UITextBorderStyleRoundedRect;
  field.textColor = UIColor.blackColor;
  field.textAlignment = NSTextAlignmentLeft;
  field.font = [UIFont systemFontOfSize:14.0];
  return field;
}

- (NEExpandButton *)rtcLogBtn {
  if (_rtcLogBtn == nil) {
    _rtcLogBtn = [NEExpandButton buttonWithType:UIButtonTypeSystem];
    [_rtcLogBtn setTitle:@"上传Rtc日志" forState:UIControlStateNormal];
    [_rtcLogBtn addTarget:self
                   action:@selector(uploadRtcLog)
         forControlEvents:UIControlEventTouchUpInside];
    _rtcLogBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  }
  return _rtcLogBtn;
}

- (NEExpandButton *)imLogBtn {
  if (_imLogBtn == nil) {
    _imLogBtn = [NEExpandButton buttonWithType:UIButtonTypeSystem];
    [_imLogBtn setTitle:@"上传IM日志" forState:UIControlStateNormal];
    [_imLogBtn addTarget:self
                  action:@selector(uploadIMLog)
        forControlEvents:UIControlEventTouchUpInside];
    _imLogBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  }
  return _imLogBtn;
}

#pragma mark - value action

- (void)changeInitRtc:(UISwitch *)uiswitch {
  [[SettingManager shareInstance] setIsGlobalInit:uiswitch.isOn
                                      withApnsCer:kAPNSCerName
                                       withAppkey:kAppKey];

  if (uiswitch.isOn == YES) {
    [NERtcEngine destroyEngine];
  } else {
    NESetupConfig *setupConfig = [[NESetupConfig alloc] initWithAppkey:kAppKey];
    [[NECallEngine sharedInstance] setup:setupConfig];
    [[NECallEngine sharedInstance] setTimeout:30];
  }
}

- (void)changeJoinRtc:(UISwitch *)uiswitch {
  [[SettingManager shareInstance] setIsJoinRtcWhenCall:uiswitch.isOn];
}

- (void)busySwitchChange:(UISwitch *)uiswitch {
  [[SettingManager shareInstance] setBusyCode:uiswitch.isOn];
}

- (void)valueChange:(UISwitch *)uiswitch {
  [[SettingManager shareInstance] setAutoJoin:uiswitch.isOn];
  NSLog(@"switch change value : %d", uiswitch.isOn);
}

- (void)cnameValueChange:(UISwitch *)uiswitch {
  [[SettingManager shareInstance] setShowCName:uiswitch.isOn];
}

- (void)audioConfirmChange:(UISwitch *)uiswitch {
  [SettingManager.shareInstance setIsAudioConfirm:uiswitch.isOn];
}

- (void)videoConfirmChange:(UISwitch *)uiswitch {
  [SettingManager.shareInstance setIsVideoConfirm:uiswitch.isOn];
}

#pragma mark - action

- (void)uploadRtcLog {
  [[NERtcEngine sharedEngine] uploadSdkInfo];
  [UIApplication.sharedApplication.keyWindow ne_makeToast:@"Rtc日志已上传"];
}

- (void)uploadIMLog {
  [[NIMSDK sharedSDK] uploadLogs:^(NSError *_Nonnull error, NSString *_Nonnull path) {
    if (error == nil) {
      [UIApplication.sharedApplication.keyWindow ne_makeToast:@"IM日志已上传"];
    } else {
      [UIApplication.sharedApplication.keyWindow
          ne_makeToast:[NSString stringWithFormat:@"日志上传错误:%@", error.localizedDescription]];
    }
  }];
}

#pragma mark - lazy init

- (UIScrollView *)contentScroll {
  if (!_contentScroll) {
    _contentScroll = [[UIScrollView alloc] init];
    _contentScroll.bounces = YES;
  }
  return _contentScroll;
}

//- (UIStackView *)stackView {
//    if (!_stackView) {
//        _stackView = [[UIStackView alloc] init];
//    }
//    return _stackView;
//}
/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before
 navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NEExpandButton *)photoBtn {
  if (_photoBtn == nil) {
    _photoBtn = [NEExpandButton buttonWithType:UIButtonTypeSystem];
    [_photoBtn setTitle:@"设置关闭视频本地缺省图片" forState:UIControlStateNormal];
    [_photoBtn addTarget:self
                  action:@selector(localDefaultPickImage)
        forControlEvents:UIControlEventTouchUpInside];
    _photoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  }
  return _photoBtn;
}

- (NEExpandButton *)remotePhotoSettingBtn {
  if (_remotePhotoSettingBtn == nil) {
    _remotePhotoSettingBtn = [NEExpandButton buttonWithType:UIButtonTypeSystem];
    [_remotePhotoSettingBtn setTitle:@"设置远端关闭视频缺省图片" forState:UIControlStateNormal];
    [_remotePhotoSettingBtn addTarget:self
                               action:@selector(remoteDefaultPickImage)
                     forControlEvents:UIControlEventTouchUpInside];
    _remotePhotoSettingBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  }
  return _remotePhotoSettingBtn;
}

- (void)enableSwitchChange:(UISwitch *)uiSwitch {
  [[SettingManager shareInstance] setEnableLocal:uiSwitch.isOn];
}

- (void)remoteDefaultPickImage {
  self.isPickLocalDefautImage = NO;
  [self pickerImage];
}

- (void)localDefaultPickImage {
  self.isPickLocalDefautImage = YES;
  [self pickerImage];
}

- (void)pickerImage {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:nil
                                          message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];

  UIAlertAction *camera =
      [UIAlertAction actionWithTitle:@"使用相机拍摄"
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *_Nonnull action) {
                               [self checkCameraPermission];  // 调用检查相机权限方法
                             }];
  UIAlertAction *album =
      [UIAlertAction actionWithTitle:@"从相册中选择"
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *_Nonnull action) {
                               [self checkAlbumPermission];  // 调起检查相册权限方法
                             }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction *action) {
                                                   [self dismissViewControllerAnimated:YES
                                                                            completion:nil];
                                                 }];

  if ([self isIpad]) {
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect =
        CGRectMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height, 1.0, 1.0);
  }

  [alert addAction:camera];
  [alert addAction:album];
  [alert addAction:cancel];

  [self presentViewController:alert animated:YES completion:nil];
}

- (UIImagePickerController *)imagePickerController {
  if (_imagePickerController == nil) {
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;  // delegate遵循了两个代理
    _imagePickerController.allowsEditing = YES;
  }
  return _imagePickerController;
}

- (void)checkCameraPermission {
  AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  if (status == AVAuthorizationStatusNotDetermined) {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                               if (granted) {
                                 [self takePhoto];
                               }
                             }];
  } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
    [self alertAlbum];  // 如果没有权限给出提示
  } else {
    [self takePhoto];  // 有权限进入调起相机方法
  }
}

- (void)checkAlbumPermission {
  PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
  if (status == PHAuthorizationStatusNotDetermined) {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (status == PHAuthorizationStatusAuthorized) {
          [self selectAlbum];
        }
      });
    }];
  } else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
    [self alertAlbum];
  } else {
    [self selectAlbum];
  }
}

- (void)takePhoto {
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([self isIpad]) {
      self.imagePickerController.popoverPresentationController.sourceView = self.view;
      self.imagePickerController.popoverPresentationController.sourceRect =
          CGRectMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height, 1.0, 1.0);
    }
    [self presentViewController:self.imagePickerController
                       animated:YES
                     completion:^{

                     }];
  } else {  // 不可用只能GG了
    NSLog(@"木有相机");
  }
}

- (void)selectAlbum {
  // 判断相册是否可用
  if ([UIImagePickerController
          isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([self isIpad]) {
      self.imagePickerController.popoverPresentationController.sourceView = self.view;
      self.imagePickerController.popoverPresentationController.sourceRect =
          CGRectMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height, 1.0, 1.0);
    }
    [self presentViewController:self.imagePickerController
                       animated:YES
                     completion:^{

                     }];
  }
}

- (void)alertAlbum {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:nil
                                          message:@"请在设置中打开相册"
                                   preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction *_Nonnull action) {
                                                   [self dismissViewControllerAnimated:YES
                                                                            completion:nil];
                                                 }];

  [alert addAction:cancel];
  if ([self isIpad]) {
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect =
        CGRectMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height, 1.0, 1.0);
  }
  [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate(最后一步,选完就把图片加上就完事了)
- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
  [picker dismissViewControllerAnimated:YES completion:nil];
  UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
  if (self.isPickLocalDefautImage == YES) {
    [[SettingManager shareInstance] setMuteDefaultImage:image];
    [UIApplication.sharedApplication.keyWindow ne_makeToast:@"本地缺省图片已设置"];
  } else {
    [[SettingManager shareInstance] setRemoteDefaultImage:image];
    [UIApplication.sharedApplication.keyWindow ne_makeToast:@"远端缺省图片已设置"];
  }
}

- (BOOL)isIpad {
  NSString *deviceType = [UIDevice currentDevice].model;

  if ([deviceType isEqualToString:@"iPhone"]) {
    // iPhone
    return NO;
  } else if ([deviceType isEqualToString:@"iPod touch"]) {
    // iPod Touch
    return NO;
  } else if ([deviceType isEqualToString:@"iPad"]) {
    // iPad
    return YES;
  }
  return NO;
}
@end
