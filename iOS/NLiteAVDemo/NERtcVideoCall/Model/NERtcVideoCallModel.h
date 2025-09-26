// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NEUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface NERtcVideoCallModel : NSObject
@property(strong, nonatomic, nonnull) NEUser *localUser;
@property(strong, nonatomic, nonnull) NEUser *remoteUser;
@property(strong, nonatomic, nonnull) NSString *requestID;
@property(strong, nonatomic, nullable) NSString *channelID;
@property(assign, nonatomic) uint64_t rtcChannelID;
- (instancetype)initWithLocalUser:(NEUser *)localUser
                       remoteUser:(NEUser *)remoteUser
                        requestId:(NSString *)requestId;
- (instancetype)initWithLocalUser:(NEUser *)localUser
                       remoteUser:(NEUser *)remoteUser
                        requestId:(NSString *)requestId
                        channelId:(NSString *__nullable)channelId;
@end

NS_ASSUME_NONNULL_END
