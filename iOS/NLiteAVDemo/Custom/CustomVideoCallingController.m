//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "CustomVideoCallingController.h"
@interface CustomVideoCallingController ()

@property(nonatomic, strong) UIButton *customButton;

@end
@implementation CustomVideoCallingController
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)customAction {
  // 自定义挂断按钮
  self.customButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.customButton.translatesAutoresizingMaskIntoConstraints = false;
  [self.view addSubview:self.customButton];
  [self.customButton setTitle:@"挂断" forState:UIControlStateNormal];
  [NSLayoutConstraint activateConstraints:@[
    [self.customButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    [self.customButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    [self.customButton.widthAnchor constraintEqualToConstant:80],
    [self.customButton.heightAnchor constraintEqualToConstant:40]
  ]];

  // 绑定事件转移
  NSArray<NSString *> *targets =
      [self.cancelBtn.maskBtn actionsForTarget:self.mainController
                               forControlEvent:UIControlEventTouchUpInside];
  for (NSString *target in targets) {
    [self.customButton addTarget:self.mainController
                          action:NSSelectorFromString(target)
                forControlEvents:UIControlEventTouchUpInside];
  }
}

@end
