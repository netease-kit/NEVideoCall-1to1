// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NEGroupUser;
@class GroupCallMember;

@interface NEDataManager : NSObject

+ (id)shareInstance;

- (void)fetchUserWithMembers:(NSArray<GroupCallMember *> *)members
                  completion:
                      (void (^)(NSError *_Nullable, NSArray<NEGroupUser *> *_Nonnull))completion;

@end

NS_ASSUME_NONNULL_END
