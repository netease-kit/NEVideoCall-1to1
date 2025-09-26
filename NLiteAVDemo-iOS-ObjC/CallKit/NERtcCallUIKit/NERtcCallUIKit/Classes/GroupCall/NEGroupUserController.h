// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEGroupUser.h"
NS_ASSUME_NONNULL_BEGIN

@protocol NEGroupUserDelegagte <NSObject>

@optional
- (void)didRemoveWithUser:(NEGroupUser *)user;

@end

@interface NEGroupUserController : UIViewController

@property(nonatomic, weak) UITableView *weakTable;

@property(nonatomic, weak) id<NEGroupUserDelegagte> delegate;

@property(nonatomic, assign) BOOL hideHeaderSection;

@property(nonatomic, assign) BOOL disableCancelUser;

- (void)addUsers:(NSArray<NEGroupUser *> *)users;

- (void)removeUsers:(NSArray<NEGroupUser *> *)users;

- (void)removeAllUsers;

- (NSMutableArray<NEGroupUser *> *)getAllUsers;

- (NSInteger)getCurrentCount;

@end

NS_ASSUME_NONNULL_END
