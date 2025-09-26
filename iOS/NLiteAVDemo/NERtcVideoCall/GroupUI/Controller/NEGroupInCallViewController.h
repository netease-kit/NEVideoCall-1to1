// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEGroupInCallViewController : UIViewController

- (void)changeUsers:(NSArray<NSArray<NEUser *> *> *)users;

@end

NS_ASSUME_NONNULL_END
