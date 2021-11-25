//
//  NECallStatusRecordModel.m
//  NLiteAVDemo
//
//  Created by chenyu on 2021/10/14.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NECallStatusRecordModel.h"

@implementation NECallStatusRecordModel

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.status forKey:@"status"];
    [coder encodeInteger:self.duration forKey:@"duration"];
    [coder encodeObject:self.startTime forKey:@"startTime"];
    [coder encodeBool:self.isCaller forKey:@"isCaller"];
    [coder encodeBool:self.isVideoCall forKey:@"isVideoCall"];
    [coder encodeObject:self.imAccid forKey:@"imAccid"];
    [coder encodeObject:self.mobile forKey:@"mobile"];
    [coder encodeObject:self.avatar forKey:@"avatar"];
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super init];
    if (self) {
        self.status = [coder decodeIntegerForKey:@"status"];
        self.duration = [coder decodeIntegerForKey:@"duration"];
        self.startTime = [coder decodeObjectForKey:@"startTime"];
        self.isCaller = [coder decodeBoolForKey:@"isCaller"];
        self.isVideoCall = [coder decodeBoolForKey:@"isVideoCall"];
        self.imAccid = [coder decodeObjectForKey:@"imAccid"];
        self.mobile = [coder decodeObjectForKey:@"mobile"];
        self.avatar = [coder decodeObjectForKey:@"avatar"];
    }
    return self;
}

@end
