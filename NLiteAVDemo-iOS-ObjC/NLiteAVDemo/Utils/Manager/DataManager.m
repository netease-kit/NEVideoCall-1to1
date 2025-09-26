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

  [NIMSDK.sharedSDK.v2UserService getUserList:accids
      success:^(NSArray<V2NIMUser *> *_Nonnull result) {
        NSMutableArray *usersArray = [[NSMutableArray alloc] init];
        for (V2NIMUser *user in result) {
          NEUser *neUser = [[NEUser alloc] init];
          neUser.imAccid = user.accountId;
          neUser.mobile = user.mobile;
          neUser.avatar = user.avatar;
          GroupCallMember *member = [dict objectForKey:neUser.imAccid];
          neUser.uid = member.rtcUid;
          neUser.state = member.state;
          neUser.isOpenVideo = member.isOpenVideo;
          [usersArray addObject:neUser];
        }
        completion(nil, usersArray);
      }
      failure:^(V2NIMError *_Nonnull error) {
        NSMutableArray *usersArray = [[NSMutableArray alloc] init];
        completion(error.nserror, usersArray);
      }];
}


@end
