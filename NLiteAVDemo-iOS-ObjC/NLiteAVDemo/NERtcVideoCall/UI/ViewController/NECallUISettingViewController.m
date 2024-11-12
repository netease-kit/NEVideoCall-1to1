//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallUISettingViewController.h"

@interface NECallUISettingViewController ()

@end

@implementation NECallUISettingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor colorWithRed:36 / 255.0
                                              green:36 / 255.0
                                               blue:45 / 255.0
                                              alpha:1.0];
  self.navigationItem.leftBarButtonItem.title = @"返回";
  self.navigationItem.title = @"UI设置";
  [self setupUI];
}

- (void)setupUI {
  // 生成一个居左的标签，显示是否开启小窗功能
  UILabel *floatWindow = [[UILabel alloc] init];
  floatWindow.translatesAutoresizingMaskIntoConstraints = NO;
  floatWindow.textColor = [UIColor whiteColor];
  floatWindow.text = @"小窗功能";
  [self.view addSubview:floatWindow];
  [NSLayoutConstraint activateConstraints:@[
    [floatWindow.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:80],
    [floatWindow.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [floatWindow.heightAnchor constraintEqualToConstant:30]
  ]];

  // 生成一个 UISwitch，用于控制是否开启小窗功能
  UISwitch *floatSwitch = [[UISwitch alloc] init];
  floatSwitch.translatesAutoresizingMaskIntoConstraints = NO;
  [floatSwitch addTarget:self
                  action:@selector(floatSwitchAction:)
        forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:floatSwitch];
  [NSLayoutConstraint activateConstraints:@[
    [floatSwitch.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [floatSwitch.centerYAnchor constraintEqualToAnchor:floatWindow.centerYAnchor],
  ]];

  // 生成一个标签，显示是否开启应用外浮窗功能
  UILabel *floatWindowOutApp = [[UILabel alloc] init];
  floatWindowOutApp.translatesAutoresizingMaskIntoConstraints = NO;
  floatWindowOutApp.textColor = [UIColor whiteColor];
  floatWindowOutApp.text = @"应用外浮窗功能";
  [self.view addSubview:floatWindowOutApp];
  [NSLayoutConstraint activateConstraints:@[
    [floatWindowOutApp.topAnchor constraintEqualToAnchor:floatWindow.bottomAnchor constant:20],
    [floatWindowOutApp.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [floatWindowOutApp.heightAnchor constraintEqualToConstant:30]
  ]];

  // 生成一个 UISwitch，用于控制是否开启应用外浮窗功能
  UISwitch *floatSwitchOutApp = [[UISwitch alloc] init];
  floatSwitchOutApp.translatesAutoresizingMaskIntoConstraints = NO;
  [floatSwitchOutApp addTarget:self
                        action:@selector(floatSwitchOutAppAction:)
              forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:floatSwitchOutApp];
  [NSLayoutConstraint activateConstraints:@[
    [floatSwitchOutApp.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [floatSwitchOutApp.centerYAnchor constraintEqualToAnchor:floatWindowOutApp.centerYAnchor],
  ]];

  // 生成一个label，是否开启被叫预览功能
  UILabel *calleePreview = [[UILabel alloc] init];
  calleePreview.translatesAutoresizingMaskIntoConstraints = NO;
  calleePreview.textColor = [UIColor whiteColor];
  calleePreview.text = @"被叫预览功能";
  [self.view addSubview:calleePreview];
  [NSLayoutConstraint activateConstraints:@[
    [calleePreview.topAnchor constraintEqualToAnchor:floatWindowOutApp.bottomAnchor constant:20],
    [calleePreview.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [calleePreview.heightAnchor constraintEqualToConstant:30]
  ]];

  // 生成一个 UISwitch，用于控制是否开启被叫预览功能
  UISwitch *calleePreviewSwitch = [[UISwitch alloc] init];
  calleePreviewSwitch.translatesAutoresizingMaskIntoConstraints = NO;
  [calleePreviewSwitch addTarget:self
                          action:@selector(calleePreviewSwitchAction:)
                forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:calleePreviewSwitch];
  [NSLayoutConstraint activateConstraints:@[
    [calleePreviewSwitch.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [calleePreviewSwitch.centerYAnchor constraintEqualToAnchor:calleePreview.centerYAnchor],
  ]];

  // 生成一个 label，显示是否开启虚化
  UILabel *blur = [[UILabel alloc] init];
  blur.translatesAutoresizingMaskIntoConstraints = NO;
  blur.textColor = [UIColor whiteColor];
  blur.text = @"虚化";
  [self.view addSubview:blur];
  [NSLayoutConstraint activateConstraints:@[
    [blur.topAnchor constraintEqualToAnchor:calleePreview.bottomAnchor constant:20],
    [blur.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [blur.heightAnchor constraintEqualToConstant:30]
  ]];

  // 生成一个 UISwitch，用于控制是否开启虚化
  UISwitch *blurSwitch = [[UISwitch alloc] init];
  blurSwitch.translatesAutoresizingMaskIntoConstraints = NO;
  [blurSwitch addTarget:self
                 action:@selector(blurSwitchAction:)
       forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:blurSwitch];
  [NSLayoutConstraint activateConstraints:@[
    [blurSwitch.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [blurSwitch.centerYAnchor constraintEqualToAnchor:blur.centerYAnchor],
  ]];

  // 获取小窗配置，设置小窗switch值
  BOOL floatWindowValue = [[[NERtcCallUIKit sharedInstance]
      valueForKeyPath:@"config.uiConfig.enableFloatingWindow"] boolValue];
  [floatSwitch setOn:floatWindowValue];

  // 获取应用外浮窗配置，设置应用外浮窗switch值
  BOOL floatWindowOutAppValue = [[[NERtcCallUIKit sharedInstance]
      valueForKeyPath:@"config.uiConfig.enableFloatingWindowOutOfApp"] boolValue];
  [floatSwitchOutApp setOn:floatWindowOutAppValue];

  // 获取被叫预览配置，设置被叫预览switch值
  BOOL calleePreviewValue = [[[NERtcCallUIKit sharedInstance]
      valueForKeyPath:@"config.uiConfig.enableCalleePreview"] boolValue];
  [calleePreviewSwitch setOn:calleePreviewValue];

  // 获取虚化配置，设置虚化switch值
  BOOL blurValue = [[[NERtcCallUIKit sharedInstance]
      valueForKeyPath:@"config.uiConfig.enableVirtualBackground"] boolValue];
  [blurSwitch setOn:blurValue];
}

// 小窗开关的响应函数
- (void)floatSwitchAction:(UISwitch *)sender {
  // 设置 NECallUIConfig 的 enableFloatingWindow 属性
  // 用于控制是否开启小窗功能
  [[NERtcCallUIKit sharedInstance] setValue:[NSNumber numberWithBool:sender.on]
                                 forKeyPath:@"config.uiConfig.enableFloatingWindow"];
}

// 应用外浮窗开关的响应函数
- (void)floatSwitchOutAppAction:(UISwitch *)sender {
  // 设置 NECallUIConfig 的 enableFloatingWindowOutApp 属性
  // 用于控制是否开启应用外浮窗功能
  [[NERtcCallUIKit sharedInstance] setValue:[NSNumber numberWithBool:sender.on]
                                 forKeyPath:@"config.uiConfig.enableFloatingWindowOutOfApp"];
}

// 被叫预览开关的响应函数
- (void)calleePreviewSwitchAction:(UISwitch *)sender {
  // 设置 NECallUIConfig 的 enableCalleePreview 属性
  // 用于控制是否开启被叫预览功能
  [[NERtcCallUIKit sharedInstance] setValue:[NSNumber numberWithBool:sender.on]
                                 forKeyPath:@"config.uiConfig.enableCalleePreview"];
}

// 虚化开关的响应函数
- (void)blurSwitchAction:(UISwitch *)sender {
  // 设置 NECallUIConfig 的 enableBlur 属性
  // 用于控制是否开启虚化
  [[NERtcCallUIKit sharedInstance] setValue:[NSNumber numberWithBool:sender.on]
                                 forKeyPath:@"config.uiConfig.enableVirtualBackground"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
