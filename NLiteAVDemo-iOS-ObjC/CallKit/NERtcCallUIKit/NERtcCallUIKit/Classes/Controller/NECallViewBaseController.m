//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallViewBaseController.h"
#import <NECommonUIKit/UIView+YXToast.h>

@interface NECallViewBaseController ()

@end

@implementation NECallViewBaseController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)showToastWithContent:(NSString *)content {
  if (self.callParam.enableShowRecorderToast == NO) {
    return;
  }
  if (content.length <= 0) {
    return;
  }
  [UIApplication.sharedApplication.keyWindow ne_makeToast:content];
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

- (BOOL)isSupportAutoJoinWhenCalled {
  return [[[NECallEngine sharedInstance] valueForKeyPath:@"context.supportAutoJoinWhenCalled"]
      boolValue];
}

@end
