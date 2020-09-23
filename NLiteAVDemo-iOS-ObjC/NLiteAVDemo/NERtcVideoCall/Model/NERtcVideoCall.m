//
//  NERtcVideoCall.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/18.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NERtcVideoCall.h"

@interface NERtcVideoCall()
@property(strong,nonatomic)NERtcVideoCallModel *currentModel;
@property(copy,nonatomic)NSMutableArray *delegateList;
@property(strong,nonatomic)NEUser *localUser;
@end

static NSString *busyCode = @"601";
static NSInteger maxTimeOut = 2 * 60;
@implementation NERtcVideoCall

static NERtcVideoCall *instance;
+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        instance.timeOutSeconds = maxTimeOut;
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NERtcVideoCall shared];
}

- (id)copy {
    return [NERtcVideoCall shared];
}

- (id)mutableCopy {
    return [NERtcVideoCall shared];
}

#pragma mark - 初始化
- (void)setupAppKey:(NSString *)appKey {
    [self setupAppKey:appKey APNSCerName:nil VoIPCerName:nil];
}
- (void)setupAppKey:(NSString *)appKey APNSCerName:(NSString * __nullable)APNSCerName VoIPCerName:(NSString * __nullable)VoIPCerName {
    // IM
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername = APNSCerName;
    option.pkCername = VoIPCerName;
    [[NIMSDK sharedSDK] registerWithOption:option];
    [[[NIMSDK sharedSDK] signalManager] addDelegate:self];
    
    // Rtc
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = appKey;
    [coreEngine setupEngineWithContext:context];
    NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
    config.maxProfile = kNERtcVideoProfileHD720P;
    [coreEngine setLocalVideoConfig:config];
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
}
- (void)updateApnsToken:(NSData *)deviceToken {
    [[NIMSDK sharedSDK] updateApnsToken:deviceToken];
}
- (void)destroy {
    [[[NIMSDK sharedSDK] signalManager] removeDelegate:self];
}
#pragma mark - 登录
- (void)login:(NEUser *)user success:(void(^)(void))success failed:(void(^)(NSError *error))failed {
    self.localUser = user;
    [self login:user.imAccid token:user.imToken success:success failed:failed];
}
- (void)login:(NSString *)account token:(NSString *)token success:(void(^)(void))success failed:(void(^)(NSError *error))failed {
    if (!self.localUser) {
        NEUser *user = [[NEUser alloc] init];
        self.localUser = [[NEUser alloc] init];
        self.localUser.imAccid = account;
        self.localUser = user;
    }
    if ([NIMSDK sharedSDK].loginManager.isLogined) {
        success();
    }else {
        [[[NIMSDK sharedSDK] loginManager] login:account token:token completion:^(NSError * _Nullable error) {
            if (error) {
                failed(error);
            }else {
                success();
            }
        }];
    }
}
- (void)logout {
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError * _Nullable error) {
    }];
}

- (void)call:(NEUser *)user completion:(void(^)(NSError * __nullable error))completion {
    NERtcVideoCallModel *model = [[NERtcVideoCallModel alloc] initWithLocalUser:self.localUser remoteUser:user requestId:[self generateRequestID]];
    self.callStatus = NECallStatusCall;
    self.currentModel = model;
    
    NIMSignalingCallRequest *request = [[NIMSignalingCallRequest alloc] init];
    request.uid = [self.currentModel.localUser.imAccid longLongValue];
    request.requestId = self.currentModel.requestID;
    request.accountId = user.imAccid;
    request.customInfo = [NSString stringWithFormat:@"%@,%@",self.currentModel.localUser.mobile,self.currentModel.localUser.avatar];
    request.channelType = NIMSignalingChannelTypeVideo;
    request.offlineEnabled = YES;
    
    NIMSignalingPushInfo *info = [[NIMSignalingPushInfo alloc] init];
    info.needPush = YES;
    info.pushTitle = @"网易云信";
    info.pushContent = [NSString stringWithFormat:@"%@邀请你视频通话",self.currentModel.localUser.mobile];
    NSDictionary *muteDic = [NSMutableDictionary dictionary];
    if (self.currentModel.localUser.imAccid) {
        [muteDic setValue:self.currentModel.localUser.imAccid forKey:@"imAccid"];
    }
    if (self.currentModel.localUser.avatar) {
        [muteDic setValue:self.currentModel.localUser.avatar forKey:@"avatar"];
    }
    if (self.currentModel.localUser.mobile) {
        [muteDic setValue:self.currentModel.localUser.mobile forKey:@"mobile"];
    }
    info.pushPayload = [muteDic copy];
    request.push = info;
    
    [[[NIMSDK sharedSDK] signalManager] signalingCall:request completion:^(NSError * _Nullable error, NIMSignalingChannelDetailedInfo * _Nullable response) {
        self.currentModel.channelID = response.channelId;
        __block NSError *imError = error;
        [[NERtcEngine sharedEngine] joinChannelWithToken:token channelName:self.currentModel.channelID myUid:[self.currentModel.localUser.imAccid longLongValue] completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
            NSError *finalError = imError ? imError : error;
            if (finalError) {
                self.callStatus = NECallStatusNone;
            }
            self.currentModel.rtcChannelID = channelId;
            [self waitTimeout];
            if (completion) {
                completion(finalError);
            }
        }];
    }];
}
- (void)cancel:(void(^)(NSError * __nullable error))completion {
    [self cancelTimeout];
    NIMSignalingCancelInviteRequest *request = [[NIMSignalingCancelInviteRequest alloc] init];
    request.channelId = self.currentModel.channelID;
    request.accountId = self.currentModel.remoteUser.imAccid;
    request.requestId = self.currentModel.requestID;
    [[[NIMSDK sharedSDK] signalManager] signalingCancelInvite:request completion:^(NSError * _Nullable error) {
        if (completion) {
            completion(error);
        }
        if (!error) {
            self.callStatus = NECallStatusNone;
            [[NERtcEngine sharedEngine] leaveChannel];
            NIMSignalingCloseChannelRequest *closeRequest = [[NIMSignalingCloseChannelRequest alloc] init];
            closeRequest.channelId = self.currentModel.channelID;
            [[[NIMSDK sharedSDK] signalManager] signalingCloseChannel:closeRequest completion:^(NSError * _Nullable error) {
            }];
        }
    }];
}
/*
 1.IM接受
 2.Rtc加入频道
*/
- (void)accept:(void(^)(NSError * __nullable error))completion {
    NIMSignalingAcceptRequest *request = [[NIMSignalingAcceptRequest alloc] init];
    request.channelId = self.currentModel.channelID;
    request.accountId = self.currentModel.remoteUser.imAccid;
    request.requestId = self.currentModel.requestID;
    [[[NIMSDK sharedSDK] signalManager] signalingAccept:request completion:^(NSError * _Nullable error, NIMSignalingChannelDetailedInfo * _Nullable response) {
        if (error) {
            self.callStatus = NECallStatusNone;
            if (completion) {
                completion(error);
            }
        }else {
            //RTC 加入频道
            [[NERtcEngine sharedEngine] joinChannelWithToken:token channelName:self.currentModel.channelID myUid:[self.currentModel.localUser.imAccid longLongValue] completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
                if (error) {
                    self.callStatus = NECallStatusNone;
                }else {
                    self.callStatus = NECallStatusCalling;
                }
                if (completion) {
                    completion(error);
                }
            }];
        }
    }];
}
- (void)reject:(void(^)(NSError * __nullable error))completion {
    self.callStatus = NECallStatusNone;
    NIMSignalingRejectRequest *rejectRequest = [[NIMSignalingRejectRequest alloc] init];
    rejectRequest.channelId = self.currentModel.channelID;
    rejectRequest.accountId = self.currentModel.remoteUser.imAccid;
    rejectRequest.requestId = self.currentModel.requestID;
    [[[NIMSDK sharedSDK] signalManager] signalingReject:rejectRequest completion:^(NSError * _Nullable error) {
        [[NERtcEngine sharedEngine] leaveChannel];
        if (completion) {
            completion(error);
        }
    }];
}
- (void)hangup {
    //RTC 离开频道
    self.callStatus = NECallStatusNone;
    NIMSignalingLeaveChannelRequest *request = [[NIMSignalingLeaveChannelRequest alloc] init];
    request.channelId = self.currentModel.channelID;
    [[[NIMSDK sharedSDK] signalManager] signalingLeaveChannel:request completion:^(NSError * _Nullable error) {
    }];
    NIMSignalingCloseChannelRequest *closeRequest = [[NIMSignalingCloseChannelRequest alloc] init];
    closeRequest.channelId = self.currentModel.channelID;
    [[[NIMSDK sharedSDK] signalManager] signalingCloseChannel:closeRequest completion:^(NSError * _Nullable error) {
    }];
    [[NERtcEngine sharedEngine] leaveChannel];
}

- (void)setupLocalView:(UIView *)localView {
    NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
    canvas.renderMode = kNERtcVideoRenderScaleCropFill;
    canvas.container = localView;
    [NERtcEngine.sharedEngine setupLocalVideoCanvas:canvas];
}

- (void)setupRemoteView:(UIView *)remoteView userID:(uint64_t)userID {
    NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
    canvas.renderMode = kNERtcVideoRenderScaleCropFill;
    canvas.container = remoteView;
    [NERtcEngine.sharedEngine setupRemoteVideoCanvas:canvas forUserID:userID];
}

- (void)enableCamera:(BOOL)enable {
    [[NERtcEngine sharedEngine] enableLocalVideo:enable];
}

- (void)switchCamera {
    [[NERtcEngine sharedEngine] switchCamera];
}

- (void)setMicMute:(BOOL)mute {
    [[NERtcEngine sharedEngine] muteLocalAudio:mute];
}

- (void)addDelegate:(id<NERtcVideoCallDelegate>)delegate {
    if ([self.delegateList containsObject:delegate]) {
        return;
    }
    [self.delegateList addObject:delegate];
}
- (void)removeDelegate:(id<NERtcVideoCallDelegate>)delegate {
    if ([self.delegateList containsObject:delegate]) {
        [self.delegateList removeObject:delegate];
    }
}
- (void)removeAllDelegte {
    [self.delegateList removeAllObjects];
}

#pragma mark - private method
- (void)_rejectInvite:(NIMSignalingInviteNotifyInfo *)info {
    NIMSignalingRejectRequest *rejectRequest = [[NIMSignalingRejectRequest alloc] init];
    rejectRequest.channelId = info.channelInfo.channelId;
    rejectRequest.accountId = info.fromAccountId;
    rejectRequest.requestId = info.requestId;
    rejectRequest.customInfo = busyCode;
    [[[NIMSDK sharedSDK] signalManager] signalingReject:rejectRequest completion:^(NSError * _Nullable error) {
    }];
}
- (void)_handleInviteInfo:(NIMSignalingInviteNotifyInfo *)info {
    if (self.callStatus != NECallStatusNone) {
        // 忙线中
        [self _rejectInvite:info];
        return;
    }
    self.callStatus = NECallStatusCalled;
    NEUser *remoteUser = [[NEUser alloc] init];
    remoteUser.imAccid = info.fromAccountId;
    NSArray *components = [info.customInfo componentsSeparatedByString:@","];
    if (components.count) {
        remoteUser.mobile = components.firstObject;
    }
    if (components.count > 1) {
        remoteUser.avatar = [components objectAtIndex:1];
    }
    NERtcVideoCallModel *model = [[NERtcVideoCallModel alloc] initWithLocalUser:self.localUser remoteUser:remoteUser requestId:info.requestId channelId:info.channelInfo.channelId];
    self.currentModel = model;
    for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
        if ([delegate respondsToSelector:@selector(onInvitedByUser:)]) {
            [delegate onInvitedByUser:remoteUser];
        }
    }
}

#pragma mark - NERtcVideoCallDelegate
/// 在线通知
- (void)nimSignalingOnlineNotifyEventType:(NIMSignalingEventType)eventType
                                 response:(NIMSignalingNotifyInfo *)notifyResponse {
    switch (eventType) {
        case NIMSignalingEventTypeClose:{
            self.callStatus = NECallStatusNone;
        }
            break;
        case NIMSignalingEventTypeJoin:
        {
            self.callStatus = NECallStatusCalling;
        }
            break;
        case NIMSignalingEventTypeInvite:
        {
            NIMSignalingInviteNotifyInfo *info = (NIMSignalingInviteNotifyInfo *)notifyResponse;
            [self _handleInviteInfo:info];
        }
            break;
        case NIMSignalingEventTypeCancelInvite:
        {
            self.callStatus = NECallStatusNone;
            NIMSignalingCancelInviteNotifyInfo *info = (NIMSignalingCancelInviteNotifyInfo *)notifyResponse;
            for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
                if ([delegate respondsToSelector:@selector(onCancelByUserId:)]) {
                    [delegate onCancelByUserId:info.fromAccountId];
                }
            }
        }
            break;
        case NIMSignalingEventTypeReject:
        {
            self.callStatus = NECallStatusNone;
            NIMSignalingRejectNotifyInfo *info = (NIMSignalingRejectNotifyInfo *)notifyResponse;
            NIMSignalingCloseChannelRequest *request = [[NIMSignalingCloseChannelRequest alloc] init];
            request.channelId = info.channelInfo.channelId;
            [[NIMSDK sharedSDK].signalManager signalingCloseChannel:request completion:^(NSError * _Nullable error) {
            }];
            [[NERtcEngine sharedEngine] leaveChannel];
            if ([info.customInfo isEqualToString:busyCode]) {
                for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
                    if ([delegate respondsToSelector:@selector(onUserBusy:)]) {
                        [delegate onUserBusy:info.fromAccountId];
                    }
                }
            }else {
                for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
                    if ([delegate respondsToSelector:@selector(onRejectByUserId:)]) {
                        [delegate onRejectByUserId:info.fromAccountId];
                    }
                }
            }
        }
            break;
        case NIMSignalingEventTypeAccept:
        {
            self.callStatus = NECallStatusCalling;
        }
        default:
            break;
    }
}

/// 离线通知
- (void)nimSignalingOfflineNotify:(NSArray <NIMSignalingNotifyInfo *> *)notifyResponse {
    NIMSignalingInviteNotifyInfo *inviteInfo = nil;
    for (NIMSignalingNotifyInfo *info in notifyResponse) {
        if (info.eventType == NIMSignalingEventTypeInvite) {
            inviteInfo = (NIMSignalingInviteNotifyInfo *)info;
        }
    }
    NIMSignalingQueryChannelRequest *request = [[NIMSignalingQueryChannelRequest alloc] init];
    request.channelId = inviteInfo.channelInfo.channelId;
    request.channelName = inviteInfo.channelInfo.channelName;
    [[[NIMSDK sharedSDK] signalManager] signalingQueryChannelInfo:request completion:^(NSError * _Nullable error, NIMSignalingChannelDetailedInfo * _Nullable response) {
        if (!error) {
            [self _handleInviteInfo:inviteInfo];
        }
    }];
}

#pragma mark - NERtcEngineDelegateEx
//  其他用户加入频道
- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName {
    self.callStatus = NECallStatusCalling;
    NEUser *user = [[NEUser alloc] init];
    user.imAccid = [NSString stringWithFormat:@"%llu",userID];
    for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
        if ([delegate respondsToSelector:@selector(onUserEnter:)]) {
            [delegate onUserEnter:user];
        }
    }
}
// 对方打开摄像头
- (void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID videoProfile:(NERtcVideoProfileType)profile {
    [NERtcEngine.sharedEngine subscribeRemoteVideo:YES forUserID:userID streamType:kNERtcRemoteVideoStreamTypeHigh];
    for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
        if ([delegate respondsToSelector:@selector(onCameraAvailable:userId:)]) {
            [delegate onCameraAvailable:YES userId:[NSString stringWithFormat:@"%llu",userID]];
        }
    }
}
// 对方关闭了摄像头
- (void)onNERtcEngineUserVideoDidStop:(uint64_t)userID {
    for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
        if ([delegate respondsToSelector:@selector(onCameraAvailable:userId:)]) {
            [delegate onCameraAvailable:NO userId:[NSString stringWithFormat:@"%llu",userID]];
        }
    }
}
// 对方打开音频
- (void)onNERtcEngineUserAudioDidStart:(uint64_t)userID {
    for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
        if ([delegate respondsToSelector:@selector(onAudioAvailable:userId:)]) {
            [delegate onAudioAvailable:YES userId:[NSString stringWithFormat:@"%llu",userID]];
        }
    }
}
// 对方关闭音频
- (void)onNERtcEngineUserAudioDidStop:(uint64_t)userID {
    for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
        if ([delegate respondsToSelector:@selector(onAudioAvailable:userId:)]) {
            [delegate onAudioAvailable:NO userId:[NSString stringWithFormat:@"%llu",userID]];
        }
    }
}

// 对方离开视频
- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason {
    self.callStatus = NECallStatusNone;
    [[NERtcEngine sharedEngine] leaveChannel];
    for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
        if ([delegate respondsToSelector:@selector(onUserHangup:)]) {
            [delegate onUserHangup:[NSString stringWithFormat:@"%llu",userID]];
        }
    }
}

#pragma mark - timer
- (void)waitTimeout {
    [self performSelector:@selector(timeout) withObject:nil afterDelay:self.timeOutSeconds];
}
- (void)timeout {
    if (self.callStatus == NECallStatusCall) {
        //超时操作
        for (id<NERtcVideoCallDelegate>delegate in self.delegateList) {
            if ([delegate respondsToSelector:@selector(timeOut)]) {
                [delegate timeOut];
            }
        }
    }
}
- (void)cancelTimeout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
#pragma mark - requestID
- (NSString *)generateRequestID {
    NSInteger random = arc4random() % 1000;
    NSString *requestID = [NSString stringWithFormat:@"%.f%zd",[NSDate timeIntervalSinceReferenceDate],random];
    return requestID;
}

#pragma mark - get
- (NSMutableArray *)delegateList {
    if (!_delegateList) {
        _delegateList = [NSMutableArray array];
    }
    return _delegateList;
}
#pragma mark - set
- (void)setTimeOutSeconds:(NSInteger)timeOutSeconds {
    _timeOutSeconds = timeOutSeconds > maxTimeOut ? maxTimeOut : timeOutSeconds;
}
@end
