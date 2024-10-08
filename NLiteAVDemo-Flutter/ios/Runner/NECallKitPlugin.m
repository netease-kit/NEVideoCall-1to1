//
//  NECallKitPlugin.m
//  Runner
//
//  Created by chenyu on 2023/8/31.
//

#import "NECallKitPlugin.h"
#import <NIMSDK/NIMSDK.h>
#import <NERtcCallUIKit/NERtcCallUIKit.h>
#import <NECoreKit/YXModel.h>

static NSString *callMethodName = @"startCall";

static NSString *initMethodName = @"initCallKit";

static NSString *imLogin = @"imLogin";

static NSString *notifyLoginMethodName = @"notifyLogin";

static NSString *imLogoutMethodName = @"imLogout";

/// 组件是否可用，因为iOS在启动时候初始化，所以只要IM 登录即可用，这里主要判断IM是否登录成功
static NSString *callkitCanBeUsedMethodName = @"callKitCanBeUsed";

static NSString *accId = @"accId";

static NSString *accessToken = @"token";

static NSString *userInfoNameMap = @"userInfoNameMap";

static NSString *userInfoAvatarMap = @"userInfoAvatarMap";

static NSString *resultKey = @"result";

static NSString *notifyCallKitStateMethodName = @"notifyCallKitState";

FlutterMethodChannel *globalChannel;


@interface NECallKitPlugin ()<NECallUIKitDelegate, NERecordProvider, NIMLoginManagerDelegate>

@property(nonatomic, strong) FlutterMethodChannel *channel;

@end

@implementation NECallKitPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    
    NECallKitPlugin *instance = [[NECallKitPlugin alloc] init];
    FlutterMethodChannel* channel = [FlutterMethodChannel
             methodChannelWithName:@"com.example.call_kit_demo_flutter/channel/call"
                   binaryMessenger:[registrar messenger]];
    globalChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
    
    /// 设置UI代理回调
    NERtcCallUIKit.sharedInstance.delegate = instance;
    
    /// 设置自定义话单 provider
    [[NECallEngine sharedInstance] setCallRecordProvider:instance];
}

- (instancetype)init {
    self = [super init];
    if (self){
        [NIMSDK.sharedSDK.loginManager addDelegate:self];
    }
    return  self;
}

- (void)onLogin:(NIMLoginStep)step {
    if(step == NIMLoginStepLoginOK){
        [self sendState:YES];
    }
}

- (void)onAutoLoginFailed:(NSError *)error {
    
}

- (void)onKickout:(NIMLoginKickoutResult *)result {
    [self sendState:NO];
}

- (void)sendState:(BOOL)state {
    [globalChannel invokeMethod:notifyCallKitStateMethodName arguments:@{@"accId":NIMSDK.sharedSDK.loginManager.currentAccount, @"state":@(state)}];
}

- (void)onRecordSend:(NERecordConfig *)config {
    switch (config.callState) {
        case NIMRtcCallStatusTimeout:
            // 超时
            break;
        case NIMRtcCallStatusBusy:
            // 忙线
            break;
        case NIMRtcCallStatusCanceled:
            // 取消
            break;
        case NIMRtcCallStatusRejected:
            // 拒接
            break;
        default:
            break;
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
   if ([call.method isEqualToString:callMethodName]) {
       NSString *accid = [call.arguments objectForKey:accId];
       NEUICallParam *param = [[NEUICallParam alloc] init];
       param.callType = NECallTypeVideo;
       param.remoteUserAccid = accid;
       NSDictionary *callParamNameMap = [call.arguments objectForKey:userInfoNameMap];
       NSDictionary *callParamAvatarMap = [call.arguments objectForKey:userInfoAvatarMap];
       
       for(NSString *key in callParamNameMap.allKeys){
           if ([key isEqualToString:accid]){
               param.remoteAvatar = callParamAvatarMap[key] ;
               param.remoteShowName = callParamNameMap[key];
           }
       }
       param.attachment = [((NSDictionary*)call.arguments) yx_modelToJSONString];
       [[NERtcCallUIKit sharedInstance] callWithParam:param];
       result( @{resultKey: @{@"code":@(200), @"msg":@"call success"}});
       
   } else if([call.method isEqualToString:imLogin]) {
       NSString *accid = [call.arguments objectForKey:accId];
       NSString *token = [call.arguments objectForKey:accessToken];
       
       [NIMSDK.sharedSDK.loginManager login:accid token:token completion:^(NSError * _Nullable error) {
           NSLog(@"account login error : %@", error);
           
           if (error == nil) {
               result( @{resultKey: @{@"code":@(200), @"msg":@"login success"}});
           }else {
               result( @{resultKey: @{@"code":@(error.code), @"msg":error.localizedDescription}});
           }
           
       }];
   } else if ([call.method isEqualToString:imLogoutMethodName]){
       [NIMSDK.sharedSDK.loginManager logout:^(NSError * _Nullable error) {
           NSLog(@"log out error : %@", error);
           [self sendState:NO];
           if (error != nil){
               result( @{resultKey: @{@"code":@(error.code), @"msg":error.localizedDescription}});
           }else {
               result( @{resultKey: @{@"code":@(200), @"msg":@"logout success"}});
           }
       }];
   } else if ([call.method isEqualToString:callkitCanBeUsedMethodName]){
       result( @{resultKey: @{@"code":@(200), @"msg":@"查询成功", @"data":@(NIMSDK.sharedSDK.loginManager.isLogined)}});
   }
 }

- (void)didCallComingWithInviteInfo:(nonnull NEInviteInfo *)inviteInfo withCallParam:(nonnull NEUICallParam *)callParam withCompletion:(nonnull void (^)(BOOL))completion {
    NSLog(@"didCallComingWithInviteInfo");
    if ([inviteInfo.extraInfo length]>0){
        NSDictionary *arguments = [self dictionaryWithJsonString:inviteInfo.extraInfo];
        NSDictionary *callParamNameMap = [arguments objectForKey:userInfoNameMap];
        NSDictionary *callParamAvatarMap = [arguments objectForKey:userInfoAvatarMap];
        for(NSString *key in callParamNameMap.allKeys){
            if ([key isEqualToString:inviteInfo.callerAccId]){
                callParam.remoteAvatar = callParamNameMap[key];
                callParam.remoteShowName = callParamAvatarMap[key];
            }
        }
    }
  
    completion(YES);
}

- (NSDictionary *)dictionaryWithJsonString: jsonString {

    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;

    }

    return dic;

}

@end
