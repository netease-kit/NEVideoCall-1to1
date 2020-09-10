//
//  NERtcVideoCallModel.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NERtcVideoCallModel.h"

@implementation NERtcVideoCallModel
- (instancetype)initWithLocalUser:(NEUser *)localUser remoteUser:(NEUser *)remoteUser requestId:(NSString *)requestId {
    return [self initWithLocalUser:localUser remoteUser:remoteUser requestId:requestId channelId:nil];
}
- (instancetype)initWithLocalUser:(NEUser *)localUser remoteUser:(NEUser *)remoteUser requestId:(NSString *)requestId channelId:(NSString * __nullable)channelId
{
    self = [super init];
    if (self) {
        self.localUser = localUser;
        self.remoteUser = remoteUser;
        self.requestID = requestId;
        self.channelID = channelId;
    }
    return self;
}

@end
