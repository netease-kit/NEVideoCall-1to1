//
//  NEUser.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEUser : NSObject<NSCoding>

/// 用户系统手机号
@property(strong,nonatomic)NSString *mobile;
/// 用户头像
@property(strong,nonatomic)NSString *avatar;
/// 云信IM 账号ID
@property(strong,nonatomic,nonnull)NSString *imAccid;
/// 云信IM token
@property(strong,nonatomic,nonnull)NSString *imToken;
/// 用户系统登录token
@property(strong,nonatomic)NSString *accessToken;
/// 音视频房间ID
@property(assign,nonatomic)NSString *avRoomUid;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
