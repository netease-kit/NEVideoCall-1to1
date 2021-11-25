//
//  NECallViewController.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEUser.h"
#import "NECallStatusRecordModel.h"
#import <NERtcCallKit/NERtcCallKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NECallViewDelegate <NSObject>

/// 只在主叫方会有回调，被叫方请监听 IM 话单 NIMessage 的回调
- (void)didEndCallWithStatusModel:(NECallStatusRecordModel *)model;

@end

@interface NECallViewController : UIViewController<NERtcCallKitDelegate>
@property(assign,nonatomic)NERtcCallStatus status;
@property(strong,nonatomic)NEUser *remoteUser;
@property(strong,nonatomic)NEUser *localUser;
@property(assign,nonatomic)NERtcCallType callType;

@property(nonatomic, weak) id<NECallViewDelegate> delegate;

//主叫
@property(nonatomic, assign) BOOL isCaller;

@end

NS_ASSUME_NONNULL_END
