// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUser.h"
#import <objc/runtime.h>
#import "NSDictionary+NTESJson.h"

@implementation NEUser

- (instancetype)init {
  self = [super init];
  if (self) {
    self.state = GroupMemberStateWaitting;
  }
  return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic {
  if (!dic) {
    return nil;
  }
  if (self = [super init]) {
    _mobile = [dic jsonString:@"mobile"];
    _imAccid = [dic jsonString:@"imAccid"];
    _imToken = [dic jsonString:@"imToken"];
    _avRoomUid = [dic jsonString:@"avRoomUid"];
    _avatar = [dic jsonString:@"avatar"];
  }
  return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:self.mobile forKey:@"mobile"];
  [coder encodeObject:self.imAccid forKey:@"imAccid"];
  [coder encodeObject:self.imToken forKey:@"imToken"];
  [coder encodeObject:self.avRoomUid forKey:@"avRoomUid"];
  [coder encodeObject:self.avatar forKey:@"avatar"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)coder {
  if (self = [super init]) {
    self.mobile = [coder decodeObjectForKey:@"mobile"];
    self.imAccid = [coder decodeObjectForKey:@"imAccid"];
    self.imToken = [coder decodeObjectForKey:@"imToken"];
    self.avRoomUid = [coder decodeObjectForKey:@"avRoomUid"];
    self.avatar = [coder decodeObjectForKey:@"avatar"];
  }
  return self;
}

- (NEUser *)getCopy {
  NEUser *copy = [[NEUser alloc] init];
  copy.mobile = self.mobile;
  copy.avatar = self.avatar;
  copy.imAccid = self.imAccid;
  copy.imToken = self.imToken;
  copy.accessToken = self.accessToken;
  copy.avRoomUid = self.avRoomUid;
  copy.isCaller = self.isCaller;

  copy.state = self.state;
  copy.uid = self.uid;
  copy.isShowLocalVideo = self.isShowLocalVideo;
  copy.isOpenVideo = self.isOpenVideo;
  return copy;
}

- (id)copyWithZone:(NSZone *)zone {
  NEUser *copy = [[NEUser alloc] init];
  copy.mobile = self.mobile;
  copy.avatar = self.avatar;
  copy.imAccid = self.imAccid;
  copy.imToken = self.imToken;
  copy.accessToken = self.accessToken;
  copy.avRoomUid = self.avRoomUid;
  copy.isCaller = self.isCaller;

  copy.state = self.state;
  copy.uid = self.uid;
  copy.isShowLocalVideo = self.isShowLocalVideo;
  copy.isOpenVideo = self.isOpenVideo;

  //    unsigned int propertyCount = 0;
  //    objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
  //    for (int i = 0; i < propertyCount; i++ ) {
  //        objc_property_t thisProperty = propertyList[i];
  //        const char* propertyCName = property_getName(thisProperty);
  //        NSString *propertyName = [NSString stringWithCString:propertyCName
  //        encoding:NSUTF8StringEncoding]; id value = [self valueForKey:propertyName]; [copy
  //        setValue:value forKey:propertyName];
  //    }
  return copy;
}
@end
