// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "GroupSettingViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface GroupSettingViewController ()

@property(nonatomic, strong) UITextField *pushContent;

@property(nonatomic, strong) UIScrollView *contentScroll;

@end

@implementation GroupSettingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  [self setupUI];
}

- (void)loadView {
  self.view = self.contentScroll;
}

- (UIScrollView *)contentScroll {
  if (!_contentScroll) {
    _contentScroll = [[UIScrollView alloc] init];
    //      _contentScroll.frame = [[[UIApplication sharedApplication] keyWindow] frame];
    _contentScroll.bounces = YES;
  }
  return _contentScroll;
}

- (void)setupUI {
  UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(saveSetting)];
  [saveItem setTintColor:[UIColor whiteColor]];

  self.navigationItem.rightBarButtonItem = saveItem;

  UIView *line = [[UIView alloc] init];
  line.backgroundColor = [UIColor clearColor];
  [self.view addSubview:line];
  [line mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(1);
    make.left.right.equalTo(self.view);
    make.width.mas_equalTo([[[UIApplication sharedApplication] keyWindow] frame].size.width);
  }];
  UILabel *pushLabel = [self createLabelWithText:NSLocalizedString(@"enable_group_push", nil)];
  [self.view addSubview:pushLabel];
  [pushLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view.mas_top).offset(20);
    make.left.equalTo(self.view.mas_left).offset(20);
  }];

  UISwitch *pushSwitch = [[UISwitch alloc] init];
  [self.view addSubview:pushSwitch];
  [pushSwitch setOn:[[SettingManager shareInstance] isGroupPush]];
  [pushSwitch addTarget:self
                 action:@selector(valueChange:)
       forControlEvents:UIControlEventValueChanged];
  [pushSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(pushLabel);
    make.right.equalTo(self.view).offset(-20);
  }];

  self.pushContent = [self createTextField];
  [self.view addSubview:self.pushContent];
  [self.pushContent mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(pushLabel.mas_left);
    make.right.equalTo(pushSwitch.mas_right);
    make.top.mas_equalTo(pushLabel.mas_bottom).offset(20);
  }];
  self.pushContent.placeholder = NSLocalizedString(@"group_push_content_placeholder", nil);
  if ([[SettingManager shareInstance] customPushContent].length > 0) {
    self.pushContent.text = [[SettingManager shareInstance] customPushContent];
  }
}

- (void)saveSetting {
  [[SettingManager shareInstance] setCustomPushContent:self.pushContent.text];
  [self.navigationController popViewControllerAnimated:YES];
  [[UIApplication sharedApplication].keyWindow
      ne_makeToast:NSLocalizedString(@"save_success", nil)];
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

- (void)valueChange:(UISwitch *)uiswitch {
  //[[SettingManager shareInstance] setAutoJoin:uiswitch.isOn];
  [[SettingManager shareInstance] setIsGroupPush:uiswitch.isOn];
  NSLog(@"switch change value : %d", uiswitch.isOn);
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
