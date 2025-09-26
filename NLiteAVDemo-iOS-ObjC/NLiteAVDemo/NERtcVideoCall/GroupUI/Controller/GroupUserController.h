// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEUser.h"
NS_ASSUME_NONNULL_BEGIN

@protocol GroupUserDelegagte <NSObject>

@optional
- (void)didRemoveWithUser:(NEUser *)user;

@end

@interface GroupUserController : UIViewController

@property(nonatomic, weak) UITableView *weakTable;

@property(nonatomic, weak) id<GroupUserDelegagte> delegate;

@property(nonatomic, assign) BOOL hideHeaderSection;

@property(nonatomic, assign) BOOL disableCancelUser;

- (void)addUsers:(NSArray<NEUser *> *)users;

- (void)removeUsers:(NSArray<NEUser *> *)users;

- (void)removeAllUsers;

- (NSMutableArray<NEUser *> *)getAllUsers;

- (NSInteger)getCurrentCount;

@end

NS_ASSUME_NONNULL_END
