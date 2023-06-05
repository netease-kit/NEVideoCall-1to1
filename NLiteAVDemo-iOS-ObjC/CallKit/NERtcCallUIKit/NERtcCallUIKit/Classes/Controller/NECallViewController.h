// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NERtcCallKit/NERtcCallKit.h>
#import <UIKit/UIKit.h>
#import "NERtcCallUIConfig.h"
#import "NEUICallParam.h"
#import "NEVideoView.h"
#import "NECustomButton.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kCallKitDismissNoti;

@interface NECallViewController : UIViewController <NERtcCallKitDelegate>

@property(nonatomic, assign) NERtcCallStatus status;

@property(nonatomic, assign) NERtcCallType callType;

@property(nonatomic, strong) NEUICallParam *callParam;

@property(nonatomic, strong) NSMutableDictionary<NSString *, Class> *uiConfigDic;

@property(nonatomic, strong) NECallUIConfig *config;

/// 呼叫前音视频转换按钮
@property(strong, nonatomic) NECustomButton *mediaSwitchBtn;

// 当前用户视频显示位置
@property(nonatomic, assign) BOOL showMyBigView;

// 远端是否关闭摄像头
@property(nonatomic, assign) BOOL remoteCameraAvailable;

// 远端是否mute
@property(nonatomic, assign) BOOL isRemoteMute;

// 主叫
@property(nonatomic, assign) BOOL isCaller;

- (void)changeDefaultImage:(BOOL)mute;

- (void)changeRemoteMute:(BOOL)mute videoView:(NEVideoView *)remoteVideo;

@end

NS_ASSUME_NONNULL_END
