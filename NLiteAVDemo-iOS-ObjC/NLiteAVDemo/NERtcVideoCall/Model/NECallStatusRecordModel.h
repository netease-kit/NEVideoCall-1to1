//
//  NECallStatusRecordModel.h
//  NLiteAVDemo
//
//  Created by chenyu on 2021/10/14.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NECallStatusRecordModel : NSObject <NSCoding>

/// 通话状态
@property (nonatomic, assign) NSInteger status;
/// 通话时长(如果接通则有，未接通字段为空)
@property (nonatomic, assign) NSInteger duration;
/// 接通时间(如果接通则有，未接通字段为空)
@property (nonatomic, strong) NSDate *startTime;
/// BOOL，YES 表主叫， NO表被叫
@property (nonatomic, assign) BOOL isCaller;
/// BOOL，YES 表视频通话，NO表示音频通话
@property (nonatomic, assign) BOOL isVideoCall;
/// 对端用户ID
@property (nonatomic, strong) NSString *imAccid;
/// 对端手机号
@property (nonatomic, strong) NSString *mobile;
/// 用户头像
@property (nonatomic, strong) NSString *avatar;

@end

NS_ASSUME_NONNULL_END
