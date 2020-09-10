//
//  NERtcVideoCallModel.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface NERtcVideoCallModel : NSObject
@property(strong,nonatomic,nonnull)NEUser *localUser;
@property(strong,nonatomic,nonnull)NEUser *remoteUser;
@property(strong,nonatomic,nonnull)NSString *requestID;
@property(strong,nonatomic,nullable)NSString *channelID;
@property(assign,nonatomic)uint64_t rtcChannelID;
- (instancetype)initWithLocalUser:(NEUser *)localUser remoteUser:(NEUser *)remoteUser requestId:(NSString *)requestId;
- (instancetype)initWithLocalUser:(NEUser *)localUser remoteUser:(NEUser *)remoteUser requestId:(NSString *)requestId channelId:(NSString * __nullable)channelId;
@end

NS_ASSUME_NONNULL_END
