// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "DataManager.h"

@implementation DataManager

+ (id)shareInstance {
  static DataManager *shareInstance = nil;
  static dispatch_once_t once_token;
  dispatch_once(&once_token, ^{
    if (!shareInstance) {
      shareInstance = [[self alloc] init];
    }
  });
  return shareInstance;
}

- (void)fetchUserWithMembers:(NSArray<GroupCallMember *> *)members
                  completion:(void (^)(NSError *_Nullable, NSArray<NEUser *> *_Nonnull))completion {
  NSMutableArray *accids = [[NSMutableArray alloc] init];
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  for (GroupCallMember *member in members) {
    [accids addObject:member.imAccid];
    [dict setObject:member forKey:member.imAccid];
  }
  [NIMSDK.sharedSDK.userManager
      fetchUserInfos:accids
          completion:^(NSArray<NIMUser *> *_Nullable users, NSError *_Nullable error) {
            NSMutableArray *usersArray = [[NSMutableArray alloc] init];
            for (NIMUser *user in users) {
              NEUser *neUser = [[NEUser alloc] init];
              neUser.imAccid = user.userId;
              neUser.mobile = user.userInfo.mobile;
              neUser.avatar = user.userInfo.avatarUrl;
              GroupCallMember *member = [dict objectForKey:neUser.imAccid];
              neUser.uid = member.rtcUid;
              neUser.state = member.state;
              neUser.isOpenVideo = member.isOpenVideo;
              [usersArray addObject:neUser];
            }
            completion(error, usersArray);
          }];
}

@end
