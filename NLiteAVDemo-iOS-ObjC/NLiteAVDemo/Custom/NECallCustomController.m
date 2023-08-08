//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallCustomController.h"

@interface NECallCustomController ()

@property(nonatomic, strong) NECalledViewController *customCalledController;

@end

@implementation NECallCustomController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self.customCalledController.rejectBtn.maskBtn addTarget:self
                                                    action:@selector(custtomRejectEvent:)
                                          forControlEvents:UIControlEventTouchUpInside];
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

- (void)custtomRejectEvent:(UIButton *)button {
  if ([[NetManager shareInstance] isClose] == YES) {
    [self destroy];
  }
  self.customCalledController.acceptBtn.userInteractionEnabled = NO;
  __weak typeof(self) weakSelf = self;

  if ([[SettingManager shareInstance] rejectBusyCode] == YES) {
    NEHangupParam *param = [[NEHangupParam alloc] init];
    [param setValue:[NSNumber numberWithInt:TerminalCodeBusy] forKey:@"reasonCode"];
    [[NECallEngine sharedInstance] hangup:param
                               completion:^(NSError *_Nullable error) {
                                 weakSelf.customCalledController.acceptBtn.userInteractionEnabled =
                                     YES;
                                 if (error != nil && error.code == CurrentStatusNotSupport) {
                                   [weakSelf destroy];
                                 }
                               }];
  } else {
    NEHangupParam *param = [[NEHangupParam alloc] init];
    [[NECallEngine sharedInstance] hangup:param
                               completion:^(NSError *_Nullable error) {
                                 weakSelf.customCalledController.acceptBtn.userInteractionEnabled =
                                     YES;
                                 if (error != nil && error.code == CurrentStatusNotSupport) {
                                   [weakSelf destroy];
                                 }
                               }];
  }
}

- (NECalledViewController *)customCalledController {
  return [self valueForKey:@"calledController"];
}

@end
