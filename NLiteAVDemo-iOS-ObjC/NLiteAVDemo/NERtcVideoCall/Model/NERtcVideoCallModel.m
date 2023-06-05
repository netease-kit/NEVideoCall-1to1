// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NERtcVideoCallModel.h"

@implementation NERtcVideoCallModel
- (instancetype)initWithLocalUser:(NEUser *)localUser
                       remoteUser:(NEUser *)remoteUser
                        requestId:(NSString *)requestId {
  return [self initWithLocalUser:localUser remoteUser:remoteUser requestId:requestId channelId:nil];
}
- (instancetype)initWithLocalUser:(NEUser *)localUser
                       remoteUser:(NEUser *)remoteUser
                        requestId:(NSString *)requestId
                        channelId:(NSString *__nullable)channelId {
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
