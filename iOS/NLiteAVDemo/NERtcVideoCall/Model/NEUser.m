//
//  NEUser.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEUser.h"
#import "NSDictionary+NTESJson.h"

@implementation NEUser

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (!dic) { return nil; }
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

@end
