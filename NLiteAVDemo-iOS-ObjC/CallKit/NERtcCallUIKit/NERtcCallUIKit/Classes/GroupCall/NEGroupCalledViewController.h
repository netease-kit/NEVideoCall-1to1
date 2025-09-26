// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEGroupUser.h"
NS_ASSUME_NONNULL_BEGIN

@protocol NEGroupCalledDelegate <NSObject>

- (void)calledDidAccept;

- (void)calledDidReject;

@end

@interface NEGroupCalledViewController : UIViewController

@property(nonatomic, weak) id<NEGroupCalledDelegate> delegate;

- (instancetype)initWithCaller:(NEGroupUser *)caller;

- (void)changeUsers:(NSArray<NEGroupUser *> *)users;

@end

NS_ASSUME_NONNULL_END
