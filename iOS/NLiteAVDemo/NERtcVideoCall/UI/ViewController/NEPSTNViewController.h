// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NECallStatusRecordModel.h"
#import "NEUser.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NECallViewDelegate <NSObject>

/// 只在主叫方会有回调，被叫方请监听 IM 话单 NIMessage 的回调
- (void)didEndCallWithStatusModel:(NECallStatusRecordModel *)model;

@end

@interface NEPSTNViewController : UIViewController <NERtcCallKitDelegate>
@property(assign, nonatomic) NERtcCallStatus status;
@property(strong, nonatomic) NEUser *remoteUser;
@property(strong, nonatomic) NEUser *localUser;
@property(assign, nonatomic) NERtcCallType callType;
@property(assign, nonatomic) CallKitType callKitType;

@property(nonatomic, weak) id<NECallViewDelegate> delegate;

// 主叫
@property(nonatomic, assign) BOOL isCaller;

@end

NS_ASSUME_NONNULL_END
