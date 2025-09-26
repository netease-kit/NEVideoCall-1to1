// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEDataManager.h"
#import <NERtcCallKit/NERtcCallKit.h>
#import "NEGroupUser.h"

@implementation NEDataManager

+ (id)shareInstance {
  static NEDataManager *shareInstance = nil;
  static dispatch_once_t once_token;
  dispatch_once(&once_token, ^{
    if (!shareInstance) {
      shareInstance = [[self alloc] init];
    }
  });
  return shareInstance;
}

- (void)fetchUserWithMembers:(NSArray<GroupCallMember *> *)members
                  completion:
                      (void (^)(NSError *_Nullable, NSArray<NEGroupUser *> *_Nonnull))completion {
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
          NEGroupUser *groupUser = [[NEGroupUser alloc] init];
          groupUser.imAccid = user.accountId;
          groupUser.mobile = user.mobile;
          groupUser.avatar = user.avatar;
          groupUser.nickname = user.name;
          GroupCallMember *member = [dict objectForKey:groupUser.imAccid];
          if (member) {
            groupUser.uid = member.rtcUid;
            groupUser.state = member.state;
            groupUser.isOpenVideo = member.isOpenVideo;
          }
          [usersArray addObject:groupUser];
        }
        completion(nil, usersArray);
      }
      failure:^(V2NIMError *_Nonnull error) {
        NSMutableArray *usersArray = [[NSMutableArray alloc] init];
        completion(error.nserror, usersArray);
      }];
}

@end
