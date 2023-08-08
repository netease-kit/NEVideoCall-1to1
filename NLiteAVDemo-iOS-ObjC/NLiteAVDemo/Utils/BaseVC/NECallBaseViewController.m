// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallBaseViewController.h"

@interface NECallBaseViewController ()

@end

@implementation NECallBaseViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setNavUI];
}

- (void)setNavUI {
  self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:38 / 255.0
                                                                         green:38 / 255.0
                                                                          blue:47 / 255.0
                                                                         alpha:1.0];
  self.navigationController.navigationBar.titleTextAttributes =
      @{NSForegroundColorAttributeName : [UIColor whiteColor]};
  self.navigationController.navigationBar.hidden = NO;
  UIColor *color = [UIColor colorWithRed:36 / 255.0 green:36 / 255.0 blue:45 / 255.0 alpha:1.0];
  [self.navigationController.navigationBar setBarTintColor:color];
  self.view.backgroundColor = color;
  UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(backAction:)];
  backItem.accessibilityIdentifier = @"nav_cancel";
  [backItem setTintColor:[UIColor whiteColor]];
  self.navigationItem.leftBarButtonItem = backItem;
}

- (void)backAction:(UIButton *)backButton {
  [self.navigationController popViewControllerAnimated:YES];
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
